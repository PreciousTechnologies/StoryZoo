import logging
from decimal import Decimal

import requests
from django.conf import settings

logger = logging.getLogger(__name__)

_cached_ipn_id = None


def _base_url() -> str:
    return settings.PESAPAL_BASE_URL.rstrip('/')


def _timeout() -> int:
    return int(getattr(settings, 'PESAPAL_TIMEOUT_SECONDS', 30))


def _auth_headers(token: str) -> dict:
    return {
        'Authorization': f'Bearer {token}',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
    }


def get_access_token() -> str:
    consumer_key = settings.PESAPAL_CONSUMER_KEY
    consumer_secret = settings.PESAPAL_CONSUMER_SECRET

    if not consumer_key or not consumer_secret:
        raise RuntimeError('Pesapal consumer key/secret are not configured.')

    url = f"{_base_url()}/api/Auth/RequestToken"
    payload = {
        'consumer_key': consumer_key,
        'consumer_secret': consumer_secret,
    }

    try:
        response = requests.post(url, json=payload, timeout=_timeout())
    except requests.RequestException as exc:
        logger.error('Pesapal token request connection failure: %s', exc)
        raise RuntimeError('Unable to connect to Pesapal authentication endpoint.')
    if response.status_code != 200:
        logger.error('Pesapal token request failed: %s', response.text)
        raise RuntimeError(f'Unable to authenticate with Pesapal ({response.status_code}).')

    try:
        data = response.json()
    except ValueError:
        logger.error('Pesapal token response is not JSON: %s', response.text)
        raise RuntimeError('Pesapal token response was not valid JSON.')

    error_obj = data.get('error') if isinstance(data, dict) else None
    if isinstance(error_obj, dict):
        code = (error_obj.get('code') or '').strip() or 'api_error'
        message = (error_obj.get('message') or '').strip()
        if message:
            raise RuntimeError(f'Pesapal authentication failed ({code}): {message}')
        raise RuntimeError(f'Pesapal authentication failed ({code}). Check consumer key/secret and API environment.')

    token = (
        data.get('token')
        or data.get('access_token')
        or data.get('Token')
        or data.get('AccessToken')
    )
    if not token:
        raise RuntimeError('Pesapal token response was invalid (missing token).')

    return token


def register_ipn_url(access_token: str) -> str:
    global _cached_ipn_id

    configured_ipn_id = (getattr(settings, 'PESAPAL_IPN_ID', '') or '').strip()
    if configured_ipn_id:
        _cached_ipn_id = configured_ipn_id
        return configured_ipn_id

    if _cached_ipn_id:
        return _cached_ipn_id

    ipn_url = settings.PESAPAL_IPN_URL
    ipn_type = settings.PESAPAL_IPN_TYPE
    if not ipn_url:
        raise RuntimeError('PESAPAL_IPN_URL is not configured.')

    url = f"{_base_url()}/api/URLSetup/RegisterIPN"
    payload = {
        'url': ipn_url,
        'ipn_notification_type': ipn_type,
    }

    try:
        response = requests.post(url, json=payload, headers=_auth_headers(access_token), timeout=_timeout())
    except requests.RequestException as exc:
        logger.error('Pesapal IPN registration connection failure: %s', exc)
        raise RuntimeError('Unable to connect to Pesapal IPN registration endpoint.')
    if response.status_code not in {200, 201}:
        logger.error('Pesapal IPN registration failed: %s', response.text)
        raise RuntimeError(f'Unable to register Pesapal IPN URL ({response.status_code}): {response.text}')

    data = response.json()
    ipn_id = data.get('ipn_id') or data.get('id') or data.get('notification_id')
    if not ipn_id:
        raise RuntimeError('Pesapal IPN response was invalid.')

    _cached_ipn_id = ipn_id
    return ipn_id


def submit_order_request(
    access_token: str,
    amount: Decimal,
    currency: str,
    description: str,
    merchant_reference: str,
    email: str,
    callback_url: str,
    ipn_id: str,
) -> dict:
    url = f"{_base_url()}/api/Transactions/SubmitOrderRequest"
    payload = {
        'id': merchant_reference,
        'currency': currency,
        'amount': float(amount),
        'description': description,
        'callback_url': callback_url,
        'notification_id': ipn_id,
        'billing_address': {
            'email_address': email,
        },
    }

    try:
        response = requests.post(url, json=payload, headers=_auth_headers(access_token), timeout=_timeout())
    except requests.RequestException as exc:
        logger.error('Pesapal submit order connection failure: %s', exc)
        raise RuntimeError('Unable to connect to Pesapal order submission endpoint.')
    if response.status_code not in {200, 201}:
        logger.error('Pesapal submit order failed: %s', response.text)
        raise RuntimeError(f'Unable to submit Pesapal order ({response.status_code}): {response.text}')

    return response.json()


def get_transaction_status(access_token: str, order_tracking_id: str) -> dict:
    url = f"{_base_url()}/api/Transactions/GetTransactionStatus"
    try:
        response = requests.get(
            url,
            params={'orderTrackingId': order_tracking_id},
            headers=_auth_headers(access_token),
            timeout=_timeout(),
        )
    except requests.RequestException as exc:
        logger.error('Pesapal status lookup connection failure: %s', exc)
        raise RuntimeError('Unable to connect to Pesapal transaction status endpoint.')

    if response.status_code != 200:
        logger.error('Pesapal status lookup failed: %s', response.text)
        raise RuntimeError('Unable to fetch Pesapal transaction status.')

    return response.json()


def normalize_status(raw_status: str) -> str:
    value = (raw_status or '').strip().lower()
    if value in {'completed', 'paid', 'success'}:
        return 'completed'
    if value in {'failed', 'invalid', 'cancelled', 'canceled'}:
        return 'failed'
    return 'pending'

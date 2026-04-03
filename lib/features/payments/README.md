# Payments Feature

This feature provides a simple Pesapal subscription flow.

- `payment_service.dart` posts to `/api/payments/initiate/`.
- `subscribe_screen.dart` launches the returned `redirect_url`.

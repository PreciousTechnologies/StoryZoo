import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/constants/app_constants.dart';

class InitiatedBookPayment {
  const InitiatedBookPayment({
    required this.redirectUri,
    required this.merchantReference,
    required this.alreadyPurchased,
  });

  final Uri? redirectUri;
  final String merchantReference;
  final bool alreadyPurchased;
}

class PaymentService {
  PaymentService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  String get _base => '${AppConstants.apiBaseUrl}${AppConstants.apiVersion}';
  Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      };

  Future<InitiatedBookPayment> initiateBookPayment({
    required String token,
    required int bookId,
    required String email,
  }) async {
    if (token.trim().isEmpty) {
      throw Exception('Authentication token is required.');
    }

    final url = Uri.parse('$_base/payments/initiate/');
    final res = await _client.post(
      url,
      headers: _headers(token),
      body: jsonEncode({'book_id': bookId, 'email': email.trim()}),
    );

    if (res.statusCode != 200) {
      String detail = 'Payment initiation failed (${res.statusCode}).';
      try {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final apiDetail = (body['detail'] ?? '').toString().trim();
        if (apiDetail.isNotEmpty) {
          detail = '$detail $apiDetail';
        }
      } catch (_) {
        // Keep generic message when response is not JSON.
      }
      throw Exception(detail);
    }

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final alreadyPurchased = body['already_purchased'] == true;
    final merchantReference = (body['merchant_reference'] ?? '').toString();
    final redirectUrl = (body['redirect_url'] ?? '').toString();

    if (alreadyPurchased) {
      return const InitiatedBookPayment(
        redirectUri: null,
        merchantReference: '',
        alreadyPurchased: true,
      );
    }

    if (redirectUrl.isEmpty || merchantReference.isEmpty) {
      throw Exception('Invalid payment response from server.');
    }

    return InitiatedBookPayment(
      redirectUri: Uri.parse(redirectUrl),
      merchantReference: merchantReference,
      alreadyPurchased: false,
    );
  }

  Future<String> fetchPaymentStatus({
    required String token,
    required String merchantReference,
  }) async {
    if (token.trim().isEmpty) {
      throw Exception('Authentication token is required.');
    }

    final url = Uri.parse('$_base/payments/status/').replace(
      queryParameters: {'merchant_reference': merchantReference},
    );
    final res = await _client.get(url, headers: _headers(token));
    if (res.statusCode != 200) {
      String detail = 'Failed to fetch payment status (${res.statusCode}).';
      try {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final apiDetail = (body['detail'] ?? '').toString().trim();
        if (apiDetail.isNotEmpty) {
          detail = '$detail $apiDetail';
        }
      } catch (_) {
        // Keep generic message when response is not JSON.
      }
      throw Exception(detail);
    }

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return (body['status'] ?? 'pending').toString().toLowerCase();
  }

  void dispose() {
    _client.close();
  }
}

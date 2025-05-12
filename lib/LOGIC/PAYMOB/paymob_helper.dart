import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kidspath/WIDGETS/CONSTANTS/constants.dart';

class PaymobHelper {
  static const String _apiKey = Paymob.api_key;
  static const String _currency = 'EGP';
  static const int _integrationId = Paymob.cardPaymentMethodIntegrationId;

  static Future<String?> getAuthToken() async {
    final response = await http.post(
      Uri.parse('https://accept.paymob.com/api/auth/tokens'),
      body: jsonEncode({'api_key': _apiKey}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body)['token'];
    }
    return null;
  }

  static Future<String?> createOrder(double amount, String bookingId) async {
    try {
      final token = await getAuthToken();
      if (token == null) throw Exception('Authentication failed');

      final response = await http.post(
        Uri.parse('https://accept.paymob.com/api/ecommerce/orders'),
        body: jsonEncode({
          'auth_token': token,
          'delivery_needed': false,
          'amount_cents': (amount * 100).round(),
          'currency': _currency,
          'merchant_order_id': bookingId,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return responseBody['id'].toString();
      } else {
        throw Exception('Order creation failed: ${responseBody['detail'] ?? response.body}');
      }
    } catch (e) {
      debugPrint('CreateOrder Error: $e');
      rethrow;
    }
  }

  static Future<String?> getPaymentKey(
      String orderId, double amount, String bookingId) async {
    final token = await getAuthToken();
    if (token == null) return null;

    final response = await http.post(
      Uri.parse('https://accept.paymob.com/api/acceptance/payment_keys'),
      body: jsonEncode({
        'auth_token': token,
        'amount_cents': (amount * 100).toStringAsFixed(0),
        'expiration': 3600,
        'order_id': orderId,
        'billing_data': {
          'first_name': 'Parent',
          'last_name': 'Name',
          'email': 'parent@example.com',
          'phone_number': '+201234567890',
          'apartment': 'NA',
          'floor': 'NA',
          'street': 'NA',
          'building': 'NA',
          'city': 'NA',
          'country': 'EG',
        },
        'currency': _currency,
        'integration_id': _integrationId,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body)['token'];
    }
    return null;
  }
}

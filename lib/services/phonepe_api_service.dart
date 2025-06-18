import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class PhonePeApiService {
  static const String _uatAuthUrl =
      'https://api-preprod.phonepe.com/apis/pg-sandbox/v1/oauth/token';
  static const String _prodAuthUrl =
      'https://api.phonepe.com/apis/identity-manager/v1/oauth/token';

  static const String _uatOrderIdUrl =
      'https://api-preprod.phonepe.com/apis/pg-sandbox/checkout/v2/sdk/order';
  static const String _prodOrderIdUrl =
      'https://api.phonepe.com/apis/pg/checkout/v2/sdk/order';

  final bool isProduction;

  PhonePeApiService({this.isProduction = false});

  String get _authUrl => isProduction ? _prodAuthUrl : _uatAuthUrl;
  String get _orderIdUrl => isProduction ? _prodOrderIdUrl : _uatOrderIdUrl;

  // Auth Token API
  Future<Map<String, dynamic>> fetchAuthToken({
    required String clientId,
    required String clientSecret,
    required String clientVersion,
  }) async {
    try {
      final url = Uri.parse(_authUrl);
      debugPrint('Fetching token from: $url');

      final Map<String, String> formData = {
        'client_id': clientId,
        'client_secret': clientSecret,
        'client_version': isProduction ? clientVersion : '1',
        'grant_type': 'client_credentials',
      };

      final body = formData.entries
          .map((e) =>
              '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}')
          .join('&');

      debugPrint('Serialized Form Body: $body');

      if (kDebugMode) {
        debugPrint('Client ID: $clientId');
        debugPrint('Client Secret: $clientSecret');
        debugPrint('Client Version: $clientVersion');
      }

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: utf8.encode(body),
      );

      debugPrint(
          '++++++++++++++++++++++++++++++++++Token fetch status code: $response');
      debugPrint('Token fetch response: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Failed to fetch token: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Token fetch error: $e');
    }
  }

  // Create Order API
  Future<Map<String, dynamic>> createOrder({
    required String accessToken,
    required String merchantOrderId,
    required int amount,
    int? expireAfter,
    Map<String, dynamic>? metaInfo,
    Map<String, dynamic>? paymentModeConfig,
  }) async {
    try {
      final url = Uri.parse(_orderIdUrl);

      final body = {
        'merchantOrderId': merchantOrderId,
        'amount': amount,
        'paymentFlow': {'type': 'PG_CHECKOUT'},
        if (expireAfter != null) 'expireAfter': expireAfter,
        if (metaInfo != null) 'metaInfo': metaInfo,
        if (paymentModeConfig != null)
          'paymentFlow': {
            'type': 'PG_CHECKOUT',
            'paymentModeConfig': paymentModeConfig,
          },
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'O-Bearer $accessToken',
        },
        body: jsonEncode(body),
      );
      debugPrint(
          '+++++++++++++++++++++++++++++++Order creation status code: $response');
      debugPrint(
          '+++++++++++++++++++++++++++++++++++++++++++++++++Creating order with body: $body');
      debugPrint('Order creation response: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Failed to create order: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Order creation error: $e');
    }
  }
}

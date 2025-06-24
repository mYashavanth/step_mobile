import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ghastep/views/urlconfig.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentValidation {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  Future<SubscriptionStatus> validateSubscription() async {
    try {
      // Read required values from secure storage
      final token = await storage.read(key: 'token');
      final selectedCourseId = await storage.read(key: 'selectedCourseId');

      if (token == null || selectedCourseId == null) {
        return SubscriptionStatus.error(
            'Token or Course ID not found in storage');
      }

      // Make API request
      final response = await http
          .get(
            Uri.parse(
                '$baseurl/app/app-purchase/subscription-validity/$token/$selectedCourseId'),
          )
          .timeout(const Duration(seconds: 30));
      print(
          'API Request: ${Uri.parse('$baseurl/app/app-purchase/subscription-validity/$token/$selectedCourseId')}');
      print('Response Body: ${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['errFlag'] == 0 && data['valid'] == true) {
          return SubscriptionStatus.valid(
            message: data['message'] ?? 'Subscription active',
            validTill: data['valid_till'] ?? 'N/A',
          );
        } else {
          return SubscriptionStatus.invalid(
            message: data['message'] ?? 'Subscription not active',
          );
        }
      } else {
        return SubscriptionStatus.error(
            'API request failed with status ${response.statusCode}');
      }
    } on TimeoutException {
      return SubscriptionStatus.error('Request timed out');
    } catch (e) {
      return SubscriptionStatus.error('An error occurred: $e');
    }
  }
}

// Result class to handle different subscription states
class SubscriptionStatus {
  final bool isValid;
  final String? message;
  final String? validTill;
  final String? error;

  SubscriptionStatus._({
    required this.isValid,
    this.message,
    this.validTill,
    this.error,
  });

  factory SubscriptionStatus.valid(
      {required String message, required String validTill}) {
    return SubscriptionStatus._(
      isValid: true,
      message: message,
      validTill: validTill,
    );
  }

  factory SubscriptionStatus.invalid({required String message}) {
    return SubscriptionStatus._(
      isValid: false,
      message: message,
    );
  }

  factory SubscriptionStatus.error(String error) {
    return SubscriptionStatus._(
      isValid: false,
      error: error,
    );
  }

  @override
  String toString() {
    if (error != null) {
      return 'Error: $error';
    }
    return 'SubscriptionStatus: $message, Valid: $isValid${isValid ? ', Valid Till: $validTill' : ''}';
  }
}

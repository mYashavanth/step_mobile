import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentService {
  // PhonePe Configuration
  static const String _phonePeMerchantId = "PGTESTPAYUAT";
  static const String _saltKey = "099eb0cd-02cf-4e2a-8aca-3e6c6aff0399";
  static const String _saltIndex = "1";
  static const String _callbackUrl =
      "https://webhook.site/3df06f70-e343-41f2-85a4-d5039600e669";
  static const String _apiEndpoint = "/pg/v1/pay";
  static const String _appSchema = "";

  // Apple Pay Configuration (for iOS)
  static const String _applePayMerchantId = "merchant.your.identifier";
  static const String _applePayCurrencyCode = "INR";
  static const String _applePayCountryCode = "IN";

  /// Initialize payment services for the current platform
  static Future<void> initialize({bool enableLogs = true}) async {
    if (Platform.isAndroid) {
      await _initializePhonePe(enableLogs: enableLogs);
    }
    // Apple Pay doesn't require explicit initialization
  }

  /// Initialize PhonePe SDK (Android only)
  static Future<void> _initializePhonePe({bool enableLogs = true}) async {
    try {
      final isInitialized = await PhonePePaymentSdk.init(
        'SANDBOX', // or 'PRODUCTION'
        _phonePeMerchantId,
        "user123", // flowId
        enableLogs,
      );
      debugPrint("PhonePe SDK Initialized: $isInitialized");
    } catch (error) {
      debugPrint("PhonePe SDK initialization error: $error");
      rethrow;
    }
  }

  /// Initiate payment based on platform
  static Future<void> initiatePayment({
    required double amount,
    required String merchantTransactionId,
    required String mobileNumber,
    required String productName,
    required BuildContext context,
    VoidCallback? onSuccess,
    Function(String)? onError,
  }) async {
    try {
      if (Platform.isIOS) {
        await _processApplePay(
          amount: amount,
          productName: productName,
          context: context,
          onSuccess: onSuccess,
          onError: onError,
        );
      } else {
        await _processPhonePePayment(
          amount: amount,
          merchantTransactionId: merchantTransactionId,
          mobileNumber: mobileNumber,
          context: context,
          onSuccess: onSuccess,
          onError: onError,
        );
      }
    } catch (e) {
      onError?.call('Payment initialization failed: ${e.toString()}');
    }
  }

  /// Process Apple Pay payment (iOS only)
  static Future<void> _processApplePay({
    required double amount,
    required String productName,
    required BuildContext context,
    VoidCallback? onSuccess,
    Function(String)? onError,
  }) async {
    try {
      const platform = MethodChannel('apple_pay_channel');

      final result = await platform.invokeMethod('startApplePay', {
        'amount': amount,
        'merchantId': _applePayMerchantId,
        'productName': productName,
        'currencyCode': _applePayCurrencyCode,
        'countryCode': _applePayCountryCode,
      });

      if (result['status'] == 'success') {
        onSuccess?.call();
      } else {
        onError?.call(result['message'] ?? 'Apple Pay payment failed');
      }
    } on PlatformException catch (e) {
      onError?.call('Apple Pay error: ${e.message}');
    } catch (e) {
      onError?.call('Apple Pay error: ${e.toString()}');
    }
  }

  /// Process PhonePe payment (Android only)
  static Future<void> _processPhonePePayment({
    required double amount,
    required String merchantTransactionId,
    required String mobileNumber,
    required BuildContext context,
    VoidCallback? onSuccess,
    Function(String)? onError,
  }) async {
    try {
      // 1. Prepare payment payload
      final body = {
        "merchantId": _phonePeMerchantId,
        "merchantTransactionId": merchantTransactionId,
        "merchantUserId": "user123",
        "amount": (amount * 100).toInt(), // Convert to paise
        "mobileNumber": mobileNumber,
        "callbackUrl": _callbackUrl,
        "paymentInstrument": {"type": "PAY_PAGE"},
      };

      // 2. Generate checksum
      final jsonBody = json.encode(body);
      final base64Body = base64.encode(utf8.encode(jsonBody));
      final checksum = _generatePhonePeChecksum(base64Body);

      // 3. Prepare final request
      final requestPayload = json.encode({
        "request": base64Body,
        "checksum": checksum,
        "endpoint": _apiEndpoint,
      });

      debugPrint("Starting PhonePe transaction...");

      // 4. Start transaction
      final result =
          await PhonePePaymentSdk.startTransaction(requestPayload, _appSchema);

      // 5. Handle result
      _handlePhonePeTransactionResult(result, onSuccess, onError);
    } catch (e) {
      debugPrint("PhonePe Transaction Error: $e");
      onError?.call('PhonePe payment failed: $e');

      // Fallback to UPI intent if PhonePe app is not installed
      await _launchPhonePeUPI(
        amount: amount,
        context: context,
        onSuccess: onSuccess,
        onError: onError,
      );
    }
  }

  /// Generate SHA256 checksum for PhonePe request
  static String _generatePhonePeChecksum(String base64Body) {
    final byteCodes = utf8.encode(base64Body + _apiEndpoint + _saltKey);
    return '${sha256.convert(byteCodes)}###$_saltIndex';
  }

  /// Handle PhonePe transaction result
  static void _handlePhonePeTransactionResult(
    dynamic result,
    VoidCallback? onSuccess,
    Function(String)? onError,
  ) {
    if (result != null) {
      final status = result['status']?.toString() ?? 'UNKNOWN';
      final error = result['error']?.toString() ?? 'No error details';

      debugPrint("PhonePe Transaction Status: $status");
      debugPrint("PhonePe Transaction Error: $error");

      if (status == 'SUCCESS') {
        onSuccess?.call();
      } else {
        onError?.call('PhonePe payment failed: $error');
      }
    } else {
      onError?.call('PhonePe transaction returned no result');
    }
  }

  /// Fallback UPI payment for Android when PhonePe app is not installed
  static Future<void> _launchPhonePeUPI({
    required double amount,
    required BuildContext context,
    VoidCallback? onSuccess,
    Function(String)? onError,
  }) async {
    try {
      final uri = Uri.parse(
        'phonepe://pay?pa=9481726689@ybl&pn=YourAppName&am=${amount.toStringAsFixed(2)}&cu=INR',
      );

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        // Note: Actual success comes through callback URL
        onSuccess?.call();
      } else {
        onError?.call('PhonePe app not installed');
        _showAlternativePaymentOptions(context, amount);
      }
    } catch (e) {
      onError?.call('Failed to launch PhonePe UPI: $e');
    }
  }

  /// Show alternative payment options if primary payment fails
  static void _showAlternativePaymentOptions(
      BuildContext context, double amount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Options'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Amount: ₹${amount.toStringAsFixed(2)}'),
            const SizedBox(height: 20),
            const Text('Please choose another payment method:'),
            const SizedBox(height: 10),
            if (Platform.isAndroid) _buildUPIPaymentButton(context, amount),
            // Add other payment options as needed
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  /// Build UPI payment button for Android fallback
  static Widget _buildUPIPaymentButton(BuildContext context, double amount) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple[800],
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      onPressed: () => _launchGenericUPI(context, amount),
      child: const Text('Pay via any UPI App'),
    );
  }

  /// Launch generic UPI payment intent
  static Future<void> _launchGenericUPI(
      BuildContext context, double amount) async {
    try {
      final uri = Uri.parse(
        'upi://pay?pa=upimercahnt@upi&pn=MerchantName&am=${amount.toStringAsFixed(2)}&cu=INR',
      );

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No UPI app found')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to launch UPI: $e')),
      );
    }
  }
}

class PlatformPaymentButton extends StatelessWidget {
  final double amount;
  final String merchantTransactionId;
  final String mobileNumber;
  final String productName;
  final VoidCallback? onSuccess;
  final Function(String)? onError;
  final ButtonStyle? style;

  const PlatformPaymentButton({
    super.key,
    required this.amount,
    required this.merchantTransactionId,
    required this.mobileNumber,
    required this.productName,
    this.onSuccess,
    this.onError,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: style ?? _defaultButtonStyle(),
      onPressed: () => _initiatePayment(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Platform.isIOS ? Icons.apple : Icons.payment, size: 24),
          const SizedBox(width: 8),
          Text(Platform.isIOS ? 'Pay with Apple Pay' : 'Pay with PhonePe'),
        ],
      ),
    );
  }

  ButtonStyle _defaultButtonStyle() {
    return ButtonStyle(
      backgroundColor: WidgetStateProperty.all(
        Platform.isIOS
            ? Colors.black
            : const Color(0xFF5F259F), // Apple Black / PhonePe Purple
      ),
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    );
  }

  Future<void> _initiatePayment(BuildContext context) async {
    await PaymentService.initialize();

    await PaymentService.initiatePayment(
      amount: amount,
      merchantTransactionId: merchantTransactionId,
      mobileNumber: mobileNumber,
      productName: productName,
      context: context,
      onSuccess: onSuccess,
      onError: onError,
    );
  }
}

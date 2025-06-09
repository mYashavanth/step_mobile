import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // <-- Required for MethodChannel
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentService {
  static Future<void> initializePhonePe(String env) async {
    try {
      await PhonePePaymentSdk.init(env, "YOUR_MERCHANT_ID", "YOUR_APP_ID", true)
          .then((val) {
        debugPrint("PhonePe initialized: $val");
      }).catchError((error) {
        debugPrint("PhonePe initialization error: $error");
      });
    } catch (e) {
      debugPrint("PhonePe initialization exception: $e");
    }
  }

  static Future<void> initiatePayment({
    required double amount,
    required String merchantId,
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
          merchantId: merchantId,
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
      onError?.call('Payment initialization failed: $e');
    }
  }

  static Future<void> _processApplePay({
    required double amount,
    required String merchantId,
    required String productName,
    required BuildContext context,
    VoidCallback? onSuccess,
    Function(String)? onError,
  }) async {
    try {
      // Implement Apple Pay using platform channels
      final result = await _startApplePay(
        amount: amount,
        merchantId: merchantId,
        productName: productName,
      );

      if (result['status'] == 'success') {
        onSuccess?.call();
      } else {
        onError?.call(result['message'] ?? 'Apple Pay payment failed');
      }
    } catch (e) {
      onError?.call('Apple Pay error: $e');
    }
  }

  static Future<Map<String, dynamic>> _startApplePay({
    required double amount,
    required String merchantId,
    required String productName,
  }) async {
    if (Platform.isIOS) {
      try {
        // Implement platform channel method
        const platform = MethodChannel('apple_pay_channel');
        final result = await platform.invokeMethod('startApplePay', {
          'amount': amount,
          'merchantId': merchantId,
          'productName': productName,
          'currencyCode': 'INR',
          'countryCode': 'IN',
        });
        return result;
      } catch (e) {
        return {'status': 'error', 'message': e.toString()};
      }
    }
    return {'status': 'error', 'message': 'Apple Pay not available'};
  }

  static Future<void> _processPhonePePayment({
    required double amount,
    required String merchantTransactionId,
    required String mobileNumber,
    required BuildContext context,
    VoidCallback? onSuccess,
    Function(String)? onError,
  }) async {
    try {
      final body = {
        "merchantId": "YOUR_MERCHANT_ID",
        "merchantTransactionId": merchantTransactionId,
        "merchantUserId": "USER_ID",
        "amount": amount * 100, // Amount in paise
        "mobileNumber": mobileNumber,
        "callbackUrl": "YOUR_CALLBACK_URL",
        "paymentInstrument": {"type": "PAY_PAGE"},
      };

      final checksum = _generateChecksum(body); // Implement checksum generation

      final result = await PhonePePaymentSdk.startTransaction(
        body.toString(),
        checksum,
      );

      final status = result != null ? result['status']?.toString() : null;
      if (status == 'SUCCESS') {
        onSuccess?.call();
      } else {
        onError?.call(result != null
            ? result['error']?.toString() ?? 'Unknown error'
            : 'Unknown error');
      }
    } catch (e) {
      // Fallback to UPI payment if PhonePe app not installed
      await _launchPhonePeUPI(
        amount: amount,
        context: context,
        onSuccess: onSuccess,
        onError: onError,
      );
    }
  }

  static String _generateChecksum(Map<String, dynamic> body) {
    // Implement your checksum generation logic
    return "YOUR_CHECKSUM";
  }

  static Future<void> _launchPhonePeUPI({
    required double amount,
    required BuildContext context,
    VoidCallback? onSuccess,
    Function(String)? onError,
  }) async {
    try {
      final uri = Uri.parse(
        'phonepe://pay?pa=YOUR_UPI_ID@ybl&pn=YourAppName&am=${amount.toStringAsFixed(2)}&cu=INR',
      );

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        // Note: You'll need to handle the callback separately
      } else {
        onError?.call('PhonePe not installed');
        _showAlternativePaymentOptions(context, amount);
      }
    } catch (e) {
      onError?.call('Payment error: $e');
    }
  }

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
            const Text('Please choose another payment option:'),
            const SizedBox(height: 20),
            // Add other payment options here
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
}

class PlatformPaymentButton extends StatelessWidget {
  final double amount;
  final String productName;
  final String merchantTransactionId;
  final String mobileNumber;
  final VoidCallback? onPaymentSuccess;
  final Function(String)? onPaymentError;
  final ButtonStyle? style;
  final Widget? iosIcon;
  final Widget? androidIcon;

  const PlatformPaymentButton({
    super.key,
    required this.amount,
    required this.productName,
    required this.merchantTransactionId,
    required this.mobileNumber,
    this.onPaymentSuccess,
    this.onPaymentError,
    this.style,
    this.iosIcon,
    this.androidIcon,
  });

  @override
  Widget build(BuildContext context) {
    // Only show the button if the platform is supported
    if (!Platform.isIOS && !Platform.isAndroid) {
      return const SizedBox.shrink();
    }

    return ElevatedButton(
      style: style ?? _defaultButtonStyle(),
      onPressed: () => _handlePayment(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (Platform.isIOS) iosIcon ?? const Icon(Icons.apple, size: 24),
          if (Platform.isAndroid)
            androidIcon ?? const Icon(Icons.phone_android, size: 24),
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
            : const Color(0xFF5F259F), // PhonePe purple
      ),
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    );
  }

  void _handlePayment(BuildContext context) {
    PaymentService.initiatePayment(
      amount: amount,
      merchantId: 'merchant.your.identifier',
      merchantTransactionId: merchantTransactionId,
      mobileNumber: mobileNumber,
      productName: productName,
      context: context,
      onSuccess: onPaymentSuccess,
      onError: onPaymentError,
    );
  }
}


                  
// PlatformPaymentButton(
//   amount: 100.0, // Payment amount
//   productName: 'Premium Subscription', // Product description
//   merchantTransactionId:
//       'txn_${DateTime.now().millisecondsSinceEpoch}', // Unique ID
//   mobileNumber: '9876543210', // User's mobile number
//   onPaymentSuccess: () {
//     // Handle successful payment
//     print('Payment successful!');
//   },
//   onPaymentError: (error) {
//     // Handle payment error
//     print('Payment failed: $error');
//   },
// ),
                  

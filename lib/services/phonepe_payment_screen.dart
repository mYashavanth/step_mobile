import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';
import '../services/phonepe_payment_manager.dart';
import '../services/phonepe_api_service.dart';

class PhonePePaymentScreen extends StatefulWidget {
  const PhonePePaymentScreen({super.key});

  @override
  State<PhonePePaymentScreen> createState() => _PhonePePaymentScreenState();
}

class _PhonePePaymentScreenState extends State<PhonePePaymentScreen> {
  late PhonePePaymentManager _paymentManager;
  String environment = "SANDBOX";
  String merchantId = "PGTESTPAYUAT";
  bool enableLogging = true;
  String result = "Ready";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _paymentManager = PhonePePaymentManager(
      apiService: PhonePeApiService(isProduction: false),
      clientId: 'TEST-M23JNKHG11XBL_25061', // Get from PhonePe
      clientSecret:
          'ODllZWY4MzktNDJiMi00OWE3LWE1ZDEtNjY1NTk0ZDE5N2Vi', // Get from PhonePe
      clientVersion: '1',
    );
    _initializePhonePe();
  }

  Future<void> _initializePhonePe() async {
    try {
      bool isInitialized = await PhonePePaymentSdk.init(
        environment,
        merchantId,
        "flow_${DateTime.now().millisecondsSinceEpoch}",
        enableLogging,
      );
      debugPrint(
          "++++++++++++++++++++++PhonePe SDK initialized: $isInitialized, Merchant ID: $merchantId");
      setState(() {
        result = isInitialized ? "Ready to pay" : "Initialization failed";
      });
    } catch (e) {
      setState(() {
        result = "Init error: ${e.toString()}";
      });
    }
  }

  Future<void> _startPayment() async {
    setState(() {
      isLoading = true;
      result = "Processing...";
    });

    try {
      // 1. Create order
      final order = await _paymentManager.createNewOrder(
        merchantOrderId: "ORDER_${DateTime.now().millisecondsSinceEpoch}",
        amount: 1000, // ₹10 in paise
      );

      // 2. Prepare payment request
      final payload = {
        "orderId": order['orderId'],
        "merchantId": merchantId,
        "token": order['token'],
        "paymentMode": {"type": "PAY_PAGE"},
        "merchantTransactionId": "MT_${DateTime.now().millisecondsSinceEpoch}",
        "amount": 1000,
        "callbackUrl": "https://your-webhook-url.com/callback",
      };

      debugPrint("Payment Payload: $payload");
      debugPrint("Payment JSON Payload: ${jsonEncode(payload)}");

      // 3. Start payment
      final response = await PhonePePaymentSdk.startTransaction(
          jsonEncode(payload), "yourapp" // Must match your iOS URL scheme
          );

      _handlePaymentResponse(response);
    } catch (e) {
      debugPrint("Error: ${e.toString()}");
      setState(() {
        result = "Error: ${e.toString()}";
        isLoading = false;
      });
    }
  }

  void _handlePaymentResponse(Map<dynamic, dynamic>? response) {
    setState(() {
      isLoading = false;
      if (response == null) {
        result = "Payment incomplete";
        return;
      }
      result = response['status'] == 'SUCCESS'
          ? "Payment successful!"
          : "Payment failed: ${response['error']}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PhonePe Payment')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: isLoading ? null : _startPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                ),
                child: const Text(
                  'Pay ₹10 with PhonePe',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              const SizedBox(height: 30),
              if (isLoading) const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(result, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}

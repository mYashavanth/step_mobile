import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';
import '../services/phonepe_payment_manager.dart';
import '../services/phonepe_api_service.dart';
import 'package:http/http.dart' as http;

class PhonePePaymentScreen extends StatefulWidget {
  const PhonePePaymentScreen({super.key});

  @override
  State<PhonePePaymentScreen> createState() => _PhonePePaymentScreenState();
}

class _PhonePePaymentScreenState extends State<PhonePePaymentScreen> {
  late PhonePePaymentManager _paymentManager;
  String environment = "PRODUCTION"; // Use "SANDBOX" for live environment
  String merchantId = "M23JNKHG11XBL"; // Get from PhonePe sandbox-PGTESTPAYUAT
  bool enableLogging = true;
  String result = "Ready";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _paymentManager = PhonePePaymentManager(
      apiService:
          PhonePeApiService(isProduction: true), // Set to false for sandbox
      clientId:
          'SU2505301410333652987907', // Get from PhonePe sandbox-TEST-M23JNKHG11XBL_25061
      clientSecret:
          '53f30118-d5df-4439-939c-f084329a2744', // Get from PhonePe sandbox-ODllZWY4MzktNDJiMi00OWE3LWE1ZDEtNjY1NTk0ZDE5N2Vi
      clientVersion: '1',
    );
    _initializePhonePe();
  }

  Future<void> _initializePhonePe() async {
    try {
      bool isInitialized = await PhonePePaymentSdk.init(
        environment,
        merchantId,
        "flow${DateTime.now().millisecondsSinceEpoch}",
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
        amount: 100, // ₹10 in paise
      );
      debugPrint(
          "+++++++++++++++++++++++++++++++++++++++++Order Created: ${order.toString()}");
      // 2. Prepare payment request
      final payload = {
        "orderId": order['orderId'],
        "merchantId": merchantId,
        "token": order['token'],
        "paymentMode": {"type": "PAY_PAGE"},
        "merchantTransactionId": "MT_${DateTime.now().millisecondsSinceEpoch}",
        "amount": 100,
        "callbackUrl":
            "https://webhook.site/0d6fb306-a6c7-4283-b856-59c51837e119",
      };

      debugPrint(
          "+++++++++++++++++++++++++++++++++++++++++Payment Payload: $payload");
      debugPrint("Payment JSON Payload: ${jsonEncode(payload)}");

      // 3. Start payment
      final response = await PhonePePaymentSdk.startTransaction(
          jsonEncode(payload), "yourapp" // Must match your iOS URL scheme
          );
      debugPrint(
          "---------------------------------------------------Payment Response: $response");
      _getOrderDetails(order['orderId'], order['token']);
      _handlePaymentResponse(response);
    } catch (e) {
      debugPrint("Error: ${e.toString()}");
      setState(() {
        result = "Error: ${e.toString()}";
        isLoading = false;
      });
    }
  }

  Future<void> _getOrderDetails(String orderId, String token) async {
    final testToken = await _paymentManager.getValidToken();
    debugPrint(
        "Fetching order details for Order ID: $orderId with token: $token ($testToken)");
    try {
      final uri = Uri.parse(
          'https://mercury-uat.phonepe.com/v3/transaction/$merchantId/$orderId/status');
      // Compute SHA256 hash for X-VERIFY header
      final String dataToHash = "/v3/transaction/$merchantId/$orderId/status" +
          "53f30118-d5df-4439-939c-f084329a2744";
      final String hash = sha256.convert(utf8.encode(dataToHash)).toString();
      final String xVerify = "$hash###1";

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'X-VERIFY': xVerify,
        },
      );
      debugPrint(
          "+++++++++++++++++++++++++++++++++++++++++Order Details Response: ${response.statusCode}");
      debugPrint(
          "+++++++++++++++++++++++++++++++++++++++++Order Details Response: ${response.body}");
    } catch (e) {
      debugPrint("Error fetching order details: ${e.toString()}");
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
                  'Pay ₹1 with PhonePe',
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

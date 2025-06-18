import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ghastep/views/urlconfig.dart';
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
  final storage = const FlutterSecureStorage();
  late PhonePePaymentManager _paymentManager;
  String environment = "PRODUCTION"; // Use "SANDBOX" for testing
  // For production, use "PRODUCTION"
  String merchantId =
      "M23JNKHG11XBL"; // for sandbox-PGTESTPAYUAT, for production-M23JNKHG11XBL
  bool enableLogging = true;
  String result = "Ready";
  bool isLoading = false;
  bool isInitializing = true;
  Map<String, dynamic> courseData = {};

  // Payment status states
  bool isPaymentSuccess = false;
  bool isPaymentFailed = false;
  bool isAlreadyPurchased = false; // Flag for already purchased status

  @override
  void initState() {
    super.initState();
    _paymentManager = PhonePePaymentManager(
      apiService: PhonePeApiService(
          isProduction: true), // Set to false for sandbox, true for production
      clientId:
          'SU2505301410333652987907', // Get from PhonePe sandbox-TEST-M23JNKHG11XBL_25061, // for production-SU2505301410333652987907
      clientSecret:
          '53f30118-d5df-4439-939c-f084329a2744', // Get from PhonePe sandbox-ODllZWY4MzktNDJiMi00OWE3LWE1ZDEtNjY1NTk0ZDE5N2Vi, // for production-53f30118-d5df-4439-939c-f084329a2744
      clientVersion: '1',
    );
    _initializePhonePe();
    _loadCourseData();
    // TODO: Check if already purchased from backend
    // _checkIfAlreadyPurchased();
  }

  Future<void> _loadCourseData() async {
    try {
      String token = await storage.read(key: 'token') ?? '';
      String selectedCourseId =
          await storage.read(key: 'selectedCourseId') ?? '1';

      debugPrint(
          "++++++++++++++++++++++Fetching course data with token: $token and courseId: $selectedCourseId");

      final response = await http.get(
        Uri.parse(
            '$baseurl/app/get-app-course-pricing/$selectedCourseId/$token'),
      );

      debugPrint(
          "++++++++++++++++++++++Course data response: ${response.statusCode}");
      debugPrint("++++++++++++++++++++++Course data body: ${response.body}");

      if (response.statusCode == 200) {
        setState(() {
          courseData = json.decode(response.body);
          debugPrint("++++++++++++++++++++++Course data loaded: $courseData");
        });
      } else {
        throw Exception('Failed to load course data');
      }
    } catch (e) {
      debugPrint(
          "++++++++++++++++++++++Error loading course data: ${e.toString()}");
      setState(() {
        result = "Error loading data: ${e.toString()}";
      });
    }
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
        isInitializing = false;
      });
    } catch (e) {
      setState(() {
        result = "Init error: ${e.toString()}";
        isInitializing = false;
      });
    }
  }

  Future<void> _startPayment() async {
    if (courseData.isEmpty) {
      debugPrint("++++++++++++++++++++++Course data not available for payment");
      return;
    }

    setState(() {
      isLoading = true;
      result = "Processing...";
      isPaymentSuccess = false;
      isPaymentFailed = false;
    });

    try {
      final amountInPaise =
          (double.parse(courseData['selling_price_inr']) * 100).toInt();
      debugPrint(
          "++++++++++++++++++++++Payment amount in paise: $amountInPaise");
      // 1. Create order
      final order = await _paymentManager.createNewOrder(
        merchantOrderId: "ORDER_${DateTime.now().millisecondsSinceEpoch}",
        amount: amountInPaise, // ₹10 in paise
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
      // _getOrderDetails(order['orderId'], order['token']);
      _handlePaymentResponse(response, order['orderId']);
    } catch (e) {
      debugPrint("Error: ${e.toString()}");
      setState(() {
        result = "Error: ${e.toString()}";
        isLoading = false;
        isPaymentFailed = true;
      });
    }
  }

  // Future<void> _getOrderDetails(String orderId, String token) async {
  //   final accessToken = await _paymentManager.getValidToken();
  //   debugPrint(
  //       "Fetching order details for Order ID: $orderId with token: $token ($accessToken)");
  //   try {
  //     final uri = Uri.parse(
  //         'https://api-preprod.phonepe.com/apis/pg-sandbox/checkout/v2/order/$orderId/status');
  //     // // Compute SHA256 hash for X-VERIFY header
  //     // final String dataToHash = "/v3/transaction/$merchantId/$orderId/status" +
  //     //     "53f30118-d5df-4439-939c-f084329a2744";
  //     // final String hash = sha256.convert(utf8.encode(dataToHash)).toString();
  //     // final String xVerify = "$hash###1";

  //     final response = await http.get(
  //       uri,
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'O-Bearer $accessToken',
  //       },
  //     );
  //     debugPrint(
  //         "+++++++++++++++++++++++++++++++++++++++++Order Details Response: ${response.statusCode}");
  //     debugPrint(
  //         "+++++++++++++++++++++++++++++++++++++++++Order Details Response: ${response.body}");
  //   } catch (e) {
  //     debugPrint("Error fetching order details: ${e.toString()}");
  //   }
  // }

  void _handlePaymentResponse(Map<dynamic, dynamic>? response, String orderId) {
    setState(() {
      isLoading = false;
      if (response == null) {
        result = "Payment incomplete";
        isPaymentFailed = true;
        _updateBackendWithPaymentStatus(
          phoneTxnId: orderId,
          paymentStatus: 0,
          appPurchaseId: courseData['app_purchase_id'],
        );
        return;
      }

      if (response['status'] == 'SUCCESS') {
        result = "Payment successful!";
        isPaymentSuccess = true;
        isPaymentFailed = false;
        _updateBackendWithPaymentStatus(
          phoneTxnId: orderId,
          paymentStatus: 1,
          appPurchaseId: courseData['app_purchase_id'],
        );
      } else {
        result = "Payment failed: ${response['error']}";
        isPaymentFailed = true;
        isPaymentSuccess = false;
        _updateBackendWithPaymentStatus(
          phoneTxnId: orderId,
          paymentStatus: 0,
          appPurchaseId: courseData['app_purchase_id'],
        );
      }
    });
  }

  Future<void> _updateBackendWithPaymentStatus({
    required String phoneTxnId,
    required int paymentStatus,
    required int appPurchaseId,
  }) async {
    try {
      String token = await storage.read(key: 'token') ?? '';
      Map body = {};
      body['phoneTxnId'] = phoneTxnId;
      body['paymentStatus'] = paymentStatus.toString();
      body['appPurchaseId'] = appPurchaseId.toString();
      body['token'] = token;
      body['appleTxnId'] = ''; // Assuming no Apple payment for PhonePe

      debugPrint(
          "+++++++++++++++++++++++++++++++++++++++++Updating Payment Status with body: $body");

      final response = await http
          .post(Uri.parse('$baseurl/app/app-user-purchase/add'), body: body);

      debugPrint(
          "+++++++++++++++++++++++++++++++++++++++++Update Payment Status Response: ${response.body}");

      if (response.statusCode == 200) {
        debugPrint("Payment status updated successfully");
      } else {
        debugPrint("Failed to update payment status: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error updating payment status: ${e.toString()}");
    }
  }

  Widget _buildPaymentSuccessUI() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/gif/success.gif',
          // height: 200,
          width: MediaQuery.of(context).size.width * 0.8,
        ),
        const SizedBox(height: 20),
        const Text(
          'Payment Successful!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Your course has been successfully purchased.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () {
            // Navigate to course or dashboard
            Navigator.pushNamed(context, '/home_page');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          ),
          child: const Text(
            'Start Learning',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentFailedUI() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/gif/failure.gif',
            width: MediaQuery.of(context).size.width * 0.8,
          ),
          const SizedBox(height: 20),
          const Text(
            'Payment Failed',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            result,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _startPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            ),
            child: const Text(
              'Try Again',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlreadyPurchasedUI() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/gif/success.gif',
            width: MediaQuery.of(context).size.width * 0.8,
          ),
          const SizedBox(height: 20),
          const Text(
            'Already Purchased!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'You already have access to this course.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              // Navigate to course or dashboard
              Navigator.pushNamed(context, '/home_page');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            ),
            child: const Text(
              'Continue Learning',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (courseData.isNotEmpty) ...[
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    courseData['course_name'] ?? 'NEET PG',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final desc
                          in (courseData['price_description'] as String)
                              .split(',')
                              .map((e) => e.trim()))
                        buildRow(desc, true),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Amount:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (courseData['actual_price_inr'] !=
                              courseData['selling_price_inr'])
                            Text(
                              '₹${courseData['actual_price_inr']}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[500],
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          Text(
                            '₹${courseData['selling_price_inr']}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
        const Text(
          'Payment Method',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.phone_android, color: Colors.deepPurple, size: 30),
                SizedBox(width: 16),
                Text(
                  'PhonePe',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Spacer(),
                Icon(Icons.radio_button_checked, color: Colors.deepPurple),
              ],
            ),
          ),
        ),
        const Spacer(),
        Center(
          child: Text(
            result,
            style: TextStyle(
              fontSize: 16,
              color: result.contains("success")
                  ? Colors.green
                  : result.contains("Error") || result.contains("failed")
                      ? Colors.red
                      : Colors.grey[700],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('PhonePe Payment'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: isAlreadyPurchased
              ? _buildAlreadyPurchasedUI()
              : isPaymentSuccess
                  ? _buildPaymentSuccessUI()
                  : isPaymentFailed
                      ? _buildPaymentFailedUI()
                      : _buildPaymentUI(),
        ),
      ),
      bottomNavigationBar:
          isPaymentSuccess || isPaymentFailed || isAlreadyPurchased
              ? null
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed:
                          (isLoading || isInitializing) ? null : _startPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Pay ₹${courseData['selling_price_inr'] ?? 'Amount'}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
    );
  }

  Widget buildRow(String title, bool neet) {
    return Row(
      children: [
        Icon(
          Icons.check_circle,
          size: 15,
          color: neet
              ? const Color.fromARGB(255, 65, 65, 65)
              : const Color(0xFFEC7800),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: neet
                  ? const Color.fromARGB(255, 65, 65, 65)
                  : const Color(0xFFEC7800),
              fontSize: 14,
              fontFamily: 'SF Pro Display',
              fontWeight: FontWeight.w500,
              height: 1.57,
            ),
          ),
        ),
      ],
    );
  }
}

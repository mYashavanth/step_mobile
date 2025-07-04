import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../views/urlconfig.dart';
import 'iap_service.dart';

class IAPPage extends StatefulWidget {
  const IAPPage({super.key});

  @override
  State<IAPPage> createState() => _IAPPageState();
}

class _IAPPageState extends State<IAPPage> {
  final IAPService iapService = IAPService();
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  bool _isPremiumUser = false;
  bool _isLoading = false;
  String _result = "Ready";
  Map<String, dynamic> courseData = {};
  bool isPaymentSuccess = false;
  bool isPaymentFailed = false;
  bool isAlreadyPurchased = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() => _isLoading = true);
    await _loadCourseData();
    await iapService.initConnection();
    final hasPremium = await iapService.checkPurchases();
    setState(() {
      _isPremiumUser = hasPremium;
      _isLoading = false;
    });
  }

  Future<void> _loadCourseData() async {
    try {
      String token = await storage.read(key: 'token') ?? '';
      String selectedCourseId =
          await storage.read(key: 'selectedCourseId') ?? '1';

      final response = await http.get(
        Uri.parse(
          '$baseurl/app/get-app-course-pricing/$selectedCourseId/$token',
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          courseData = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load course data');
      }
    } catch (e) {
      setState(() {
        _result = "Error loading data: ${e.toString()}";
      });
    }
  }

  Future<void> _updateBackendWithPaymentStatus({
    required String appleTxnId,
    required int paymentStatus,
    required int appPurchaseId,
  }) async {
    try {
      String token = await storage.read(key: 'token') ?? '';
      Map body = {};
      body['phoneTxnId'] = ''; // No PhonePe txn for IAP
      body['paymentStatus'] = paymentStatus.toString();
      body['appPurchaseId'] = appPurchaseId.toString();
      body['token'] = token;
      body['appleTxnId'] = appleTxnId;

      final response = await http.post(
        Uri.parse('$baseurl/app/app-user-purchase/add'),
        body: body,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['errFlag'] == '0') {
          // Success
        } else {
          // Handle backend error
        }
      }
    } catch (e) {
      // Handle error
    }
  }

  void _onBuyPressed() async {
    setState(() => _isLoading = true);
    final purchaseResult = await iapService.buyProduct();
    if (purchaseResult == true) {
      // You should get the Apple transaction ID from your IAPService
      final appleTxnId =
          ''; // Update this if your IAPService returns a transactionId
      await _updateBackendWithPaymentStatus(
        appleTxnId: appleTxnId,
        paymentStatus: 1,
        appPurchaseId: courseData['app_purchase_id'],
      );
      setState(() {
        _isPremiumUser = true;
        isPaymentSuccess = true;
        isPaymentFailed = false;
        _result = "Purchase success!";
      });
    } else {
      await _updateBackendWithPaymentStatus(
        appleTxnId: '',
        paymentStatus: 0,
        appPurchaseId: courseData['app_purchase_id'],
      );
      setState(() {
        isPaymentFailed = true;
        isPaymentSuccess = false;
        _result = "Purchase failed. Please try again.";
      });
    }
    setState(() => _isLoading = false);
  }

  void _onRestorePressed() async {
    setState(() => _isLoading = true);
    final success = await iapService.restorePurchases();
    if (success) {
      setState(() {
        _isPremiumUser = true;
        _result = "Purchase restored!";
      });
    } else {
      setState(() {
        _result = "No previous purchase found.";
      });
    }
    setState(() => _isLoading = false);
  }

  Widget _buildPaymentSuccessUI() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/gif/success.gif',
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
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/home_page');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF007AFF),
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
            _result,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _onBuyPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF007AFF),
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
              color: Color(0xFF007AFF),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'You already have access to this course.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/home_page');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF007AFF),
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
                    courseData['course_name'] ?? 'Course',
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
                              color: Color(0xFF007AFF),
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
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                Icon(Icons.apple, color: Color(0xFF007AFF), size: 30),
                SizedBox(width: 16),
                Text(
                  'Apple In-App Purchase',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                Spacer(),
                Icon(Icons.radio_button_checked, color: Color(0xFF007AFF)),
              ],
            ),
          ),
        ),
        const Spacer(),
        Center(
          child: Text(
            _result,
            style: TextStyle(
              fontSize: 16,
              color: _result.contains("success")
                  ? Colors.green
                  : _result.contains("Error") || _result.contains("failed")
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
      appBar: AppBar(title: const Text('In-App Purchase'), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : isAlreadyPurchased
                  ? _buildAlreadyPurchasedUI()
                  : isPaymentSuccess
                      ? _buildPaymentSuccessUI()
                      : isPaymentFailed
                          ? _buildPaymentFailedUI()
                          : _buildPaymentUI(),
        ),
      ),
      bottomNavigationBar:
          (isPaymentSuccess || isPaymentFailed || isAlreadyPurchased)
              ? null
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _onBuyPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF007AFF),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: _isLoading
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
      persistentFooterButtons: [
        if (!isPaymentSuccess && !isPaymentFailed && !isAlreadyPurchased)
          ElevatedButton(
            onPressed: _isLoading ? null : _onRestorePressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
              foregroundColor: Color(0xFF007AFF),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Restore Purchases',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
      ],
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

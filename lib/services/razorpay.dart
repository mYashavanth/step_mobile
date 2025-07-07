import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ghastep/widgets/pyment_validation.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../views/urlconfig.dart';
import 'package:facebook_app_events/facebook_app_events.dart'; // Add this import
import '../main.dart'; // Import to access global facebookAppEvents instance

class RazorPayScreen extends StatefulWidget {
  const RazorPayScreen({super.key});

  @override
  State<RazorPayScreen> createState() => _RazorPayScreenState();
}

class _RazorPayScreenState extends State<RazorPayScreen> {
  final Razorpay _razorpay = Razorpay();
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  final PaymentValidation _paymentValidation = PaymentValidation();

  // Razorpay keys
  static const String keyId = 'rzp_live_eI133IZegW9ZQt';
  static const String keySecret = '0sLl1YXdRxgDMpg2s2H83yEd';

  // Updated color theme to match application (0xFF247E80)
  static const Color primaryColor = Color(0xFF247E80); // Teal/Green
  static const Color accentColor = Color(0xFF34B7B9); // Lighter teal
  static const Color successColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFF44336);
  static const Color textColor = Color(0xFF333333);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color darkPrimary =
      Color(0xFF1A5E5F); // Darker shade for contrast

  bool _isLoading = false;
  String _result = "Ready to pay";
  Map<String, dynamic> courseData = {};
  bool isPaymentSuccess = false;
  bool isPaymentFailed = false;
  bool isAlreadyPurchased = false;
  String? validTillDate;

  @override
  void initState() {
    super.initState();
    _initialize();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> _initialize() async {
    setState(() => _isLoading = true);
    await _loadCourseData();
    await _checkExistingPurchase();
    setState(() => _isLoading = false);
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
          courseData = jsonDecode(response.body);
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

  Future<void> _checkExistingPurchase() async {
    final subscriptionStatus = await _paymentValidation.validateSubscription();

    if (subscriptionStatus.error != null) {
      setState(() {
        _result = subscriptionStatus.error!;
        isAlreadyPurchased = false;
      });
      return;
    }

    setState(() {
      isAlreadyPurchased = subscriptionStatus.isValid;
      if (subscriptionStatus.isValid) {
        validTillDate = subscriptionStatus.validTill;
        _result = subscriptionStatus.message ?? 'Subscription active';
      } else {
        _result = subscriptionStatus.message ?? 'No active subscription';
      }
    });
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    setState(() {
      _isLoading = true;
      _result = "Processing payment...";
    });

    try {
      String token = await storage.read(key: 'token') ?? '';
      Map body = {};
      body['phoneTxnId'] = response.paymentId;
      body['paymentStatus'] = '1';
      body['appPurchaseId'] = courseData['app_purchase_id'].toString();
      body['token'] = token;
      body['appleTxnId'] = '';

      final backendResponse = await http.post(
        Uri.parse('$baseurl/app/app-user-purchase/add'),
        body: body,
      );

      if (backendResponse.statusCode == 200) {
        final responseData = json.decode(backendResponse.body);
        if (responseData['errFlag'] == '0') {
          // Track Facebook payment success event
          await _trackPaymentSuccess(
            paymentMethod: 'Razorpay',
            transactionId: response.paymentId ?? 'razorpay_${DateTime.now().millisecondsSinceEpoch}',
          );

          setState(() {
            isPaymentSuccess = true;
            isPaymentFailed = false;
            _result = "Payment successful!";
          });
        } else {
          setState(() {
            isPaymentFailed = true;
            _result = "Backend error: ${responseData['errMsg']}";
          });
        }
      } else {
        setState(() {
          isPaymentFailed = true;
          _result = "Failed to update backend";
        });
      }
    } catch (e) {
      setState(() {
        isPaymentFailed = true;
        _result = "Error: ${e.toString()}";
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() {
      isPaymentFailed = true;
      _result = "Payment failed: ${response.message ?? 'Unknown error'}";
    });
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    setState(() {
      _result = "Using external wallet: ${response.walletName}";
    });
  }

  Future<void> _startPayment() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _result = "Creating order...";
    });

    try {
      var headers = {
        'Content-Type': 'application/json',
        'Authorization':
            'Basic ${base64Encode(utf8.encode('$keyId:$keySecret'))}',
      };

      int amount =
          (double.parse(courseData['selling_price_inr'].toString()) * 100)
              .toInt();

      var request = http.Request(
        'POST',
        Uri.parse('https://api.razorpay.com/v1/orders'),
      );

      request.body = json.encode({
        "amount": amount,
        "currency": "INR",
        "receipt": "Receipt-${DateTime.now().millisecondsSinceEpoch}",
        "notes": {
          "course_id": courseData['course_id'],
          "app_purchase_id": courseData['app_purchase_id'],
        }
      });

      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        final body = await response.stream.bytesToString();
        final orderData = json.decode(body);
        String orderId = orderData['id'];

        var options = {
          'key': keyId,
          'amount': amount,
          'currency': 'INR',
          'name': 'GHA Step',
          'description': courseData['course_name'] ?? 'Course Purchase',
          'order_id': orderId,
          'timeout': 300,
          'prefill': {
            'contact': '',
            'email': '',
          },
          'theme': {
            'color': '#247E80',
          }
        };

        _razorpay.open(options);
      } else {
        setState(() {
          _result = "Order creation failed: ${response.reasonPhrase}";
          isPaymentFailed = true;
        });
      }
    } catch (e) {
      setState(() {
        _result = "Error: ${e.toString()}";
        isPaymentFailed = true;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Add this new method for tracking payment success
  Future<void> _trackPaymentSuccess({
    required String paymentMethod,
    required String transactionId,
  }) async {
    try {
      // Get user data from storage
      String? userData = await storage.read(key: 'user_data');
      String? mobile = await storage.read(key: 'mobile');

      Map<String, dynamic> userInfo = {};
      if (userData != null) {
        try {
          userInfo = json.decode(userData);
        } catch (e) {
          print('Error parsing user data: $e');
        }
      }

      // Track payment success event
      await facebookAppEvents.logEvent(
        name: 'PaymentSuccess',
        parameters: {
          'email': userInfo['email'] ?? '',
          'name': userInfo['name'] ?? '',
          'mobile': mobile ?? '',
          'city': userInfo['city'] ?? 'Unknown',
          'country': 'IN',
          'college': userInfo['college'] ?? '',
          'course_name': courseData['course_name'] ?? '',
          'actual_price': courseData['actual_price_inr']?.toString() ?? '',
          'selling_price': courseData['selling_price_inr']?.toString() ?? '',
          'currency': 'INR',
          'payment_method': paymentMethod,
          'transaction_id': transactionId,
          'platform': 'Android',
          'purchase_type': 'razorpay_payment',
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        },
      );

      print('PaymentSuccess event tracked successfully');
    } catch (e) {
      print('Facebook PaymentSuccess tracking error: $e');
    }
  }

  // Add this method for tracking payment initiation
  Future<void> _trackPaymentInitiated() async {
    try {
      String? userData = await storage.read(key: 'user_data');
      String? mobile = await storage.read(key: 'mobile');

      Map<String, dynamic> userInfo = {};
      if (userData != null) {
        try {
          userInfo = json.decode(userData);
        } catch (e) {
          print('Error parsing user data: $e');
        }
      }

      await facebookAppEvents.logEvent(
        name: 'InitiateCheckout',
        parameters: {
          'email': userInfo['email'] ?? '',
          'name': userInfo['name'] ?? '',
          'mobile': mobile ?? '',
          'city': userInfo['city'] ?? 'Unknown',
          'country': 'IN',
          'college': userInfo['college'] ?? '',
          'course_name': courseData['course_name'] ?? '',
          'selling_price': courseData['selling_price_inr']?.toString() ?? '',
          'currency': 'INR',
          'payment_method': 'Razorpay',
          'platform': 'Android',
        },
      );

      print('InitiateCheckout event tracked successfully');
    } catch (e) {
      print('Facebook InitiateCheckout tracking error: $e');
    }
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
            color: successColor,
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
          onPressed: () {
            Navigator.pushNamed(context, '/home_page');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
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
              color: errorColor,
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
            onPressed: _startPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
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
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            validTillDate != null
                ? 'Your subscription is valid until $validTillDate'
                : 'You already have access to this course.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/home_page');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
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
            color: Colors.white,
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
                      color: textColor,
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
                          color: textColor,
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
                              color: primaryColor,
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
            color: textColor,
          ),
        ),
        const SizedBox(height: 10),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.white,
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.payment, color: primaryColor, size: 30),
                SizedBox(width: 16),
                Text(
                  'Razorpay Payment Gateway',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
                Spacer(),
                Icon(Icons.radio_button_checked, color: primaryColor),
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
                  ? successColor
                  : _result.contains("Error") || _result.contains("failed")
                      ? errorColor
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
      backgroundColor: lightGrey,
      appBar: AppBar(
        title: const Text('Payment'),
        centerTitle: true,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: accentColor,
                  ),
                )
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
                      onPressed: _isLoading ? null : _startPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                        elevation: 3,
                        shadowColor: darkPrimary.withOpacity(0.3),
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
    );
  }

  Widget buildRow(String title, bool neet) {
    return Row(
      children: [
        Icon(
          Icons.check_circle,
          size: 15,
          color: neet ? textColor : accentColor,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: neet ? textColor : accentColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.57,
            ),
          ),
        ),
      ],
    );
  }
}

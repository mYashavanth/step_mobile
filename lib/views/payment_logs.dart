import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ghastep/views/urlconfig.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

class PaymentLogsPage extends StatefulWidget {
  const PaymentLogsPage({Key? key}) : super(key: key);

  @override
  _PaymentLogsPageState createState() => _PaymentLogsPageState();
}

class _PaymentLogsPageState extends State<PaymentLogsPage> {
  final storage = const FlutterSecureStorage();
  List<dynamic> paymentHistory = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchPaymentHistory();
  }

  Future<void> fetchPaymentHistory() async {
    try {
      final String token = await storage.read(key: 'token') ?? '';
      if (token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('$baseurl/app/app-purchase/user-purchase-history/$token'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          paymentHistory = data;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load payment history');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  String _getPaymentStatusText(int status) {
    switch (status) {
      case 0:
        return 'Failed';
      case 1:
        return 'Completed';
      default:
        return 'Unknown';
    }
  }

  Color _getPaymentStatusColor(int status) {
    switch (status) {
      case 0:
        return Colors.redAccent;
      case 1:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(String? dateStr, String? timeStr) {
    try {
      if (dateStr == null || timeStr == null) return 'N/A';

      // Parse the date string (e.g., "Thu, 19 Jun 2025 00:00:00 GMT")
      final date = DateFormat('EEE, dd MMM yyyy HH:mm:ss').parse(dateStr);

      // Parse the time string (e.g., "12:00:55")
      final timeParts = timeStr.split(':');
      final time = TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      );

      // Combine date and time
      final combinedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );

      // Format as "19 Jun 2025, 12:00 PM"
      return DateFormat('dd MMM yyyy, hh:mm a').format(combinedDateTime);
    } catch (e) {
      return '${dateStr?.split(',').last.trim()} at $timeStr'; // Fallback to original format
    }
  }

  String _formatValidTill(String? validTillStr) {
    if (validTillStr == null) return 'N/A';

    try {
      final date = DateTime.parse(validTillStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return validTillStr; // Return original if parsing fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment History'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : paymentHistory.isEmpty
                  ? const Center(child: Text('No payment history found'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: paymentHistory.length,
                      itemBuilder: (context, index) {
                        final payment = paymentHistory[index];
                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      payment['course_name'] ?? 'N/A',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: _getPaymentStatusColor(
                                            payment['payment_status'] ?? -1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        _getPaymentStatusText(
                                            payment['payment_status'] ?? -1),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  payment['price_description'] ?? 'N/A',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Text(
                                      '₹${payment['selling_price_inr']}',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '₹${payment['actual_price_inr']}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        decoration: TextDecoration.lineThrough,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const Divider(),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Date',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          _formatDateTime(
                                            payment['created_date'],
                                            payment['created_time'],
                                          ),
                                          style: const TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (payment['no_of_days'] != null &&
                                        payment['no_of_days'] > 0)
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          const Text(
                                            'Valid Till',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            _formatValidTill(
                                                payment['valid_till']),
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                if (payment['phonepay_transaction_id'] != null)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Transaction ID',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        payment['phonepay_transaction_id'],
                                        style: const TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}

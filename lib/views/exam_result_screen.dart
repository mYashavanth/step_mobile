import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ghastep/widgets/common_widgets.dart';
import 'package:ghastep/widgets/exam_result_widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ghastep/views/urlconfig.dart';

class ExamResultScreen extends StatefulWidget {
  const ExamResultScreen({super.key});

  @override
  State<ExamResultScreen> createState() => _ExamResultScreenState();
}

class _ExamResultScreenState extends State<ExamResultScreen> {
  final storage = const FlutterSecureStorage();
  Map<String, dynamic>? resultData;
  bool isLoading = true;
  String? errorMessage;

  // Add this local AppBar builder to resolve the error
  PreferredSizeWidget buildAppBar(BuildContext context, String title) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 1,
      centerTitle: true,
      shadowColor: Colors.grey.withOpacity(0.2),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchExamResults();
  }

  Future<void> _fetchExamResults() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      // Read the stored results JSON
      String? resultsJson = await storage.read(key: "exam_results");

      if (resultsJson != null) {
        setState(() {
          resultData = jsonDecode(resultsJson);
          isLoading = false;
        });
      } else {
        // This case happens if the result wasn't stored correctly
        throw Exception("Could not find exam results. Please try again.");
      }
    } catch (e) {
      print("Error loading exam result data: $e");
      setState(() {
        isLoading = false;
        errorMessage = "An error occurred while loading results: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, "Exam Result"),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : resultData == null
                  ? const Center(child: Text("No result data available."))
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          borderHorizontal(),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  resultData!['exam_title'] ?? 'Exam Result',
                                  style: const TextStyle(
                                    color: Color(0xFF1A1A1A),
                                    fontSize: 20,
                                    fontFamily: 'SF Pro Display',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${resultData!['total_questions']} Questions • ${resultData!['exam_duration_minutes']} minutes • ${resultData!['max_marks']} marks',
                                  style: const TextStyle(
                                    color: Color(0xFF737373),
                                    fontSize: 14,
                                    fontFamily: 'SF Pro Display',
                                    fontWeight: FontWeight.w400,
                                    height: 1.57,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Replace buildButton to fix the arguments error
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/view_exam_solutions_screen',
                                        arguments: {
                                          'solutionData': resultData!['solutions']
                                        },
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF247E80),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                    ),
                                    child: const Text(
                                      "View solutions",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          borderHorizontal(),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Overview',
                                  style: TextStyle(
                                    color: Color(0xFF1A1A1A),
                                    fontSize: 20,
                                    fontFamily: 'SF Pro Display',
                                    fontWeight: FontWeight.w500,
                                    height: 1.40,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Summary of marks scored in your attempt.',
                                  style: TextStyle(
                                    color: Color(0xFF737373),
                                    fontSize: 14,
                                    fontFamily: 'SF Pro Display',
                                    fontWeight: FontWeight.w400,
                                    height: 1.57,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                buildExamResultScreenOverviewtable(resultData!),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                            bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Color(0x0C000000),
                blurRadius: 100,
                offset: Offset(0, -1),
                spreadRadius: 0,
              )
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () {
              Navigator.pushNamed(context, "/home_page");
            },
            child: Container(
              height: 52,
              decoration: ShapeDecoration(
                color: const Color(0xFFC7F3F4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Center(
                child: Text(
                  'Go home',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF247E80),
                    fontSize: 16,
                    fontFamily: 'SF Pro Display',
                    fontWeight: FontWeight.w500,
                    height: 1.50,
                  ),
                ),
              ),
            ),
          ),
        ),
    );
  }
}
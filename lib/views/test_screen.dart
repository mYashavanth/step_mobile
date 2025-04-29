import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:step_mobile/views/dry.dart';
import 'package:step_mobile/widgets/test_screen_widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:step_mobile/views/urlconfig.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() {
    return _TestScreen();
  }
}

class _TestScreen extends State<TestScreen> {
  final storage = const FlutterSecureStorage();
  static List<Map<String, dynamic>> questions = List.generate(
    4,
    (index) => {
      'question':
          'Question ${index + 1}: Which of the following arteries is a direct branch of the external carotid artery?',
      'options': [
        'Middle Meningeal Artery',
        'Inferior Thyroid Artery',
        'Superior Thyroid Artery',
        'Vertebral Artery'
      ],
      'correctAnswer': 'Middle Meningeal Artery',
    },
  );

  final PageController _pageController = PageController();
  int currentPage = 0;
  void nextPage() {
    if (currentPage < questions.length - 1) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void previousPage() {
    if (currentPage > 0) {
      _pageController.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  List<Map> feedbackReviewData = [
    {"name": "Incorrect or incomplete question", "id": 1},
    {"name": "Incorrect or incomplete options", "id": 2},
    {"name": "Formatting or image quality issue", "id": 3},
    {"name": "Other", "id": 4},
  ];

  List<int> selectedReviewoption = [0];

  Future<void> _endTest() async {
    try {
      String? token = await storage.read(key: "token");
      String? preCourseTestTransactionId =
          await storage.read(key: "preCourseTestTransactionId");

      if (token == null || preCourseTestTransactionId == null) {
        print("Missing required data to end the test.");
        return;
      }

      String apiUrl =
          "$baseurl/app/end-pre-course-test/$token/$preCourseTestTransactionId";
      print("API URL: $apiUrl");

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['errFlag'] == 0) {
          print("Test ended successfully: ${data}");
          showCustomSnackBar(
            context: context,
            message: "Test ended successfully",
            isSuccess: true,
          );

          // Navigate to the result screen
          Navigator.pushReplacementNamed(context, "/result_test_screen");
        } else {
          print("Error ending test: ${data}");
          showCustomSnackBar(
            context: context,
            message: data['message'],
            isSuccess: false,
          );
        }
      } else {
        print("Failed to end test. Status code: ${response.statusCode}");
        showCustomSnackBar(
          context: context,
          message: "Failed to end test. Please try again.",
          isSuccess: false,
        );
      }
    } catch (e) {
      print("Error ending test: $e");
      showCustomSnackBar(
        context: context,
        message: "An error occurred: $e",
        isSuccess: false,
      );
    }
  }

  Future<bool> _onWillPop() async {
    // Show the submit test dialog when the user tries to leave the page
    submitTestDialog(context, _endTest);
    return false; // Prevents navigation by default
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: testScreenAppBar(context, _endTest),
        body: PageView.builder(
            controller: _pageController,
            itemCount: questions.length,
            physics:
                const NeverScrollableScrollPhysics(), // Prevent manual swiping
            onPageChanged: (index) {
              setState(() {
                currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return TestScreenWidgets(
                questionData: questions[index],
                index: index,
                questionLength: questions.length,
              );
            }),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Color(0x0C23004C),
                blurRadius: 12,
                offset: Offset(0, -3),
                spreadRadius: 0,
              )
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () {
                  previousPage();
                },
                child: Container(
                  width: 40,
                  height: 40,
                  // padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: ShapeDecoration(
                    color: const Color(0xFFEDEEF0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.arrow_back),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  showModalBottomSheet(
                      isScrollControlled: true,
                      context: context,
                      //  isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) {
                        return StatefulBuilder(builder:
                            (BuildContext context, StateSetter modalSetState) {
                          return buidQuestionReviewBottomSheet(
                              modalSetState,
                              feedbackReviewData,
                              selectedReviewoption,
                              "Select your Course",
                              context);
                        });
                      });
                },
                child: Container(
                  // width: 127,
                  height: 40,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: ShapeDecoration(
                    color: const Color(0x19FE7D14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Mark for review',
                      style: TextStyle(
                        color: Color(0xFFFE7D14),
                        fontSize: 16,
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.w500,
                        height: 1.50,
                      ),
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {},
                child: Container(
                  // width: 121,
                  height: 40,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: ShapeDecoration(
                    color: const Color(0x1931B5B9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Center(
                      child: Text(
                    'Clear selected',
                    style: TextStyle(
                      color: Color(0xFF289799),
                      fontSize: 16,
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w500,
                      height: 1.50,
                    ),
                  )),
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () {
                  nextPage();
                },
                child: Container(
                  width: 40,
                  height: 40,
                  // padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: ShapeDecoration(
                    color: const Color(0xFFEDEEF0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.arrow_forward),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
  final PageController _pageController = PageController();
  int currentPage = 0;
  int totalQuestions = 3; // Hardcoded total number of questions
  List<Map<String, dynamic>> questions = [];
  List<int?> selectedOptions =
      []; // To track selected options for each question
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    // Initialize selectedOptions with null values
    selectedOptions = List<int?>.filled(totalQuestions, null);
    _fetchQuestion(1); // Fetch first question when the screen loads
  }

  Future<void> _fetchQuestion(int questionNo) async {
    if (questionNo > totalQuestions) return;

    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      String? token = await storage.read(key: "token");
      String? preCourseTestId = await storage.read(key: "preCourseTestId");

      if (token == null) {
        print("Missing required data to fetch questions.");
      }

      String apiUrl =
          "$baseurl/app/get-pre-course-test-questions/$token/1/$questionNo";
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is List && data.isNotEmpty) {
          final questionData = data[0];
          List<String> options = [];

          // Extract options from the response
          for (var option in questionData['options']) {
            options.add(option['option_text']);
          }

          // Create question map in the format expected by your TestScreenWidgets
          Map<String, dynamic> question = {
            'question': questionData['question'],
            'options': options,
            'correctAnswer':
                options[0], // Assuming first option is correct for now
            'question_no': questionData['question_no'],
          };

          // If we already have this question (from going back), update it
          bool questionExists = false;
          for (int i = 0; i < questions.length; i++) {
            if (questions[i]['question_no'] == questionNo) {
              questions[i] = question;
              questionExists = true;
              break;
            }
          }

          if (!questionExists) {
            questions.add(question);
          }

          setState(() {
            isLoading = false;
          });
        } else {
          throw Exception("No questions found in response");
        }
      } else {
        throw Exception(
            "Failed to fetch question. Status code: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Error loading question: $e";
      });
      print("Error fetching question: $e");
    }
  }

  // Callback function to update selected option
  void _onOptionSelected(int questionIndex, int optionIndex) {
    setState(() {
      selectedOptions[questionIndex] = optionIndex;
    });

    // Print the selected answer and its ID
    final selectedAnswer = questions[questionIndex]['options'][optionIndex];
    final questionId = questions[questionIndex]['question_no'];
    print("Selected Answer: $selectedAnswer, Question ID: $questionId");
  }

  void nextPage() {
    if (currentPage < totalQuestions - 1) {
      // Check if no option is selected for the current question
      if (selectedOptions[currentPage] == null) {
        final questionId = questions[currentPage]['question_no'];
        print("No option selected for Question ID: $questionId, Answer: 0");
      }

      setState(() {
        currentPage++;
      });
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);

      // Only fetch next question if we don't have it and it exists
      if (currentPage >= questions.length && currentPage < totalQuestions) {
        _fetchQuestion(currentPage + 1); // Questions are 1-indexed
      }
    } else {
      // User is on last question - you could add a submit button here
      submitTestDialog(context, _endTest);
    }
  }

  void previousPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
      });
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
        body: isLoading && questions.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
                ? Center(child: Text(errorMessage!))
                : PageView.builder(
                    controller: _pageController,
                    itemCount: totalQuestions,
                    physics:
                        const NeverScrollableScrollPhysics(), // Prevent manual swiping
                    onPageChanged: (index) {
                      setState(() {
                        currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      // If we're at the last question and have all questions, show it
                      if (index < questions.length) {
                        return TestScreenWidgets(
                          questionData: questions[index],
                          index: index,
                          questionLength: totalQuestions,
                          selectedOption: selectedOptions[index],
                          onOptionSelected: _onOptionSelected,
                        );
                      }
                      // Otherwise show loading only if we're not at the last question
                      return index == totalQuestions - 1
                          ? Container() // Empty container for last question
                          : const Center(child: CircularProgressIndicator());
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
                onTap: () {
                  // Clear selected option for current question
                  setState(() {
                    selectedOptions[currentPage] = null;
                  });
                },
                child: Container(
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
                onTap: currentPage == totalQuestions - 1
                    ? null // Disable the button on the last question
                    : () {
                        nextPage();
                      },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: ShapeDecoration(
                    color: currentPage == totalQuestions - 1
                        ? const Color(0xFFE0E0E0) // Disabled color
                        : const Color(0xFFEDEEF0), // Enabled color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.arrow_forward,
                      color: currentPage == totalQuestions - 1
                          ? Colors.grey // Disabled icon color
                          : Colors.black, // Enabled icon color
                    ),
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

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ghastep/views/dry.dart';
import 'package:ghastep/widgets/test_screen_widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ghastep/views/urlconfig.dart';
import 'dart:async';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});
  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final storage = const FlutterSecureStorage();
  final PageController _pageController = PageController();
  Timer? countdownTimer;
  Duration remainingTime = Duration.zero;
  static Duration? sharedRemainingTime; // Shared state for the timer
  int currentPage = 0;
  int totalQuestions = 3;
  String course_test_question_id = '';
  List<Map<String, dynamic>> questions = [];
  List<int?> selectedOptions =
      []; // To track selected options for each question
  bool isLoading = true;
  String? errorMessage;
  bool isPreCourse = true;

  @override
  void initState() {
    super.initState();
    // Initialize selectedOptions with null values
    selectedOptions = List<int?>.filled(totalQuestions, null);
    _initializeTimer();
    _loadIsPreCourseFlag();
  }

  @override
  void dispose() {
    countdownTimer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  Future<void> _initializeTimer() async {
    if (sharedRemainingTime != null) {
      // Use the shared remaining time if it exists
      remainingTime = sharedRemainingTime!;
    } else {
      // Fetch the duration from Flutter Secure Storage
      String? durationString = await storage.read(key: "test_duration");

      if (durationString != null) {
        int totalMinutes = int.tryParse(durationString) ?? 0;
        setState(() {
          remainingTime = Duration(minutes: totalMinutes);
          sharedRemainingTime = remainingTime; // Save to shared state
        });
      } else {
        setState(() {
          remainingTime = Duration.zero;
        });
      }
    }

    _startCountdown();
  }

  void _startCountdown() {
    countdownTimer?.cancel(); // Cancel any existing timer
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingTime.inSeconds > 0) {
        setState(() {
          remainingTime -= const Duration(seconds: 1);
          sharedRemainingTime = remainingTime; // Update shared state
        });
      } else {
        timer.cancel(); // Stop the timer when it reaches 0
        _handleTimerEnd(); // Handle timer end
      }
    });
  }

  Future<void> _handleTimerEnd() async {
    await _endTest();
    print("+++++++++++++++++++++++++++++++++Timer ended++++++++++++++++++++++++++++++");
    // try {
    //   // End the test and fetch the result
    //   await _endTest();
    // } catch (e) {
    //   print("Error handling timer end: $e");
    //   showCustomSnackBar(
    //     context: context,
    //     message: "An error occurred while ending the test.",
    //     isSuccess: false,
    //   );
    // }
  }

  String _formatDuration(Duration duration) {
    String minutes =
        duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    String seconds =
        duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds mins";
  }

  Future<void> _loadIsPreCourseFlag() async {
    try {
      String? isPreCourseFlag = await storage.read(key: "isPreCourse");
      setState(() {
        isPreCourse = isPreCourseFlag == "true";
      });
      _fetchQuestion(1);
    } catch (e) {
      print("Error loading isPreCourse flag: $e");
      showCustomSnackBar(
        context: context,
        message: "An error occurred while loading test details.",
        isSuccess: false,
      );
    }
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
      String? postCourseTestId = await storage.read(key: "postCourseTestId");

      if (token == null) {
        print("Missing required data to fetch questions.");
      }

      String apiUrl = isPreCourse
          ? "$baseurl/app/get-pre-course-test-questions/$token/1/$questionNo"
          : "$baseurl/app/get-post-course-test-questions/$token/1/$questionNo";
      final response = await http.get(Uri.parse(apiUrl));

      print(response.body);
      print("data printing in fetch question ++++++++++++++++++++++++++++ ^");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        course_test_question_id = isPreCourse
            ? data[0]['pre_course_test_question_id'].toString()
            : data[0]['post_course_test_question_id'].toString();

        if (data is List && data.isNotEmpty) {
          final questionData = data[0];
          List<Map<String, dynamic>> options = [];

          // Extract options from the response including their IDs
          for (var option in questionData['options']) {
            isPreCourse
                ? options.add({
                    'option_text': option['option_text'],
                    'pre_course_test_questions_options_id':
                        option['pre_course_test_questions_options_id'],
                  })
                : options.add({
                    'option_text': option['option_text'],
                    'post_course_test_questions_options_id':
                        option['post_course_test_questions_options_id'],
                  });
          }

          // Create question map in the format expected by your TestScreenWidgets
          Map<String, dynamic> question = {
            'question': questionData['question'],
            'options': options.map((opt) => opt['option_text']).toList(),
            'options_data':
                options, // Store the full options data including IDs
            'correctAnswer': options[0]
                ['option_text'], // Assuming first option is correct for now
            'question_no': questionData['question_no'],
            'course_test_question_id': isPreCourse
                ? questionData['pre_course_test_question_id']
                : questionData['post_course_test_question_id'],
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

  Future<void> _saveResponse(int questionIndex, int? optionIndex) async {
    try {
      String? token = await storage.read(key: "token");
      String? CourseTestTransactionId = await storage.read(
          key: isPreCourse
              ? "preCourseTestTransactionId"
              : "postCourseTestTransactionId");

      if (token == null || CourseTestTransactionId == null) {
        print(token);
        print(CourseTestTransactionId);
        print("Missing required data to save response");
        return;
      }

      if (questionIndex >= questions.length) {
        print("Question data not loaded yet");
        return;
      }

      final question = questions[questionIndex];
      final questionId = question['course_test_question_id'];
      // final optionId = optionIndex != null
      //     ? isPreCourse ? question['options_data'][optionIndex]['pre_course_test_questions_options_id'] : question['options_data'][optionIndex]
      //         ['post_course_test_questions_options_id']
      //     : 0; // 0 means no option selected

      int optionId = 0;
      if (optionIndex != null) {
        optionId = isPreCourse
            ? question['options_data'][optionIndex]
                ['pre_course_test_questions_options_id']
            : question['options_data'][optionIndex]
                ['post_course_test_questions_options_id'];

        print("Selected option ID: $optionId");
      }

      String apiUrl = isPreCourse
          ? "$baseurl/app/save-update-pre-course-test-questions-response/" +
              "$token/$CourseTestTransactionId/$questionId/$optionId"
          : "$baseurl/app/save-update-post-course-test-questions-response/" +
              "$token/$CourseTestTransactionId/$questionId/$optionId";

      final response = await http.get(Uri.parse(apiUrl));

      print(
          "url printing for update answere api +++++++++++ $isPreCourse +++++++++++++++++ $apiUrl");

      print(response.body);
      print(
          "data printing in save response for save and updateing ++++++++++++++++++++++++++++ ^");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        print(data);
        print(
            "data printing in save response for save and updateing ++++++++++++++++++++++++++++ ^");
        if (data['errFlag'] == 0) {
          print("Response saved successfully for question $questionId");
        } else {
          print("Error saving response: ${data['message']}");
        }
      } else {
        print("Failed to save response. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error saving response: $e");
    }
  }

  Future<void> submitReview(
      List<int> selectedOptions, String additionalFeedback) async {
    try {
      // Ensure the current question is loaded
      if (currentPage >= questions.length) {
        print("Question data not loaded yet");
        showCustomSnackBar(
          context: context,
          message: "Please wait while the question loads",
          isSuccess: false,
        );
        return;
      }

      // Fetch required data from storage
      String? token = await storage.read(key: "token");
      String? CourseTestTransactionId = isPreCourse
          ? await storage.read(key: "preCourseTestTransactionId")
          : await storage.read(key: "postCourseTestTransactionId"); 

          print("course test transaction id $isPreCourse : $CourseTestTransactionId");

      if (token == null || CourseTestTransactionId == null) {
        print("Missing required data to submit review");
        showCustomSnackBar(
          context: context,
          message: "Session expired. Please restart the test.",
          isSuccess: false,
        );
        return;
      }

      // Get the current question's ID
      final currentQuestion = questions[currentPage];
      final questionId = currentQuestion['course_test_question_id'];

      if (questionId == null) {
        print("Missing question ID");
        showCustomSnackBar(
          context: context,
          message: "Invalid question data",
          isSuccess: false,
        );
        return;
      }

      // Prepare the feedback type (using the first selected option)
      int feedbackType = selectedOptions.isNotEmpty ? selectedOptions[0] : 0;

      // Construct the API URL
      final apiUrl = isPreCourse ? Uri.parse("$baseurl/app/pre-course-test-mark-review/"+
              "$token/$CourseTestTransactionId/$questionId"): Uri.parse("$baseurl/app/post-course-test-mark-review/"+
              "$token/$CourseTestTransactionId/$questionId");

      // Make the API call
      final response = await http.get(apiUrl);
      print("course-test- transaction id: $CourseTestTransactionId");
      print("question id: $questionId");
      print("feedback type: $feedbackType");
      print(response.body);
      print("data printing in submit review ++++++++++++++++++++++++++++ ^");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['errFlag'] == 0) {
          print("Review submitted successfully");
          if (context.mounted) {
            Navigator.pop(context); // Close the review sheet
            showModalBottomSheet(
              isScrollControlled: true,
              context: context,
              builder: (context) => buildQuestionReportedBotomSheet(context),
            );
          }
        } else {
          print("Error submitting review: ${data['message']}");
          if (context.mounted) {
            showCustomSnackBar(
              context: context,
              message: data['message'] ?? "Failed to submit review",
              isSuccess: false,
            );
          }
        }
      } else {
        throw Exception(
            "Failed to submit review. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error submitting review: $e");
      if (context.mounted) {
        showCustomSnackBar(
          context: context,
          message: "Error submitting review. Please try again.",
          isSuccess: false,
        );
      }
    }
  }

  // Callback function to update selected option
  void _onOptionSelected(int questionIndex, int optionIndex) {
    setState(() {
      selectedOptions[questionIndex] = optionIndex;
    });

    // Save the response to API
    _saveResponse(questionIndex, optionIndex);
  }

  void nextPage() {
    if (currentPage < totalQuestions - 1) {
      setState(() {
        currentPage++;
      });
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);

      // Only fetch the next question if we don't have it and it exists
      if (currentPage >= questions.length && currentPage < totalQuestions) {
        _fetchQuestion(currentPage + 1); // Questions are 1-indexed
      }
    } else {
      // User is on the last question - you could add a submit button here
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
      String? testTransactionId = isPreCourse
          ? await storage.read(key: "preCourseTestTransactionId")
          : await storage.read(key: "postCourseTestTransactionId");

      if (token == null || testTransactionId == null) {
        print("Missing required data to end the test.");
        return;
      }

      // Determine the API endpoint based on isPreCourse flag
      String apiUrl = isPreCourse
          ? "$baseurl/app/end-pre-course-test/$token/$testTransactionId"
          : "$baseurl/app/end-post-course-test/$token/$testTransactionId";

      print("API URL: $apiUrl");

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['errFlag'] == 0) {
          print("Test ended successfully: $data");

          // Reset the timer
          setState(() {
            remainingTime = Duration.zero;
            sharedRemainingTime = null; // Reset shared state
          });

          // Fetch and store the result
          await _fetchTestResults();

          // Navigate to the result screen
          if (context.mounted) {
            Navigator.pushReplacementNamed(context, "/result_test_screen");
          }
        } else {
          print("Error ending test: ${data['message']}");
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

  Future<Map<String, dynamic>?> _fetchTestResults() async {
    try {
      String? token = await storage.read(key: "token");
      bool? isPreCourseFlag = await storage.read(key: "isPreCourse") == "true";
      String? testTransactionId = await storage.read(
          key: isPreCourseFlag
              ? "preCourseTestTransactionId"
              : "postCourseTestTransactionId");

      if (token == null || testTransactionId == null) {
        print("Missing required data to fetch test results.");
        return null;
      }

      String apiUrl = isPreCourseFlag
          ? "$baseurl/app/get-pre-course-test-response/$token/$testTransactionId"
          : "$baseurl/app/get-post-course-test-response/$token/$testTransactionId";

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> resultData = jsonDecode(response.body);

        // Store the results in secure storage
        await storage.write(key: "test_results", value: jsonEncode(resultData));
        print("Test results fetched and stored successfully.");
        return resultData;
      } else {
        print(
            "Failed to fetch test results. Status code: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error fetching test results: $e");
      return null;
    }
  }

  Future<bool> _onWillPop() async {
    // Show the submit test dialog when the user tries to leave the page
    submitTestDialog(context, _endTest);
    return false; // Prevents navigation by default
  }

  Widget _buildBottomNavigationBar() {
    return Container(
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
                  return StatefulBuilder(
                    builder: (BuildContext context, StateSetter modalSetState) {
                      return buidQuestionReviewBottomSheet(
                        modalSetState,
                        feedbackReviewData,
                        selectedReviewoption,
                        "Select your Course",
                        context,
                        onSubmitReview: (selectedOptions, additionalFeedback) {
                          submitReview(selectedOptions, additionalFeedback);
                        }, // Pass the required callback here
                      );
                    },
                  );
                },
              );
            },
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
          // InkWell(
          //   onTap: () {
          //     // Clear selected option for current question
          //     setState(() {
          //       selectedOptions[currentPage] = null;
          //     });
          //     // Save the cleared response
          //     _saveResponse(currentPage, null);
          //   },
          //   child: Container(
          //     height: 40,
          //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          //     decoration: ShapeDecoration(
          //       color: const Color(0x1931B5B9),
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(24),
          //       ),
          //     ),
          //     child: const Center(
          //         child: Text(
          //       'Clear selected',
          //       style: TextStyle(
          //         color: Color(0xFF289799),
          //         fontSize: 16,
          //         fontFamily: 'SF Pro Display',
          //         fontWeight: FontWeight.w500,
          //         height: 1.50,
          //       ),
          //     )),
          //   ),
          // ),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: testScreenAppBar(context, _endTest,
            _formatDuration(remainingTime)), // Pass the formatted time
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
                      if (index < questions.length) {
                        return TestScreenWidgets(
                          questionData: questions[index],
                          index: index,
                          questionLength: totalQuestions,
                          selectedOption: selectedOptions[index],
                          onOptionSelected: _onOptionSelected,
                        );
                      }
                      return index == totalQuestions - 1
                          ? Container()
                          : const Center(child: CircularProgressIndicator());
                    }),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }
}

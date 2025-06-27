import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ghastep/views/dry.dart';
// Assuming you have a similar widgets file for exam, or adapt test_screen_widgets
import 'package:ghastep/widgets/test_screen_widgets.dart' as TestScreenWidgetsImport; // Alias to avoid conflict
import 'package:ghastep/widgets/exam_screen_widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ghastep/views/urlconfig.dart';
import 'dart:async';

class ExamScreen extends StatefulWidget {
  const ExamScreen({super.key});
  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  final storage = const FlutterSecureStorage();
  final PageController _pageController = PageController();
  Timer? countdownTimer;
  Duration remainingTime = Duration.zero;
  static Duration? sharedRemainingTime;
  int currentPage = 0;
  int totalQuestions = 0;
  // String course_test_question_id = ''; // Not used in exam flow directly with this name
  List<Map<String, dynamic>> questions = [];
  List<int?> selectedOptions = [];
  bool isLoading = true;
  String? errorMessage;
  // bool isPreCourse = true; // This screen is specifically for EXAM, so isPreCourse should be false.
                           // We'll rely on a passed argument or a specific storage key for exam context.

  String? examId; // To be passed from before_enter_exam_screen
  String? examTransactionId; // To be fetched or passed

  @override
  void initState() {
    super.initState();
    // Arguments are expected to be passed from BeforeEnterExamScreen
    // containing examId and examTransactionId
    Future.delayed(Duration.zero, () {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        examId = args['examId']?.toString();
        examTransactionId = args['examTransactionId']?.toString();
        print("ExamScreen initState: examId: $examId, examTransactionId: $examTransactionId");
      } else {
        print("ExamScreen initState: ERROR - Arguments are null!");
        setState(() {
          isLoading = false;
          errorMessage = "Error: Exam details not found. Please go back and try again.";
        });
        return;
      }

      if (examId == null || examTransactionId == null) {
         print("ExamScreen initState: ERROR - examId or examTransactionId is null from arguments!");
         setState(() {
          isLoading = false;
          errorMessage = "Error: Invalid exam session. Please go back and try again.";
        });
        return;
      }

      _loadTotalQuestions().then((_) {
        _initializeTimer();
        _fetchQuestion(1); // Fetch the first question
      });
    });
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeTimer() async {
    if (sharedRemainingTime != null) {
      remainingTime = sharedRemainingTime!;
    } else {
      String? durationString = await storage.read(key: "exam_duration_minutes"); // Use a specific key for exam duration
      if (durationString != null) {
        int totalMinutes = int.tryParse(durationString) ?? 0;
        setState(() {
          remainingTime = Duration(minutes: totalMinutes);
          sharedRemainingTime = remainingTime;
        });
      } else {
        print("No exam duration found in storage, defaulting to 30 minutes");
        setState(() { // Default if not found
          remainingTime = const Duration(minutes: 30);
          sharedRemainingTime = remainingTime;
        });
      }
    }
    _startCountdown();
  }

  void _startCountdown() {
    countdownTimer?.cancel(); // Cancel any existing timer
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          if (remainingTime.inSeconds > 0) {
            remainingTime = remainingTime - const Duration(seconds: 1);
            sharedRemainingTime = remainingTime; // Update shared state
          } else {
            countdownTimer?.cancel();
            _endTest(timeUp: true); // Auto-submit if time is up
          }
        });
      } else {
        countdownTimer?.cancel();
      }
    });
  }

  String _formatDuration(Duration duration) {
    String minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    String seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds mins";
  }

  Future<void> _loadTotalQuestions() async {
    String? totalQuestionsStr = await storage.read(key: "exam_total_questions"); // Use specific key
    setState(() {
      totalQuestions = int.tryParse(totalQuestionsStr ?? '') ?? 0;
      if (totalQuestions > 0) {
        selectedOptions = List<int?>.filled(totalQuestions, null);
      } else {
        errorMessage = "Number of questions not found.";
      }
      print("Total exam questions: $totalQuestions");
    });
  }

  Future<void> _fetchQuestion(int questionNo) async {
    if (questionNo > totalQuestions || examId == null) {
      print("Cannot fetch question: questionNo $questionNo > totalQuestions $totalQuestions or examId is null");
      return;
    }

    // Check if question already fetched
    if (questions.any((q) => q['question_no'] == questionNo)) {
        print("Question $questionNo already fetched.");
        return;
    }

    // Only set isLoading for the very first fetch. For subsequent fetches,
    // the PageView remains visible, showing a loader for the specific page.
    if (questions.isEmpty) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    try {
      String? token = await storage.read(key: "token");
      if (token == null) {
        throw Exception("Authentication token not found.");
      }

      // API for exam questions: /app/exam/get-exam-questions/{exam_id}/{question_no}
      String apiUrl = "$examurl/app/exam/get-exam-questions/$examId/$questionNo";
      print("Fetching exam question from API URL: $apiUrl");

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {"Authorization": "Bearer $token"},
      );

      print("API Response for exam question $questionNo: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          final questionData = data[0]; // Assuming API returns a list with one question object

          List<Map<String, dynamic>> options = [];
          if (questionData['options'] != null && questionData['options'] is List) {
            for (var option in questionData['options']) {
              options.add({
                'option_text': option['option_text'],
                'id': option['exam_option_id'], // Correct key for exam option ID
              });
            }
          }

          Map<String, dynamic> question = {
            'question': questionData['question'], // The JSON string for the question body
            'options_data': options,
            'question_no': questionData['question_no'],
            'exam_question_id': questionData['exam_question_id'], // Correct key for exam question ID
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
            questions.sort((a, b) => (a['question_no'] as int).compareTo(b['question_no'] as int)); // Keep sorted
          }


          setState(() {
            // This ensures the main loading indicator is turned off after the first question is loaded.
            isLoading = false;
          });
        } else {
          throw Exception("No question data found in response for question $questionNo");
        }
      } else {
        throw Exception("Failed to fetch exam question $questionNo. Status code: ${response.statusCode}, Body: ${response.body}");
      }
    } catch (e) {
      print("Error fetching exam question: $e");
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = "Error loading question: $e";
        });
      }
    }
  }

  Future<void> _saveResponse(int questionIndex, int? optionIndexInWidget) async {
    if (examTransactionId == null) {
      print("Error saving response: examTransactionId is null.");
      if(mounted) showCustomSnackBar(context: context, message: "Exam session error. Cannot save.", isSuccess: false);
      return;
    }
    if (questionIndex < 0 || questionIndex >= questions.length) {
      print("Error saving response: Invalid questionIndex $questionIndex for questions length ${questions.length}");
      return;
    }

    final question = questions[questionIndex];
    final examQuestionId = question['exam_question_id'];

    if (examQuestionId == null) {
        print("Error saving response: exam_question_id is null for question at index $questionIndex");
        if(mounted) showCustomSnackBar(context: context, message: "Invalid question data. Cannot save.", isSuccess: false);
        return;
    }

    int? apiExamOptionId;

    if (optionIndexInWidget != null &&
        optionIndexInWidget >= 0 &&
        (question['options_data'] as List).isNotEmpty &&
        optionIndexInWidget < (question['options_data'] as List).length) {
      final selectedOptionData = question['options_data'][optionIndexInWidget];
      if (selectedOptionData != null && selectedOptionData['id'] != null) {
        apiExamOptionId = selectedOptionData['id'] as int?;
        if (apiExamOptionId == null) {
          print("Error: Selected option ID is null after cast. Option data: $selectedOptionData");
        }
      } else {
        print("Error: Selected option data or its 'id' is null. Option data: $selectedOptionData");
      }
    } else if (optionIndexInWidget == null) {
      // Answer is cleared. API expects an examOptionId.
      // For "exam", if clearing means "no option selected", the API might expect 0 or a specific value.
      // Or, it might expect this call not to be made / a different call.
      // Let's assume 0 for now if the API is designed to handle it for clearing.
      // THIS NEEDS CONFIRMATION WITH YOUR BACKEND API SPECIFICATION for the save-update-exam-response endpoint.
      apiExamOptionId = 0; // Placeholder: Confirm with backend if 0 means "cleared" or "unanswered"
      print("Clearing response for exam question $examQuestionId, using option ID $apiExamOptionId");
    }

    if (apiExamOptionId == null) {
      print("Error: apiExamOptionId is null before API call. Cannot save response.");
       if(mounted) showCustomSnackBar(context: context, message: "Error selecting option. Cannot save.", isSuccess: false);
      return;
    }

    try {
      String? token = await storage.read(key: "token");
      if (token == null) {
        throw Exception("Authentication token not found.");
      }

      // Add a timestamp as a query parameter to prevent GET request caching
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      String apiUrl = "$examurl/app/exam/save-update-exam-response/$examTransactionId/$examQuestionId/$apiExamOptionId?t=$timestamp";
      print("Saving exam response to API URL: $apiUrl");

      final response = await http.get( // Assuming GET, adjust if POST/PUT
        Uri.parse(apiUrl),
        headers: {"Authorization": "Bearer $token"},
      );

      print("Save exam response API Response: ${response.body}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['errFlag'] == 0) {
          print("Exam response saved successfully for question $examQuestionId");
        } else {
          print("Error saving exam response: ${data['message']}");
          if(mounted) showCustomSnackBar(context: context, message: "Error saving: ${data['message']}", isSuccess: false);
        }
      } else {
        print("Failed to save exam response. Status code: ${response.statusCode}, Body: ${response.body}");
        if(mounted) showCustomSnackBar(context: context, message: "Server error saving response.", isSuccess: false);
      }
    } catch (e) {
      print("Error saving exam response: $e");
      if(mounted) showCustomSnackBar(context: context, message: "An error occurred while saving.", isSuccess: false);
    }
  }

  Future<void> _submitReview(List<int> selectedReviewOptions, String additionalFeedback) async {
    // This function needs to be adapted for the "Exam" flow if review functionality is required.
    // It would use exam_transaction_id and exam_question_id, and the exam-specific mark-review API.
    // For now, let's print a placeholder message.
    print("Submit Review for Exam: Not yet fully implemented for exam flow.");
    print("Selected Review Options: $selectedReviewOptions, Feedback: $additionalFeedback");

    if (currentPage >= questions.length || examTransactionId == null) {
        print("Cannot submit review: Question data not loaded or exam session invalid.");
        if(mounted) showCustomSnackBar(context: context, message: "Cannot submit review now.", isSuccess: false);
        return;
    }
    final currentQuestion = questions[currentPage];
    final currentExamQuestionId = currentQuestion['exam_question_id'];

    if (currentExamQuestionId == null) {
        print("Cannot submit review: currentExamQuestionId is null.");
        if(mounted) showCustomSnackBar(context: context, message: "Invalid question data for review.", isSuccess: false);
        return;
    }
    
    // Example: /app/exam/mark-exam-question-review/{exam_transaction_id}/{exam_question_id}/{feedback_type_id}
    // You'll need to define how feedback_type_id is determined from selectedReviewOptions
    // and if additionalFeedback is sent in the body or as a query param.
    // This is a simplified example.

    // For now, just showing a message.
    if(mounted) {
        showCustomSnackBar(context: context, message: "Review submitted (placeholder).", isSuccess: true);
        Navigator.pop(context); // Close the review sheet
         showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            builder: (context) => TestScreenWidgetsImport.buildQuestionReportedBotomSheet(context), // Using aliased import
        );
    }
  }


  void _onOptionSelected(int questionIndexInPage, int optionIndexInWidget) {
     if (questionIndexInPage < 0 || questionIndexInPage >= totalQuestions) return;
    setState(() {
      selectedOptions[questionIndexInPage] = optionIndexInWidget;
    });
    _saveResponse(questionIndexInPage, optionIndexInWidget);
  }

  void nextPage() async {
    // If on the last question, show the submit confirmation dialog.
    if (currentPage == totalQuestions - 1) {
      final attemptedQuestions = selectedOptions.where((o) => o != null).length;
      submitExamDialog(
        context,
        () => _endTest(timeUp: false),
        totalQuestions,
        attemptedQuestions,
      );
      return;
    }

    // If not on the last question, proceed to the next one.
    if (currentPage < totalQuestions - 1) {
      // Pre-fetch the next question's data before animating.
      await _fetchQuestion(currentPage + 2);

      if (mounted) {
        // Animate to the next page. onPageChanged will update the state.
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void previousPage() {
    if (currentPage > 0) {
      // Animate to the previous page. onPageChanged will update the state.
      _pageController.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  List<Map<String, dynamic>> feedbackReviewData = [ // Keep or adapt as needed
    {"name": "Incorrect or incomplete question", "id": 1},
    {"name": "Incorrect or incomplete options", "id": 2},
    {"name": "Formatting or image quality issue", "id": 3},
    {"name": "Other", "id": 4},
  ];
  List<int> selectedReviewoption = [0];

  Future<void> _endTest({bool timeUp = false}) async {
    try {
      String? token = await storage.read(key: "token");
      if (token == null || examTransactionId == null) {
        print("Missing required data to end the exam.");
        return;
      }

      String apiUrl = "$examurl/app/exam/end-exam/$examTransactionId";
      print("Ending exam with API URL: $apiUrl");

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {"Authorization": "Bearer $token"},
      );

      print("End exam API Response: ${response.body}");
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['errFlag'] == 0) {
        print("Exam ended successfully: $data");
        countdownTimer?.cancel();
        setState(() {
          remainingTime = Duration.zero;
        });

        // Fetch and store the result BEFORE navigating
        await _fetchExamResults();

        if (mounted) {
          Navigator.pushReplacementNamed(context, "/exam_result_screen");
        }
      } else {
        print("Error ending exam: ${data['message']}");
        if (mounted) {
          showCustomSnackBar(
            context: context,
            message: data['message'] ?? "Failed to end exam.",
            isSuccess: false,
          );
        }
      }
    } catch (e) {
      print("Error ending exam: $e");
      if (mounted) {
        showCustomSnackBar(
          context: context,
          message: "An error occurred while ending the exam.",
          isSuccess: false,
        );
      }
    }
  }

  // Add this new function to fetch and store results
  Future<void> _fetchExamResults() async {
    try {
      String? token = await storage.read(key: "token");
      if (token == null || examTransactionId == null) {
        print("Missing required data to fetch exam results.");
        return;
      }

      String apiUrl = "$examurl/app/exam/get-exam-response/$examTransactionId";
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final resultData = jsonDecode(response.body);
        if (resultData['errFlag'] == 0) {
          // Store the results payload in secure storage
          await storage.write(
              key: "exam_results", value: jsonEncode(resultData['data']));
          print("Exam results fetched and stored successfully.");
        } else {
          print("API error fetching exam results: ${resultData['message']}");
        }
      } else {
        print(
            "Failed to fetch exam results. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching exam results: $e");
    }
  }

  Future<bool> _onWillPop() async {
    final attemptedQuestions = selectedOptions.where((o) => o != null).length;
    submitExamDialog(
      context,
      () => _endTest(timeUp: false),
      totalQuestions,
      attemptedQuestions,
    );
    return false;
  }

  Widget _buildBottomNavigationBar() {
    // This can be adapted from test_screen_widgets.dart or a new exam_screen_widgets.dart
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Color(0x0C23004C), blurRadius: 12, offset: Offset(0, -3))
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: currentPage == 0 ? null : previousPage,
            child: Container(
              width: 40, height: 40,
              decoration: ShapeDecoration(
                color: currentPage == 0 ? Colors.grey.shade300 : const Color(0xFFEDEEF0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              child: Center(child: Icon(Icons.arrow_back, color: currentPage == 0 ? Colors.grey.shade600 : Colors.black)),
            ),
          ),
          InkWell( // Mark for review - adapt if needed
            onTap: () {
              showModalBottomSheet(
                isScrollControlled: true, context: context, backgroundColor: Colors.transparent,
                builder: (context) {
                  return StatefulBuilder(
                    builder: (BuildContext context, StateSetter modalSetState) {
                      return TestScreenWidgetsImport.buidQuestionReviewBottomSheet( // Using aliased import
                        modalSetState, feedbackReviewData, selectedReviewoption,
                        "Report issue with this question", context,
                        onSubmitReview: (selectedOpts, feedback) => _submitReview(selectedOpts, feedback),
                      );
                    },
                  );
                },
              );
            },
            child: Container(
              height: 40, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: ShapeDecoration(
                color: const Color(0x19FE7D14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              child: const Center(child: Text('Mark for review', style: TextStyle(color: Color(0xFFFE7D14), fontSize: 16, fontWeight: FontWeight.w500))),
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: nextPage, // nextPage handles submit on last question
            child: Container(
              width: 40, height: 40,
              decoration: ShapeDecoration(
                color: const Color(0xFFEDEEF0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              child: Center(child: Icon(currentPage == totalQuestions - 1 ? Icons.check : Icons.arrow_forward, color: Colors.black)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final attemptedQuestions = selectedOptions.where((o) => o != null).length;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: buildExamAppBar(
          context: context,
          remainingTime: remainingTime,
          formatDuration: _formatDuration,
          totalQuestions: totalQuestions,
          attemptedQuestions: attemptedQuestions,
          endExam: () => _endTest(timeUp: false),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
                ? Center(child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontSize: 16)),
                  ))
                : PageView.builder(
                    controller: _pageController,
                    itemCount: totalQuestions > 0 ? totalQuestions : 1, // Show at least 1 page for error message if no questions
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) {
                      // This callback is the single source of truth for the current page.
                      setState(() {
                        currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      if (totalQuestions == 0 && errorMessage != null) {
                        return Center(child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontSize: 16)),
                        ));
                      }
                      if (index < questions.length) {
                        // Use a new ExamScreenQuestionWidget or adapt TestScreenWidgets
                        return ExamScreenQuestionWidget( // We'll create this widget
                          questionData: questions[index],
                          questionIndexInPage: index, // This is the current page index
                          totalQuestions: totalQuestions,
                          selectedOptionIndex: selectedOptions[index],
                          onOptionSelected: (optionIdx) => _onOptionSelected(index, optionIdx),
                        );
                      }
                      // Show loading for pages not yet fetched
                      return const Center(child: CircularProgressIndicator());
                    }),
        bottomNavigationBar: totalQuestions > 0 ? _buildBottomNavigationBar() : null,
      ),
    );
  }
}

// Placeholder for ExamScreenQuestionWidget - you'll need to create this
// It will be very similar to TestScreenWidgets from test_screen_widgets.dart
// but tailored for the exam question data structure if different.
// For now, let's assume it's similar enough that you can adapt TestScreenWidgets.
// You would create lib/widgets/exam_screen_widgets.dart
// and put a widget like ExamScreenQuestionWidget there.
// For this example, I'll assume you'll create it based on TestScreenWidgets.
// If TestScreenWidgets is generic enough, you might be able to reuse it directly
// by passing the correct data.
// The key is that `onOptionSelected` in `ExamScreenQuestionWidget`
// should call `_onOptionSelected(questionIndexInPage, optionIndexInWidget)`
// where `questionIndexInPage` is the `index` from the PageView.builder.

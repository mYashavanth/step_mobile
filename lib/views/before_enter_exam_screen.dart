import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ghastep/views/before_enter_test_screen.dart';
import 'package:ghastep/views/dry.dart';
import 'package:ghastep/widgets/common_widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:ghastep/views/urlconfig.dart';

class BeforeEnterExamScreen extends StatefulWidget {
  const BeforeEnterExamScreen({super.key});

  @override
  State<BeforeEnterExamScreen> createState() => _BeforeEnterExamScreenState();
}

class _BeforeEnterExamScreenState extends State<BeforeEnterExamScreen> {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  Map<String, dynamic> examData = {}; // Changed from testData to examData
  // bool isPreCourse = true; // This screen is for EXAM, so isPreCourse is false.
  bool _isLoading = true; // For loading test details
  bool _isStartingTest = false; // For loading when starting test

  String? courseStepDetailIdForExam; // To store the passed argument

  @override
  void initState() {
    super.initState();
    // Fetch arguments passed to this screen
    Future.delayed(Duration.zero, () {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      if (args != null && args.containsKey('courseStepDetailId')) {
        courseStepDetailIdForExam = args['courseStepDetailId']?.toString();
        print("BeforeEnterExamScreen initState: courseStepDetailIdForExam: $courseStepDetailIdForExam");
        _fetchExamDetails();
      } else {
        print("BeforeEnterExamScreen initState: ERROR - courseStepDetailId not passed!");
        setState(() {
          _isLoading = false;
          examData = {'error': 'Required information missing to load exam details.'};
        });
         if(mounted){
          showCustomSnackBar(context: context, message: "Error: Could not load exam details. Please go back.", isSuccess: false);
        }
      }
    });
  }

  Future<void> _fetchExamDetails() async {
    if (courseStepDetailIdForExam == null) {
      print("Cannot fetch exam details: courseStepDetailIdForExam is null.");
      setState(() => _isLoading = false);
      return;
    }
    setState(() => _isLoading = true);
    try {
      String? token = await storage.read(key: "token");
      if (token == null) {
        throw Exception("Authentication token not found.");
      }

      // API for exam details: /app/exam/get-exam-by-course-step-details-id/{course_step_details_id}
      // This API does not require token in path based on your logs, but in header.
      String apiUrl = "$examurl/app/exam/get-exam-by-course-step-details-id/$courseStepDetailIdForExam";
      print("Fetching exam details from API URL: $apiUrl");

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {"Authorization": "Bearer $token"},
      );

      print("Fetch exam details API Response: ${response.body}");
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          setState(() {
            examData = data[0];
            _isLoading = false;
          });
          // Store exam duration and total questions for ExamScreen
          await storage.write(key: "exam_duration_minutes", value: examData['exam_duration_minutes']?.toString() ?? '30');
          await storage.write(key: "exam_total_questions", value: examData['no_of_questions']?.toString() ?? '0');
          await storage.write(key: "current_exam_id", value: examData['id']?.toString()); // Store exam_id
        } else {
          throw Exception("No exam data found in response.");
        }
      } else {
        throw Exception("Failed to fetch exam details. Status: ${response.statusCode}, Body: ${response.body}");
      }
    } catch (e) {
      print("Error fetching exam details: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          examData = {'error': e.toString()};
        });
        showCustomSnackBar(context: context, message: "Error loading exam details: ${e.toString()}", isSuccess: false);
      }
    }
  }

Future<bool> _endOngoingExam(String ongoingExamTransactionId) async {
  try {
    String? token = await storage.read(key: "token");
    if (token == null) {
      throw Exception("Authentication token not found.");
    }

    String apiUrl = "$examurl/app/exam/end-exam/$ongoingExamTransactionId";
    print("Ending ongoing exam with API URL: $apiUrl");

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {"Authorization": "Bearer $token"},
    );

    print("End ongoing exam API Response: ${response.body}");
    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['errFlag'] == 0) {
      print("Ongoing exam ended successfully: $data");
      return true;
    } else {
      print("Error ending ongoing exam: ${data['message']}");
      if (mounted) {
        showCustomSnackBar(
          context: context,
          message: data['message'] ?? "Failed to end ongoing exam.",
          isSuccess: false,
        );
      }
      return false;
    }
  } catch (e) {
    print("Error ending ongoing exam: $e");
    if (mounted) {
      showCustomSnackBar(
        context: context,
        message: "An error occurred while ending the ongoing exam.",
        isSuccess: false,
      );
    }
    return false;
  }
}

 Future<void> _startExam() async {
  if (examData['id'] == null) {
    print("Cannot start exam: examData['id'] is null.");
    showCustomSnackBar(context: context, message: "Exam details not loaded properly.", isSuccess: false);
    return;
  }
  setState(() => _isStartingTest = true);
  try {
    String? token = await storage.read(key: "token");
    String? currentExamId = examData['id'].toString();

    if (token == null) {
      throw Exception("Authentication token not found.");
    }

    String apiUrl = "$examurl/app/exam/start-exam/$currentExamId";
    print("Starting exam with API URL: $apiUrl");

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {"Authorization": "Bearer $token"},
    );

    print("Start exam API Response: ${response.body}");
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['errFlag'] == 0 && data['exam_transaction_id'] != null) {
        String examTransactionId = data['exam_transaction_id'].toString();
        print("Exam started successfully. Transaction ID: $examTransactionId");
        await storage.write(key: "current_exam_transaction_id", value: examTransactionId);

        if (mounted) {
          showCustomSnackBar(context: context, message: "Exam started successfully.", isSuccess: true);
          Navigator.pushNamed(
            context,
            "/exam_screen",
            arguments: {
              'examId': currentExamId,
              'examTransactionId': examTransactionId,
            },
          );
        }
      } else if (data['errFlag'] == 1 &&
                 data['message'] == "Cannot start again, exam already started" &&
                 data['exam_transaction_id'] != null) {
        String ongoingExamTransactionId = data['exam_transaction_id'].toString();
        print("Ongoing exam detected. Transaction ID: $ongoingExamTransactionId");
        bool endedSuccessfully = await _endOngoingExam(ongoingExamTransactionId);
        if (endedSuccessfully) {
          print("Retrying to start new exam after ending ongoing exam.");
          await _startExam(); // Retry starting the new exam
        } else {
          if (mounted) {
            showCustomSnackBar(
              context: context,
              message: "Failed to end ongoing exam. Cannot start new exam.",
              isSuccess: false,
            );
          }
        }
      } else {
        throw Exception("Error starting exam: ${data['message'] ?? 'Unknown error from server.'}");
      }
    } else {
      throw Exception("Failed to start exam. Status: ${response.statusCode}, Body: ${response.body}");
    }
  } catch (e) {
    print("Error starting exam: $e");
    if (mounted) {
      showCustomSnackBar(context: context, message: "Error starting exam: ${e.toString()}", isSuccess: false);
    }
  } finally {
    if (mounted) {
      setState(() => _isStartingTest = false);
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : examData.containsKey('error')
              ? Center(child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text("Error: ${examData['error']}", style: const TextStyle(color: Colors.red, fontSize: 16), textAlign: TextAlign.center),
                ))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SafeArea(
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios_new),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Display Exam Title and Details
                            Text(
                              // Use a generic title or step context if available
                              "SUBJECT TEST • ${examData['exam_title']?.split(' ').first ?? 'General'} - STEP ${examData['step_no'] ?? 'N/A'}",
                              style: const TextStyle(color: Color(0xFFFE860A), fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              examData['exam_title'] ?? 'Exam Title Not Available',
                              style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 20, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              // "Description or subject name here"
                              "${examData['no_of_questions'] ?? 'N/A'} Questions • ${examData['exam_duration_minutes'] ?? 'N/A'} minutes",
                              style: const TextStyle(color: Color(0xFF737373), fontSize: 14),
                            ),
                            const SizedBox(height: 20),
                            // Exam Details Card
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: ShapeDecoration(
                                color: const Color(0x0CFE860A), // Light orange accent for exam
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(width: 1, color: Color(0xFFFEB16A)),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Exam details', style: TextStyle(color: Color(0xFF1A1A1A), fontSize: 20, fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 12),
                                  _buildDetailRow(Icons.help_outline, '${examData['no_of_questions'] ?? 'N/A'} full-length questions, ${examData['max_marks'] ?? 'N/A'} marks'),
                                  _buildDetailRow(Icons.trending_up, 'All India & State Rankings'), // Placeholder
                                  _buildDetailRow(Icons.assignment, 'Latest exam pattern-based'), // Placeholder
                                ],
                              ),
                            ),
                            borderHorizontal(),
                            // Syllabus Section
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Syllabus', style: TextStyle(color: Color(0xFF1A1A1A), fontSize: 20, fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 12),
                                  if (examData['syllabus_text_line_1'] != null && examData['syllabus_text_line_1'].isNotEmpty)
                                    listViewWithDot(examData['syllabus_text_line_1']),
                                  if (examData['syllabus_text_line_2'] != null && examData['syllabus_text_line_2'].isNotEmpty)
                                    listViewWithDot(examData['syllabus_text_line_2']),
                                  if (examData['syllabus_text_line_3'] != null && examData['syllabus_text_line_3'].isNotEmpty)
                                    listViewWithDot(examData['syllabus_text_line_3']),
                                  if ((examData['syllabus_text_line_1'] == null || examData['syllabus_text_line_1'].isEmpty) &&
                                      (examData['syllabus_text_line_2'] == null || examData['syllabus_text_line_2'].isEmpty) &&
                                      (examData['syllabus_text_line_3'] == null || examData['syllabus_text_line_3'].isEmpty))
                                    const Text("Syllabus details not available.", style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                            ),
                            borderHorizontal(),
                            // Instructions Section
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Instructions', style: TextStyle(color: Color(0xFF1A1A1A), fontSize: 20, fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 12),
                                  listViewWithDot("+${examData['marks_per_question'] ?? 'N/A'} marks for each correct answer"),
                                  listViewWithDot("${examData['negative_marks'] ?? 'N/A'} negative marks for every incorrect answer."),
                                  listViewWithDot("No marks will be deducted for unattempted questions."),
                                  // listViewWithDot("Tie-breaking criteria include the number of correct responses and candidate age."),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: ElevatedButton(
          onPressed: (_isLoading || _isStartingTest || examData.containsKey('error')) ? null : _startExam,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            backgroundColor: const Color(0xFFFE860A), // Exam accent color
            disabledBackgroundColor: const Color(0xFFFE860A).withOpacity(0.7),
          ),
          child: _isStartingTest
              ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
              : const Text('Start Exam', style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFE860A), size: 20), // Exam accent color
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 16))),
        ],
      ),
    );
  }
}
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ghastep/views/dry.dart';
import 'package:ghastep/widgets/common_widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:ghastep/views/urlconfig.dart';

class BeforeEnterTestScreen extends StatefulWidget {
  const BeforeEnterTestScreen({super.key});

  @override
  State<BeforeEnterTestScreen> createState() => _BeforeEnterTestScreen();
}

class _BeforeEnterTestScreen extends State<BeforeEnterTestScreen> {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  Map<String, dynamic> testData = {};
  bool isPreCourse = true; // Default to pre-course test

  @override
  void initState() {
    super.initState();
    _loadIsPreCourseFlag(); // Load the isPreCourse flag from secure storage
  }

  Future<void> _loadIsPreCourseFlag() async {
    try {
      String? isPreCourseFlag = await storage.read(key: "isPreCourse");
      setState(() {
        isPreCourse = isPreCourseFlag == "true"; // Convert string to boolean
      });
      _fetchTestDetails(); // Fetch test details after loading the flag
    } catch (e) {
      print("Error loading isPreCourse flag: $e");
      showCustomSnackBar(
        context: context,
        message: "An error occurred while loading test details.",
        isSuccess: false,
      );
    }
  }

  Future<void> _fetchTestDetails() async {
    try {
      // Retrieve values from Flutter Secure Storage
      String? token = await storage.read(key: "token");
      String? courseStepDetailsId =
          await storage.read(key: "courseStepDetailId");
      String? stepNo = await storage.read(key: "selectedStepNo");

      // Ensure all required values are available
      if (token == null || courseStepDetailsId == null || stepNo == null) {
        if (token == null) print("Token is null");
        if (courseStepDetailsId == null) print("courseStepDetailsId is null");
        if (stepNo == null) print("stepNo is null");
        print("Missing required data in Flutter Secure Storage.");
        return;
      }

      // Determine the API endpoint based on isPreCourse flag
      //  String apiUrl = isPreCourse
      //     ? "$baseurl/app/get-pre-course-test-by-course-step-details-id/$token/$courseStepDetailsId/$stepNo"
      //     : "$baseurl/app/get-post-course-test-by-course-step-details-id/$token/$courseStepDetailsId/$stepNo";
      String apiUrl = isPreCourse
          ? "$baseurl/app/get-pre-course-test-by-course-step-details-id/$token/$courseStepDetailsId"
          : "$baseurl/app/get-post-course-test-by-course-step-details-id/$token/$courseStepDetailsId/$stepNo";

      print("API URL: $apiUrl");

      // Make the GET request
      final response = await http.get(Uri.parse(apiUrl));

      // Check the response status
      if (response.statusCode == 200) {
        print("API Response: ${response.body}");
        final data = jsonDecode(response.body);

        // Store the test title in Flutter Secure Storage
        await storage.write(
          key: "test_title",
          value: isPreCourse
              ? data[0]["pre_course_test_title"]
              : data[0]["post_course_test_title"],
        );

          await storage.write(
            key: isPreCourse ? "preCourseTestId" : "postCourseTestId",
            value: testData['id'].toString(),
          );

        setState((){
          testData = data.isNotEmpty ? data[0] : {};
        });
      } else {
        print("Failed to fetch data. Status code: ${response.statusCode}");
        showCustomSnackBar(
          context: context,
          message: "Failed to fetch data. Please try again.",
          isSuccess: false,
        );
      }
    } catch (e) {
      print("Error fetching test details: $e");
      showCustomSnackBar(
        context: context,
        message: "An error occurred: $e",
        isSuccess: false,
      );
    }
  }

  Future<void> _startTest() async {
    try {
      String? token = await storage.read(key: "token");
      String? testId = testData['id'].toString();

      if (token == null || testId == null) {
        print("Missing required data to start the test.");
        return;
      }

      // Determine the API endpoint based on isPreCourse flag
      String apiUrl = isPreCourse
          ? "$baseurl/app/start-pre-course-test/$token/$testId"
          : "$baseurl/app/start-post-course-test/$token/$testId";

      print("API URL: $apiUrl");

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data);

        if (data['errFlag'] == 0) {
          print("Test started successfully: $data");

          // Save the transaction ID to secure storage
          await storage.write(
              key: isPreCourse
                  ? "preCourseTestTransactionId"
                  : "postCourseTestTransactionId",
              value: isPreCourse
                  ? data['pre_course_test_transaction_id'].toString()
                  : data['post_course_test_transaction_id'].toString());

          showCustomSnackBar(
            context: context,
            message: "Test started successfully.",
            isSuccess: true,
          );

          // Navigate to the test screen and pass the transaction ID
          Navigator.pushNamed(context, "/test_screen");
        } else {
          print("Error starting test: $data");
          showCustomSnackBar(
            context: context,
            message: data['message'],
            isSuccess: false,
          );
        }
      } else {
        print("Failed to start test. Status code: ${response.statusCode}");
        showCustomSnackBar(
          context: context,
          message: "Failed to start test. Please try again.",
          isSuccess: false,
        );
      }
    } catch (e) {
      print("Error starting test: $e");
      showCustomSnackBar(
        context: context,
        message: "An error occurred: $e",
        isSuccess: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SafeArea(
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back_ios_new),
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${isPreCourse ? "PRE COURSE TEST" : "POST COURSE TEST"} • ANATOMY - STEP ${testData['step_no']}',
                        style: const TextStyle(
                          color: Color(0xFF247E80),
                          fontSize: 12,
                          fontFamily: 'SF Pro Display',
                          fontWeight: FontWeight.w700,
                          height: 1.67,
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Text(
                        '${isPreCourse ? testData["pre_course_test_title"] : testData["post_course_test_title"]}',
                        style: const TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 20,
                          fontFamily: 'SF Pro Display',
                          fontWeight: FontWeight.w500,
                          height: 1.40,
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Text(
                        "PYQ's - Anatomy for NEET PG \n${testData['no_of_questions']} Questions • ${isPreCourse ? testData['pre_course_test_duration_minutes'] : testData['post_course_test_duration_minutes']} minutes",
                        style: const TextStyle(
                          color: Color(0xFF737373),
                          fontSize: 14,
                          fontFamily: 'SF Pro Display',
                          fontWeight: FontWeight.w400,
                          height: 1.57,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        clipBehavior: Clip.antiAlias,
                        decoration: ShapeDecoration(
                          color: const Color(0x0C31B5B9),
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                                width: 1, color: Color(0xFF8FE1E3)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Exam details',
                              style: TextStyle(
                                color: Color(0xFF1A1A1A),
                                fontSize: 20,
                                fontFamily: 'SF Pro Display',
                                fontWeight: FontWeight.w500,
                                height: 1.20,
                              ),
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            Column(children: [
                              Row(
                                children: [
                                  SvgPicture.asset("assets/icons/query.svg"),
                                  const SizedBox(
                                    width: 12,
                                  ),
                                  Text(
                                    '${testData['no_of_questions']} full-length questions, ${testData['max_marks']} marks',
                                    style: const TextStyle(
                                      color: Color(0xFF1A1A1A),
                                      fontSize: 16,
                                      fontFamily: 'SF Pro Display',
                                      fontWeight: FontWeight.w400,
                                      height: 1.50,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    "assets/icons/ranking_filled.svg",
                                    width: 24,
                                    colorFilter: const ColorFilter.mode(
                                        Color(0xFF247E80), BlendMode.srcIn),
                                  ),
                                  const SizedBox(
                                    width: 12,
                                  ),
                                  const Text(
                                    'All India & State Rankings',
                                    style: TextStyle(
                                      color: Color(0xFF1A1A1A),
                                      fontSize: 16,
                                      fontFamily: 'SF Pro Display',
                                      fontWeight: FontWeight.w400,
                                      height: 1.50,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    "assets/icons/list_icon.svg",
                                    width: 24,
                                    colorFilter: const ColorFilter.mode(
                                        Color(0xFF247E80), BlendMode.srcIn),
                                  ),
                                  const SizedBox(
                                    width: 12,
                                  ),
                                  const Text(
                                    'Latest exam pattern-based',
                                    style: TextStyle(
                                      color: Color(0xFF1A1A1A),
                                      fontSize: 16,
                                      fontFamily: 'SF Pro Display',
                                      fontWeight: FontWeight.w400,
                                      height: 1.50,
                                    ),
                                  ),
                                ],
                              ),
                            ]),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                borderHorizontal(),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      testAtemptedCard("4 / 200 marks", context),
                      const SizedBox(
                        height: 12,
                      ),
                      testAtemptedCard("4 / 200 marks", context),
                    ],
                  ),
                ),
                borderHorizontal(),
                const SizedBox(
                  height: 16,
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Syllabus',
                        style: TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 20,
                          fontFamily: 'SF Pro Display',
                          fontWeight: FontWeight.w500,
                          height: 1.20,
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      listViewWithDot(testData['syllabus_text_line_1'] ?? ''),
                      const SizedBox(
                        height: 12,
                      ),
                      listViewWithDot(testData['syllabus_text_line_2'] ?? ''),
                      const SizedBox(
                        height: 12,
                      ),
                      listViewWithDot(testData['syllabus_text_line_3'] ?? ''),
                    ],
                  ),
                ),
                borderHorizontal(),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Instructions',
                        style: TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 20,
                          fontFamily: 'SF Pro Display',
                          fontWeight: FontWeight.w500,
                          height: 1.20,
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      listViewWithDot("+4 marks for each correct answer"),
                      const SizedBox(
                        height: 12,
                      ),
                      listViewWithDot("-1 mark for every incorrect answer."),
                      const SizedBox(
                        height: 12,
                      ),
                      listViewWithDot(
                          "No marks will be deducted for unattempted questions."),
                      const SizedBox(
                        height: 12,
                      ),
                      listViewWithDot(
                          "Tie-breaking criteria include the number of correct responses and candidate age."),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: ElevatedButton(
          onPressed: () async {
            await _startTest(); // Call the API to start the test before navigating
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            backgroundColor: const Color(0xFF247E80),
          ),
          child: const Text(
            'Start test',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'SF Pro Display',
              fontWeight: FontWeight.w500,
              height: 1.50,
            ),
          ),
        ),
      ),
    );
  }
}

Widget listViewWithDot(String data) {
  return Padding(
    padding: const EdgeInsets.only(left: 8.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(right: 8, top: 8),
          width: 5,
          height: 5,
          decoration: ShapeDecoration(
            color: const Color(0xFF737373),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),
        Expanded(
          child: Text(
            data,
            style: const TextStyle(
              color: Color(0xFF737373),
              fontSize: 16,
              fontFamily: 'SF Pro Display',
              fontWeight: FontWeight.w400,
              height: 1.50,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget testAtemptedCard(String title, BuildContext context) {
  return Container(
    decoration: ShapeDecoration(
      color: const Color(0xFFF9FAFB),
      shape: RoundedRectangleBorder(
        side: const BorderSide(width: 1, color: Color(0xFFDDDDDD)),
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    child: ListTile(
      leading: SvgPicture.asset(
        "assets/icons/list_icon.svg",
        colorFilter: const ColorFilter.mode(Color(0xFF5C5C5C), BlendMode.srcIn),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF1A1A1A),
          fontSize: 16,
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w400,
          height: 1.50,
        ),
      ),
      subtitle: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '23 Jan 25',
            style: TextStyle(
              color: Color(0xFF737373),
              fontSize: 12,
              fontFamily: 'SF Pro Display',
              fontWeight: FontWeight.w400,
              height: 1.67,
            ),
          ),
        ],
      ),
      trailing: InkWell(
        borderRadius: BorderRadius.circular(50),
        onTap: () {
          Navigator.pushNamed(context, "/before_enter_test");
        },
        child: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    ),
  );
}

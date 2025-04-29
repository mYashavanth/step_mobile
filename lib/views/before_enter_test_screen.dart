import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:step_mobile/widgets/common_widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'urlconfig.dart';

class BeforeEnterTestScreen extends StatefulWidget {
  const BeforeEnterTestScreen({super.key});

  @override
  State<BeforeEnterTestScreen> createState() => _BeforeEnterTestScreen();
}

class _BeforeEnterTestScreen extends State<BeforeEnterTestScreen> {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  @override
  void initState() {
    _fetchPreCourseTestDetails();
    super.initState();
  }

  Map<String, dynamic> preCourseTestData = {};

  Future<void> _fetchPreCourseTestDetails() async {
    try {
      // Retrieve values from Flutter Secure Storage
      String? token = await storage.read(key: "token");
      String? courseStepDetailsId =
          await storage.read(key: "courseStepDetailId");
      String? stepNo = await storage.read(key: "selectedStepNo");

      // Ensure all required values are available
      if (token == null || courseStepDetailsId == null || stepNo == null) {
        print("Missing required data in Flutter Secure Storage.");
        return;
      }

      // Construct the API URL
      // Replace with your actual base URL
      String apiUrl =
          "$baseurl/app/get-pre-course-test-by-course-step-details-id/$token/$courseStepDetailsId/$stepNo";

      // Make the GET request
      final response = await http.get(Uri.parse(apiUrl));

// {"course_step_details_master_id":4,"created_date":"Mon, 28 Apr 2025 00:00:00 GMT","created_time":"17:36:47","id":5,"marks_per_question":4,"max_marks":0,"negative_marks":1,"no_of_questions":0,"pre_course_test_duration_minutes":50,"pre_course_test_title":"pre course test title","status":1,"step_no":1,"syllabus_text_line_1":"asdfasdfasdf","syllabus_text_line_2":"asdfasdf","syllabus_text_line_3":"asdfasdfas"}
      // Check the response status
      if (response.statusCode == 200) {
        print("API Response: ${response.body}");

        final data = jsonDecode(response.body);
        setState(() {
          preCourseTestData = data.isNotEmpty ? data[0] : {};
        });
      } else {
        print("Failed to fetch data. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching pre-course test details: $e");
    }
  }

  Future<void> _startTest() async {
    try {
      String? token = await storage.read(key: "token");
      String? preCourseTestId = preCourseTestData['id'].toString();

      if (token == null || preCourseTestId == null) {
        print("Missing required data to start the test.");
        return;
      }

      String apiUrl =
          "$baseurl/app/start-pre-course-test/$token/$preCourseTestId";

      final response = await http.post(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['errFlag'] == 0) {
          print("Test started successfully: ${data['message']}");

          // Save the pre_course_test_transaction_id to secure storage
          await storage.write(
              key: "preCourseTestTransactionId",
              value: data['pre_course_test_transaction_id'].toString());

          // Navigate to the test screen and pass the transaction ID
          Navigator.pushNamed(
            context,
            "/test_screen",
            arguments: {
              "preCourseTestTransactionId":
                  data['pre_course_test_transaction_id'],
            },
          );
        } else {
          print("Error starting test: ${data['message']}");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message']),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        print("Failed to start test. Status code: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to start test. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Error starting test: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("An error occurred: $e"),
          backgroundColor: Colors.red,
        ),
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
                onPressed: () {},
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
                        'PRE COURSE TEST • ANATOMY - STEP ${preCourseTestData['step_no']}',
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
                        '${preCourseTestData["pre_course_test_title"]}',
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
                        "PYQ's - Anatomy for NEET PG \n${preCourseTestData['no_of_questions']} Questions • ${preCourseTestData['pre_course_test_duration_minutes']} minutes",
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
                                    '${preCourseTestData['no_of_questions']} full-length questions, ${preCourseTestData['max_marks']} marks',
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
                      listViewWithDot(
                          preCourseTestData['syllabus_text_line_1']),
                      const SizedBox(
                        height: 12,
                      ),
                      listViewWithDot(
                          preCourseTestData['syllabus_text_line_2']),
                      const SizedBox(
                        height: 12,
                      ),
                      listViewWithDot(
                          preCourseTestData['syllabus_text_line_3']),
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
  print(data);
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

import 'dart:math';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:ghastep/views/urlconfig.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ghastep/widgets/common_widgets.dart';
import 'package:ghastep/views/dry.dart';
import 'dart:ui';
import 'dart:math' as math;

String title = "Exam title name should go here";

PreferredSizeWidget testScreenAppBar(
    BuildContext context, void Function() _endTest, String remainingTime) {
  return AppBar(
    automaticallyImplyLeading: false,
    flexibleSpace: SafeArea(
      child: Container(
        padding: const EdgeInsets.only(left: 12),
        child: Row(
          children: [
            // InkWell(
            //   borderRadius: BorderRadius.circular(24),
            //   onTap: () {},
            //   child: Container(
            //     width: 40,
            //     height: 40,
            //     padding:
            //         const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            //     decoration: ShapeDecoration(
            //       color: const Color(0xFFEDEEF0),
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(24),
            //       ),
            //     ),
            //     child: Center(
            //       child: SvgPicture.asset("assets/icons/exit.svg"),
            //     ),
            //   ),
            // ),
            // const SizedBox(
            //   width: 12,
            // ),
            // InkWell(
            //   borderRadius: BorderRadius.circular(24),
            //   onTap: () {},
            //   child: Container(
            //     width: 40,
            //     height: 40,
            //     padding:
            //         const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            //     decoration: ShapeDecoration(
            //       color: const Color(0xFFEDEEF0),
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(24),
            //       ),
            //     ),
            //     child: Center(
            //       child: SvgPicture.asset("assets/icons/pause.svg"),
            //     ),
            //   ),
            // ),
            Container(
              margin: const EdgeInsets.only(left: 12, right: 12),
              padding: const EdgeInsets.all(8),
              decoration: ShapeDecoration(
                color: const Color(0xFFFFEDEF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  SvgPicture.asset("assets/icons/clock_red.svg"),
                  const SizedBox(
                    width: 12,
                  ),
                  Text(
                    remainingTime, // Display the countdown timer here
                    style: const TextStyle(
                      color: Color(0xFFFF3B30),
                      fontSize: 16,
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w400,
                      height: 1.50,
                    ),
                  )
                ],
              ),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                submitTestDialog(context, _endTest);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF247E80),
              ),
              child: const Text(
                'Submit test',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'SF Pro Display',
                  fontWeight: FontWeight.w500,
                  height: 1.50,
                ),
              ),
            ),
            const SizedBox(
              width: 12,
            ),
          ],
        ),
      ),
    ),
  );
}

void submitTestDialog(BuildContext context, void Function() _endTest) async {
  // Fetch the result data from the API
  Map<String, dynamic>? resultData = await _fetchTestResults();

  // If the result data is null, show an error message
  if (resultData == null) {
    showCustomSnackBar(
      context: context,
      message: "Failed to fetch test results. Please try again.",
      isSuccess: false,
    );
    return;
  }

  showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      contentPadding: const EdgeInsets.all(0),
      content: Container(
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              width: double.maxFinite,
              clipBehavior: Clip.antiAlias,
              decoration: const ShapeDecoration(
                color: Color(0xFF247E80),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'NEET-PG',
                    style: TextStyle(
                      color: const Color(0xFFFFCC00),
                      fontSize: 28,
                      fontFamily: 'Rubik Spray Paint',
                      fontWeight: FontWeight.w400,
                      height: 1.29,
                      shadows: [
                        Shadow(
                            offset: const Offset(0, 4),
                            blurRadius: 20,
                            color: const Color(0xFF000000).withOpacity(0.15))
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  const Text(
                    'Are you sure you want to submit your test?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w700,
                      height: 1.40,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              width: double.maxFinite,
              clipBehavior: Clip.antiAlias,
              decoration: const ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
              ),
              child: Column(
                children: [
                  submitTestRow(
                      "clock_red.svg", "Time left", "20 mins 56 secs"),
                  submitTestRow("done_green_icon.svg", "Attempted",
                      "${resultData['answered_questions']} questions"),
                  submitTestRow("unanswered.svg", "Unanswered",
                      "${resultData['unanswered_questions']}"),
                  submitTestRow("not_visited.svg", "Not visited",
                      "${resultData['total_questions'] - resultData['answered_questions']}"),
                  submitTestRow("flag_marked.svg", "Marked for review",
                      resultData['marked_for_review'].toString()),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: ShapeDecoration(
                          color: const Color(0xFFEDEEF0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'Cancel',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF737373),
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
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        _endTest();
                        Navigator.pushNamed(context, "/result_test_screen");
                      },
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: ShapeDecoration(
                          color: const Color(0xFF247E80),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'Submit test',
                            textAlign: TextAlign.center,
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
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    ),
  );
}

Future<Map<String, dynamic>?> _fetchTestResults() async {
  try {
    final storage = const FlutterSecureStorage();
    String? token = await storage.read(key: "token");

    bool? isPreCourseFlag = await storage.read(key: "isPreCourse") == "true";
    String? preCourseTestTransactionId = await storage.read(
        key: isPreCourseFlag
            ? "preCourseTestTransactionId"
            : "postCourseTestTransactionId");

    if (token == null || preCourseTestTransactionId == null) {
      print(token);
      print(preCourseTestTransactionId);
      print("Missing required data to fetch test results.");
      return null;
    }

    String apiUrl = isPreCourseFlag
        ? "$baseurl/app/get-pre-course-test-response/$token/$preCourseTestTransactionId"
        : "$baseurl/app/get-post-course-test-response/$token/$preCourseTestTransactionId";
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> resultData = jsonDecode(response.body);

      // Store the results in secure storage
      await storage.write(key: "test_results", value: jsonEncode(resultData));
      print(response.body);
      print(
          "++++++++++++++++++++++++++++++++++++++++++ line  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
      return jsonDecode(response.body);
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

Widget submitTestRow(String icon, String title, String subTitle) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        SvgPicture.asset(
          'assets/icons/$icon',
          width: 24,
          height: 24,
        ),
        const SizedBox(
          width: 12,
        ),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 16,
            fontFamily: 'SF Pro Display',
            fontWeight: FontWeight.w500,
            height: 1.50,
          ),
        ),
        const Spacer(),
        Text(
          subTitle,
          style: const TextStyle(
            color: Color(0xFF737373),
            fontSize: 16,
            fontFamily: 'SF Pro Display',
            fontWeight: FontWeight.w400,
            height: 1.50,
          ),
        )
      ],
    ),
  );
}

Widget answerCard(bool selected, String title, String ans) {
  return Container(
    padding: const EdgeInsets.all(8),
    decoration: ShapeDecoration(
      color: selected ? const Color(0x2631B5B9) : Colors.white,
      shape: RoundedRectangleBorder(
        side: BorderSide(
            width: 1,
            color:
                selected ? const Color(0xFF8FE1E3) : const Color(0xFFDDDDDD)),
        borderRadius: BorderRadius.circular(8),
      ),
      shadows: const [
        BoxShadow(
          color: Color(0x0C000000),
          blurRadius: 20,
          offset: Offset(0, 4),
          spreadRadius: 0,
        )
      ],
    ),
    child: Row(
      children: [
        Container(
          height: 40,
          width: 40,
          // padding: const EdgeInsets.all(10),
          decoration: ShapeDecoration(
            color: selected ? const Color(0xFF58C9CC) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
              side: BorderSide(
                  width: 1,
                  color:
                      selected ? Colors.transparent : const Color(0xFFDDDDDD)),
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black,
                fontSize: 16,
                fontFamily: 'SF Pro Display',
                fontWeight: FontWeight.w400,
                height: 1.50,
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 12,
        ),
        Expanded(
          // This allows text to wrap within available space
          child: Text(
            ans,
            style: const TextStyle(
              color: Color(0xFF1A1A1A),
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

class TestScreenWidgets extends StatefulWidget {
  final Map questionData;
  final int index;
  final int questionLength;
  final int? selectedOption; // Add this parameter
  final Function(int, int) onOptionSelected; // Add this parameter

  const TestScreenWidgets({
    super.key,
    required this.index,
    required this.questionData,
    required this.questionLength,
    required this.selectedOption, // Include in the constructor
    required this.onOptionSelected, // Include in the constructor
  });

  @override
  State<TestScreenWidgets> createState() => _TestScreenWidgetsState();
}

class _TestScreenWidgetsState extends State<TestScreenWidgets> {
  late int? ansSel;
  int selectListOrGrid = 0; // Initialize selectListOrGrid with a default value
  List<int> statusList = List.generate(
      40, (index) => 0); // Initialize statusList with default statuses

  @override
  void initState() {
    super.initState();
    ansSel = widget.selectedOption; // Initialize with the selected option
  }

  @override
  Widget build(BuildContext context) {
    Map data = widget.questionData;
    List options = widget.questionData['options'];

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildTestScreenTopBar(
                  widget.index + 1, widget.questionLength, context),
              const SizedBox(height: 12),
              borderHorizontal(),
              const SizedBox(height: 12),
              RichText(
                text: TextSpan(
                  children: _buildQuestionContent(data["question"], context),
                ),
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: () {
                  setState(() {
                    ansSel = 0;
                  });
                  widget.onOptionSelected(widget.index, 0);
                },
                child: answerCard(ansSel == 0, 'A', options[0]),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () {
                  setState(() {
                    ansSel = 1;
                  });
                  widget.onOptionSelected(widget.index, 1);
                },
                child: answerCard(ansSel == 1, 'B', options[1]),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () {
                  setState(() {
                    ansSel = 2;
                  });
                  widget.onOptionSelected(widget.index, 2);
                },
                child: answerCard(ansSel == 2, 'C', options[2]),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () {
                  setState(() {
                    ansSel = 3;
                  });
                  widget.onOptionSelected(widget.index, 3);
                },
                child: answerCard(ansSel == 3, 'D', options[3]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> loadTitle() async {
    final storage = const FlutterSecureStorage();
    final value = await storage.read(key: "test_title");
    if (value != null && mounted) {
      setState(() {
        title = value;
      });
    }
  }

  Widget buildTestScreenTopBar(int number, int length, BuildContext context) {
    loadTitle(); // Call the function to load the title
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 20,
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w500,
                      height: 1.40,
                    ),
                  ),
                  const Spacer(),
                  // IconButton(
                  //     onPressed: () {},
                  //     icon: const Icon(Icons.bookmark_border_outlined)),
                  // IconButton(
                  //     onPressed: () {},
                  //     icon: const Icon(Icons.outlined_flag_rounded)),
                  // IconButton(
                  //     onPressed: () {
                  //       showModalBottomSheet(
                  //           isScrollControlled: true,
                  //           context: context,
                  //           //  isScrollControlled: true,
                  //           backgroundColor: Colors.transparent,
                  //           builder: (context) {
                  //             return StatefulBuilder(builder:
                  //                 (BuildContext context,
                  //                     StateSetter modalSetState) {
                  //               return buildQuestionGridOrListViewBottomSheet(
                  //                   modalSetState, context);
                  //             });
                  //           });
                  //     },
                  //     icon: const Icon(Icons.grid_view_outlined)),
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              Row(
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '$number/$length',
                          style: const TextStyle(
                            color: Color(0xFF1A1A1A),
                            fontSize: 20,
                            fontFamily: 'SF Pro Display',
                            fontWeight: FontWeight.w700,
                            height: 1.40,
                          ),
                        ),
                        const TextSpan(
                          text: ' ',
                          style: TextStyle(
                            color: Color(0xFF1A1A1A),
                            fontSize: 16,
                            fontFamily: 'SF Pro Display',
                            fontWeight: FontWeight.w400,
                            height: 1.50,
                          ),
                        ),
                        const TextSpan(
                          text: 'Question',
                          style: TextStyle(
                            color: Color(0xFF737373),
                            fontSize: 16,
                            fontFamily: 'SF Pro Display',
                            fontWeight: FontWeight.w400,
                            height: 1.50,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(1),
                    decoration: ShapeDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment(1.00, 0.00),
                        end: Alignment(-1, 0),
                        // colors: [Color(0xFFABFFD7), Color(0xFFFFB9C0)],
                        colors: [
                          Color(0xFFFF3B30),
                          Color(0xFF34C759),
                        ],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Container(
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: ShapeDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment(1.00, 0.00),
                            end: Alignment(-1, 0),
                            colors: [
                              Color.fromARGB(55, 255, 185, 192),
                              Color.fromARGB(85, 171, 255, 214)
                            ],
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Center(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '+4.0 ',
                                  style: TextStyle(
                                    color: Color(0xFF34C759),
                                    fontSize: 14,
                                    fontFamily: 'SF Pro Display',
                                    fontWeight: FontWeight.w500,
                                    height: 1.57,
                                  ),
                                ),
                                TextSpan(
                                  text: '/',
                                  style: TextStyle(
                                    color: Color(0xFF9CA3AF),
                                    fontSize: 14,
                                    fontFamily: 'SF Pro Display',
                                    fontWeight: FontWeight.w500,
                                    height: 1.57,
                                  ),
                                ),
                                TextSpan(
                                  text: ' -1.0',
                                  style: TextStyle(
                                    color: Color(0xFFFF3B30),
                                    fontSize: 14,
                                    fontFamily: 'SF Pro Display',
                                    fontWeight: FontWeight.w500,
                                    height: 1.57,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // SizedBox(
        //   height: 36,
        //   child: Stack(
        //     children: [
        //       SvgPicture.asset("assets/icons/bookmark_rectangle.svg"),
        //       // ignore: prefer_const_constructors
        //       Padding(
        //         padding: const EdgeInsets.only(left: 8.0),
        //         child: const Center(
        //           child: Align(
        //             alignment: Alignment.centerLeft,
        //             child: Text(
        //               'Marked for Review',
        //               style: TextStyle(
        //                 color: Colors.white,
        //                 fontSize: 16,
        //                 fontFamily: 'SF Pro Display',
        //                 fontWeight: FontWeight.w400,
        //                 height: 1.50,
        //               ),
        //             ),
        //           ),
        //         ),
        //       )
        //     ],
        //   ),
        // )
      ],
    );
  }

  Widget buildQuestionGridOrListViewBottomSheet(
      StateSetter setModeState, BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.maxFinite,
          margin: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.09, left: 60),
          padding:
              const EdgeInsets.only(top: 12, left: 12, right: 12, bottom: 12),
          decoration: const ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12)),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  'Exam title name here',
                  style: TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 20,
                    fontFamily: 'SF Pro Display',
                    fontWeight: FontWeight.w500,
                    height: 1.40,
                  ),
                ),
                const Text(
                  '35 Questions | Step 1 • Pre-test ',
                  style: TextStyle(
                    color: Color(0xFF737373),
                    fontSize: 16,
                    fontFamily: 'SF Pro Display',
                    fontWeight: FontWeight.w400,
                    height: 1.50,
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                borderHorizontal(),
                const SizedBox(
                  height: 12,
                ),
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        selectListOrGrid = 0;
                        setModeState(() {});
                      },
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: ShapeDecoration(
                          color: selectListOrGrid == 0
                              ? const Color(0xFF007AFF)
                              : const Color(0xFFEDEEF0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.grid_view_rounded,
                              color: selectListOrGrid == 0
                                  ? Colors.white
                                  : const Color(0xFF737373),
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            Text(
                              'Grid view',
                              style: TextStyle(
                                color: selectListOrGrid == 0
                                    ? Colors.white
                                    : const Color(0xFF737373),
                                fontSize: 14,
                                fontFamily: 'SF Pro Display',
                                fontWeight: FontWeight.w400,
                                height: 1.57,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        selectListOrGrid = 1;
                        setModeState(() {});
                      },
                      child: Container(
                        height: 40,
                        margin: const EdgeInsets.only(left: 16),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: ShapeDecoration(
                          color: selectListOrGrid == 1
                              ? const Color(0xFF007AFF)
                              : const Color(0xFFEDEEF0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.list_rounded,
                              color: selectListOrGrid == 1
                                  ? Colors.white
                                  : const Color(0xFF737373),
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            Text(
                              'List view',
                              style: TextStyle(
                                color: selectListOrGrid == 1
                                    ? Colors.white
                                    : const Color(0xFF737373),
                                fontSize: 14,
                                fontFamily: 'SF Pro Display',
                                fontWeight: FontWeight.w400,
                                height: 1.57,
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 12,
                ),
                Wrap(
                  spacing: 40,
                  runAlignment: WrapAlignment.start,
                  runSpacing: 12,
                  children: [
                    buildIndicator(const Color(0xFF289799), "Answered"),
                    buildIndicator(const Color(0xFFFFCC00), "Unanswered"),
                    buildIndicator(const Color(0xFFFE7D14), "Review"),
                    buildIndicator(const Color(0xFF737373), "Not Visited"),
                  ],
                ),
                const SizedBox(
                  height: 12,
                ),
                borderHorizontal(),
                const SizedBox(
                  height: 12,
                ),
                Visibility(
                  visible: selectListOrGrid == 0,
                  child: Wrap(
                    runSpacing: 12,
                    spacing: 22,
                    children: List.generate(40, (index) {
                      return buildGridItem(statusList[index], index + 1);
                    }),
                  ),
                ),
                Visibility(
                  visible: selectListOrGrid == 1,
                  child: Column(
                    children: List.generate(40, (i) {
                      return buildQuestioncard(statusList[i], i + 1);
                    }),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.2,
                )
              ],
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.09,
          left: 10,
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget buildQuestioncard(int status, int num) {
    Color bgColor = const Color(0x2631B5B9);

    switch (status) {
      case 1:
        bgColor = const Color(0xFFFFECC1);
      case 2:
        bgColor = const Color(0x33FE7D14);
      case 3:
        bgColor = const Color(0xFFEDEEF0);
    }

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(top: 6, bottom: 6),
      decoration: ShapeDecoration(
        color: bgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        shadows: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 20,
            offset: Offset(0, 4),
            spreadRadius: 0,
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$num) ',
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 16,
                  fontFamily: 'SF Pro Display',
                  fontWeight: FontWeight.w700,
                  height: 1.50,
                ),
              ),
              const Expanded(
                child: Text(
                  'Which of the following arteries is a direct branch of the external carotid artery?',
                  style: TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 16,
                    fontFamily: 'SF Pro Display',
                    fontWeight: FontWeight.w400,
                    height: 1.50,
                  ),
                ),
              ),
            ],
          ),
          num % 4 == 0
              ? Center(
                  child: SizedBox(
                      width: 200,
                      child: Image.asset('assets/image/question_image.png')),
                )
              : const Text("")
        ],
      ),
    );
  }
}

Widget buidQuestionReviewBottomSheet(
    StateSetter modalSetState,
    List<Map> feedbackReviewData,
    List<int> selected,
    String bottomSheetTitle,
    BuildContext context,
    {required Function(List<int>, String) onSubmitReview}) {
  // Add this parameter

  TextEditingController feedbackController = TextEditingController();

  return Stack(
    clipBehavior: Clip.none,
    children: [
      Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Container(
          padding:
              const EdgeInsets.only(top: 16, left: 20, right: 20, bottom: 16),
          clipBehavior: Clip.antiAlias,
          decoration: const ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'What seems to be the problem?',
                style: TextStyle(
                  color: Color(0xFF323836),
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Column(
                children: List.generate(feedbackReviewData.length, (index) {
                  return buildFeedbackRow(
                      modalSetState, feedbackReviewData[index], selected);
                }),
              ),
              const SizedBox(height: 12),
              const Text(
                'Additional feedback',
                style: TextStyle(
                  color: Color(0xFF737373),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: feedbackController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: "You can type your text here...",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Use the provided callback to submit the review
                  onSubmitReview(selected, feedbackController.text);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: const Color(0xFF247E80),
                ),
                child: const Text(
                  'Apply',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      Positioned(
        right: 15,
        top: -50,
        child: CircleAvatar(
          backgroundColor: Colors.white,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
    ],
  );
}

Widget buildQuestionReportedBotomSheet(BuildContext context) {
  return Stack(clipBehavior: Clip.none, children: [
    Container(
      width: double.maxFinite,
      padding: const EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 40),
      // margin: EdgeInsets.only(top: 50),
      clipBehavior: Clip.antiAlias,
      decoration: const ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
      ),
      child: SizedBox(
        width: double.maxFinite,
        // color: Colors.green,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset("assets/icons/done_green_icon.svg"),
            const SizedBox(
              height: 12,
            ),
            const Text(
              'Question Reported',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF323836),
                fontSize: 20,
                fontFamily: 'SF Pro Display',
                fontWeight: FontWeight.w500,
                height: 1.10,
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            const Text(
              'Thankyou. Your valuable feedback will help us \nto improve our tests!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF737373),
                fontSize: 14,
                fontFamily: 'SF Pro Display',
                fontWeight: FontWeight.w400,
                height: 1.57,
              ),
            ),
          ],
        ),
      ),
    ),
    Positioned(
      right: 15,
      top: -50,
      child: CircleAvatar(
        backgroundColor: Colors.white,
        child: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          // onPressed: () => Navigator.pop(context),
          onPressed: () {
            print("clicked");
          },
        ),
      ),
    ),
  ]);
}

Widget buildFeedbackRow(
    StateSetter modalSetState, Map value, List<int> selected) {
  return Container(
    margin: const EdgeInsets.only(top: 4, bottom: 4),
    child: Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value['name'],
              style: const TextStyle(
                color: Color(0xFF247E80),
                fontSize: 16,
                fontFamily: 'SF Pro Display',
                fontWeight: FontWeight.w500,
                height: 1.50,
              ),
            ),
          ],
        ),
        const Spacer(),
        Radio(
          focusColor: const Color(0xFF247E80),
          fillColor: getMaterialStateThemeColor(),
          value: value["id"],
          groupValue: selected[0],
          onChanged: (value) {
            modalSetState(() {
              selected[0] = value;
            });
          },
        ),
      ],
    ),
  );
}

List<int> generateRandomNumbers(int count, int min, int max) {
  Random random = Random();
  return List.generate(count, (_) => min + random.nextInt(max - min + 1));
}

Widget buildGridItem(int status, int qNum) {
  Color bgColor = const Color(0xFF737373);
  switch (status) {
    case 1:
      bgColor = const Color(0xFF289799);
    case 2:
      bgColor = const Color(0xFFFFCC00);
    case 3:
      bgColor = const Color(0xFFFE7D14);
  }

  return Container(
    width: 45,
    height: 45,
    // padding: const EdgeInsets.all(10),
    decoration: ShapeDecoration(
      color: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
      ),
    ),
    child: Center(
      child: Text(
        qNum.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w700,
          height: 1.50,
        ),
      ),
    ),
  );
}

Widget buildIndicator(Color colorCode, String text) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7),
          ),
          color: colorCode,
        ),
        width: 14,
        height: 14,
      ),
      const SizedBox(
        width: 8,
      ),
      Text(
        text,
        style: const TextStyle(
          color: Color(0xFF737373),
          fontSize: 14,
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w400,
          height: 1.57,
        ),
      )
    ],
  );
}

List<InlineSpan> _buildQuestionContent(
    dynamic questionData, BuildContext context) {
  final List<InlineSpan> spans = [];

  // Handle case when questionData is already a Map (parsed JSON)
  if (questionData is Map<String, dynamic>) {
    return _buildEditorJsContent(questionData, context);
  }

  // Handle case when questionData is a String
  if (questionData is String) {
    // First try to parse it as JSON
    try {
      final parsedData = jsonDecode(questionData);
      if (parsedData is Map<String, dynamic>) {
        return _buildEditorJsContent(parsedData, context);
      }
    } catch (e) {
      // If parsing fails, treat it as plain text
      return _buildPlainTextContent(questionData, context);
    }
  }

  // Fallback to empty content
  return spans;
}

List<InlineSpan> _buildEditorJsContent(
    Map<String, dynamic> questionData, BuildContext context) {
  final List<InlineSpan> spans = [];

  try {
    final List<dynamic> blocks = questionData['blocks'] ?? [];

    for (final block in blocks) {
      final String type = block['type'];
      final Map<String, dynamic> data = block['data'];

      switch (type) {
        case 'paragraph':
          if (data['text'] != null) {
            String paragraphText = data['text'].toString();

            // Check if the text is empty or only contains whitespace/HTML line breaks
            bool isEmptyText = paragraphText.trim().isEmpty ||
                paragraphText
                    .replaceAll(RegExp(r'<br\s*/?>'), '')
                    .trim()
                    .isEmpty;

            if (!isEmptyText) {
              // Handle all variations of line breaks
              paragraphText = paragraphText
                  .replaceAll('<br>', '\n')
                  .replaceAll('<br/>', '\n')
                  .replaceAll('<br />', '\n');

              // Process bold tags and split text by newlines
              spans.addAll(_processTextWithFormatting(paragraphText));
              // Add spacing after paragraph
              spans.add(const TextSpan(text: '\n\n'));
            }
          }
          break;

        case 'image':
          // Handle images
          final String? imageUrl = data['file']?['url'];
          if (imageUrl != null && imageUrl.isNotEmpty) {
            spans.add(WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: GestureDetector(
                  onTap: () => _showFullScreenImage(context, imageUrl),
                  child: Image.network(
                    imageUrl,
                    width: 200,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image, size: 40),
                  ),
                ),
              ),
            ));
            // Add spacing after image
            spans.add(const TextSpan(text: '\n\n'));
          }
          break;

        case 'header':
          if (data['text'] != null && data['text'].toString().isNotEmpty) {
            spans.addAll(_processTextWithFormatting(
              data['text'],
              baseStyle: TextStyle(
                color: const Color(0xFF1A1A1A),
                fontSize: _getHeaderFontSize(data['level'] ?? 1),
                fontWeight: FontWeight.bold,
                height: 1.50,
              ),
            ));
            spans.add(const TextSpan(text: '\n\n'));
          }
          break;

        case 'list':
          if (data['items'] != null && data['items'] is List) {
            for (var item in data['items']) {
              spans.addAll(_processTextWithFormatting('• $item\n'));
            }
            spans.add(const TextSpan(text: '\n'));
          }
          break;

        case 'table':
          if (data['content'] != null && data['content'] is List) {
            spans.add(WidgetSpan(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                child: _buildTableWidget(data, context),
              ),
            ));
            spans.add(const TextSpan(text: '\n\n'));
          }
          break;

        default:
          // For unsupported types, try to display any text content
          if (data['text'] != null && data['text'].toString().isNotEmpty) {
            spans.addAll(_processTextWithFormatting(data['text']));
            spans.add(const TextSpan(text: '\n\n'));
          }
          break;
      }
    }
  } catch (e) {
    // If something goes wrong with JSON processing, fall back to showing raw data
    spans.addAll(_processTextWithFormatting(jsonEncode(questionData)));
  }

  return spans;
}

List<InlineSpan> _processTextWithFormatting(String text,
    {TextStyle? baseStyle}) {
  final List<InlineSpan> spans = [];
  final baseTextStyle = baseStyle ??
      const TextStyle(
        color: Color(0xFF1A1A1A),
        fontSize: 16,
        fontFamily: 'SF Pro Display',
        fontWeight: FontWeight.w400,
        height: 1.50,
      );

  // Split text by lines first
  final lines = text.split('\n');

  for (int lineIndex = 0; lineIndex < lines.length; lineIndex++) {
    final line = lines[lineIndex];
    int currentPos = 0;
    final boldPattern = RegExp(r'<b>(.*?)<\/b>');
    final matches = boldPattern.allMatches(line);

    if (matches.isEmpty) {
      if (line.isNotEmpty) {
        spans.add(TextSpan(text: line, style: baseTextStyle));
      }
    } else {
      for (final match in matches) {
        // Add text before the bold tag
        if (match.start > currentPos) {
          spans.add(TextSpan(
            text: line.substring(currentPos, match.start),
            style: baseTextStyle,
          ));
        }

        // Add the bold text
        spans.add(TextSpan(
          text: match.group(1),
          style: baseTextStyle.copyWith(fontWeight: FontWeight.bold),
        ));

        currentPos = match.end;
      }

      // Add remaining text after last bold tag
      if (currentPos < line.length) {
        spans.add(TextSpan(
          text: line.substring(currentPos),
          style: baseTextStyle,
        ));
      }
    }

    // Add newline if it's not the last line
    if (lineIndex < lines.length - 1) {
      spans.add(const TextSpan(text: '\n'));
    }
  }

  return spans;
}

Widget _buildTableWidget(Map<String, dynamic> tableData, BuildContext context) {
  String _decodeHtmlEntities(String text) {
    return text
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ');
  }

  final bool withHeadings = tableData['withHeadings'] ?? false;
  final bool stretched = tableData['stretched'] ?? false;
  final List<List<String>> content = List<List<String>>.from(
    tableData['content']?.map((row) => List<String>.from(row)) ?? [],
  );

  if (content.isEmpty) return const SizedBox();

  Widget _buildTextWithFormatting(String text) {
    final decodedText = _decodeHtmlEntities(text);
    final List<InlineSpan> spans = [];
    int currentPos = 0;
    final boldPattern = RegExp(r'<b>(.*?)<\/b>');
    final matches = boldPattern.allMatches(decodedText);

    if (matches.isEmpty) {
      return Text(
        decodedText,
        style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
      );
    } else {
      for (final match in matches) {
        if (match.start > currentPos) {
          spans.add(TextSpan(
            text: decodedText.substring(currentPos, match.start),
            style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
          ));
        }

        spans.add(TextSpan(
          text: match.group(1),
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.bold,
          ),
        ));

        currentPos = match.end;
      }

      if (currentPos < decodedText.length) {
        spans.add(TextSpan(
          text: decodedText.substring(currentPos),
          style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
        ));
      }

      return RichText(
        text: TextSpan(children: spans),
      );
    }
  }

  Widget buildTableCell(String cellText) {
    final decodedText = _decodeHtmlEntities(cellText);

    if (decodedText.toLowerCase().endsWith('.png') ||
        decodedText.toLowerCase().endsWith('.jpg') ||
        decodedText.toLowerCase().endsWith('.jpeg') ||
        decodedText.toLowerCase().endsWith('.gif')) {
      return GestureDetector(
        onTap: () => _showFullScreenImage(context, decodedText),
        child: Image.network(
          decodedText,
          width: 150,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.broken_image, size: 40),
        ),
      );
    }

    final anchorPattern =
        RegExp(r'<a\s+(?:[^>]*?\s+)?href="([^"]*)"[^>]*>(.*?)<\/a>');
    final anchorMatch = anchorPattern.firstMatch(decodedText);

    if (anchorMatch != null) {
      final url = anchorMatch.group(1)!;
      final linkText =
          anchorMatch.group(2)!.isNotEmpty ? anchorMatch.group(2)! : url;

      if (url.toLowerCase().endsWith('.png') ||
          url.toLowerCase().endsWith('.jpg') ||
          url.toLowerCase().endsWith('.jpeg') ||
          url.toLowerCase().endsWith('.gif')) {
        return GestureDetector(
          onTap: () => _showFullScreenImage(context, url),
          child: Image.network(
            url,
            width: 150,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image, size: 40),
          ),
        );
      } else {
        return InkWell(
          onTap: () => _showFullScreenImage(context, url),
          child: Text(
            linkText,
            style: const TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
              fontSize: 14,
            ),
          ),
        );
      }
    }

    return _buildTextWithFormatting(decodedText);
  }

  final screenWidth = MediaQuery.of(context).size.width;
  final columnCount = content.isNotEmpty ? content[0].length : 0;
  final maxColumnWidth = screenWidth * 0.6; // 60% of screen width
  final minColumnWidth = 120.0; // Minimum width for columns

  // Calculate the total content width needed
  double totalContentWidth = 0;
  final columnWidths = <int, double>{};

  // First pass: Calculate natural column widths
  for (int col = 0; col < columnCount; col++) {
    double maxWidth = minColumnWidth;
    for (int row = 0; row < content.length; row++) {
      final cellText = content[row][col];
      final textPainter = TextPainter(
        text: TextSpan(
          text:
              _decodeHtmlEntities(cellText.replaceAll(RegExp(r'<[^>]*>'), '')),
          style: const TextStyle(fontSize: 14),
        ),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout();
      maxWidth = math.max(maxWidth, textPainter.width + 16); // Add padding
    }
    columnWidths[col] = math.min(maxWidth, maxColumnWidth);
    totalContentWidth += columnWidths[col]!;
  }

  return ConstrainedBox(
    constraints: BoxConstraints(
      maxWidth: screenWidth,
      minWidth:
          stretched ? screenWidth : math.min(totalContentWidth, screenWidth),
    ),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        constraints: BoxConstraints(
          minWidth: stretched ? screenWidth : totalContentWidth,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Table(
          columnWidths: columnWidths
              .map((index, width) => MapEntry(index, FixedColumnWidth(width))),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          border: TableBorder(
            horizontalInside: BorderSide(color: Colors.grey.shade300),
            verticalInside: BorderSide(color: Colors.grey.shade300),
          ),
          children: [
            if (withHeadings && content.isNotEmpty)
              TableRow(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                ),
                children: content[0].map((cell) {
                  return Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      _decodeHtmlEntities(
                          cell.replaceAll('<b>', '').replaceAll('</b>', '')),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
              ),
            ...content
                .sublist(withHeadings ? 1 : 0)
                .map((row) => TableRow(
                      children: row.map((cell) {
                        return Padding(
                          padding: const EdgeInsets.all(8),
                          child: buildTableCell(cell),
                        );
                      }).toList(),
                    ))
                .toList(),
          ],
        ),
      ),
    ),
  );
}

List<InlineSpan> _buildPlainTextContent(String text, BuildContext context) {
  final List<InlineSpan> spans = [];
  final RegExp urlRegExp = RegExp(
    r'(https?:\/\/[^\s]+(?:\.png|\.jpg|\.jpeg|\.gif))',
    caseSensitive: false,
  );
  final matches = urlRegExp.allMatches(text);

  int lastEnd = 0;
  for (final match in matches) {
    // Add text before the image
    if (match.start > lastEnd) {
      spans.add(TextSpan(
        text: text.substring(lastEnd, match.start),
        style: const TextStyle(
          color: Color(0xFF1A1A1A),
          fontSize: 16,
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w400,
          height: 1.50,
        ),
      ));
    }
    // Add the image as a WidgetSpan
    final url = match.group(0)!;
    spans.add(WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: GestureDetector(
          onTap: () => _showFullScreenImage(context, url),
          child: Image.network(
            url,
            width: 200,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image, size: 40),
          ),
        ),
      ),
    ));
    lastEnd = match.end;
  }
  // Add any remaining text after the last image
  if (lastEnd < text.length) {
    spans.add(TextSpan(
      text: text.substring(lastEnd),
      style: const TextStyle(
        color: Color(0xFF1A1A1A),
        fontSize: 16,
        fontFamily: 'SF Pro Display',
        fontWeight: FontWeight.w400,
        height: 1.50,
      ),
    ));
  }
  return spans;
}

double _getHeaderFontSize(int level) {
  switch (level) {
    case 1:
      return 24;
    case 2:
      return 20;
    case 3:
      return 18;
    default:
      return 16;
  }
}

void _showFullScreenImage(BuildContext context, String imageUrl) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Image",
    pageBuilder: (context, anim1, anim2) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Glassmorphism background
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
              child: Container(
                color: const Color.fromRGBO(255, 255, 255, 0.2),
              ),
            ),
            // Centered zoomable image
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.broken_image,
                      color: Colors.white,
                      size: 80),
                ),
              ),
            ),
            // Close button
            Positioned(
              top: 40,
              right: 24,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(0, 0, 0, 0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 32),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

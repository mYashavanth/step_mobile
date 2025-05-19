import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ghastep/widgets/common_widgets.dart';
import 'package:ghastep/widgets/course_screen_widgets.dart';
import 'package:ghastep/widgets/homepage_widgets.dart';
import 'package:ghastep/views/urlconfig.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CourseScreen extends StatefulWidget {
  const CourseScreen({super.key});

  @override
  State<CourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen>
    with SingleTickerProviderStateMixin {
  final storage = const FlutterSecureStorage();
  late TabController _tabController;
  Map<String, dynamic> courseStepDetails = {};
  var authToken = '';
  int selectedStepId = 1; // Track selected step by ID
  String courseStepDetailId = '';
  List<dynamic> videoData = []; // To store video data from API

  List<int> stepTabSelectedIndex = [0];
  List<Map> selectStepList = [
    {"name": "Step 1", "id": 1},
    {"name": "Step 2", "id": 2},
    {"name": "Step 3", "id": 3},
    {"name": "Notes", "id": 4},
  ];
  List<int> chooseStepList = [0];
  String courseId = '0'; // Default value until set
  String subjectId = '0'; // Default value until set
  @override
  void initState() {
    _tabController = TabController(length: 5, vsync: this);
    super.initState();
    _loadSelectedStep();
    fetchCourseStepDetails();
  }

  @override
  void didUpdateWidget(covariant CourseScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Call API when selectedStepId changes
    if (courseStepDetailId.isNotEmpty) {
      // fetchVideoData();
      fetchCourseStepDetails();
    }
  }

  Future<void> _loadSelectedStep() async {
    String? stepId = await storage.read(key: "selectedStepNo");
    if (stepId == null) {
      await storage.write(key: "selectedStepNo", value: "1");
      stepId = "1";
    }
    setState(() {
      selectedStepId = int.parse(stepId!);
      chooseStepList[0] = selectedStepId;
      stepTabSelectedIndex[0] = selectedStepId - 1;
    });
  }

  Future<void> fetchCourseStepDetails() async {
    final token = await storage.read(key: 'token');
    authToken = token ?? '';
    if (authToken.isEmpty) {
      print("Token is not available");
      return;
    }
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        courseId = args['courseId'].toString(); // Update class variable
        subjectId = args['subjectId'].toString(); // Update class variable
    print("_____________________$courseId, $subjectId");
    try {
      final url = Uri.parse(
          '$baseurl/app/get-course-step-details-details/$token/$courseId/$subjectId/$selectedStepId');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          final courseStepDetailsData = data[0];
          final courseStepId = courseStepDetailsData['id'].toString();
          courseStepDetailId = courseStepId;

          await storage.write(key: "courseStepDetailId", value: courseStepId);

          setState(() {
            courseStepDetails = courseStepDetailsData;
          });

          // Fetch video data after getting courseStepDetailId
          fetchVideoData();
        } else {
          setState(() {
            courseStepDetails = {};
          });
        }
      } else {
        print("Error fetching course step details: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching course step details: $e");
    }
  }

  Future<void> fetchVideoData() async {
    if (authToken.isEmpty || courseStepDetailId.isEmpty) return;

    try {
      final url =
          Uri.parse('$baseurl/app/get-video/$authToken/$courseStepDetailId');
      print("Fetching video data from: $url");
      final response = await http.get(url);

      print("Video API Response: ${response.body}"); // Print response data

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          videoData = data;
        });
      } else {
        print("Error fetching video data: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching video data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 300,
              width: double.maxFinite,
              child: courseStepDetails.isNotEmpty
                  ? Image.network(
                      '$baseurl/app/course-step-detail-banner-image/${courseStepDetails['banner_image_name']}/$authToken',
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      "assets/image/vedio_image.png",
                      fit: BoxFit.cover,
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: ShapeDecoration(
                          color: const Color(0xFF247E80),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          courseStepDetails.isNotEmpty
                              ? courseStepDetails['subject_name']
                              : "Subject Name",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'SF Pro Display',
                            fontWeight: FontWeight.w400,
                            height: 1.67,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: ShapeDecoration(
                          color: const Color(0xFFF9FAFB),
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                                width: 1, color: Color(0xFF247E80)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          shadows: const [
                            BoxShadow(
                              color: Color(0x19000000),
                              blurRadius: 20,
                              offset: Offset(0, 4),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: InkWell(
                          onTap: () {
                            showModalBottomSheet(
                                isScrollControlled: true,
                                context: context,
                                backgroundColor: Colors.transparent,
                                builder: (context) {
                                  return StatefulBuilder(builder:
                                      (BuildContext context,
                                          StateSetter modalSetState) {
                                    return buidSelectCourseBottomSheetStep(
                                      context,
                                      modalSetState,
                                      selectStepList,
                                      chooseStepList,
                                      "Select your Course",
                                      (String stepName) {
                                        final selectedStep =
                                            selectStepList.firstWhere(
                                          (step) => step["name"] == stepName,
                                          orElse: () => selectStepList[0],
                                        );
                                        setState(() {
                                          selectedStepId = selectedStep["id"];
                                          chooseStepList[0] = selectedStepId;
                                          stepTabSelectedIndex[0] =
                                              selectedStepId - 1;
                                        });
                                        storage.write(
                                          key: "selectedStepNo",
                                          value: selectedStep["id"].toString(),
                                        );
                                        // fetchVideoData();
                                        fetchCourseStepDetails();
                                      },
                                    );
                                  });
                                });
                          },
                          child: Row(
                            children: [
                              Text(
                                "STEP $selectedStepId",
                                style: const TextStyle(
                                  color: Color(0xFF247E80),
                                  fontSize: 14,
                                  fontFamily: 'SF Pro Display',
                                  fontWeight: FontWeight.w500,
                                  height: 1.71,
                                ),
                              ),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Color(0xFF247E80),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: courseStepDetails.isNotEmpty
                              ? '${courseStepDetails['course_step_title']}: '
                              : "Step name: ",
                          style: const TextStyle(
                            color: Color(0xFF1A1A1A),
                            fontSize: 20,
                            fontFamily: 'SF Pro Display',
                            fontWeight: FontWeight.w500,
                            height: 1.40,
                          ),
                        ),
                        TextSpan(
                          text: courseStepDetails.isNotEmpty
                              ? courseStepDetails['course_step_description']
                              : "step description",
                          style: const TextStyle(
                            color: Color(0xFF1A1A1A),
                            fontSize: 20,
                            fontFamily: 'SF Pro Display',
                            fontWeight: FontWeight.w400,
                            height: 1.40,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  buildFacultyCard(courseStepDetails, authToken),
                  const SizedBox(height: 12),
                  const Text(
                    'Course overview',
                    style: TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 16,
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w500,
                      height: 1.50,
                    ),
                  ),
                  const SizedBox(height: 8),
                  buildCourseOverViewCard(
                      courseStepDetails.isNotEmpty
                          ? '${courseStepDetails['course_overview_hours_text']} on-demand video'
                          : "4 hours on-demand video",
                      "play2.svg"),
                  const SizedBox(height: 8),
                  buildCourseOverViewCard(
                      courseStepDetails.isNotEmpty
                          ? '${courseStepDetails['course_overview_downloadable_text']} downloadable resources'
                          : "5 downloadable resources",
                      "Download.svg"),
                  const SizedBox(height: 8),
                  buildCourseOverViewCard(
                      courseStepDetails.isNotEmpty
                          ? '${courseStepDetails['course_overview_access_time_text']} access'
                          : "Full lifetime access",
                      "Time.svg"),
                  const SizedBox(height: 8),
                  buildCourseOverViewCard(
                      courseStepDetails.isNotEmpty
                          ? '${courseStepDetails['no_of_test_text']} tests included for assessment'
                          : "4 tests included for assessment",
                      "Time (1).svg"),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            borderHorizontal(),
            Padding(
              padding: const EdgeInsets.all(12),
              child: buildTabBarCourse(
                _tabController,
                stepTabSelectedIndex,
                setState,
                videoData,
                chooseStepList,
                selectedStepId,
                (newStepId) {
                  // This callback will be called when step changes
                  setState(() {
                    selectedStepId = newStepId;
                    chooseStepList[0] = newStepId;
                    stepTabSelectedIndex[0] = newStepId - 1;
                  });
                  storage.write(
                    key: "selectedStepNo",
                    value: newStepId.toString(),
                  );
                  // Fetch new video data for the new step
                  // fetchVideoData();
                  fetchCourseStepDetails();
                },
                courseId, // e.g., 3
                subjectId, // e.g., 3
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildFacultyCard(courseStepDetails, String authToken) {
  return Container(
    padding: const EdgeInsets.all(12),
    clipBehavior: Clip.antiAlias,
    decoration: ShapeDecoration(
      color: const Color(0xFFF9F2FF),
      shape: RoundedRectangleBorder(
        side: const BorderSide(
          width: 1,
          color: Color(0xFFEEDBFF),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    child: Row(
      children: [
        Container(
          margin: const EdgeInsets.only(right: 12),
          width: 50,
          height: 50,
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            image: DecorationImage(
              image: courseStepDetails.isNotEmpty
                  ? NetworkImage(
                      '$baseurl/app/doctor-image/${courseStepDetails['doctor_profile_pic']}/$authToken')
                  : const AssetImage("assets/image/profile.jpg"),
              fit: BoxFit.cover,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: courseStepDetails.isNotEmpty
                        ? '${courseStepDetails['doctor_full_name']} '
                        : "Doctor Name ",
                    style: const TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 14,
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w500,
                      height: 1.57,
                    ),
                  ),
                  TextSpan(
                    text: courseStepDetails.isNotEmpty
                        ? ' ${courseStepDetails['doctor_practice_profession']} '
                        : "( Doctor Profession )",
                    style: const TextStyle(
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
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: courseStepDetails.isNotEmpty
                        ? '${courseStepDetails['doctor_education']} | '
                        : "Doctor Education | ",
                    style: const TextStyle(
                      color: Color(0xFF737373),
                      fontSize: 14,
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w400,
                      height: 1.57,
                    ),
                  ),
                  TextSpan(
                    text: courseStepDetails.isNotEmpty
                        ? '${courseStepDetails['years_of_experience']} exp'
                        : "15 years exp",
                    style: const TextStyle(
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
          ],
        )
      ],
    ),
  );
}

Widget buildCourseOverViewCard(String title, String icon) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      SizedBox(
          width: 24, height: 24, child: SvgPicture.asset("assets/icons/$icon")),
      const SizedBox(width: 12),
      Text(
        title,
        style: const TextStyle(
          color: Color(0xFF1A1A1A),
          fontSize: 14,
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w400,
          height: 1.57,
        ),
      ),
    ],
  );
}

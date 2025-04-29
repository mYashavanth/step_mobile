import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:step_mobile/widgets/common_widgets.dart';
import 'package:step_mobile/widgets/course_screen_widgets.dart';
import 'package:step_mobile/widgets/homepage_widgets.dart';
import 'package:step_mobile/views/urlconfig.dart';
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
  Map<String, dynamic> courseStepDetails = {}; // Initialize with an empty map
  var authToken = '';
  String selectedStepName = "STEP 1"; // Default value

  List<int> stepTabSelectedIndex = [0];

  List<Map> selectStepList = [
    {"name": "Step 1", "id": 1},
    {"name": "Step 2", "id": 2},
    {"name": "Step 3", "id": 3},
  ];

  List<int> chooseStepList = [0];

  @override
  void initState() {
    _tabController = TabController(length: 5, vsync: this);
    super.initState();
    _loadSelectedStep();
    fetchCourseStepDetails();
  }

  Future<void> _loadSelectedStep() async {
    const storage = FlutterSecureStorage();
    String? stepName = await storage.read(key: "selectedStepNo");
    if (stepName != null) {
      setState(() {
        selectedStepName = stepName;
      });
    }
  }

  Future<void> fetchCourseStepDetails() async {
    final token = await storage.read(key: 'token');
    authToken = token ?? '';
    if (authToken.isEmpty) {
      // Handle the case when the token is not available
      print("Token is not available");
      return;
    }
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final courseId = args['courseId'];
    final subjectId = args['subjectId'];
    try {
      // print(
      //     '$baseurl/app/get-course-step-details-details/$token/$courseId/$subjectId');
      final url = Uri.parse(
          '$baseurl/app/get-course-step-details-details/$token/$courseId/$subjectId');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          final courseStepDetailsData = data[0];
          final courseStepTitle = courseStepDetailsData['course_step_title'];
          final courseStepId = courseStepDetailsData['id'].toString();

          // Write to storage outside of setState
          await storage.write(key: "courseStepDetailId", value: courseStepId);

          // Update state synchronously
          setState(() {
            courseStepDetails = courseStepDetailsData;
            selectedStepName = courseStepTitle;
          });
        } else {
          setState(() {
            courseStepDetails = {};
          });
        }
      } else {
        // Handle error response
        print("Error fetching course step details: ${response.statusCode}");
      }
    } catch (e) {
      // Handle error
      print("Error fetching course step details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Course Step Details: $courseStepDetails");
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
                                        setState(() {
                                          selectedStepName = stepName;
                                        });
                                      },
                                    );
                                  });
                                });
                          },
                          child: Row(
                            children: [
                              Text(
                                selectedStepName,
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
                  const SizedBox(
                    height: 8,
                  ),
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
                  buildFacultyCard(
                      courseStepDetails, authToken), // faculty card

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
                          ? '${courseStepDetails['course_overview_hours_text']} hours on-demand video'
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
                  _tabController, stepTabSelectedIndex, setState),
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

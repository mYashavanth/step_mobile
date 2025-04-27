import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:step_mobile/views/notes.dart';
import 'package:step_mobile/widgets/homepage_widgets.dart';
import 'package:step_mobile/widgets/navbar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:step_mobile/views/urlconfig.dart';
import 'dart:math' as math;
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> courses = [];
  bool isLoadingCourses = true;
  String courseError = '';
  List<int> selectedCourseIds = [1]; // Default selected course

  // New state variables for subjects
  List<Map<String, dynamic>> subjects = [];
  bool isLoadingSubjects = true;
  String subjectError = '';

  @override
  void initState() {
    super.initState();
    _fetchCourses();
    _fetchSubjects();
  }

  Future<void> _fetchCourses() async {
    setState(() {
      isLoadingCourses = true;
      courseError = '';
    });

    final storage = const FlutterSecureStorage();

    try {
      String token = await storage.read(key: 'token') ?? '';

      final response = await http.get(
        Uri.parse('$baseurl/app/get-all-course-names/$token'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          courses = data
              .map((course) =>
                  {'name': course['course_name'], 'id': course['id']})
              .toList();
        });
      } else {
        throw Exception('Failed to load courses: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        courseError = 'Failed to load courses: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoadingCourses = false;
      });
    }
  }

  Future<void> _fetchSubjects() async {
    setState(() {
      isLoadingSubjects = true;
      subjectError = '';
    });

    final storage = const FlutterSecureStorage();

    try {
      String token = await storage.read(key: 'token') ?? '';
      int courseId = selectedCourseIds.isNotEmpty ? selectedCourseIds.first : 1;

      final response = await http.get(
        Uri.parse(
            '$baseurl/app/get-all-subjects-by-course-id/$token/$courseId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          subjects = data
              .map((subject) => {
                    'id': subject['id'],
                    'name': subject['subject_name'],
                  })
              .toList();
        });
      } else {
        throw Exception('Failed to load subjects: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        subjectError = 'Failed to load subjects: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoadingSubjects = false;
      });
    }
  }

  String get selectedCourseName {
    if (isLoadingCourses) return 'Loading...';
    if (courseError.isNotEmpty) return 'Error loading courses';
    if (courses.isEmpty) return 'No courses available';

    final selected = courses.firstWhere(
      (course) => course['id'] == selectedCourseIds.first,
      orElse: () => courses.first,
    );
    return selected['name'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () async {
          await _fetchCourses();
          await _fetchSubjects();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Hello ',
                                    style: TextStyle(
                                      color: Color(0xFF1A1A1A),
                                      fontSize: 16,
                                      fontFamily: 'SF Pro Display',
                                      fontWeight: FontWeight.w400,
                                      height: 1.50,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Rohan Canara ',
                                    style: TextStyle(
                                      color: Color(0xFF247E80),
                                      fontSize: 16,
                                      fontFamily: 'SF Pro Display',
                                      fontWeight: FontWeight.w700,
                                      height: 1.50,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '👋 ',
                                    style: TextStyle(
                                      color: Color(0xFF887E5B),
                                      fontSize: 16,
                                      fontFamily: 'SF Pro Display',
                                      fontWeight: FontWeight.w700,
                                      height: 1.50,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              if (courses.isEmpty) return;

                              showModalBottomSheet(
                                isScrollControlled: true,
                                context: context,
                                backgroundColor: Colors.transparent,
                                builder: (context) {
                                  return StatefulBuilder(
                                    builder: (BuildContext context,
                                        StateSetter modalSetState) {
                                      return buidSelectCourseBottomSheet(
                                          modalSetState,
                                          courses,
                                          selectedCourseIds,
                                          "Select your Course");
                                    },
                                  );
                                },
                              ).then((_) {
                                // When course selection changes, fetch subjects for the new course
                                _fetchSubjects();
                              });
                            },
                            child: Row(
                              children: [
                                Text(
                                  selectedCourseName,
                                  style: const TextStyle(
                                    color: Color(0xFF737373),
                                    fontSize: 14,
                                    fontFamily: 'SF Pro Display',
                                    fontWeight: FontWeight.w400,
                                    height: 1.57,
                                  ),
                                ),
                                const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Color(0xFF737373),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                                width: 2, color: Color(0xB231B5B9)),
                            borderRadius: BorderRadius.circular(50),
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
                            SvgPicture.asset("assets/icons/Group (6).svg"),
                            const SizedBox(width: 12),
                            const Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: '35',
                                    style: TextStyle(
                                      color: Color(0xFF1A1A1A),
                                      fontSize: 14,
                                      fontFamily: 'SF Pro Display',
                                      fontWeight: FontWeight.w400,
                                      height: 1.57,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '/',
                                    style: TextStyle(
                                      color: Color(0xFF1A1A1A),
                                      fontSize: 14,
                                      fontFamily: 'SF Pro Display',
                                      fontWeight: FontWeight.w500,
                                      height: 1.57,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '60',
                                    style: TextStyle(
                                      color: Color(0xFFFE7D14),
                                      fontSize: 14,
                                      fontFamily: 'SF Pro Display',
                                      fontWeight: FontWeight.w700,
                                      height: 1.57,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const CourseBanner(),
                const SizedBox(height: 20),
                const CalendarSection(),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                        child: homeStepsCard(
                            "TOTAL WATCH MINS", "238 Mins", "clock.svg")),
                    const SizedBox(width: 16),
                    Expanded(
                        child: homeStepsCard(
                            "STEPS COMPLETED", "23", "steps.svg")),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child:
                            homeStepsCard("TESTS ATTEMPTED", "5", "done.svg")),
                    const SizedBox(width: 16),
                    Expanded(
                        child: homeStepsCard(
                            "QUESTIONS ATTEMPTED", "85", "questions.svg")),
                  ],
                ),
                const SizedBox(height: 20),
                const UpcomingTests(),
                bannerNotes(),
                const Text(
                  'Resume learning',
                  style: TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 20,
                    fontFamily: 'SF Pro Display',
                    fontWeight: FontWeight.w500,
                    height: 1.40,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 310,
                  child: ListView(
                    itemExtent: 220,
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    children: [
                      buildVedioLearnCard(
                          'vedio1.png',
                          "Types of bones, joints, and cartilage",
                          "Teacher Name",
                          "Anatomy"),
                      buildVedioLearnCard('vedio1.png', "Epithelium types",
                          "Teacher Name", "Pediatrics"),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Step-wise course",
                      style: TextStyle(
                        color: Color(0xFF1A1A1A),
                        fontSize: 20,
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.w500,
                        height: 1.40,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, "/all_subjects");
                      },
                      child: const Text(
                        'View',
                        style: TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 14,
                          fontFamily: 'SF Pro Display',
                          fontWeight: FontWeight.w400,
                          height: 1.57,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (isLoadingSubjects)
                  const Center(child: CircularProgressIndicator())
                else if (subjectError.isNotEmpty)
                  Text(subjectError)
                else if (subjects.isEmpty)
                  const Text('No subjects available')
                else
                  ...subjects.asMap().entries.map((entry) {
                    int index = entry.key;
                    var subject = entry.value;
                    return Column(
                      children: [
                        buildStepWiseCourseCard(
                          (index + 1).toString().padLeft(2, '0'),
                          0, // All steps set to 0 as requested
                          subject['name'],
                          context,
                        ),
                        const SizedBox(height: 8),
                      ],
                    );
                  }).toList(),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: ShapeDecoration(
                    image: const DecorationImage(
                        image: AssetImage("assets/image/gradient_bg.jpg"),
                        fit: BoxFit.cover),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Spread the Success, Share STEP!',
                              style: TextStyle(
                                color: Color(0xFF003E40),
                                fontSize: 16,
                                fontFamily: 'SF Pro Display',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Text(
                              'Help your friends ace their exams with STEP - because success is better when shared!',
                              style: TextStyle(
                                color: Color(0xCC003F40),
                                fontSize: 14,
                                fontFamily: 'SF Pro Display',
                                fontWeight: FontWeight.w400,
                                height: 1.43,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: 170,
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF247E80),
                                ),
                                child: Row(
                                  children: [
                                    Transform.rotate(
                                      angle: 320 * math.pi / 180,
                                      child: const Icon(
                                        Icons.send_rounded,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Invite friends',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontFamily: 'SF Pro Display',
                                        fontWeight: FontWeight.w700,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: SvgPicture.asset("assets/icons/boy_writing.svg"),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const StepNavigationBar(0),
    );
  }
}

class CourseBanner extends StatelessWidget {
  const CourseBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      height: 248,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        // color: Colors.blue.shade100,
        image: const DecorationImage(
            image: AssetImage("assets/image/student.png"), fit: BoxFit.cover),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Join Course,  NEET-PG 2025',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontFamily: 'SF Pro Display',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Text(
                  'Your shortcut to NEET-PG success!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontFamily: 'SF Pro Display',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Row(
                  children: [
                    Icon(
                      Icons.star_rate_rounded,
                      color: Color(0xFFFFC107),
                      size: 20,
                    ),
                    Text(
                      'Recorded Classes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.w400,
                      ),
                    )
                  ],
                ),
                const Row(
                  children: [
                    Icon(
                      Icons.star_rate_rounded,
                      color: Color(0xFFFFC107),
                      size: 20,
                    ),
                    Text(
                      'Mock Tests',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.w400,
                      ),
                    )
                  ],
                ),
                const Row(
                  children: [
                    Icon(
                      Icons.star_rate_rounded,
                      color: Color(0xFFFFC107),
                      size: 20,
                    ),
                    Text(
                      'Study Materials',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.w400,
                      ),
                    )
                  ],
                ),
                ElevatedButton(
                  style: ButtonStyle(backgroundColor: getColor()),
                  onPressed: () {},
                  child: const Text(
                    'Enroll Now @ ₹1000',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.7,
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Row(
                  children: [
                    Icon(
                      Icons.date_range_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Text(
                      "Mar 17",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      " onwards",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          const Expanded(
            flex: 1,
            child: Column(),
          ),
        ],
      ),
    );
  }
}

List<String> weeksList = ['SUN', "MON", "TUE", "WED", "THUR", "FRI", "SAT"];

class CalendarSection extends StatefulWidget {
  const CalendarSection({super.key});

  @override
  State<CalendarSection> createState() => _CalendarSectionState();
}

class _CalendarSectionState extends State<CalendarSection> {
  List<bool> statusSelectList = [false, false, false];
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Calendar of events",
              style: TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 20,
                fontFamily: 'SF Pro Display',
                fontWeight: FontWeight.w500,
                height: 1.40,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, "/calendar_view");
              },
              child: const Text(
                'View',
                style: TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 14,
                  fontFamily: 'SF Pro Display',
                  fontWeight: FontWeight.w400,
                  height: 1.57,
                ),
              ),
            )
          ],
        ),
        const SizedBox(height: 16),
        const Row(
          children: [
            Text(
              "2025/Jan",
              style: TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 16,
                fontFamily: 'SF Pro Display',
                fontWeight: FontWeight.w500,
                height: 1,
              ),
            ),
            Text(
              " Exam in 34 days",
              style: TextStyle(
                color: Color(0xFFFE860A),
                fontSize: 12,
                fontFamily: 'SF Pro Display',
                fontWeight: FontWeight.w500,
                height: 1,
              ),
            )
          ],
        ),
        const SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.all(4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              return Text(
                weeksList[index],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 12,
                  fontFamily: 'SF Pro Display',
                  fontWeight: FontWeight.w500,
                  height: 1.67,
                ),
              );
            }),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              return Column(
                children: [
                  Text(
                    "${index + 1}",
                    style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.w400,
                        color: index == 5 ? Colors.orange : Colors.black),
                  ),
                  if (index == 5)
                    const Icon(Icons.circle, color: Colors.orange, size: 8),
                ],
              );
            }),
          ),
        ),
        GestureDetector(
          onTap: () {
            statusSelectList[0] = true;
            statusSelectList[1] = false;
            statusSelectList[2] = false;
            setState(() {});
          },
          child: buildStatusCard(
              true, 'list2.svg', statusSelectList[0], "Pre-Test"),
        ),
        const SizedBox(
          height: 12,
        ),
        GestureDetector(
          onTap: () {
            statusSelectList[0] = false;
            statusSelectList[1] = true;
            statusSelectList[2] = false;
            setState(() {});
          },
          child: buildStatusCard(
              false, 'vedio.svg', statusSelectList[1], "Videos Lessons"),
        ),
        const SizedBox(
          height: 12,
        ),
        GestureDetector(
          onTap: () {
            statusSelectList[0] = false;
            statusSelectList[1] = false;
            statusSelectList[2] = true;
            setState(() {});
          },
          child: buildStatusCard(
              false, 'list2.svg', statusSelectList[2], "Post-lesson test"),
        ),
        const SizedBox(
          height: 12,
        ),
      ],
    );
  }
}

class UpcomingTests extends StatelessWidget {
  const UpcomingTests({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Upcoming test events',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 20,
            fontFamily: 'SF Pro Display',
            fontWeight: FontWeight.w500,
            height: 1.40,
          ),
        ),
        SizedBox(height: 10),
        TestCard(
          date: "22\nJan",
          title: "Step 4 - Pre test",
          details: "35 MCQs | 1 Day to go",
          color: Color(0xFF289799),
          borderColor: Color(0x7F58C9CC),
          bodyColor: Color(0x0C31B5B9),
        ),
        SizedBox(height: 10),
        TestCard(
          date: "25\nJan",
          title: "Weekly test",
          details: "60 MCQs | 4 Days to go",
          color: Color(0xFFE36600),
          borderColor: Color(0x7FFE860A),
          bodyColor: Color(0x0CFE7D14),
        ),
      ],
    );
  }
}

class TestCard extends StatelessWidget {
  final String date, title, details;
  final Color color, borderColor, bodyColor;

  const TestCard(
      {super.key,
      required this.date,
      required this.title,
      required this.details,
      required this.bodyColor,
      required this.borderColor,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: ShapeDecoration(
        color: bodyColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: borderColor),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 50,
            padding:
                const EdgeInsets.only(top: 7, left: 13, right: 12, bottom: 7),
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: color,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
            ),
            child: Center(
              child: Text(
                date,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontFamily: 'SF Pro Display',
                  fontWeight: FontWeight.w500,
                  height: 1.50,
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 12,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              Text(
                details,
                style: const TextStyle(
                  color: Color(0xFF737373),
                  fontSize: 12,
                  fontFamily: 'SF Pro Display',
                  fontWeight: FontWeight.w400,
                  height: 1.67,
                ),
              )
            ],
          ),
          const Spacer(),
          const Center(
            child: Icon(Icons.keyboard_arrow_right),
          )
        ],
      ),
    );
  }
}

WidgetStateProperty<Color> getColor() {
  return WidgetStateProperty.all(const Color(0xFF31B5B9));
}

WidgetStateProperty<Size> getFullWidth() {
  return WidgetStateProperty.all(
      const Size(double.infinity, double.maxFinite));
}

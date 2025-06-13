import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ghastep/widgets/homepage_widgets.dart';
import 'package:ghastep/widgets/navbar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ghastep/views/urlconfig.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final storage = const FlutterSecureStorage();

  int videosWatched = 0;
  bool isLoadingVideosWatched = false;
  String videosWatchedError = '';
  int testsAttempted = 0;
  int questionsAttempted = 0;
  int stepsCompleted = 0;
  int totalSteps = 0;
  bool isLoadingMetrics = false;
  String metricsError = '';

  String userName = '';

  List<Map> selectCourseData = [
    {"name": "NEET PG (2025)", "id": 1},
    {"name": "FMGE ( June - 2025 )", "id": 2},
    {"name": "JEE ( June - 2025 )", "id": 3},
  ];
  List<int> selectedCourse = [1];

  @override
  void initState() {
    super.initState();
    _loadUserName();
    fetchUserMetrics();
  }

  Future<void> _loadUserName() async {
    final storedUserName = await storage.read(key: 'userName');
    setState(() {
      userName = storedUserName ?? 'User';
    });
  }

  Future<void> fetchUserMetrics() async {
    final token = await storage.read(key: 'token') ?? '';
    final courseId = await storage.read(key: 'selectedCourseId') ?? '';
    final subjectId = await storage.read(key: 'selectedSubjectId') ?? '';

    if (courseId.isEmpty || subjectId.isEmpty || token.isEmpty) {
      setState(() {
        videosWatched = 0;
        testsAttempted = 0;
        questionsAttempted = 0;
        stepsCompleted = 0;
        totalSteps = 0;
      });
      return;
    }

    setState(() {
      isLoadingVideosWatched = true;
      isLoadingMetrics = true;
      videosWatchedError = '';
      metricsError = '';
    });

    try {
      // First API call - Videos Watched
      final videosResponse = await http.get(Uri.parse(
          '$baseurl/app/no-of-video-watched/$courseId/$subjectId/$token'));

      if (videosResponse.statusCode == 200) {
        final List<dynamic> videosData = json.decode(videosResponse.body);
        print(
            '+++++++++++++++++++++++++++Videos watched response: ${videosResponse.statusCode} ${videosResponse.body}');
        if (videosData.isNotEmpty &&
            videosData[0]['no_of_videos_watched'] != null) {
          setState(() {
            videosWatched = videosData[0]['no_of_videos_watched'] ?? 0;
          });
        }
      } else {
        print(
            '+++++++++++++++++++++++++++Failed to load videos watched: ${videosResponse.statusCode}');
      }

      // Second API call - Tests/Questions/Steps
      final metricsResponse = await http.get(Uri.parse(
          '$baseurl/app/home/tests-questions-steps/$token/$courseId/$subjectId'));
      print(
          '+++++++++++++++++++++++++++Metrics metricsResponse: ${metricsResponse.statusCode} ${metricsResponse.body}');
      if (metricsResponse.statusCode == 200) {
        final metricsData = json.decode(metricsResponse.body);
        if (metricsData.isNotEmpty) {
          setState(() {
            testsAttempted = metricsData['totalTestAttempted'] ?? 0;
            questionsAttempted = metricsData['totalQuestionsAtempted'] ?? 0;
            stepsCompleted = metricsData['totalStepsCompleted'] ?? 0;
            totalSteps = metricsData['totalSteps'] ?? 0;
          });
        }
      } else {
        print(
            '+++++++++++++++++++++++++++Failed to load metrics: ${metricsResponse.statusCode}');
      }
    } catch (e) {
      setState(() {
        videosWatchedError = e.toString();
        metricsError = e.toString();
        videosWatched = 0;
        testsAttempted = 0;
        questionsAttempted = 0;
        stepsCompleted = 0;
        totalSteps = 0;
      });
    } finally {
      setState(() {
        isLoadingVideosWatched = false;
        isLoadingMetrics = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(12),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Hello ',
                                  style: TextStyle(
                                    color: Color(0xFF1A1A1A),
                                    fontSize: 16,
                                    fontFamily: 'SF Pro Display',
                                    fontWeight: FontWeight.w400,
                                    height: 1.50,
                                  ),
                                ),
                                const TextSpan(
                                  text: '👋 ',
                                  style: TextStyle(
                                    color: Color(0xFF887E5B),
                                    fontSize: 16,
                                    fontFamily: 'SF Pro Display',
                                    fontWeight: FontWeight.w700,
                                    height: 1.50,
                                  ),
                                ),
                                TextSpan(
                                  text: userName,
                                  style: const TextStyle(
                                    color: Color(0xFF247E80),
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
                        // InkWell(
                        //   onTap: () {
                        //     showModalBottomSheet(
                        //         isScrollControlled: true,
                        //         context: context,
                        //         backgroundColor: Colors.transparent,
                        //         builder: (context) {
                        //           return StatefulBuilder(builder:
                        //               (BuildContext context,
                        //                   StateSetter modalSetState) {
                        //             return buidSelectCourseBottomSheet(
                        //                 context,
                        //                 modalSetState,
                        //                 selectCourseData,
                        //                 selectedCourse,
                        //                 "Select your Course");
                        //           });
                        //         });
                        //   },
                        //   child: const Row(
                        //     children: [
                        //       Text(
                        //         'NEET - PG (2025)',
                        //         style: TextStyle(
                        //           color: Color(0xFF737373),
                        //           fontSize: 14,
                        //           fontFamily: 'SF Pro Display',
                        //           fontWeight: FontWeight.w400,
                        //           height: 1.57,
                        //         ),
                        //       ),
                        //       Icon(
                        //         Icons.keyboard_arrow_down,
                        //         color: Color(0xFF737373),
                        //       )
                        //     ],
                        //   ),
                        // )
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
                          const SizedBox(
                            width: 12,
                          ),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: stepsCompleted.toString(),
                                  style: const TextStyle(
                                    color: Color(0xFF1A1A1A),
                                    fontSize: 14,
                                    fontFamily: 'SF Pro Display',
                                    fontWeight: FontWeight.w400,
                                    height: 1.57,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const TextSpan(
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
                                const TextSpan(
                                  text: "60",
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
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                            onTap: () {
                              Navigator.pushNamed(context, "/settings");
                            },
                            child:
                                buildProfileCard("Settings", "settings.svg")),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            profileBannerNotes(context),
            Container(
              margin: const EdgeInsets.only(top: 6, bottom: 6),
              padding: const EdgeInsets.all(12),
              color: Colors.white,
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Overall statistics",
                        style: TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 20,
                          fontFamily: 'SF Pro Display',
                          fontWeight: FontWeight.w500,
                          height: 1.40,
                        ),
                      ),
                      Text(
                        "All time",
                        style: TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 14,
                          fontFamily: 'SF Pro Display',
                          fontWeight: FontWeight.w400,
                          height: 1.57,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: homeStepsCard(
                            "VIDEOS WATCHED",
                            isLoadingVideosWatched
                                ? "Loading..."
                                : "$videosWatched",
                            "clock.svg"),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: homeStepsCard(
                            "STEPS COMPLETED",
                            isLoadingMetrics ? "Loading..." : "$stepsCompleted",
                            "steps.svg"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: homeStepsCard(
                            "TESTS ATTEMPTED",
                            isLoadingMetrics ? "Loading..." : "$testsAttempted",
                            "done.svg"),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: homeStepsCard(
                            "QUESTIONS ATTEMPTED",
                            isLoadingMetrics
                                ? "Loading..."
                                : "$questionsAttempted",
                            "questions.svg"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const StepNavigationBar(3),
    );
  }
}

Widget buildProfileCard(String title, String icon) {
  return Container(
    margin: const EdgeInsets.only(left: 6, right: 6),
    clipBehavior: Clip.antiAlias,
    padding: const EdgeInsets.all(12),
    decoration: ShapeDecoration(
      color: const Color(0xFFF3F4F6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    child: Row(
      children: [
        SvgPicture.asset("assets/icons/profile/$icon"),
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
        )
      ],
    ),
  );
}

Widget profileBannerNotes(BuildContext context) {
  return Container(
    color: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Container(
      height: 240,
      width: double.maxFinite,
      decoration: const ShapeDecoration(
        image: DecorationImage(
            image: AssetImage("assets/image/subscribe-to-premium-package.jpg"),
            fit: BoxFit.fitWidth),
        shape: RoundedRectangleBorder(),
      ),
      child: Column(
        children: [
          const SizedBox(
            height: 16,
          ),
          const Text(
            'Get Unlimited Accesss',
            style: TextStyle(
              color: Color(0xFFEB7700),
              fontSize: 20,
              fontFamily: 'SF Pro Display',
              fontWeight: FontWeight.w700,
              height: 1.40,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 64),
            child: Text(
              'Get access to 60+ recorded sessions, 200+ videos, Downloadable resources & 60+ practice tests',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xCCEC7800),
                fontSize: 14,
                fontFamily: 'SF Pro Display',
                fontWeight: FontWeight.w400,
                height: 1.43,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle button press
              Navigator.pushNamed(context, "/subscribe");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFE860A),
            ),
            child: const Text(
              'Enroll Now',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'SF Pro Display',
                fontWeight: FontWeight.w500,
                height: 1.50,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

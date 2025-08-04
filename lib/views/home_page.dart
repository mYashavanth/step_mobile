import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ghastep/services/iap_payment_screen.dart';
import 'package:ghastep/services/phonepe_payment_screen.dart';
import 'package:ghastep/widgets/payment_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ghastep/views/notes.dart';
import 'package:ghastep/widgets/homepage_widgets.dart';
import 'package:ghastep/widgets/navbar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ghastep/views/urlconfig.dart';
import 'dart:math' as math;
import 'package:share_plus/share_plus.dart';

final GlobalKey<_HomePageState> homePageKey = GlobalKey<_HomePageState>();

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: homePageKey);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final storage = const FlutterSecureStorage();
  var token = '';

  int videosWatched = 0;
  bool isLoadingVideosWatched = false;
  String videosWatchedError = '';
  int testsAttempted = 0;
  int questionsAttempted = 0;
  int stepsCompleted = 0;
  int totalSteps = 0;
  bool isLoadingMetrics = false;
  String metricsError = '';

  List<Map<String, dynamic>> resumeVideos = [];
  bool isLoadingResumeVideos = false;
  String resumeVideosError = '';

  List<Map<String, dynamic>> courses = [];
  bool isLoadingCourses = true;
  String courseError = '';
  List<int> selectedCourseIds = [1]; // Default selected course
  String userName = ''; // Variable to store the username

  // New state variables for subjects
  List<Map<String, dynamic>> subjects = [];
  bool isLoadingSubjects = true;
  String subjectError = '';
  String bannerImage = '';

  int? daysToExam; // Add this variable
  dynamic examDateApiResponse; // Add this variable

  // Add this method
  Future<void> _fetchExamDate() async {
    final storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'token');
    if (token == null) return;

    try {
      final response =
          await http.get(Uri.parse('$baseurl/app/exam-date/$token'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty && data[0]['neet_exam_date'] != null) {
          final examDateStr = data[0]['neet_exam_date'];
          final parts = examDateStr.split('-');
          if (parts.length == 3) {
            final examDate = DateTime(
              int.parse(parts[2]),
              int.parse(parts[1]),
              int.parse(parts[0]),
            );
            final today = DateTime.now();
            final diff = examDate.difference(today).inDays;
            setState(() {
              daysToExam = diff;
              examDateApiResponse = data;
            });
          }
        }
      }
    } catch (e) {
      print("Error fetching exam date: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _initializeState();
    _loadAuthToken();
    _fetchExamDate(); // Fetch exam date on initialization
  }

  Future<void> _loadAuthToken() async {
    token = await storage.read(key: 'token') ?? '';
    setState(() {});
  }

  Future<void> _initializeState() async {
    _fetchCourses();
    _fetchSubjects();
    _fetchBannerImages();
    final storedId = await storage.read(key: 'selectedCourseId');
    if (storedId == null) {
      // Store default course ID if none exists
      await storage.write(key: 'selectedCourseId', value: '1');
      setState(() {
        selectedCourseIds = [1]; // Set to course ID
      });
    } else {
      setState(() {
        selectedCourseIds = [int.parse(storedId)];
      });
    }
    fetchUserMetrics();
    fetchResumeVideos();
  }

  Future<void> fetchResumeVideos() async {
    setState(() {
      isLoadingResumeVideos = true;
      resumeVideosError = '';
    });

    try {
      String token = await storage.read(key: 'token') ?? '';
      final response = await http.get(
        Uri.parse('$baseurl/app/video/resume-list/$token'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // print(
        //     '+++++++++++++++++++++++++++Resume videos response: ${response.statusCode} ${response.body}');
        if (data['errFlag'] == 0 && data['data'] != null) {
          setState(() {
            resumeVideos = List<Map<String, dynamic>>.from(data['data']);
          });
        }
      } else {
        setState(() {
          resumeVideosError = 'Failed to load resume videos';
        });
      }
    } catch (e) {
      setState(() {
        resumeVideosError = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoadingResumeVideos = false;
      });
    }
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
        // print(
        //     '+++++++++++++++++++++++++++Videos watched response: ${videosResponse.statusCode} ${videosResponse.body}');
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
      // print(
      //     '+++++++++++++++++++++++++++Metrics metricsResponse: ${metricsResponse.statusCode} ${metricsResponse.body}');
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

  Future<void> _loadUserName() async {
    final storedUserName = await storage.read(key: 'userName');
    setState(() {
      userName = storedUserName ?? 'User'; // Default to 'User' if not found
    });
  }

  Future<void> _fetchCourses() async {
    setState(() {
      isLoadingCourses = true;
      courseError = '';
    });

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
        print('Failed to load courses: ${response.statusCode}');
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
    final storedCourseId = await storage.read(key: 'selectedCourseId');
    setState(() {
      isLoadingSubjects = true;
      subjectError = '';
    });

    try {
      String token = await storage.read(key: 'token') ?? '';
      int courseId = storedCourseId != null ? int.parse(storedCourseId) : 1;

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
                    'total_minutes': subject['total_minutes'],
                    'total_duration': subject['total_duration'],
                    'total_steps': subject['total_steps'],
                  })
              .toList();
        });
      } else {
        print('Failed to load subjects: ${response.statusCode}');
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

  List<String> bannerImages = []; // Change from String to List<String>

  Future<void> _fetchBannerImages() async {
    const storage = FlutterSecureStorage();
    try {
      // Retrieve the token from secure storage
      String? token = await storage.read(key: 'token');
      if (token == null) {
        print('No token found in secure storage.');
        return;
      }

      // API call to fetch banner images
      final response = await http.get(
        Uri.parse('$baseurl/app/display-ad-banners/$token'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // Parse the response
        final data = json.decode(response.body);

        // Store the response in secure storage
        await storage.write(key: 'bannerImages', value: json.encode(data));

        // Print the response
        print('Banner Images Response: $data');
        _setHomePageBannerImage(data);
      } else {
        print('Failed to fetch banner images: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching banner images: $e');
    }
  }

  void _setHomePageBannerImage(List<dynamic> banners) async {
    List<String> images = [];
    String token = await storage.read(key: 'token') ?? '';
    for (var banner in banners) {
      if (banner['banner_title'] == 'home_page') {
        String imageUrl =
            '$baseurl/app/ad-banners/display/$token/${banner['banner_image_name']}';
        images.add(imageUrl);
      }
    }
    setState(() {
      bannerImages = images;
    });
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
          await _fetchBannerImages();
        },
        child: SafeArea(
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
                                            context,
                                            modalSetState,
                                            courses,
                                            selectedCourseIds,
                                            "Select your Course");
                                      },
                                    );
                                  },
                                ).then((_) async {
                                  // When course selection changes, fetch subjects for the new course

                                  await storage.write(
                                    key: 'selectedCourseId',
                                    value: selectedCourseIds.first.toString(),
                                  );

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
                                      style: const TextStyle(
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
                  // Initialize PhonePe (only needed for Android)
                  // Call this once at app startup
                  // await PaymentService.initializePhonePe('SANDBOX'); // or 'PRODUCTION'

                  // In your widget tree:
                  // PlatformPaymentButton(
                  //   amount: 100.0,
                  //   merchantTransactionId:
                  //       'txn_${DateTime.now().millisecondsSinceEpoch}',
                  //   mobileNumber: '9876543210',
                  //   productName: 'Premium Subscription',
                  //   onSuccess: () {
                  //     ScaffoldMessenger.of(context).showSnackBar(
                  //       const SnackBar(content: Text('Payment successful!')),
                  //     );
                  //   },
                  //   onError: (error) {
                  //     ScaffoldMessenger.of(context).showSnackBar(
                  //       SnackBar(content: Text('Payment failed: $error')),
                  //     );
                  //   },
                  // ),

                  // ElevatedButton(
                  //   onPressed: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //           builder: (context) => const PhonePePaymentScreen()),
                  //     );
                  //   },
                  //   child: const Text('Make Payment'),
                  // ),
                  // ElevatedButton(
                  //   onPressed: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //           builder: (context) => const IAPPage()),
                  //     );
                  //   },
                  //   child: const Text('IAP Payment'),
                  // ),

                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Days Remaining
                        Expanded(
                          child: Column(
                            children: [
                              const Text(
                                "DAYS REMAINING",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '$daysToExam DAYS',
                                style: const TextStyle(
                                  color: Color(0xFF247E80), // Teal shade
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.grey.shade300,
                        ),
                        // Steps Remaining
                        Expanded(
                          child: Column(
                            children: [
                              const Text(
                                "STEPS REMAINING",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "${60 - stepsCompleted} STEPS",
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const CalendarSection(),
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
                  const SizedBox(height: 20),
                  // const UpcomingTests(),
                  // bannerNotes(context),

                  CourseBannerCarousel(bannerImages: bannerImages),
                  const SizedBox(height: 20),
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
                  if (isLoadingResumeVideos)
                    const Center(child: CircularProgressIndicator())
                  else if (resumeVideosError.isNotEmpty)
                    Text(resumeVideosError)
                  else if (resumeVideos.isEmpty)
                    const Text('No videos to resume')
                  else
                    SizedBox(
                      height: 310,
                      child: ListView(
                        itemExtent: 270,
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        children: resumeVideos.map((video) {
                          return buildVedioLearnCard(
                            token: token,
                            imagePath: 'vedio1.png',
                            bannerImageUrl:
                                video['banner_image_name']?.toString(),
                            title:
                                video['video_title']?.toString() ?? 'No title',
                            teacherName: video['doctor_name']?.toString() ??
                                'Unknown teacher',
                            duration:
                                video['video_duration_in_mins']?.toString() ??
                                    '0',
                            videoId: int.tryParse(
                                video['videoLearningId']?.toString() ?? '0'),
                            videoUrl: video['videoLink']?.toString() ?? '',
                            videoPauseTime:
                                video['video_pause_time']?.toString(),
                            subjectName:
                                video['subject_name']?.toString() ?? '',
                            context: context,
                          );
                        }).toList(),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Step-wise Subjects",
                        style: TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 20,
                          fontFamily: 'SF Pro Display',
                          fontWeight: FontWeight.w500,
                          height: 1.40,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (isLoadingSubjects)
                    const Center(child: CircularProgressIndicator())
                  else if (subjectError.isNotEmpty)
                    Text(subjectError)
                  else if (subjects.isEmpty)
                    const Text('No subjects available')
                  else
                    Column(
                      children: [
                        // Display only 4 subjects instead of 5
                        ...subjects
                            .asMap()
                            .entries
                            .take(subjects.length > 4 ? 4 : subjects.length)
                            .map((entry) {
                          int index = entry.key;
                          var subject = entry.value;
                          return Column(
                            children: [
                              buildStepWiseCourseCard(
                                (index + 1).toString().padLeft(2, '0'),
                                1, // 0 = unlocked, 1 = locked, 2 = completed
                                subject['name'],
                                subject['id'].toString(),
                                context,
                                totalMinutes: subject['total_minutes'],
                                totalDuration: subject['total_duration'],
                                totalSteps: subject['total_steps'],
                              ),
                              const SizedBox(height: 8),
                            ],
                          );
                        }).toList(),
                        // Add the "View All" button in place of the 5th subject
                        if (subjects.length > 4)
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, "/all_subjects");
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFC7F3F4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              child: const Text(
                                'View All Subjects',
                                style: TextStyle(
                                  color: Color(0xFF247E80),
                                  fontSize: 16,
                                  fontFamily: 'SF Pro Display',
                                  fontWeight: FontWeight.w500,
                                  height: 1.50,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),

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
                                  onPressed: () {
                                    Share.share(
                                        "Hey! I’ve been using the Global Healthcare Academy NEET PG App and it’s a game-changer for NEET PG prep — structured video lectures, MCQs with explanations, study planners, and more. "
                                        "If you’re preparing too, I’d highly recommend checking it out. Let’s crack NEET PG together!\n"
                                        "https://play.google.com/store/apps/details?id=com.ghastep&pcampaignid=web_share");
                                  },
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
                          child:
                              SvgPicture.asset("assets/icons/boy_writing.svg"),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const StepNavigationBar(0),
    );
  }
}

class CourseBanner extends StatelessWidget {
  final String bannerImage;

  const CourseBanner({super.key, required this.bannerImage});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      height: 248,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image:
              //  bannerImage.isNotEmpty?
              DecorationImage(
            image: NetworkImage(bannerImage), // Use the fetched image URL
            fit: BoxFit.cover,
          )
          // : const DecorationImage(
          //     image: AssetImage("assets/image/student.png"), // Fallback image
          //     fit: BoxFit.cover,
          //   ),
          ),
      // child: Row(
      //   children: [
      //     Expanded(
      //       flex: 2,
      //       child: Column(
      //         crossAxisAlignment: CrossAxisAlignment.start,
      //         children: [
      //           const Text(
      //             'Join Course,  NEET-PG 2025',
      //             style: TextStyle(
      //               color: Colors.white,
      //               fontSize: 20,
      //               fontFamily: 'SF Pro Display',
      //               fontWeight: FontWeight.w700,
      //             ),
      //           ),
      //           const Text(
      //             'Your shortcut to NEET-PG success!',
      //             style: TextStyle(
      //               color: Colors.white,
      //               fontSize: 12,
      //               fontFamily: 'SF Pro Display',
      //               fontWeight: FontWeight.w400,
      //             ),
      //           ),
      //           const Row(
      //             children: [
      //               Icon(
      //                 Icons.star_rate_rounded,
      //                 color: Color(0xFFFFC107),
      //                 size: 20,
      //               ),
      //               Text(
      //                 'Recorded Classes',
      //                 style: TextStyle(
      //                   color: Colors.white,
      //                   fontSize: 10,
      //                   fontFamily: 'SF Pro Display',
      //                   fontWeight: FontWeight.w400,
      //                 ),
      //               )
      //             ],
      //           ),
      //           const Row(
      //             children: [
      //               Icon(
      //                 Icons.star_rate_rounded,
      //                 color: Color(0xFFFFC107),
      //                 size: 20,
      //               ),
      //               Text(
      //                 'Mock Tests',
      //                 style: TextStyle(
      //                   color: Colors.white,
      //                   fontSize: 10,
      //                   fontFamily: 'SF Pro Display',
      //                   fontWeight: FontWeight.w400,
      //                 ),
      //               )
      //             ],
      //           ),
      //           const Row(
      //             children: [
      //               Icon(
      //                 Icons.star_rate_rounded,
      //                 color: Color(0xFFFFC107),
      //                 size: 20,
      //               ),
      //               Text(
      //                 'Study Materials',
      //                 style: TextStyle(
      //                   color: Colors.white,
      //                   fontSize: 10,
      //                   fontFamily: 'SF Pro Display',
      //                   fontWeight: FontWeight.w400,
      //                 ),
      //               )
      //             ],
      //           ),
      //           ElevatedButton(
      //             style: ButtonStyle(backgroundColor: getColor()),
      //             onPressed: () {},
      //             child: const Text(
      //               'Enroll Now @ ₹1000',
      //               style: TextStyle(
      //                 color: Colors.white,
      //                 fontSize: 13.7,
      //                 fontFamily: 'SF Pro Display',
      //                 fontWeight: FontWeight.w700,
      //               ),
      //             ),
      //           ),
      //           const Row(
      //             children: [
      //               Icon(
      //                 Icons.date_range_outlined,
      //                 color: Colors.white,
      //                 size: 24,
      //               ),
      //               SizedBox(
      //                 width: 4,
      //               ),
      //               Text(
      //                 "Mar 17",
      //                 style: TextStyle(
      //                   color: Colors.white,
      //                   fontSize: 10,
      //                   fontFamily: 'SF Pro Display',
      //                   fontWeight: FontWeight.w700,
      //                 ),
      //               ),
      //               Text(
      //                 " onwards",
      //                 style: TextStyle(
      //                   color: Colors.white,
      //                   fontSize: 10,
      //                   fontFamily: 'SF Pro Display',
      //                   fontWeight: FontWeight.w400,
      //                 ),
      //               ),
      //             ],
      //           )
      //         ],
      //       ),
      //     ),
      //     const Expanded(
      //       flex: 1,
      //       child: Column(),
      //     ),
      //   ],
      // ),
    );
  }
}

class CourseBannerCarousel extends StatefulWidget {
  final List<String> bannerImages;
  const CourseBannerCarousel({super.key, required this.bannerImages});

  @override
  State<CourseBannerCarousel> createState() => _CourseBannerCarouselState();
}

class _CourseBannerCarouselState extends State<CourseBannerCarousel> {
  late final PageController _controller;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = PageController();

    // The key change is here: We wait until the widget is built before starting the timer.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _startAutoScroll();
      }
    });
  }

  void _startAutoScroll() {
    _timer?.cancel(); // Cancel any existing timer
    if (widget.bannerImages.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        // Check if the controller has clients (i.e., is attached to a PageView)
        if (_controller.hasClients) {
          int nextPage = _controller.page!.round() + 1;
          _controller.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  void didUpdateWidget(CourseBannerCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bannerImages.length != widget.bannerImages.length) {
      _currentPage = 0;
      if (_controller.hasClients) {
        _controller.jumpToPage(0);
      }
      _startAutoScroll(); // Restart scrolling logic if images change
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.bannerImages.isEmpty) {
      return const SizedBox(height: 248); // Placeholder
    }

    // Infinite scroll implementation
    final int itemCount = widget.bannerImages.length > 1
        ? 10000 // Large number for infinite feel
        : 1;

    return SizedBox(
      height: 248,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: itemCount,
            onPageChanged: (index) {
              if (mounted) {
                setState(() {
                  _currentPage = index % widget.bannerImages.length;
                });
              }
              // Reset timer on manual swipe to avoid weird double-scroll behavior
              _startAutoScroll();
            },
            itemBuilder: (context, index) {
              final imageIndex = index % widget.bannerImages.length;
              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/subscribe');
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(widget.bannerImages[imageIndex]),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
          if (widget.bannerImages.length > 1)
            Positioned(
              bottom: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.bannerImages.length, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _currentPage == index ? 16 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color:
                          _currentPage == index ? Colors.white : Colors.white54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}

List<String> weeksList = ['SUN', "MON", "TUE", "WED", "THU", "FRI", "SAT"];

DateTime today = DateTime.now();
int weekday = today.weekday; // 1 (Mon) - 7 (Sun)
DateTime weekStart = today.subtract(Duration(days: weekday - 1)); // Monday
List<DateTime> weekDates =
    List.generate(7, (i) => weekStart.add(Duration(days: i)));

class CalendarSection extends StatefulWidget {
  const CalendarSection({super.key});

  @override
  State<CalendarSection> createState() => _CalendarSectionState();
}

class _CalendarSectionState extends State<CalendarSection> {
  List<bool> statusSelectList = [false, false, false];

  int? daysToExam; // Add this variable
  dynamic examDateApiResponse; // Add this variable

  @override
  void initState() {
    super.initState();
    _fetchExamDate();
  }

  Future<void> _fetchExamDate() async {
    final storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'token');
    if (token == null) return;

    try {
      final response =
          await http.get(Uri.parse('$baseurl/app/exam-date/$token'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty && data[0]['neet_exam_date'] != null) {
          final examDateStr = data[0]['neet_exam_date']; // e.g., "15-06-2025"
          final parts = examDateStr.split('-');
          if (parts.length == 3) {
            final examDate = DateTime(
              int.parse(parts[2]), // year
              int.parse(parts[1]), // month
              int.parse(parts[0]), // day
            );
            final today = DateTime.now();
            final diff = examDate.difference(today).inDays;
            setState(() {
              daysToExam = diff;
              examDateApiResponse = data; // Store the full response
            });
          }
        }
      }
    } catch (e) {
      print("Error fetching exam date: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateTime today = DateTime.now();
    final int weekday = today.weekday; // 1 (Mon) - 7 (Sun)
    final DateTime weekStart =
        today.subtract(Duration(days: weekday - 1)); // Monday as start
    final List<DateTime> weekDates =
        List.generate(7, (i) => weekStart.add(Duration(days: i)));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Your steps journey",
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
                Navigator.pushNamed(
                  context,
                  "/calendar_view",
                  arguments: {
                    'examDateData':
                        examDateApiResponse, // Pass the full response
                  },
                );
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
        Row(
          children: [
            Text(
              "${DateTime.now().year}/${_monthName(DateTime.now().month)}",
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 16,
                fontFamily: 'SF Pro Display',
                fontWeight: FontWeight.w500,
                height: 1,
              ),
            ),
            const Spacer(),
            Text(
              daysToExam != null
                  ? " Exam in $daysToExam days"
                  : " Exam in ... days",
              style: const TextStyle(
                color: Color(0xFFFE860A),
                fontSize: 16,
                fontFamily: 'SF Pro Display',
                fontWeight: FontWeight.w500,
                height: 1,
              ),
            )
          ],
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.all(4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final date = weekDates[index];
              final isToday = date.day == today.day &&
                  date.month == today.month &&
                  date.year == today.year;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    weeksList[date.weekday % 7],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 12,
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w500,
                      height: 1.67,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w400,
                      color: isToday ? Colors.orange : Colors.black,
                    ),
                  ),
                  if (isToday)
                    const Icon(Icons.circle, color: Colors.orange, size: 8),
                ],
              );
            }),
          ),
        ),
        // GestureDetector(
        //   onTap: () {
        //     // statusSelectList[0] = true;
        //     // statusSelectList[1] = false;
        //     // statusSelectList[2] = false;
        //     // setState(() {});
        //     Navigator.pushNamed(context, "/course_screen" , arguments: {
        //       'courseId': 1,
        //       'subjectId': 1,
        //     });
        //   },
        //   child: buildStatusCard(
        //       false, 'list2.svg', statusSelectList[0], "Pre-Test"),
        // ),
        // const SizedBox(
        //   height: 12,
        // ),
        // GestureDetector(
        //   onTap: () {
        //     // statusSelectList[0] = false;
        //     // statusSelectList[1] = true;
        //     // statusSelectList[2] = false;
        //     // setState(() {});
        //     Navigator.pushNamed(context, "/course_screen" , arguments: {
        //       'courseId': 1,
        //       'subjectId': 1,
        //     });
        //   },
        //   child: buildStatusCard(
        //       false, 'vedio.svg', statusSelectList[1], "Videos Lessons"),
        // ),
        // const SizedBox(
        //   height: 12,
        // ),
        // GestureDetector(
        //   onTap: () {
        //     // statusSelectList[0] = false;
        //     // statusSelectList[1] = false;
        //     // statusSelectList[2] = true;
        //     // setState(() {});
        //     Navigator.pushNamed(context, "/course_screen", arguments: {
        //       'courseId': 1,
        //       'subjectId': 1,
        //     });
        //   },
        //   child: buildStatusCard(
        //       false, 'list2.svg', statusSelectList[2], "Post-lesson test"),
        // ),
        // const SizedBox(
        //   height: 12,
        // ),
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
  return WidgetStateProperty.all(const Size(double.infinity, double.maxFinite));
}

String _monthName(int month) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  return months[month - 1];
}

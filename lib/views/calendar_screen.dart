import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:ghastep/widgets/homepage_widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ghastep/views/urlconfig.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  List<DateTime> dateList = [DateTime.now()];
  final storage = const FlutterSecureStorage();
  List<DateTime> highlightedDates = [];
  int videosWatched = 0;
  bool isLoadingVideosWatched = false;
  String videosWatchedError = '';
  int testsAttempted = 0;
  int questionsAttempted = 0;
  int stepsCompleted = 0;
  int totalSteps = 0;
  bool isLoadingMetrics = false;
  String metricsError = '';

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
  void initState() {
    super.initState();
    fetchUserMetrics();
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args['examDateData'] != null) {
      print('Received exam date data: ${args['examDateData']}');
      highlightedDates = (args['examDateData'] as List)
          .map((item) {
            final dateStr = item['neet_exam_date'];
            if (dateStr != null) {
              final parts = dateStr.split('-');
              if (parts.length == 3) {
                return DateTime(
                  int.parse(parts[2]), // year
                  int.parse(parts[1]), // month
                  int.parse(parts[0]), // day
                );
              }
            }
            return null;
          })
          .whereType<DateTime>()
          .toList();
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Your steps journey',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 20,
            fontFamily: 'SF Pro Display',
            fontWeight: FontWeight.w500,
            height: 1.40,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            buildCalendar(dateList, highlightedDates),
            const SizedBox(
              height: 8,
            ),
            Container(
              // width: 390,
              decoration: const ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 1,
                    strokeAlign: BorderSide.strokeAlignCenter,
                    color: Color(0xFFDDDDDD),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Statistics",
                        style: TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 20,
                          fontFamily: 'SF Pro Display',
                          fontWeight: FontWeight.w500,
                          height: 1.40,
                        ),
                      ),
                      Text(
                        "Today",
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
      bottomNavigationBar: const SizedBox(
        height: 64,
        child: Center(
          child: Text(
            'Navigate to today',
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
    );
  }
}

Widget buildCalendar(List<DateTime> dateList, List<DateTime> highlightedDates) {
  final config = CalendarDatePicker2Config(
    calendarType: CalendarDatePicker2Type.single,
    dayBuilder: ({
      required DateTime date,
      TextStyle? textStyle,
      BoxDecoration? decoration,
      bool? isSelected,
      bool? isDisabled,
      bool? isToday,
    }) {
      final isExamDate = highlightedDates.any((d) =>
          d.year == date.year && d.month == date.month && d.day == date.day);

      if (isToday == true) {
        // Today: blue background, white text
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFF247E80), // blue background
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '${date.day}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  fontFamily: "SF Pro Display",
                ),
              ),
            ),
            if (isExamDate)
              Positioned(
                bottom: 2,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        );
      }

      // Exam date (not today): orange text and dot
      return Stack(
        alignment: Alignment.center,
        children: [
          Text(
            '${date.day}',
            style: textStyle?.copyWith(
                  color: isExamDate
                      ? Colors.orange
                      : (textStyle?.color ?? Colors.black),
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  fontFamily: "SF Pro Display",
                ) ??
                TextStyle(
                  color: isExamDate ? Colors.orange : Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  fontFamily: "SF Pro Display",
                ),
          ),
          if (isExamDate)
            Positioned(
              bottom: 2,
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      );
    },
    selectedDayHighlightColor: const Color(0xFF247E80),
    centerAlignModePicker: true,
    calendarViewMode: CalendarDatePicker2Mode.scroll,
    hideScrollViewMonthWeekHeader: true,
    scrollViewController: ScrollController(),
    weekdayLabelTextStyle: const TextStyle(
      color: Color(0xFF030917),
      fontSize: 16,
      fontFamily: "SF Pro Display",
      fontWeight: FontWeight.w500,
    ),
    dayTextStyle: const TextStyle(
      color: Color(0xFF030917),
      fontSize: 16,
      fontFamily: "SF Pro Display",
      fontWeight: FontWeight.w500,
    ),
    controlsTextStyle: const TextStyle(
      color: Color(0xFF030917),
      fontSize: 16,
      fontFamily: "SF Pro Display",
      fontWeight: FontWeight.w500,
    ),
    disabledDayTextStyle: const TextStyle(
      color: Color(0xFFCDCED7),
      fontSize: 16,
      fontFamily: "SF Pro Display",
      fontWeight: FontWeight.w500,
    ),
    selectableDayPredicate: (day) {
      final calDay = day;
      final todayWithTime = DateTime.now().toString();
      final today = todayWithTime.split(' ');
      final todayDate = today[0];
      DateTime dt1 = DateTime.parse(todayDate);

      int dateTrue = dt1.compareTo(calDay);
      if (dateTrue <= 0) {
        return true;
      } else {
        return false;
      }
    },
  );

  return SizedBox(
    height: 400,
    child: CalendarDatePicker2(
      config: config,
      value: dateList,
      onValueChanged: (dates) {},
    ),
  );
}

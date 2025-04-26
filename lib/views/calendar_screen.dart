import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:step_mobile/widgets/homepage_widgets.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  List<DateTime> dateList = [DateTime.now()];
  @override
  Widget build(BuildContext context) {
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
            buildCalendar(dateList),
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
                              "TOTAL WATCH MINS", "238 Mins", "clock.svg")),
                      const SizedBox(
                        width: 16,
                      ),
                      Expanded(
                          child: homeStepsCard(
                              "STEPS COMPLETED", "23", "steps.svg")),
                    ],
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: homeStepsCard(
                              "TESTS ATTEMPTED", "5", "done.svg")),
                      const SizedBox(
                        width: 16,
                      ),
                      Expanded(
                          child: homeStepsCard(
                              "QUESTIONS ATTEMPTED", "85", "questions.svg")),
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

Widget buildCalendar(List<DateTime> dateList) {
  final config = CalendarDatePicker2Config(
    calendarType: CalendarDatePicker2Type.single,
    selectedDayHighlightColor: const Color(0xFF247E80),
    centerAlignModePicker: true,
    calendarViewMode: CalendarDatePicker2Mode.scroll,
    // rangeBidirectional: true,
    hideScrollViewMonthWeekHeader: true,
    scrollViewController: ScrollController(),
    // disableModePicker: false,
    // disableMonthPicker: false,
    weekdayLabelTextStyle: const TextStyle(
      color: Color(0xFF030917),
      fontSize: 16,
      fontFamily: "SF Pro Display",
      fontWeight: FontWeight.w500,
      // height: 0.09,
    ),
    dayTextStyle: const TextStyle(
      color: Color(0xFF030917),
      fontSize: 16,
      fontFamily: "SF Pro Display",
      fontWeight: FontWeight.w500,
      // height: 0.09,
    ),
    controlsTextStyle: const TextStyle(
      color: Color(0xFF030917),
      fontSize: 16,
      fontFamily: "SF Pro Display",
      fontWeight: FontWeight.w500,
      // height: 0.09,
    ),
    disabledDayTextStyle: const TextStyle(
      color: Color(0xFFCDCED7),
      fontSize: 16,
      fontFamily: "SF Pro Display",
      fontWeight: FontWeight.w500,
      // height: 0.09,
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
        onValueChanged: (dates) {
          // setState(() => dateProvider.changeDate(dates));
        }),
  );
}

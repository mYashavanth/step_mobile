import 'package:flutter/material.dart';
import 'package:step_mobile/widgets/inputs.dart';
import 'package:step_mobile/widgets/select_course_widgets.dart';

class SelectCourse extends StatefulWidget {
  const SelectCourse({super.key});

  @override
  State<SelectCourse> createState() => _SelectCourseState();
}

class _SelectCourseState extends State<SelectCourse> {
  bool graduate = false;
  TextEditingController yearOfStudy = TextEditingController();

  List<bool> selectCourseList = [true, false, false];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Select your course',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 20,
            fontFamily: 'SF Pro Display',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.maxFinite,
                height: 48,
                decoration: ShapeDecoration(
                  color: const Color(0xFFD2F7FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          graduate = false;
                          setState(() {});
                        },
                        child: Container(
                          // width: 178.95,
                          height: 48,
                          decoration: ShapeDecoration(
                            color: graduate ? Colors.transparent : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                            shadows: graduate
                                ? null
                                : [
                                    const BoxShadow(
                                      color: Color(0x3F9396AE),
                                      blurRadius: 10,
                                      offset: Offset(0, 2),
                                      spreadRadius: 0,
                                    )
                                  ],
                          ),
                          child: const Center(
                            child: Text(
                              'Undergraduate',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF1A1A1A),
                                fontSize: 14,
                                fontFamily: 'SF Pro Display',
                                fontWeight: FontWeight.w500,
                                height: 1.57,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          graduate = true;
                          setState(() {});
                        },
                        child: Container(
                          // width: 178.95,
                          height: 48,
                          decoration: ShapeDecoration(
                              color:
                                  graduate ? Colors.white : Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                              shadows: graduate
                                  ? [
                                      const BoxShadow(
                                        color: Color(0x3F9396AE),
                                        blurRadius: 10,
                                        offset: Offset(0, 2),
                                        spreadRadius: 0,
                                      )
                                    ]
                                  : null),
                          child: const Center(
                            child: Text(
                              'Graduate',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF1A1A1A),
                                fontSize: 14,
                                fontFamily: 'SF Pro Display',
                                fontWeight: FontWeight.w500,
                                height: 1.57,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              formInputWithLabel(
                  yearOfStudy, "Enter Yera Of Study", "Year Of Study"),
              const SizedBox(height: 16),
              const Text(
                'Select course',
                style: TextStyle(
                  color: Color(0xFF323836),
                  fontSize: 16,
                  fontFamily: 'SF Pro Display',
                  fontWeight: FontWeight.w400,
                  height: 1.38,
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              GestureDetector(
                onTap: () {
                  selectCourseList[2] = false;
                  selectCourseList[1] = false;
                  selectCourseList[0] = true;
                  setState(() {});
                },
                child: createSelectCourseCard(
                    "NEET-PG (2025)",
                    "class 11 | class 12",
                    "microscope.svg",
                    selectCourseList[0]),
              ),
              const SizedBox(
                height: 16,
              ),
              GestureDetector(
                onTap: () {
                  selectCourseList[2] = false;
                  selectCourseList[1] = true;
                  selectCourseList[0] = false;
                  setState(() {});
                },
                child: createSelectCourseCard("FMGE (JUNE-2025)", "MMBS Prof",
                    "microscope.svg", selectCourseList[1]),
              ),
              const SizedBox(
                height: 16,
              ),
              GestureDetector(
                onTap: () {
                  selectCourseList[2] = true;
                  selectCourseList[1] = false;
                  selectCourseList[0] = false;
                  setState(() {});
                },
                child: createSelectCourseCard("FMGE (DEC-2025)",
                    "class 11 | class 12", "list (2).svg", selectCourseList[2]),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                // Handle login with mobile number
                Navigator.pushNamed(context, "/home_page");
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: const Color(0xFF247E80),
              ),
              child: const Text(
                'Proceed',
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
}

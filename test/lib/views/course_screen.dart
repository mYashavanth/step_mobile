import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:step_mobile/widgets/common_widgets.dart';
import 'package:step_mobile/widgets/course_screen_widgets.dart';
import 'package:step_mobile/widgets/homepage_widgets.dart';

class CourseScreen extends StatefulWidget {
  const CourseScreen({super.key});

  @override
  State<CourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<int> stepTabSelectedIndex = [0];

  List<Map> selectStepList = [
    {"name": "Step 1", "id": 1},
    {"name": "Step 2", "id": 2},
    {"name": "Step 3", "id": 3},
  ];

  List<int> chooseStepList = [0];

  @override
  void initState() {
    // TODO: implement initState
    _tabController = TabController(length: 5, vsync: this);
    super.initState();
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
              child: Image.asset(
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
                        child: const Text(
                          'ANATOMY',
                          style: TextStyle(
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
                                //  isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) {
                                  return StatefulBuilder(builder:
                                      (BuildContext context,
                                          StateSetter modalSetState) {
                                    return buidSelectCourseBottomSheet(
                                        modalSetState,
                                        selectStepList,
                                        chooseStepList,
                                        "Select your Course");
                                  });
                                });
                          },
                          child: const Row(
                            children: [
                              Text(
                                'STEP 1',
                                style: TextStyle(
                                  color: Color(0xFF247E80),
                                  fontSize: 14,
                                  fontFamily: 'SF Pro Display',
                                  fontWeight: FontWeight.w500,
                                  height: 1.71,
                                ),
                              ),
                              Icon(
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
                  const Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'EMBRYOLOGY: ',
                          style: TextStyle(
                            color: Color(0xFF1A1A1A),
                            fontSize: 20,
                            fontFamily: 'SF Pro Display',
                            fontWeight: FontWeight.w500,
                            height: 1.40,
                          ),
                        ),
                        TextSpan(
                          text:
                              'Fertilization, early embryonic development, germ layers, organogenesis, congenital anomalies.',
                          style: TextStyle(
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
                  buildFacultyCard(), // faculty card

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
                      "4 hours on-demand video", "play2.svg"),
                  const SizedBox(height: 8),
                  buildCourseOverViewCard(
                      "5 downloadable resources", "Download.svg"),
                  const SizedBox(height: 8),
                  buildCourseOverViewCard("Full lifetime access", "Time.svg"),
                  const SizedBox(height: 8),
                  buildCourseOverViewCard(
                      "4 tests included for assessment", "Time (1).svg"),
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

Widget buildFacultyCard() {
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
            image: const DecorationImage(
              image: AssetImage("assets/image/profile.jpg"),
              fit: BoxFit.cover,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
            ),
          ),
        ),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Dr. Kalyan Vedas ',
                    style: TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 14,
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w500,
                      height: 1.57,
                    ),
                  ),
                  TextSpan(
                    text: '( Radiologist specialist )',
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
            Text(
              'MBBS | 15 years exp',
              style: TextStyle(
                color: Color(0xFF737373),
                fontSize: 14,
                fontFamily: 'SF Pro Display',
                fontWeight: FontWeight.w400,
                height: 1.57,
              ),
            )
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

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:step_mobile/widgets/common_widgets.dart';

class BeforeEnterTestScreen extends StatefulWidget {
  const BeforeEnterTestScreen({super.key});

  State<BeforeEnterTestScreen> createState() => _BeforeEnterTestScreen();
}

class _BeforeEnterTestScreen extends State<BeforeEnterTestScreen> {
  //  List<Map> examDetailsData = [{"icon":"query.svg","title":""},{},{}];
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SafeArea(
              child: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.arrow_back_ios_new),
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PRE COURSE TEST • ANATOMY - STEP 1',
                        style: TextStyle(
                          color: Color(0xFF247E80),
                          fontSize: 12,
                          fontFamily: 'SF Pro Display',
                          fontWeight: FontWeight.w700,
                          height: 1.67,
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      const Text(
                        'Anatomy Challenge: Ace the Basics',
                        style: TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 20,
                          fontFamily: 'SF Pro Display',
                          fontWeight: FontWeight.w500,
                          height: 1.40,
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      const Text(
                        "PYQ's - Anatomy for NEET PG \n50 Questions • 45 minutes",
                        style: TextStyle(
                          color: Color(0xFF737373),
                          fontSize: 14,
                          fontFamily: 'SF Pro Display',
                          fontWeight: FontWeight.w400,
                          height: 1.57,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        padding: EdgeInsets.all(12),
                        clipBehavior: Clip.antiAlias,
                        decoration: ShapeDecoration(
                          color: const Color(0x0C31B5B9),
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                                width: 1, color: Color(0xFF8FE1E3)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Exam details',
                              style: TextStyle(
                                color: Color(0xFF1A1A1A),
                                fontSize: 20,
                                fontFamily: 'SF Pro Display',
                                fontWeight: FontWeight.w500,
                                height: 1.20,
                              ),
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            Column(children: [
                              Row(
                                children: [
                                  SvgPicture.asset("assets/icons/query.svg"),
                                  const Text(
                                    '50 full-length questions, 200 marks',
                                    style: TextStyle(
                                      color: Color(0xFF1A1A1A),
                                      fontSize: 16,
                                      fontFamily: 'SF Pro Display',
                                      fontWeight: FontWeight.w400,
                                      height: 1.50,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    "assets/icons/ranking_filled.svg",
                                    width: 24,
                                    colorFilter: const ColorFilter.mode(
                                        Color(0xFF247E80), BlendMode.srcIn),
                                  ),
                                  const SizedBox(
                                    width: 12,
                                  ),
                                  const Text(
                                    'All India & State Rankings',
                                    style: TextStyle(
                                      color: Color(0xFF1A1A1A),
                                      fontSize: 16,
                                      fontFamily: 'SF Pro Display',
                                      fontWeight: FontWeight.w400,
                                      height: 1.50,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    "assets/icons/list_icon.svg",
                                    width: 24,
                                    colorFilter: const ColorFilter.mode(
                                        Color(0xFF247E80), BlendMode.srcIn),
                                  ),
                                  const SizedBox(
                                    width: 12,
                                  ),
                                  const Text(
                                    'Latest exam pattern-based',
                                    style: TextStyle(
                                      color: Color(0xFF1A1A1A),
                                      fontSize: 16,
                                      fontFamily: 'SF Pro Display',
                                      fontWeight: FontWeight.w400,
                                      height: 1.50,
                                    ),
                                  ),
                                ],
                              ),
                            ]),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                borderHorizontal(),
                Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    children: [
                      testAtemptedCard("4 / 200 marks", context),
                      const SizedBox(
                        height: 12,
                      ),
                      testAtemptedCard("4 / 200 marks", context),
                    ],
                  ),
                ),
                borderHorizontal(),
                const SizedBox(
                  height: 16,
                ),
                Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Syllabus',
                        style: TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 20,
                          fontFamily: 'SF Pro Display',
                          fontWeight: FontWeight.w500,
                          height: 1.20,
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      listViewWithDot(
                          "General Anatomy: Basic Terminology, Tissues: Types and Functions & Bone and Cartilage Structure."),
                      const SizedBox(
                        height: 12,
                      ),
                      listViewWithDot(
                          "Upper Limb Anatomy: Brachial Plexus, Shoulder Joint and Movements & Muscles of the Arm and Forearm."),
                      const SizedBox(
                        height: 12,
                      ),
                      listViewWithDot(
                          "Lower Limb Anatomy: Hip Joint and Movements, Femoral Triangle and Popliteal Fossa & Nerve Supply of the Lower Limb."),
                    ],
                  ),
                ),
                // const SizedBox(
                //   height: 16,
                // ),
                borderHorizontal(),
                Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Instructions',
                        style: TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 20,
                          fontFamily: 'SF Pro Display',
                          fontWeight: FontWeight.w500,
                          height: 1.20,
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      listViewWithDot("+4 marks for each correct answer"),
                      const SizedBox(
                        height: 12,
                      ),
                      listViewWithDot("-1 mark for every incorrect answer."),
                      const SizedBox(
                        height: 12,
                      ),
                      listViewWithDot(
                          "No marks will be deducted for unattempted questions."),
                      const SizedBox(
                        height: 12,
                      ),
                      listViewWithDot(
                          "Tie-breaking criteria include the number of correct responses and candidate age."),
                      const SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Handle login with mobile number
                          Navigator.pushNamed(context, "/test_screen");
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: const Color(0xFF247E80),
                        ),
                        child: const Text(
                          'Start test',
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
              ],
            )
          ],
        ),
      ),
    );
  }
}

Widget listViewWithDot(String data) {
  return Padding(
    padding: const EdgeInsets.only(left: 8.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(right: 8, top: 8),
          width: 5,
          height: 5,
          decoration: ShapeDecoration(
            color: const Color(0xFF737373),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),
        Expanded(
          child: Text(
            data,
            style: const TextStyle(
              color: Color(0xFF737373),
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

Widget testAtemptedCard(String title, BuildContext context) {
  return Container(
    decoration: ShapeDecoration(
      color: const Color(0xFFF9FAFB),
      shape: RoundedRectangleBorder(
        side: const BorderSide(width: 1, color: Color(0xFFDDDDDD)),
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    child: ListTile(
      // isThreeLine: true,
      leading: SvgPicture.asset(
        "assets/icons/list_icon.svg",
        colorFilter: const ColorFilter.mode(Color(0xFF5C5C5C), BlendMode.srcIn),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF1A1A1A),
          fontSize: 16,
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w400,
          height: 1.50,
        ),
      ),
      subtitle: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '23 Jan 25',
            style: TextStyle(
              color: Color(0xFF737373),
              fontSize: 12,
              fontFamily: 'SF Pro Display',
              fontWeight: FontWeight.w400,
              height: 1.67,
            ),
          ),
        ],
      ),
      trailing: InkWell(
        borderRadius: BorderRadius.circular(50),
        onTap: () {
          Navigator.pushNamed(context, "/before_enter_test");
        },
        child: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    ),
  );
}

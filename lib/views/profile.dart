import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ghastep/widgets/homepage_widgets.dart';
import 'package:ghastep/widgets/navbar.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  List<Map> selectCourseData = [
    {"name": "NEET PG (2025)", "id": 1},
    {"name": "FMGE ( June - 2025 )", "id": 2},
    {"name": "JEE ( June - 2025 )", "id": 3},
  ];
  List<int> selectedCourse = [1];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        const SizedBox(
                          // width: 160,
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
                                        context,
                                        modalSetState,
                                        selectCourseData,
                                        selectedCourse,
                                        "Select your Course");
                                  });
                                });
                          },
                          child: const Row(
                            children: [
                              Text(
                                'NEET - PG (2025)',
                                style: TextStyle(
                                  color: Color(0xFF737373),
                                  fontSize: 14,
                                  fontFamily: 'SF Pro Display',
                                  fontWeight: FontWeight.w400,
                                  height: 1.57,
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_down,
                                color: Color(0xFF737373),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                    Container(
                      // width: 92,
                      // height: 34,
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
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  // Row(
                  //   children: [
                  //     Expanded(
                  //       child: InkWell(
                  //           onTap: () {
                  //             Navigator.pushNamed(context, "/updates");
                  //           },
                  //           child: buildProfileCard(
                  //               "Updates", "notification.svg")),
                  //     ),
                  //     Expanded(
                  //       child: InkWell(
                  //         onTap: () {
                  //           Navigator.pushNamed(context, "/saved_items");
                  //         },
                  //         child: buildProfileCard("Saved items", "saved.svg"),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // const SizedBox(height: 12),
                  Row(
                    children: [
                      // Expanded(
                      //   child: InkWell(
                      //       onTap: () {
                      //         Navigator.pushNamed(context, "/faq");
                      //       },
                      //       child: buildProfileCard("FAQs", "faq.svg")),
                      // ),
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
            profileBannerNotes(),
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

Widget profileBannerNotes() {
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
            'Get Unlimited Access',
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
              // Handle login with mobile number
              // Navigator.pushNamed(context, "/otp_verify");
            },
            style: ElevatedButton.styleFrom(
              // minimumSize: const Size(double.infinity, 50),
              backgroundColor: const Color(0xFFFE860A),
            ),
            child: const Text(
              'Enroll Now @ ₹1000',
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

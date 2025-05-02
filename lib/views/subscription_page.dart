import "package:flutter/material.dart";
import "package:flutter_svg/svg.dart";
import "package:ghastep/widgets/homepage_widgets.dart";

class SubscribePage extends StatefulWidget {
  const SubscribePage({super.key});

  @override
  State<SubscribePage> createState() {
    return _SubscribePage();
  }
}

class _SubscribePage extends State<SubscribePage> {
  List<Map> selectCourseData = [
    {"name": "FMGE ( June - 2025 )", "id": 1},
    {"name": "FMGE ( December - 2025 )", "id": 2},
  ];
  List<int> selectedCourse = [1];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              height: 200,
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(1.00, 0.04),
                  end: Alignment(-1, -0.04),
                  colors: [
                    Color.fromARGB(117, 164, 227, 185),
                    Colors.white,
                  ],
                ),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                            onTap: () {},
                            child: const Icon(Icons.arrow_back_ios_new)),
                        const SizedBox(
                          height: 12,
                        ),
                        const Text(
                          'Select a plan',
                          style: TextStyle(
                            color: Color(0xFF1A1A1A),
                            fontSize: 20,
                            fontFamily: 'SF Pro Display',
                            fontWeight: FontWeight.w500,
                            height: 1.40,
                          ),
                        ),
                        const Text(
                          'Start your preparation for\nNEET PG, FMGE (2025) today!',
                          style: TextStyle(
                            color: Color(0xFF737373),
                            fontSize: 16,
                            fontFamily: 'SF Pro Display',
                            fontWeight: FontWeight.w400,
                            height: 1.50,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    SvgPicture.asset("assets/icons/subscribe/notes_pad.svg")
                  ],
                ),
              ),
            ),
            buildSubscribeNeetcard(),
            buildSubscribeFmgecard(),
          ],
        ),
      ),
    );
  }

  Widget buildSubscribeFmgecard() {
    return Container(
      margin: const EdgeInsets.all(12),
      // height: 204,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: const Color(0x0CFE7D14),
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            width: 1,
            color: Color(0xFFFE860A),
          ),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              // mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                            'FMGE (2025)',
                            style: TextStyle(
                              color: Color(0xFFEC7800),
                              fontSize: 20,
                              fontFamily: 'SF Pro Display',
                              fontWeight: FontWeight.w700,
                              height: 1.40,
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down_sharp,
                            color: Color(0xFFEC7800),
                          )
                        ],
                      ),
                    ),
                    const Text(
                      '@ ₹1000/year',
                      style: TextStyle(
                        color: Color(0xFFEC7800),
                        fontSize: 14,
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.w500,
                        height: 1.57,
                      ),
                    )
                  ],
                ),
                const Spacer(),
                Container(
                  // height: 33,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      side:
                          const BorderSide(width: 1, color: Color(0xFFEC7800)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    shadows: const [
                      BoxShadow(
                        color: Color(0x19000000),
                        blurRadius: 25,
                        offset: Offset(0, 4),
                        spreadRadius: 0,
                      )
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'Get course',
                      style: TextStyle(
                        color: Color(0xFFEC7800),
                        fontSize: 14,
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                flex: 4,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      buildRow("Structured courses & PDF’s for NEET", false),
                      buildRow("Daily video lessons", false),
                      buildRow("Daily tests and weekly exams", false),
                      buildRow("Content curated & prepared by doctors", false),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: SvgPicture.asset(
                      "assets/icons/subscribe/patient_sheet.svg"),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

Widget buildSubscribeNeetcard() {
  return Container(
    margin: const EdgeInsets.all(12),
    // height: 204,
    clipBehavior: Clip.antiAlias,
    decoration: ShapeDecoration(
      color: const Color(0x0C31B5B9),
      shape: RoundedRectangleBorder(
        side: const BorderSide(
          width: 1,
          color: Color(0xFF289799),
        ),
        borderRadius: BorderRadius.circular(6),
      ),
    ),
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            // mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'NEET-PG (2025)',
                        style: TextStyle(
                          color: Color(0xFF003E40),
                          fontSize: 20,
                          fontFamily: 'SF Pro Display',
                          fontWeight: FontWeight.w700,
                          height: 1.40,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '@ ₹1000/year',
                    style: TextStyle(
                      color: Color(0xCC003F40),
                      fontSize: 14,
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w500,
                      height: 1.57,
                    ),
                  )
                ],
              ),
              const Spacer(),
              Container(
                // height: 33,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(width: 1, color: Color(0xFF289799)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: Color(0x19000000),
                      blurRadius: 25,
                      offset: Offset(0, 4),
                      spreadRadius: 0,
                    )
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Get course',
                    style: TextStyle(
                      color: Color(0xFF247E80),
                      fontSize: 14,
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              flex: 4,
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildRow("Structured courses & PDF’s for NEET", true),
                    buildRow("Daily video lessons", true),
                    buildRow("Daily tests and weekly exams", true),
                    buildRow("Content curated & prepared by doctors", true),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.bottomRight,
                child:
                    SvgPicture.asset("assets/icons/subscribe/micro_scope.svg"),
              ),
            ),
          ],
        )
      ],
    ),
  );
}

Widget buildRow(String title, bool neet) {
  return Row(
    children: [
      Icon(
        Icons.check_circle,
        size: 15,
        color: neet ? const Color(0xFF247E80) : const Color(0xFFEC7800),
      ),
      const SizedBox(
        width: 4,
      ),
      Expanded(
        child: Text(
          title,
          style: TextStyle(
            color: neet ? const Color(0xFF247E80) : const Color(0xFFEC7800),
            fontSize: 14,
            fontFamily: 'SF Pro Display',
            fontWeight: FontWeight.w500,
            height: 1.57,
          ),
        ),
      )
    ],
  );
}

Widget buidSelectCourseBottomSheet(StateSetter modalSetState,
    List<Map> selectCourseList, List<int> selected, String bottomSheetTitle) {
  return Stack(clipBehavior: Clip.none, children: [
    Container(
      padding: const EdgeInsets.only(top: 16, left: 20, right: 20, bottom: 16),
      // margin: EdgeInsets.only(top: 50),
      clipBehavior: Clip.antiAlias,
      decoration: const ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            bottomSheetTitle,
            style: const TextStyle(
              color: Color(0xFF323836),
              fontSize: 20,
              fontFamily: 'SF Pro Display',
              fontWeight: FontWeight.w500,
              height: 1.10,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Container(
            width: 358,
            decoration: const ShapeDecoration(
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: 1,
                  strokeAlign: BorderSide.strokeAlignCenter,
                  color: Color(0xFFEAEAEA),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Column(
            children: List.generate(selectCourseList.length, (int) {
              return buildSelectCourseRow(
                  modalSetState, selectCourseList[int], selected);
            }),
          ),
          const SizedBox(
            height: 12,
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: const Color(0xFF247E80),
            ),
            child: const Text(
              'Apply',
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
    Positioned(
      right: 15,
      top: -50,
      child: CircleAvatar(
        backgroundColor: Colors.white,
        child: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          // onPressed: () => Navigator.pop(context),
          onPressed: () {
            print("clicked");
          },
        ),
      ),
    ),
  ]);
}

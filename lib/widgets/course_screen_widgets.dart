import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

Widget buildTabBarCourse(TabController tabController,
    List<int> stepTabSelectedIndex, StateSetter setState) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      buildStepTabButton(setState, stepTabSelectedIndex),
      // Container(
      //   color: Colors.white,
      //   child: TabBar(
      //     controller: _tabController,
      //     labelColor: Colors.black,
      //     indicatorColor: Colors.black,
      //     unselectedLabelColor: Colors.grey,
      //     dividerColor: Colors.transparent,
      //     onTap: (i) {
      //       stepTabSelectedIndex[0] = i;
      //       setState(() {});
      //       print(i);
      //     },
      //     tabs: const [
      //       Tab(text: "Step 1"),
      //       Tab(text: "Step 2"),
      //       Tab(text: "Step 3"),
      //       Tab(text: "Notes"),
      //       Tab(text: "Subject test"),
      //     ],
      //   ),
      // ),
      Container(
        padding: const EdgeInsets.only(left: 12, right: 12),
        // height: 300,
        child:
            // TabBarView(
            //   controller: _tabController,
            //   children: [
            //     SingleChildScrollView(child: StepContent()),
            //     const Center(child: Text("Step 2 Content")),
            //     const Center(child: Text("Step 3 Content")),
            //     const Center(child: Text("Notes Content")),
            //   ],
            // ),

            Column(
          children: [
            Visibility(
              visible: stepTabSelectedIndex[0] == 0,
              child: StepContent(),
            ),
            Visibility(
              visible: stepTabSelectedIndex[0] == 1,
              child: StepContent(),
            ),
            Visibility(
              visible: stepTabSelectedIndex[0] == 2,
              child: const SizedBox(
                height: 200,
                child: Center(
                  child: Text("Step 3 Content"),
                ),
              ),
            ),
            Visibility(
              visible: stepTabSelectedIndex[0] == 3,
              child: Column(
                children: [
                  courseNotes(
                      "Name of document here", 25, false, "adobe_pdf.svg"),
                  courseNotes("Name of document here if it exceeds 1 lines", 27,
                      false, "adobe_pdf.svg"),
                  courseNotes("Name of document here", 29, false, "excel.svg"),
                  courseNotes("Name of document here if it exceeds 1 lines", 31,
                      true, "excel.svg"),

                  const SizedBox(
                    height: 28,
                  ),
                  //
                  InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                            width: 1,
                            color: Color(0xFF247E80),
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      // ignore: prefer_const_constructors
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.lock,
                            color: Color(0xFF247E80),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Text(
                            'Enroll for ₹1000 to unlock',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF247E80),
                              fontSize: 16,
                              fontFamily: 'SF Pro Display',
                              fontWeight: FontWeight.w500,
                              height: 1.50,
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

List stepTabCourse = ['Step 1', "Step 2", "Step 3", "Notes", "Subject test"];

Widget buildStepTabButton(
  StateSetter setState,
  List<int> stepTabSelectedIndex,
) {
  return Row(
      children: List.generate(5, (i) {
    return GestureDetector(
      onTap: () {
        stepTabSelectedIndex[0] = i;
        setState(() {});
      },
      child: Container(
        // ignore: prefer_const_constructors
        margin: EdgeInsets.only(right: 12),
        padding: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          border: stepTabSelectedIndex[0] == i
              ? const Border(
                  // left: BorderSide(color: Colors.transparent),
                  // top: BorderSide(color: Color.fromARGB(0, 26, 26, 26)),
                  // right: BorderSide(color: Color(0xFF1A1A1A)),
                  bottom: BorderSide(width: 2, color: Color(0xFF1A1A1A)),
                )
              : null,
        ),
        child: Text(
          stepTabCourse[i],
          style: TextStyle(
            color: stepTabSelectedIndex[0] == i
                ? const Color(0xFF1A1A1A)
                : const Color(0xFF737373),
            fontSize: 16,
            fontFamily: 'SF Pro Display',
            fontWeight: stepTabSelectedIndex[0] == i
                ? FontWeight.w500
                : FontWeight.w400,
            height: 1.50,
          ),
        ),
      ),
    );
  }));
}

Widget courseNotes(String docName, int page, bool locked, String icon) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 4),
    padding: const EdgeInsets.all(8),
    decoration: ShapeDecoration(
      color: const Color(0xFFF9FAFB),
      shape: RoundedRectangleBorder(
        side: const BorderSide(width: 1, color: Color(0xFFDDDDDD)),
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    child: ListTile(
      // isThreeLine: true,
      leading: Container(
        width: 40,
        height: 40,
        padding: const EdgeInsets.all(10),
        decoration: ShapeDecoration(
          color: const Color(0xFFEAEAEA),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        child: SvgPicture.asset("assets/icons/$icon"),
      ),
      title: Text(
        docName,
        style: const TextStyle(
          color: Color(0xFF1A1A1A),
          fontSize: 16,
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w400,
          height: 1.50,
        ),
      ),
      subtitle: Text(
        '$page pages',
        style: const TextStyle(
          color: Color(0xFF737373),
          fontSize: 12,
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w400,
          height: 1.67,
        ),
      ),

      trailing: locked
          ? const Icon(Icons.lock, color: Color(0xFF1A1A1A), size: 24)
          : null,
    ),
  );
}

Widget preCourseCard(bool pending,BuildContext context) {
  return Container(
    decoration: ShapeDecoration(
      color: const Color(0x0C31B5B9),
      shape: RoundedRectangleBorder(
        side: const BorderSide(width: 1, color: Color(0xFF8FE1E3)),
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    child: ListTile(
      // isThreeLine: true,
      leading: SvgPicture.asset("assets/icons/list_icon.svg"),
      title: const Text(
        'PYQ Test (2020-24)',
        style: TextStyle(
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
            '1h 30m • 35 MCQS',
            style: TextStyle(
              color: Color(0xFF737373),
              fontSize: 12,
              fontFamily: 'SF Pro Display',
              fontWeight: FontWeight.w400,
              height: 1.67,
            ),
          ),
          Container(
            width: 75,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: ShapeDecoration(
              color:
                  pending ? const Color(0xFFFF9500) : const Color(0xFF34C759),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Center(
              child: Text(
                pending ? 'Pending' : "Completed",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontFamily: 'SF Pro Display',
                  fontWeight: FontWeight.w400,
                  height: 1.67,
                ),
              ),
            ),
          )
        ],
      ),
      trailing: InkWell(
        borderRadius: BorderRadius.circular(50),
        onTap: (){
          Navigator.pushNamed(context, "/before_enter_test");
        },
        child: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    ),
  );
}

Widget collapseStepClassCard(
    int num, List<bool> showList, StateSetter setState) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 4),
    padding: const EdgeInsets.all(8),
    decoration: ShapeDecoration(
      color: const Color(0xFFF9FAFB),
      shape: RoundedRectangleBorder(
        side: const BorderSide(width: 1, color: Color(0xFFDDDDDD)),
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.all(10),
          decoration: ShapeDecoration(
            color: const Color(0xFFEAEAEA),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
          ),
          child: Center(
            child: Text(
              "$num",
              style: const TextStyle(
                color: Color(0xFF5C5C5C),
                fontSize: 16,
                fontFamily: 'SF Pro Display',
                fontWeight: FontWeight.w500,
                height: 1.50,
              ),
            ),
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Text(
                      'Blood supply, lymphatic drainage, and innervation',
                      style: TextStyle(
                        color: Color(0xFF1A1A1A),
                        fontSize: 16,
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.w400,
                        height: 1.50,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      showList[num - 1] = !showList[num - 1];
                      setState(() {});
                    },
                    child: Icon(
                      !showList[num - 1]
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_up,
                      color: const Color(0xFF737373),
                    ),
                  ),
                ],
              ),
              Visibility(
                visible: showList[num - 1],
                child: const Text(
                  'Blood supply provides nutrients and removes waste, lymphatic drainage clears excess fluid, and innervation controls bodily functions, all maintaining tissue health and homeostasis.',
                  style: TextStyle(
                    color: Color(0xFF737373),
                    fontSize: 12,
                    fontFamily: 'SF Pro Display',
                    fontWeight: FontWeight.w400,
                    height: 1.67,
                  ),
                ),
              ),
              const Row(
                children: [
                  Icon(
                    Icons.access_time_filled_rounded,
                    color: Color(0xFF737373),
                    size: 16,
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  Text(
                    '23:50 mins',
                    style: TextStyle(
                      color: Color(0xFF737373),
                      fontSize: 12,
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w400,
                      height: 1.67,
                    ),
                  )
                ],
              )
            ],
          ),
        ),
        const SizedBox(
          width: 8,
        ),
        num <= 3
            ? const Icon(
                Icons.play_circle_filled_rounded,
                size: 40,
                color: Color(0xFF737373),
              )
            : Container(
                width: 40,
                height: 40,
                // padding: const EdgeInsets.all(10),
                decoration: ShapeDecoration(
                  color: const Color(0xFFEAEAEA),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.lock,
                    color: Color(0xFF737373),
                  ),
                ),
              ),
      ],
    ),
  );
}

class StepContent extends StatefulWidget {
  const StepContent({super.key});

  @override
  State<StepContent> createState() => _StepContentState();
}

class _StepContentState extends State<StepContent> {
  List<bool> showCardBoolList = [true, false, false, false];
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20),
        preCourseCard(true,context),
        const SizedBox(height: 20),
        Column(
          children: List.generate(4, (i) {
            return collapseStepClassCard(i + 1, showCardBoolList, setState);
          }),
        ),
        const SizedBox(height: 20),
        preCourseCard(false,context),
      ],
    );
  }
}

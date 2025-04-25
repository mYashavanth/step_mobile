import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:step_mobile/widgets/common_widgets.dart';

class UpdatesScreen extends StatefulWidget {
  const UpdatesScreen({super.key});

  @override
  State<UpdatesScreen> createState() => _UpdatesScreenState();
}

class _UpdatesScreenState extends State<UpdatesScreen> {
  List<int> stepTabSelectedIndex = [0];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
          ),
        ),
        title: const Text(
          'Updates',
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
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              buildUpdateTabButton(setState, stepTabSelectedIndex),
              buildUpdateRowCard(
                  const Color(0x7FFF3B30),
                  "update1.svg",
                  "Trending Topics! – Most students are revising ‘Neuroanatomy’ today. Join them now!",
                  1),
              borderHorizontal(),
              buildUpdateRowCard(
                  const Color(0x7FFF3B30),
                  "update8.svg",
                  "Subscription Activated! – Welcome! Your subscription for the NEET PG Course is now active.",
                  2),
              borderHorizontal(),
              buildUpdateRowCard(
                  const Color(0x7FF34C759),
                  "update3.svg",
                  "Revisit Notes before Test – Review your notes on ‘Respiratory System’ before your upcoming test.",
                  3),
              borderHorizontal(),
              buildUpdateRowCard(
                  const Color(0x7FFF3B30),
                  "update4.svg",
                  "Trending Topics! – Most students are revising ‘Neuroanatomy’ today. Join them now!",
                  4),
              borderHorizontal(),
              buildUpdateRowCard(
                  const Color(0x7FF3498DB),
                  "update5.svg",
                  "Subscription Activated! – Welcome! Your subscription for the NEET PG Course is now active.",
                  5),
              borderHorizontal(),
              buildUpdateRowCard(
                  const Color(0x7FF3498DB),
                  "update6.svg",
                  "Trending Topics! – Most students are revising ‘Neuroanatomy’ today. Join them now!",
                  6),
              borderHorizontal(),
              buildUpdateRowCard(
                  const Color(0x7FF34C759),
                  "update7.svg",
                  "Subscription Activated! – Welcome! Your subscription for the NEET PG Course is now active.",
                  7),
              borderHorizontal(),
            ],
          ),
        ),
      ),
    );
  }
}

List stepTabCourse = ["All", "Last 7 Days"];

Widget buildUpdateTabButton(
  StateSetter setState,
  List<int> stepTabSelectedIndex,
) {
  return Row(
    children: List.generate(stepTabCourse.length, (i) {
      return GestureDetector(
        onTap: () {
          stepTabSelectedIndex[0] = i;
          setState(() {});
        },
        child: Container(
          // ignore: prefer_const_constructors
          margin: EdgeInsets.only(right: 12, left: 12),
          padding: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            border: stepTabSelectedIndex[0] == i
                ? const Border(
                    // left: BorderSide(color: Colors.transparent),
                    // top: BorderSide(color: Color.fromARGB(0, 26, 26, 26)),
                    // right: BorderSide(color: Color(0xFF1A1A1A)),
                    bottom: BorderSide(width: 2, color: Color(0xFF247E80)),
                  )
                : null,
          ),
          child: Row(
            children: [
              Text(
                stepTabCourse[i],
                style: TextStyle(
                  color: stepTabSelectedIndex[0] == i
                      ? const Color(0xFF247E80)
                      : const Color(0xFF737373),
                  fontSize: 16,
                  fontFamily: 'SF Pro Display',
                  fontWeight: stepTabSelectedIndex[0] == i
                      ? FontWeight.w500
                      : FontWeight.w400,
                  height: 1.50,
                ),
              ),
              stepTabSelectedIndex[0] == i
                  ? Container(
                      margin: const EdgeInsets.only(left: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: ShapeDecoration(
                        color: const Color(0xFFC7F3F4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          '23',
                          style: TextStyle(
                            color: Color(0xFF1A1A1A),
                            fontSize: 16,
                            fontFamily: 'SF Pro Display',
                            fontWeight: FontWeight.w400,
                            height: 1.50,
                          ),
                        ),
                      ),
                    )
                  : const Text("")
            ],
          ),
        ),
      );
    }),
  );
}

Widget buildUpdateRowCard(Color color, String icon, String title, int num) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(right: 12, top: 4),
          padding: const EdgeInsets.all(10),
          decoration: ShapeDecoration(
            // color: const Color(0xFFFFF1F0),
            shape: RoundedRectangleBorder(
              side: BorderSide(width: 1, color: color),
              borderRadius: BorderRadius.circular(50),
            ),
          ),
          child: Center(
            child: SvgPicture.asset("assets/icons/updates/$icon"),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 16,
                  fontFamily: 'SF Pro Display',
                  fontWeight: FontWeight.w400,
                  height: 1.50,
                ),
              ),
              const Text(
                '8h ago • General',
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
        ),
        Visibility(
          visible: num % 3 == 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: ShapeDecoration(
              color: const Color(0xFF247E80),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Center(
              child: Text(
                'Review',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'SF Pro Display',
                  fontWeight: FontWeight.w500,
                  height: 1.57,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

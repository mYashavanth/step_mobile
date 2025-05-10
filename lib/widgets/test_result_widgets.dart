import 'package:flutter/material.dart';

Widget buildUserRow(int num, String name) {
  int imgNum = num == 420 ? 4 : num;
  return Container(
    margin: num == 420 ? null : const EdgeInsets.only(bottom: 8, top: 8),
    padding: num == 420 ? const EdgeInsets.only(bottom: 8, top: 8) : null,
    color: num == 420 ? const Color(0x0C31B5B9) : Colors.white,
    child: Row(
      children: [
        Container(
          width: 50,
          height: 50,
          padding: const EdgeInsets.all(10),
          decoration: ShapeDecoration(
            image: DecorationImage(
              image: AssetImage("assets/image/user$imgNum.jpg"),
              fit: BoxFit.cover,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
          ),
        ),
        const SizedBox(
          width: 16,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: TextStyle(
                color: num == 420
                    ? const Color(0xFF247E80)
                    : const Color(0xFF1A1A1A),
                fontSize: 16,
                fontFamily: 'SF Pro Display',
                fontWeight: num == 420 ? FontWeight.w700 : FontWeight.w400,
                height: 1.50,
              ),
            ),
            const Text(
              '199 marks • 19 mins 8 secs',
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
        const Spacer(),
        Text(
          '#$num',
          style: TextStyle(
            color:
                num == 420 ? const Color(0xFF247E80) : const Color(0xFF1A1A1A),
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

Widget buildResultScreenOverviewtable(Map<String, dynamic> resultData) {
  return Container(
    decoration: const ShapeDecoration(
      shape: RoundedRectangleBorder(
        side: BorderSide(
          width: 1,
          strokeAlign: BorderSide.strokeAlignOutside,
          color: Color(0xFFDDDDDD),
        ),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              columnOneCard1and2(1, resultData),
              columnOneCard1and2(2, resultData),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              columnTwoCard1and2(1, resultData),
              columnTwoCard1and2(2, resultData),
            ],
          ),
        )
      ],
    ),
  );
}

Widget columnOneCard1and2(int cardNo, Map<String, dynamic> resultData) {
  return Container(
    width: double.maxFinite,
    padding: const EdgeInsets.all(12),
    decoration: const BoxDecoration(
      border: Border(
        bottom: BorderSide(
          width: 1,
          color: Color(0xFFDDDDDD),
        ),
        right: BorderSide(
          width: 1,
          color: Color(0xFFDDDDDD),
        ),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          cardNo == 1 ? 'Total marks scored' : "Incorrect",
          style: const TextStyle(
            color: Color(0xFF737373),
            fontSize: 12,
            fontFamily: 'SF Pro Display',
            fontWeight: FontWeight.w400,
            height: 1.67,
          ),
        ),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: cardNo == 1
                    ? '${resultData["marks_obtained"]} '
                    : '${resultData["total_questions"] - resultData["right_answers"] - resultData["unanswered_questions"]}',
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 20,
                  fontFamily: 'SF Pro Display',
                  fontWeight: FontWeight.w500,
                  height: 1.40,
                ),
              ),
              const TextSpan(
                text: ' marks',
                style: TextStyle(
                  color: Color(0xFF737373),
                  fontSize: 12,
                  fontFamily: 'SF Pro Display',
                  fontWeight: FontWeight.w400,
                  height: 2.33,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget columnTwoCard1and2(int cardNo, Map<String, dynamic> resultData) {
  return Container(
    width: double.maxFinite,
    padding: const EdgeInsets.all(12),
    decoration: const BoxDecoration(
      border: Border(
        bottom: BorderSide(
          width: 1,
          color: Color(0xFFDDDDDD),
        ),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          cardNo == 1 ? 'Correct answers' : "Unanswered",
          style: const TextStyle(
            color: Color(0xFF737373),
            fontSize: 12,
            fontFamily: 'SF Pro Display',
            fontWeight: FontWeight.w400,
            height: 1.67,
          ),
        ),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: cardNo == 1
                    ? '${resultData["right_answers"]} '
                    : '${resultData["unanswered_questions"]} ',
                style: TextStyle(
                  color: cardNo == 1
                      ? const Color(0xFF34C759)
                      : const Color(0xFFFE7D14),
                  fontSize: 20,
                  fontFamily: 'SF Pro Display',
                  fontWeight: FontWeight.w500,
                  height: 1.40,
                ),
              ),
              const TextSpan(
                text: 'marks',
                style: TextStyle(
                  color: Color(0xFF737373),
                  fontSize: 12,
                  fontFamily: 'SF Pro Display',
                  fontWeight: FontWeight.w400,
                  height: 2.33,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget rowCard3(int cardNo) {
  return Container(
    width: double.maxFinite,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      border: Border(
        right: cardNo == 2
            ? BorderSide.none
            : const BorderSide(
                width: 1,
                color: Color(0xFFDDDDDD),
              ),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          cardNo == 1 ? 'Total time taken' : "Correct answer time",
          style: const TextStyle(
            color: Color(0xFF737373),
            fontSize: 12,
            fontFamily: 'SF Pro Display',
            fontWeight: FontWeight.w400,
            height: 1.67,
          ),
        ),
        Text(
          cardNo == 1 ? '5 mins 8 secs' : "2 mins 56 secs",
          style: const TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 20,
            fontFamily: 'SF Pro Display',
            fontWeight: FontWeight.w500,
            height: 1.40,
          ),
        ),
      ],
    ),
  );
}

Widget buildTopLeaderBoardUserCard(bool center) {
  return Column(
    children: [
      Container(
        width: center ? 85 : 63,
        height: center ? 85 : 63,
        padding: const EdgeInsets.all(10),
        decoration: ShapeDecoration(
          image: const DecorationImage(
            image: AssetImage("assets/image/user1.jpg"),
            fit: BoxFit.cover,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
      ),
      const Text(
        'Shushant Raj',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFF1A1A1A),
          fontSize: 14,
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w400,
          height: 1.57,
        ),
      ),
      const Text(
        '199 marks',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFF737373),
          fontSize: 12,
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w400,
          height: 1.67,
        ),
      ),
      const Text(
        '19 mins 8 secs',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFF737373),
          fontSize: 12,
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w400,
          height: 1.67,
        ),
      ),
    ],
  );
}

import 'package:flutter/material.dart';

Widget buildExamResultScreenOverviewtable(Map<String, dynamic> resultData) {
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
              columnOneCard(1, resultData),
              columnOneCard(2, resultData),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              columnTwoCard(1, resultData),
              columnTwoCard(2, resultData),
            ],
          ),
        )
      ],
    ),
  );
}

Widget columnOneCard(int cardNo, Map<String, dynamic> resultData) {
  return Container(
    width: double.maxFinite,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      border: Border(
        bottom: cardNo == 1
            ? const BorderSide(width: 1, color: Color(0xFFDDDDDD))
            : BorderSide.none,
        right: const BorderSide(width: 1, color: Color(0xFFDDDDDD)),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          cardNo == 1 ? "Correct" : "Incorrect",
          style: const TextStyle(
            color: Color(0xFF737373),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          cardNo == 1
              ? "${resultData['correct_answers'] ?? 0}"
              : "${resultData['incorrect_answers'] ?? 0}",
          style: TextStyle(
            color:
                cardNo == 1 ? const Color(0xFF34C759) : const Color(0xFFFF3B30),
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

Widget columnTwoCard(int cardNo, Map<String, dynamic> resultData) {
  return Container(
    width: double.maxFinite,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      border: Border(
        bottom: cardNo == 1
            ? const BorderSide(width: 1, color: Color(0xFFDDDDDD))
            : BorderSide.none,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          cardNo == 1 ? "Unattempted" : "Marks Scored",
          style: const TextStyle(
            color: Color(0xFF737373),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          cardNo == 1
              ? "${resultData['unattempted_questions'] ?? 0}"
              : "${resultData['marks_scored'] ?? 0}",
          style: const TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}
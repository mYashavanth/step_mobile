import 'package:flutter/material.dart';

Widget buildTopSelectCards(bool selected, String title) {
  return Container(
    margin: const EdgeInsets.only(left: 6, right: 6),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    decoration: ShapeDecoration(
      color: selected ? const Color(0x0C31B5B9) : Colors.white,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          width: 1,
          color: selected ? const Color(0xFF31B5B9) : const Color(0xFFDDDDDD),
        ),
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    child: Center(
      child: Text(
        title,
        style: TextStyle(
          color: selected ? const Color(0xFF247E80) : const Color(0xFF737373),
          fontSize: 14,
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w500,
          height: 1.57,
        ),
      ),
    ),
  );
}

class QuestAnsSolWidget extends StatelessWidget {
  final List<Map<String, dynamic>> solutionData;

  const QuestAnsSolWidget({super.key, required this.solutionData});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(solutionData.length, (i) {
        return buildQuestionAnsSol(solutionData[i]);
      }),
    );
  }
}

Widget buildQuestionAnsSol(Map<String, dynamic> data) {
  return Container(
    color: Colors.white,
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Question ${data["question_no"]}',
          style: const TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 16,
            fontFamily: 'SF Pro Display',
            fontWeight: FontWeight.w500,
            height: 1.50,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${data["marks_for_question"]} MARKS',
          style: TextStyle(
            color: int.parse(data["marks_for_question"]) <= 0
                ? const Color(0xFFFF3B30)
                : const Color(0xFF34C759),
            fontSize: 14,
            fontFamily: 'SF Pro Display',
            fontWeight: FontWeight.w400,
            height: 1.57,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          data["question"],
          style: const TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 16,
            fontFamily: 'SF Pro Display',
            fontWeight: FontWeight.w400,
            height: 1.50,
          ),
        ),
        const SizedBox(height: 8),
        ...data["options"].asMap().entries.map<Widget>((entry) {
          int index = entry.key;
          var option = entry.value;
          return solAnswerCard(
            data["selected_pre_course_test_options_id"] ==
                option["pre_course_test_questions_options_id"],
            option["option_text"],
            option["option_text"],
            data["correct_option_text"],
            index: index,
          );
        }).toList(),
        const SizedBox(height: 6),
        if (data["solution_text"] != null &&
            data["solution_text"].toString().isNotEmpty)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEBFFF6),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF34C759),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Solution',
                  style: TextStyle(
                    color: Color(0xFF34C759),
                    fontSize: 16,
                    fontFamily: 'SF Pro Display',
                    fontWeight: FontWeight.w700,
                    height: 1.50,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  data["solution_text"] ?? '',
                  style: const TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 16,
                    fontFamily: 'SF Pro Display',
                    fontWeight: FontWeight.w400,
                    height: 1.50,
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}

Widget solAnswerCard(bool selected, String title, String optionText, String ans,
    {int index = 0}) {
  bool ansBool = title == ans;

  String optionPrefix = String.fromCharCode(97 + index);

  return Container(
    padding: const EdgeInsets.all(8),
    margin: const EdgeInsets.only(top: 6, bottom: 6),
    decoration: ShapeDecoration(
      color: selected ? const Color(0x2631B5B9) : Colors.white,
      shape: RoundedRectangleBorder(
        side: BorderSide(
            width: 1,
            color:
                selected ? const Color(0xFF8FE1E3) : const Color(0xFFDDDDDD)),
        borderRadius: BorderRadius.circular(8),
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
        Container(
          height: 40,
          width: 40,
          decoration: ShapeDecoration(
            color: selected ? const Color(0xFF58C9CC) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
              side: BorderSide(
                  width: 1,
                  color:
                      selected ? Colors.transparent : const Color(0xFFDDDDDD)),
            ),
          ),
          child: Center(
            child: Text(
              "$optionPrefix.",
              style: TextStyle(
                color: selected ? Colors.white : Colors.black,
                fontSize: 16,
                fontFamily: 'SF Pro Display',
                fontWeight: FontWeight.w400,
                height: 1.50,
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 12,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                optionText,
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 16,
                  fontFamily: 'SF Pro Display',
                  fontWeight: FontWeight.w400,
                  height: 1.50,
                ),
              ),
              Visibility(
                visible: ansBool,
                child: const Text(
                  'CORRECT ANSWER',
                  style: TextStyle(
                    color: Color(0xFF34C759),
                    fontSize: 14,
                    fontFamily: 'SF Pro Display',
                    fontWeight: FontWeight.w500,
                    height: 1.57,
                  ),
                ),
              ),
              Visibility(
                visible: !ansBool && selected,
                child: const Text(
                  'INCORRECT',
                  style: TextStyle(
                    color: Color(0xFFFF3B30),
                    fontSize: 14,
                    fontFamily: 'SF Pro Display',
                    fontWeight: FontWeight.w500,
                    height: 1.57,
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    ),
  );
}





// Widget solAnswerCard(
//     bool selected, String title, String optionText, String ans) {
//   bool ansBool = title == ans;
//   return Container(
//     padding: const EdgeInsets.all(8),
//     margin: const EdgeInsets.only(top: 6, bottom: 6),
//     decoration: ShapeDecoration(
//       color: selected ? const Color(0x2631B5B9) : Colors.white,
//       shape: RoundedRectangleBorder(
//         side: BorderSide(
//             width: 1,
//             color:
//                 selected ? const Color(0xFF8FE1E3) : const Color(0xFFDDDDDD)),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       shadows: const [
//         BoxShadow(
//           color: Color(0x0C000000),
//           blurRadius: 20,
//           offset: Offset(0, 4),
//           spreadRadius: 0,
//         )
//       ],
//     ),
//     child: Row(
//       children: [
//         Container(
//           height: 40,
//           width: 40,
//           // padding: const EdgeInsets.all(10),
//           decoration: ShapeDecoration(
//             color: selected ? const Color(0xFF58C9CC) : Colors.white,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(50),
//               side: BorderSide(
//                   width: 1,
//                   color:
//                       selected ? Colors.transparent : const Color(0xFFDDDDDD)),
//             ),
//           ),
//           child: Center(
//             child: Text(
//               "a.",
//               style: TextStyle(
//                 color: selected ? Colors.white : Colors.black,
//                 fontSize: 16,
//                 fontFamily: 'SF Pro Display',
//                 fontWeight: FontWeight.w400,
//                 height: 1.50,
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(
//           width: 12,
//         ),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               optionText,
//               style: const TextStyle(
//                 color: Color(0xFF1A1A1A),
//                 fontSize: 16,
//                 fontFamily: 'SF Pro Display',
//                 fontWeight: FontWeight.w400,
//                 height: 1.50,
//               ),
//             ),
//             Visibility(
//               visible: ansBool,
//               child: const Text(
//                 'CORRECT ANSWER',
//                 style: TextStyle(
//                   color: Color(0xFF34C759),
//                   fontSize: 14,
//                   fontFamily: 'SF Pro Display',
//                   fontWeight: FontWeight.w500,
//                   height: 1.57,
//                 ),
//               ),
//             ),
//             Visibility(
//               visible: !ansBool && selected,
//               child: const Text(
//                 'INCORRECT',
//                 style: TextStyle(
//                   color: Color(0xFFFF3B30),
//                   fontSize: 14,
//                   fontFamily: 'SF Pro Display',
//                   fontWeight: FontWeight.w500,
//                   height: 1.57,
//                 ),
//               ),
//             ),
//           ],
//         )
//       ],
//     ),
//   );
// }

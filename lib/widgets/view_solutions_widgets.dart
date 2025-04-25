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

class QuestAnsSolWidget extends StatefulWidget {
  const QuestAnsSolWidget({super.key});

  @override
  State<QuestAnsSolWidget> createState() => _QuestAnsSolWidgetState();
}

class _QuestAnsSolWidgetState extends State<QuestAnsSolWidget> {
  List<Map> solData = [
    {
      "no": 1,
      "marks": -4,
      "answer": "B",
      "question":
          "Identify the structure marked 'X' in the following diagram of the brachial plexus. The marked structure:",
      "selected": 1,
      "options": [
        'Middle Meningeal Artery',
        'Inferior Thyroid Artery',
        'Superior Thyroid Artery',
        'Vertebral Artery'
      ],
      "solution":
          "The median nerve is a major nerve of the upper limb and is formed by the contributions from the lateral and medial cords of the brachial plexus. It lies in the center of the brachial plexus diagram and travels down the arm, passing through the carpal tunnel to supply the forearm and hand.",
      "solution_image": null
    },
    {
      "no": 2,
      "marks": 4,
      "answer": "B",
      "question":
          "Identify the structure marked 'X' in the following diagram of the brachial plexus. The marked structure:",
      "selected": 2,
      "options": [
        'Middle Meningeal Artery',
        'Inferior Thyroid Artery',
        'Superior Thyroid Artery',
        'Vertebral Artery'
      ],
      "solution":
          "The median nerve is a major nerve of the upper limb and is formed by the contributions from the lateral and medial cords of the brachial plexus. It lies in the center of the brachial plexus diagram and travels down the arm, passing through the carpal tunnel to supply the forearm and hand.",
      "solution_image": null
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(solData.length, (i) {
        return buildQuestionAnsSol(solData[i]);
      }),
    );
  }
}

Widget buildQuestionAnsSol(
  Map data,
) {
  return Container(
    color: Colors.white,
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Question ${data["no"]}',
          style: const TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 16,
            fontFamily: 'SF Pro Display',
            fontWeight: FontWeight.w500,
            height: 1.50,
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          '${data["marks"]} MARKS',
          style: TextStyle(
            color: data["marks"] <= 0
                ? const Color(0xFFFF3B30)
                : const Color(0xFF34C759),
            fontSize: 14,
            fontFamily: 'SF Pro Display',
            fontWeight: FontWeight.w400,
            height: 1.57,
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: ShapeDecoration(
                color: const Color(0xFFF3F4F6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Center(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Your time taken: ',
                        style: TextStyle(
                          color: Color(0xFF737373),
                          fontSize: 14,
                          fontFamily: 'SF Pro Display',
                          fontWeight: FontWeight.w400,
                          height: 1.57,
                        ),
                      ),
                      TextSpan(
                        text: '1m 40s',
                        style: TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 14,
                          fontFamily: 'SF Pro Display',
                          fontWeight: FontWeight.w500,
                          height: 1.57,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 12,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: ShapeDecoration(
                color: const Color(0xFFF3F4F6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Center(
                child: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Answer: ',
                        style: TextStyle(
                          color: Color(0xFF737373),
                          fontSize: 14,
                          fontFamily: 'SF Pro Display',
                          fontWeight: FontWeight.w400,
                          height: 1.57,
                        ),
                      ),
                      TextSpan(
                        text: data['answer'],
                        style: const TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 14,
                          fontFamily: 'SF Pro Display',
                          fontWeight: FontWeight.w500,
                          height: 1.57,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 8,
        ),
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
        const SizedBox(
          height: 8,
        ),
        solAnswerCard(
            data["selected"] == 1, "A", data["options"][0], data["answer"]),
        solAnswerCard(
            data["selected"] == 2, "B", data["options"][1], data["answer"]),
        solAnswerCard(
            data["selected"] == 3, "C", data["options"][2], data["answer"]),
        solAnswerCard(
            data["selected"] == 4, "D", data["options"][3], data["answer"]),
        const SizedBox(
          height: 6,
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: ShapeDecoration(
            color: const Color(0xFFEBFFF6),
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1, color: Color(0xFFC8FFE6)),
              borderRadius: BorderRadius.circular(8),
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
              const SizedBox(
                height: 12,
              ),
              Text(
                data["solution"],
                style: const TextStyle(
                  color: Color(0xFF737373),
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

Widget solAnswerCard(
    bool selected, String title, String optionText, String ans) {
  bool ansBool = title == ans;
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
          // padding: const EdgeInsets.all(10),
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
              title,
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
        Column(
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
        )
      ],
    ),
  );
}

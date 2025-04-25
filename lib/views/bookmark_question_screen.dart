import 'package:flutter/material.dart';
import 'package:step_mobile/widgets/view_solutions_widgets.dart';

class BookmarkQuestionScreen extends StatefulWidget {
  const BookmarkQuestionScreen({super.key});

  @override
  State<BookmarkQuestionScreen> createState() => _BookmarkQuestionScreenState();
}

class _BookmarkQuestionScreenState extends State<BookmarkQuestionScreen> {
  List<Map> solData = [
    {
      "no": 1,
      "marks": -4,
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
    {
      "no": 2,
      "marks": 4,
      "answer": "C",
      "question":
          "Identify the structure marked 'X' in the following diagram of the brachial plexus. The marked structure:",
      "selected": 3,
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
      "answer": "A",
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
  ];

  final PageController _pageController = PageController();
  int currentPage = 0;
  void nextPage() {
    if (currentPage < solData.length - 1) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void previousPage() {
    if (currentPage > 0) {
      _pageController.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
          ),
        ),
        title: Text(
          'Question ${currentPage + 1}/${solData.length} )',
          style: const TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 20,
            fontFamily: 'SF Pro Display',
            fontWeight: FontWeight.w500,
            height: 1.40,
          ),
        ),
        actions: const [
          Icon(Icons.bookmark_sharp),
        ],
      ),
      body: PageView.builder(
          controller: _pageController,
          itemCount: solData.length,
          physics:
              const NeverScrollableScrollPhysics(), // Prevent manual swiping
          onPageChanged: (index) {
            print(index);
            setState(() {
              currentPage = index;
            });
          },
          itemBuilder: (context, index) {
            return buildBookMarkQuestionAnsSol(solData[index]);
          }),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () {
                previousPage();
              },
              child: Container(
                width: 40,
                height: 40,
                // padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: ShapeDecoration(
                  color: const Color(0xFFEDEEF0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.arrow_back),
                ),
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () {
                nextPage();
              },
              child: Container(
                width: 40,
                height: 40,
                // padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: ShapeDecoration(
                  color: const Color(0xFFEDEEF0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.arrow_forward),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildBookMarkQuestionAnsSol(
  Map data,
) {
  return Container(
    color: Colors.white,
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text(
        //   'Question ${data["no"]}',
        //   style: const TextStyle(
        //     color: Color(0xFF1A1A1A),
        //     fontSize: 16,
        //     fontFamily: 'SF Pro Display',
        //     fontWeight: FontWeight.w500,
        //     height: 1.50,
        //   ),
        // ),
        // const SizedBox(
        //   height: 8,
        // ),
        // Text(
        //   '${data["marks"]} MARKS',
        //   style: TextStyle(
        //     color: data["marks"] <= 0
        //         ? const Color(0xFFFF3B30)
        //         : const Color(0xFF34C759),
        //     fontSize: 14,
        //     fontFamily: 'SF Pro Display',
        //     fontWeight: FontWeight.w400,
        //     height: 1.57,
        //   ),
        // ),
        // const SizedBox(
        //   height: 8,
        // ),
        // Row(
        //   children: [
        //     Container(
        //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        //       decoration: ShapeDecoration(
        //         color: const Color(0xFFF3F4F6),
        //         shape: RoundedRectangleBorder(
        //           borderRadius: BorderRadius.circular(8),
        //         ),
        //       ),
        //       child: const Center(
        //         child: Text.rich(
        //           TextSpan(
        //             children: [
        //               TextSpan(
        //                 text: 'Your time taken: ',
        //                 style: TextStyle(
        //                   color: Color(0xFF737373),
        //                   fontSize: 14,
        //                   fontFamily: 'SF Pro Display',
        //                   fontWeight: FontWeight.w400,
        //                   height: 1.57,
        //                 ),
        //               ),
        //               TextSpan(
        //                 text: '1m 40s',
        //                 style: TextStyle(
        //                   color: Color(0xFF1A1A1A),
        //                   fontSize: 14,
        //                   fontFamily: 'SF Pro Display',
        //                   fontWeight: FontWeight.w500,
        //                   height: 1.57,
        //                 ),
        //               ),
        //             ],
        //           ),
        //         ),
        //       ),
        //     ),
        //     const SizedBox(
        //       width: 12,
        //     ),
        //     Container(
        //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        //       decoration: ShapeDecoration(
        //         color: const Color(0xFFF3F4F6),
        //         shape: RoundedRectangleBorder(
        //           borderRadius: BorderRadius.circular(8),
        //         ),
        //       ),
        //       child: Center(
        //         child: Text.rich(
        //           TextSpan(
        //             children: [
        //               const TextSpan(
        //                 text: 'Answer: ',
        //                 style: TextStyle(
        //                   color: Color(0xFF737373),
        //                   fontSize: 14,
        //                   fontFamily: 'SF Pro Display',
        //                   fontWeight: FontWeight.w400,
        //                   height: 1.57,
        //                 ),
        //               ),
        //               TextSpan(
        //                 text: data['answer'],
        //                 style: const TextStyle(
        //                   color: Color(0xFF1A1A1A),
        //                   fontSize: 14,
        //                   fontFamily: 'SF Pro Display',
        //                   fontWeight: FontWeight.w500,
        //                   height: 1.57,
        //                 ),
        //               ),
        //             ],
        //           ),
        //         ),
        //       ),
        //     ),
        //   ],
        // ),
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

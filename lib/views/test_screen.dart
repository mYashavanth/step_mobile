import 'package:flutter/material.dart';
import 'package:step_mobile/widgets/test_screen_widgets.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() {
    return _TestScreen();
  }
}

class _TestScreen extends State<TestScreen> {
  static List<Map<String, dynamic>> questions = List.generate(
    4,
    (index) => {
      'question':
          'Question ${index + 1}: Which of the following arteries is a direct branch of the external carotid artery?',
      'options': [
        'Middle Meningeal Artery',
        'Inferior Thyroid Artery',
        'Superior Thyroid Artery',
        'Vertebral Artery'
      ],
      'correctAnswer': 'Middle Meningeal Artery',
    },
  );

  final PageController _pageController = PageController();
  int currentPage = 0;
  void nextPage() {
    if (currentPage < questions.length - 1) {
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

  List<Map> feedbackReviewData = [
    {"name": "Incorrect or incomplete question", "id": 1},
    {"name": "Incorrect or incomplete options", "id": 2},
    {"name": "Formatting or image quality issue", "id": 3},
    {"name": "Other", "id": 4},
  ];

  List<int> selectedReviewoption = [0];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: testScreenAppBar(context),
      body: PageView.builder(
          controller: _pageController,
          itemCount: questions.length,
          physics:
              const NeverScrollableScrollPhysics(), // Prevent manual swiping
          onPageChanged: (index) {
            setState(() {
              currentPage = index;
            });
          },
          itemBuilder: (context, index) {
            return TestScreenWidgets(
              questionData: questions[index],
              index: index,
              questionLength: questions.length,
            );
          }),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x0C23004C),
              blurRadius: 12,
              offset: Offset(0, -3),
              spreadRadius: 0,
            )
          ],
        ),
        padding: const EdgeInsets.all(8),
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
              onTap: () {
                showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    //  isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) {
                      return StatefulBuilder(builder:
                          (BuildContext context, StateSetter modalSetState) {
                        return buidQuestionReviewBottomSheet(
                            modalSetState,
                            feedbackReviewData,
                            selectedReviewoption,
                            "Select your Course",
                            context);
                      });
                    });
              },
              child: Container(
                // width: 127,
                height: 40,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: ShapeDecoration(
                  color: const Color(0x19FE7D14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Mark for review',
                    style: TextStyle(
                      color: Color(0xFFFE7D14),
                      fontSize: 16,
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w500,
                      height: 1.50,
                    ),
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {},
              child: Container(
                // width: 121,
                height: 40,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: ShapeDecoration(
                  color: const Color(0x1931B5B9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Center(
                    child: Text(
                  'Clear selected',
                  style: TextStyle(
                    color: Color(0xFF289799),
                    fontSize: 16,
                    fontFamily: 'SF Pro Display',
                    fontWeight: FontWeight.w500,
                    height: 1.50,
                  ),
                )),
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

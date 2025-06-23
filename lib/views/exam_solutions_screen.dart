import 'package:flutter/material.dart';
import 'package:ghastep/widgets/common_widgets.dart';
import 'package:ghastep/widgets/exam_solution_widgets.dart'; // We'll update this

class ViewExamSolutionScreen extends StatefulWidget {
  const ViewExamSolutionScreen({super.key});

  @override
  State<ViewExamSolutionScreen> createState() => _ViewExamSolutionScreenState();
}

class _ViewExamSolutionScreenState extends State<ViewExamSolutionScreen> {
  List<dynamic> solutionData = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    if (args != null && args.containsKey('solutionData')) {
      final rawSolutionData = args['solutionData'] as List<dynamic>;

      // De-duplicate the list based on 'exam_question_id' to prevent repeats
      final uniqueSolutions = <Map<String, dynamic>>[];
      final seenIds = <dynamic>{}; // Use a Set for efficient lookup
      for (var item in rawSolutionData) {
        final questionId = item['exam_question_id'];
        if (questionId != null && seenIds.add(questionId)) {
          uniqueSolutions.add(item as Map<String, dynamic>);
        }
      }

      setState(() {
        solutionData = uniqueSolutions;
      });
    }
  }

  // Reuse the same top card widget from ViewSolution
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        title: const Text(
          'Solutions',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 20,
            fontFamily: 'SF Pro Display',
            fontWeight: FontWeight.w500,
            height: 1.40,
          ),
        ),
      ),
      body: solutionData.isEmpty
          ? const Center(child: Text("No solutions available."))
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    color: Colors.white,
                    height: 42,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        buildTopSelectCards(true, "All Solutions"),
                        // Add more filters if needed in the future
                      ],
                    ),
                  ),
                  Container(height: 12, color: Colors.white),
                  // Assuming borderHorizontal() is a common widget; if not, define it or remove
                  Column(
                    children: List.generate(solutionData.length, (i) {
                      return buildExamQuestionAnsSol(solutionData[i], context);
                    }),
                  ),
                ],
              ),
            ),
    );
  }
}
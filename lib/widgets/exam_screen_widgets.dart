import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart'; // For rendering HTML/JSON content
import 'package:flutter_svg/flutter_svg.dart';

PreferredSizeWidget buildExamAppBar({
  required BuildContext context,
  required Duration remainingTime,
  required String Function(Duration) formatDuration,
  required int totalQuestions,
  required int attemptedQuestions,
  required void Function() endExam,
}) {
  return AppBar(
    elevation: 0,
    backgroundColor: Colors.white,
    automaticallyImplyLeading: false, // To prevent default back button
    flexibleSpace: SafeArea(
      child: Container(
        padding: const EdgeInsets.only(left: 12),
        child: Row(
          children: [
            Container(
              margin: const EdgeInsets.only(left: 12, right: 12),
              padding: const EdgeInsets.all(8),
              decoration: ShapeDecoration(
                color: const Color(0xFFFFEDEF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/clock_red.svg',
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    formatDuration(remainingTime),
                    style: const TextStyle(
                      color: Color(0xFFFF3B30),
                      fontSize: 16,
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w400,
                      height: 1.50,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                submitExamDialog(
                  context,
                  endExam,
                  totalQuestions,
                  attemptedQuestions,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF247E80),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Submit test',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'SF Pro Display',
                  fontWeight: FontWeight.w500,
                  height: 1.50,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    ),
  );
}

class ExamScreenQuestionWidget extends StatefulWidget {
  final Map<String, dynamic> questionData;
  final int questionIndexInPage; // Index of this question in the PageView
  final int totalQuestions;
  final int? selectedOptionIndex; // The index of the selected option in the options_data list
  final Function(int) onOptionSelected; // Callback with the selected option's index

  const ExamScreenQuestionWidget({
    Key? key,
    required this.questionData,
    required this.questionIndexInPage,
    required this.totalQuestions,
    required this.selectedOptionIndex,
    required this.onOptionSelected,
  }) : super(key: key);

  @override
  _ExamScreenQuestionWidgetState createState() => _ExamScreenQuestionWidgetState();
}

class _ExamScreenQuestionWidgetState extends State<ExamScreenQuestionWidget> {
  int? _currentlySelectedOptionIndex;

  @override
  void initState() {
    super.initState();
    _currentlySelectedOptionIndex = widget.selectedOptionIndex;
  }

  @override
  void didUpdateWidget(covariant ExamScreenQuestionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedOptionIndex != _currentlySelectedOptionIndex) {
      setState(() {
        _currentlySelectedOptionIndex = widget.selectedOptionIndex;
      });
    }
  }

  Widget _buildQuestionContent(String questionJson) {
    try {
      final decoded = jsonDecode(questionJson);
      if (decoded is Map && decoded.containsKey('blocks')) {
        var textContent = StringBuffer();
        for (var block in decoded['blocks']) {
          if (block['type'] == 'paragraph' && block['data'] != null && block['data']['text'] != null) {
            textContent.writeln(block['data']['text']);
          }
          // Add more block types if your JSON structure supports them (e.g., header, list, image)
        }
        if (textContent.isNotEmpty) {
          return Text(
            textContent.toString().trim(),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF1A1A1A)),
          );
        }
      }
    } catch (e) {
      print("Error decoding question JSON: $e. Displaying raw content.");
      // Fallback to rendering as plain text or HTML if JSON parsing fails or structure is unexpected
    }
    // Fallback for non-JSON or unparsable JSON, or if JSON structure doesn't yield text
    return Html(
      data: questionJson,
      style: {
        "body": Style(
          fontSize: FontSize(16.0),
          fontWeight: FontWeight.w500,
          color: const Color(0xFF1A1A1A),
        ),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final questionNumber = widget.questionData['question_no'] ?? widget.questionIndexInPage + 1;
    final questionText = widget.questionData['question'] as String? ?? 'Question text not available.';
    final options = (widget.questionData['options_data'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Question ${questionNumber}/${widget.totalQuestions}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF247E80)),
          ),
          const SizedBox(height: 16),
          _buildQuestionContent(questionText),
          const SizedBox(height: 24),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: options.length,
            itemBuilder: (context, optionIdx) {
              final option = options[optionIdx];
              final optionText = option['option_text'] as String? ?? 'Option text not available';
              bool isSelected = _currentlySelectedOptionIndex == optionIdx;

              return InkWell(
                onTap: () {
                  setState(() {
                    _currentlySelectedOptionIndex = optionIdx;
                  });
                  widget.onOptionSelected(optionIdx);
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 6.0),
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFD4EFF0) : const Color(0xFFF0F0F0), // Teal accent for selected
                    border: Border.all(
                      color: isSelected ? const Color(0xFF247E80) : Colors.grey.shade300,
                      width: isSelected ? 1.5 : 1.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${String.fromCharCode(65 + optionIdx)}. ', // A, B, C...
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? const Color(0xFF247E80) : Colors.black,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          optionText,
                          style: TextStyle(
                            fontSize: 16,
                            color: isSelected ? const Color(0xFF247E80) : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Helper widget for the submission dialog
Widget _buildSubmitStatRow(String icon, String title, String subTitle) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        SvgPicture.asset(
          'assets/icons/$icon',
          width: 24,
          height: 24,
        ),
        const SizedBox(
          width: 12,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF737373),
                fontSize: 14,
                fontFamily: 'SF Pro Display',
                fontWeight: FontWeight.w400,
                height: 1.57,
              ),
            ),
            Text(
              subTitle,
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 16,
                fontFamily: 'SF Pro Display',
                fontWeight: FontWeight.w500,
                height: 1.50,
              ),
            )
          ],
        )
      ],
    ),
  );
}

void submitExamDialog(
  BuildContext context,
  void Function() endExam,
  int totalQuestions,
  int attemptedQuestions,
) {
  showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      contentPadding: const EdgeInsets.all(0),
      content: Container(
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              width: double.maxFinite,
              clipBehavior: Clip.antiAlias,
              decoration: const ShapeDecoration(
                color: Color(0xFF247E80),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Exam',
                    style: TextStyle(
                      color: const Color(0xFFFFCC00),
                      fontSize: 28,
                      fontFamily: 'Rubik Spray Paint',
                      fontWeight: FontWeight.w400,
                      height: 1.29,
                      shadows: [
                        Shadow(
                          offset: const Offset(0, 4),
                          blurRadius: 20,
                          color: const Color(0xFF000000).withOpacity(0.15),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Are you sure you want to submit your exam?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w700,
                      height: 1.40,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              width: double.maxFinite,
              clipBehavior: Clip.antiAlias,
              decoration: const ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
              ),
              child: Column(
                children: [
                  _buildSubmitStatRow(
                    "query.svg",
                    "Total Questions",
                    "$totalQuestions Questions",
                  ),
                  _buildSubmitStatRow(
                    "check_circle.svg",
                    "Attempted",
                    "$attemptedQuestions Questions",
                  ),
                  _buildSubmitStatRow(
                    "cancel.svg",
                    "Unattempted",
                    "${totalQuestions - attemptedQuestions} Questions",
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: ShapeDecoration(
                          color: const Color(0xFFEDEEF0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'Cancel',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF737373),
                              fontSize: 16,
                              fontFamily: 'SF Pro Display',
                              fontWeight: FontWeight.w500,
                              height: 1.50,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop(); // Close the dialog
                        endExam(); // Call the end exam function
                      },
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: ShapeDecoration(
                          color: const Color(0xFF247E80),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'Submit test',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'SF Pro Display',
                              fontWeight: FontWeight.w500,
                              height: 1.50,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
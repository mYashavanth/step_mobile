import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:ui';

// Copy necessary functions from view_solutions_widgets.dart
List<InlineSpan> _buildQuestionContent(dynamic questionData, BuildContext context) {
  final List<InlineSpan> spans = [];
  if (questionData is Map<String, dynamic>) {
    return _buildEditorJsContent(questionData, context);
  }
  if (questionData is String) {
    try {
      final parsedData = jsonDecode(questionData);
      if (parsedData is Map<String, dynamic>) {
        return _buildEditorJsContent(parsedData, context);
      }
    } catch (e) {
      return _buildPlainTextContent(questionData, context);
    }
  }
  return spans;
}

List<InlineSpan> _buildEditorJsContent(Map<String, dynamic> questionData, BuildContext context) {
  final List<InlineSpan> spans = [];
  final List<dynamic> blocks = questionData['blocks'] ?? [];
  for (final block in blocks) {
    final String type = block['type'];
    final Map<String, dynamic> data = block['data'];
    switch (type) {
      case 'paragraph':
        if (data['text'] != null && data['text'].toString().isNotEmpty) {
          String paragraphText = data['text']
              .replaceAll('<br>', '\n')
              .replaceAll('<br/>', '\n')
              .replaceAll('<br />', '\n');
          spans.addAll(_processTextWithFormatting(paragraphText));
          spans.add(const TextSpan(text: '\n\n'));
        }
        break;
      case 'image':
        final String? imageUrl = data['file']?['url'];
        if (imageUrl != null && imageUrl.isNotEmpty) {
          spans.add(WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: GestureDetector(
                onTap: () => _showFullScreenImage(context, imageUrl),
                child: Image.network(
                  imageUrl,
                  width: 200,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 40),
                ),
              ),
            ),
          ));
          spans.add(const TextSpan(text: '\n\n'));
        }
        break;
      case 'header':
        if (data['text'] != null && data['text'].toString().isNotEmpty) {
          spans.addAll(_processTextWithFormatting(
            data['text'],
            baseStyle: TextStyle(
              color: const Color(0xFF1A1A1A),
              fontSize: _getHeaderFontSize(data['level'] ?? 1),
              fontWeight: FontWeight.bold,
              height: 1.50,
            ),
          ));
          spans.add(const TextSpan(text: '\n\n'));
        }
        break;
      case 'list':
        if (data['items'] != null && data['items'] is List) {
          for (var item in data['items']) {
            spans.addAll(_processTextWithFormatting('• $item\n'));
          }
          spans.add(const TextSpan(text: '\n'));
        }
        break;
      case 'table':
        if (data['content'] != null && data['content'] is List) {
          spans.add(WidgetSpan(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              child: _buildTableWidget(data, context),
            ),
          ));
          spans.add(const TextSpan(text: '\n\n'));
        }
        break;
      default:
        if (data['text'] != null && data['text'].toString().isNotEmpty) {
          spans.addAll(_processTextWithFormatting(data['text']));
          spans.add(const TextSpan(text: '\n\n'));
        }
        break;
    }
  }
  return spans;
}

List<InlineSpan> _processTextWithFormatting(String text, {TextStyle? baseStyle}) {
  final List<InlineSpan> spans = [];
  final baseTextStyle = baseStyle ??
      const TextStyle(
        color: Color(0xFF1A1A1A),
        fontSize: 16,
        fontFamily: 'SF Pro Display',
        fontWeight: FontWeight.w400,
        height: 1.50,
      );
  final lines = text.split('\n');
  for (int lineIndex = 0; lineIndex < lines.length; lineIndex++) {
    final line = lines[lineIndex];
    int currentPos = 0;
    final boldPattern = RegExp(r'<b>(.*?)<\/b>');
    final matches = boldPattern.allMatches(line);
    if (matches.isEmpty) {
      if (line.isNotEmpty) {
        spans.add(TextSpan(text: line, style: baseTextStyle));
      }
    } else {
      for (final match in matches) {
        if (match.start > currentPos) {
          spans.add(TextSpan(
            text: line.substring(currentPos, match.start),
            style: baseTextStyle,
          ));
        }
        spans.add(TextSpan(
          text: match.group(1),
          style: baseTextStyle.copyWith(fontWeight: FontWeight.bold),
        ));
        currentPos = match.end;
      }
      if (currentPos < line.length) {
        spans.add(TextSpan(
          text: line.substring(currentPos),
          style: baseTextStyle,
        ));
      }
    }
    if (lineIndex < lines.length - 1) {
      spans.add(const TextSpan(text: '\n'));
    }
  }
  return spans;
}

Widget _buildTableWidget(Map<String, dynamic> tableData, BuildContext context) {
  // Simplified placeholder; expand if table support is needed
  return Container();
}

List<InlineSpan> _buildPlainTextContent(String text, BuildContext context) {
  final List<InlineSpan> spans = [];
  final RegExp urlRegExp = RegExp(
    r'(https?:\/\/[^\s]+(?:\.png|\.jpg|\.jpeg|\.gif))',
    caseSensitive: false,
  );
  final matches = urlRegExp.allMatches(text);
  int lastEnd = 0;
  for (final match in matches) {
    if (match.start > lastEnd) {
      spans.add(TextSpan(
        text: text.substring(lastEnd, match.start),
        style: const TextStyle(
          color: Color(0xFF1A1A1A),
          fontSize: 16,
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w400,
          height: 1.50,
        ),
      ));
    }
    final url = match.group(0)!;
    spans.add(WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: GestureDetector(
          onTap: () => _showFullScreenImage(context, url),
          child: Image.network(
            url,
            width: 200,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 40),
          ),
        ),
      ),
    ));
    lastEnd = match.end;
  }
  if (lastEnd < text.length) {
    spans.add(TextSpan(
      text: text.substring(lastEnd),
      style: const TextStyle(
        color: Color(0xFF1A1A1A),
        fontSize: 16,
        fontFamily: 'SF Pro Display',
        fontWeight: FontWeight.w400,
        height: 1.50,
      ),
    ));
  }
  return spans;
}

double _getHeaderFontSize(int level) {
  switch (level) {
    case 1: return 24;
    case 2: return 20;
    case 3: return 18;
    default: return 16;
  }
}

void _showFullScreenImage(BuildContext context, String imageUrl) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Image",
    pageBuilder: (context, anim1, anim2) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
              child: Container(
                color: const Color.fromRGBO(255, 255, 255, 0.2),
              ),
            ),
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.broken_image,
                      color: Colors.white,
                      size: 80),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 24,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(0, 0, 0, 0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 32),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

// Updated option rendering widget with explicit logic
Widget examSolAnswerCard(
    bool selected, bool correct, String optionText, int index) {
  String optionPrefix = String.fromCharCode(97 + index); // a, b, c...

  Color cardColor = Colors.white;
  Color borderColor = const Color(0xFFDDDDDD);
  Color prefixColor = Colors.white;
  Color prefixTextColor = Colors.black;
  Widget? statusLabel;

  // Case 1: The user selected the correct answer.
  if (selected && correct) {
    cardColor = const Color(0x1A34C759); // Light green
    borderColor = const Color(0xFF34C759); // Green
    prefixColor = const Color(0xFF34C759);
    prefixTextColor = Colors.white;
    statusLabel = const Text(
      'CORRECT',
      style: TextStyle(
        color: Color(0xFF34C759),
        fontSize: 14,
        fontFamily: 'SF Pro Display',
        fontWeight: FontWeight.w500,
      ),
    );
  }
  // Case 2: The user selected an incorrect answer.
  else if (selected && !correct) {
    cardColor = const Color(0x1AFF3B30); // Light red
    borderColor = const Color(0xFFFF3B30); // Red
    prefixColor = const Color(0xFFFF3B30);
    prefixTextColor = Colors.white;
    statusLabel = const Text(
      'INCORRECT',
      style: TextStyle(
        color: Color(0xFFFF3B30),
        fontSize: 14,
        fontFamily: 'SF Pro Display',
        fontWeight: FontWeight.w500,
      ),
    );
  }
  // Case 3: This is the correct answer, but the user didn't select it.
  else if (!selected && correct) {
    cardColor = const Color(0x1A34C759); // Light green
    borderColor = const Color(0xFF34C759); // Green
    prefixColor = const Color(0xFF34C759);
    prefixTextColor = Colors.white;
    statusLabel = const Text(
      'Correct Answer',
      style: TextStyle(
        color: Color(0xFF34C759),
        fontSize: 14,
        fontFamily: 'SF Pro Display',
        fontWeight: FontWeight.w500,
      ),
    );
  }
  // Case 4: An unselected, incorrect option (uses default styling).

  return Container(
    padding: const EdgeInsets.all(8),
    margin: const EdgeInsets.only(top: 6, bottom: 6),
    decoration: ShapeDecoration(
      color: cardColor,
      shape: RoundedRectangleBorder(
        side: BorderSide(width: 1, color: borderColor),
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
            color: prefixColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
              side: BorderSide(
                  width: 1,
                  color: (correct || selected)
                      ? Colors.transparent
                      : const Color(0xFFDDDDDD)),
            ),
          ),
          child: Center(
            child: Text(
              "$optionPrefix.",
              style: TextStyle(
                color: prefixTextColor,
                fontSize: 16,
                fontFamily: 'SF Pro Display',
                fontWeight: FontWeight.w400,
                height: 1.50,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
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
              if (statusLabel != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: statusLabel,
                ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget buildExamQuestionAnsSol(Map<String, dynamic> data, BuildContext context) {
  final options = (data['options'] as List?)?.cast<Map<String, dynamic>>() ?? [];
  
  // Convert IDs to strings to ensure type-safe comparison.
  final userSelectedOptionId = data['user_selected_option_id']?.toString();
  final correctOptionId = data['correct_option_id']?.toString();
print("Question ${data['question_no']}: userSelectedOptionId=$userSelectedOptionId, correctOptionId=$correctOptionId, options=${options.map((o) => o['exam_option_id'])}");
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
        if (data["marks_for_question"] != null)
          Text(
            '${data["marks_for_question"]} MARKS',
            style: TextStyle(
              color: int.parse(data["marks_for_question"].toString()) <= 0
                  ? const Color(0xFFFF3B30)
                  : const Color(0xFF34C759),
              fontSize: 14,
              fontFamily: 'SF Pro Display',
              fontWeight: FontWeight.w400,
              height: 1.57,
            ),
          ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            children: _buildQuestionContent(data['question'] ?? '', context),
          ),
        ),
        const SizedBox(height: 8),
        ...List.generate(options.length, (i) {
          final option = options[i];
          // Also convert the option's ID to a string for a safe comparison.
          final optionId = option['exam_option_id']?.toString();

          // Perform a null-safe and type-safe comparison.
          final isSelected = userSelectedOptionId != null && optionId == userSelectedOptionId;
          final isCorrect = correctOptionId != null && optionId == correctOptionId;
          
          return examSolAnswerCard(isSelected, isCorrect, option['option_text'] ?? '', i);
        }),
        if (data['solution_text'] != null &&
            data['solution_text'].toString().isNotEmpty)
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
                RichText(
                  text: TextSpan(
                    children: _buildQuestionContent(data['solution_text'] ?? '', context),
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}
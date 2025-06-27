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
    bool isSelected, bool isCorrect, String optionText, int index, BuildContext context) {
  String optionPrefix = String.fromCharCode(97 + index); // a, b, c...

  // Determine colors based on selection state
  Color cardColor = isSelected ? const Color(0x1A31B5B9) : Colors.white;
  Color borderColor = isSelected ? const Color(0xFF31B5B9) : const Color(0xFFDDDDDD);
  Color prefixColor = isSelected ? const Color(0xFF31B5B9) : const Color(0xFF737373);
  Color prefixTextColor = Colors.white;

  Widget? statusLabel;

  // Determine status labels based on correctness
  if (isCorrect) {
    statusLabel = const Text(
      'CORRECT ANSWER',
      style: TextStyle(
        color: Color(0xFF34C759), // Green
        fontSize: 14,
        fontFamily: 'SF Pro Display',
        fontWeight: FontWeight.w500,
      ),
    );
  } else if (isSelected && !isCorrect) {
    statusLabel = const Text(
      'INCORRECT ANSWER',
      style: TextStyle(
        color: Color(0xFFFF3B30), // Red
        fontSize: 14,
        fontFamily: 'SF Pro Display',
        fontWeight: FontWeight.w500,
      ),
    );
  }

  return Container(
    padding: const EdgeInsets.all(12),
    margin: const EdgeInsets.only(top: 6, bottom: 6),
    decoration: ShapeDecoration(
      color: cardColor,
      shape: RoundedRectangleBorder(
        side: BorderSide(width: 1, color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: ShapeDecoration(
            color: prefixColor,
            shape: const OvalBorder(),
          ),
          child: Center(
            child: Text(
              optionPrefix.toUpperCase(),
              style: TextStyle(
                color: prefixTextColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: _buildQuestionContent(optionText, context),
                  style: const TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 16,
                    fontFamily: 'SF Pro Display',
                    fontWeight: FontWeight.w400,
                    height: 1.50,
                  ),
                ),
              ),
              if (statusLabel != null) ...[
                const SizedBox(height: 8),
                statusLabel,
              ],
            ],
          ),
        ),
      ],
    ),
  );
}

Widget buildExamQuestionAnsSol(Map<String, dynamic> data, BuildContext context) {
  final options = (data['options'] as List?)?.cast<Map<String, dynamic>>() ?? [];
  
  // Using the correct key from the logs: 'selected_exam_option_id'
  final userSelectedOptionId = data['selected_exam_option_id']?.toString();
  final correctOptionId = data['correct_option_id']?.toString();

  return Container(
    color: Colors.white,
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Question ${data['question_no']}',
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 16,
                fontFamily: 'SF Pro Display',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        RichText(
          text: TextSpan(
            children: _buildQuestionContent(data['question'], context),
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(options.length, (i) {
          final option = options[i];
          final optionId = option['exam_option_id']?.toString();
          final bool isSelected = userSelectedOptionId == optionId;
          final bool isCorrect = correctOptionId == optionId;
          return examSolAnswerCard(
              isSelected, isCorrect, option['option_text'], i, context);
        }),
        const SizedBox(height: 12),
        const Text(
          'Solution',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 16,
            fontFamily: 'SF Pro Display',
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            children: _buildQuestionContent(data['solution_text'], context),
          ),
        ),
      ],
    ),
  );
}
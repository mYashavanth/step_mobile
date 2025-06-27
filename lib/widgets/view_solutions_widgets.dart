import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ghastep/views/dry.dart';
import 'dart:ui';
import 'dart:convert';
import 'dart:math' as math;

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
  final List<Map<String, dynamic>> solutionData;

  const QuestAnsSolWidget({super.key, required this.solutionData});

  @override
  State<QuestAnsSolWidget> createState() => _QuestAnsSolWidgetState();
}

class _QuestAnsSolWidgetState extends State<QuestAnsSolWidget> {
  final storage = const FlutterSecureStorage();
  bool isPreCourse = true;
  @override
  void initState() {
    super.initState();
    _loadIsPreCourseFlag();
    // Initialize any state or fetch data if needed
  }

  Future<void> _loadIsPreCourseFlag() async {
    try {
      String? isPreCourseFlag = await storage.read(key: "isPreCourse");
      setState(() {
        isPreCourse = isPreCourseFlag == "true";
      });
    } catch (e) {
      print("Error loading isPreCourse flag: $e");
      showCustomSnackBar(
        context: context,
        message: "An error occurred while loading test details.",
        isSuccess: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Solution Data: ${widget.solutionData}");
    return Column(
      children: List.generate(widget.solutionData.length, (i) {
        return buildQuestionAnsSol(
            widget.solutionData[i], isPreCourse, context);
      }),
    );
  }
}

Widget buildQuestionAnsSol(
    Map<String, dynamic> data, bool isPreCourse, context) {
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
        RichText(
          text: TextSpan(
            children: _buildQuestionContent(data["question"], context),
          ),
        ),
        const SizedBox(height: 8),
        ...data["options"].asMap().entries.map<Widget>((entry) {
          int index = entry.key;
          var option = entry.value;
          return solAnswerCard(
            isPreCourse
                ? data["selected_pre_course_test_options_id"] ==
                    option["pre_course_test_questions_options_id"]
                : data["selected_post_course_test_options_id"] ==
                    option["post_course_test_questions_options_id"],
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
                RichText(
                  text: TextSpan(
                    children: _buildQuestionContent(
                        data["solution_text"] ?? '', context),
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

List<InlineSpan> buildSolutionContent(String solution, BuildContext context) {
  final RegExp urlRegExp = RegExp(
    r'(https?:\/\/[^\s]+(?:\.png|\.jpg|\.jpeg|\.gif))',
    caseSensitive: false,
  );
  final List<InlineSpan> spans = [];
  final matches = urlRegExp.allMatches(solution);

  int lastEnd = 0;
  for (final match in matches) {
    // Add text before the image
    if (match.start > lastEnd) {
      spans.add(TextSpan(
        text: solution.substring(lastEnd, match.start),
        style: const TextStyle(
          color: Color(0xFF1A1A1A),
          fontSize: 16,
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w400,
          height: 1.50,
        ),
      ));
    }
    // Add the image as a WidgetSpan
    final url = match.group(0)!;
    spans.add(WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: GestureDetector(
          onTap: () {
            showGeneralDialog(
              context: context,
              barrierDismissible: true,
              barrierLabel: "Image",
              pageBuilder: (context, anim1, anim2) {
                return Scaffold(
                  backgroundColor: Colors.transparent,
                  body: Stack(
                    children: [
                      // Glassmorphism background
                      BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                        child: Container(
                          color: const Color.fromRGBO(255, 255, 255, 0.2),
                        ),
                      ),
                      // Centered zoomable image
                      Center(
                        child: InteractiveViewer(
                          minScale: 0.5,
                          maxScale: 4,
                          child: Image.network(
                            url,
                            fit: BoxFit.contain,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image,
                                    color: Colors.white, size: 80),
                          ),
                        ),
                      ),
                      // Close button
                      Positioned(
                        top: 40,
                        right: 24,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color.fromRGBO(0, 0, 0, 0.5),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.close,
                                color: Colors.white, size: 32),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          child: Image.network(
            url,
            width: 200,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image, size: 40),
          ),
        ),
      ),
    ));
    lastEnd = match.end;
  }
  // Add any remaining text after the last image
  if (lastEnd < solution.length) {
    spans.add(TextSpan(
      text: solution.substring(lastEnd),
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

List<InlineSpan> _buildQuestionContent(
    dynamic questionData, BuildContext context) {
  final List<InlineSpan> spans = [];

  // Handle case when questionData is already a Map (parsed JSON)
  if (questionData is Map<String, dynamic>) {
    return _buildEditorJsContent(questionData, context);
  }

  // Handle case when questionData is a String
  if (questionData is String) {
    // First try to parse it as JSON
    try {
      final parsedData = jsonDecode(questionData);
      if (parsedData is Map<String, dynamic>) {
        return _buildEditorJsContent(parsedData, context);
      }
    } catch (e) {
      // If parsing fails, treat it as plain text
      return _buildPlainTextContent(questionData, context);
    }
  }

  // Fallback to empty content
  return spans;
}

List<InlineSpan> _buildEditorJsContent(
    Map<String, dynamic> questionData, BuildContext context) {
  final List<InlineSpan> spans = [];

  try {
    final List<dynamic> blocks = questionData['blocks'] ?? [];

    for (final block in blocks) {
      final String type = block['type'];
      final Map<String, dynamic> data = block['data'];

      switch (type) {
        case 'paragraph':
          if (data['text'] != null) {
            String paragraphText = data['text'].toString();

            // Check if the text is empty or only contains whitespace/HTML line breaks
            bool isEmptyText = paragraphText.trim().isEmpty ||
                paragraphText
                    .replaceAll(RegExp(r'<br\s*/?>'), '')
                    .trim()
                    .isEmpty;

            if (!isEmptyText) {
              // Handle all variations of line breaks
              paragraphText = paragraphText
                  .replaceAll('<br>', '\n')
                  .replaceAll('<br/>', '\n')
                  .replaceAll('<br />', '\n');

              // Process bold tags and split text by newlines
              spans.addAll(_processTextWithFormatting(paragraphText));
              // Add spacing after paragraph
              spans.add(const TextSpan(text: '\n\n'));
            }
          }
          break;

        case 'image':
          // Handle images
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
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image, size: 40),
                  ),
                ),
              ),
            ));
            // Add spacing after image
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
          // For unsupported types, try to display any text content
          if (data['text'] != null && data['text'].toString().isNotEmpty) {
            spans.addAll(_processTextWithFormatting(data['text']));
            spans.add(const TextSpan(text: '\n\n'));
          }
          break;
      }
    }
  } catch (e) {
    // If something goes wrong with JSON processing, fall back to showing raw data
    spans.addAll(_processTextWithFormatting(jsonEncode(questionData)));
  }

  return spans;
}

List<InlineSpan> _processTextWithFormatting(String text,
    {TextStyle? baseStyle}) {
  final List<InlineSpan> spans = [];
  final baseTextStyle = baseStyle ??
      const TextStyle(
        color: Color(0xFF1A1A1A),
        fontSize: 16,
        fontFamily: 'SF Pro Display',
        fontWeight: FontWeight.w400,
        height: 1.50,
      );

  // Split text by lines first
  final lines = text.split('\n');

  for (int lineIndex = 0; lineIndex < lines.length; lineIndex++) {
    final line = lines[lineIndex];
    int currentPos = 0;
    final boldPattern = RegExp(r'<b>(.*?)<\/b>');
    final matches = boldPattern.allMatches(line);

    if (matches.isEmpty) {
      if (line.isNotEmpty) {
        if (line.contains('<b>') || line.contains('</b>')) {
          // If the line contains bold tags but no matches, treat it as bold text
          spans.add(TextSpan(
            text: line.replaceAll(RegExp(r'<b>|<\/b>'), ''),
            style: baseTextStyle.copyWith(fontWeight: FontWeight.bold),
          ));
        } else {
          spans.add(TextSpan(
            text: line,
            style: baseTextStyle,
          ));
        }
      }
    } else {
      for (final match in matches) {
        // Add text before the bold tag
        if (match.start > currentPos) {
          spans.add(TextSpan(
            text: line.substring(currentPos, match.start),
            style: baseTextStyle,
          ));
        }

        // Add the bold text
        spans.add(TextSpan(
          text: match.group(1),
          style: baseTextStyle.copyWith(fontWeight: FontWeight.bold),
        ));

        currentPos = match.end;
      }

      // Add remaining text after last bold tag
      if (currentPos < line.length) {
        spans.add(TextSpan(
          text: line.substring(currentPos),
          style: baseTextStyle,
        ));
      }
    }

    // Add newline if it's not the last line
    if (lineIndex < lines.length - 1) {
      spans.add(const TextSpan(text: '\n'));
    }
  }

  return spans;
}

Widget _buildTableWidget(Map<String, dynamic> tableData, BuildContext context) {
  String _decodeHtmlEntities(String text) {
    return text
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ');
  }

  final bool withHeadings = tableData['withHeadings'] ?? false;
  final bool stretched = tableData['stretched'] ?? false;
  final List<List<String>> content = List<List<String>>.from(
    tableData['content']?.map((row) => List<String>.from(row)) ?? [],
  );

  if (content.isEmpty) return const SizedBox();

  Widget _buildTextWithFormatting(String text) {
    final decodedText = _decodeHtmlEntities(text);
    final List<InlineSpan> spans = [];
    int currentPos = 0;
    final boldPattern = RegExp(r'<b>(.*?)<\/b>');
    final matches = boldPattern.allMatches(decodedText);

    if (matches.isEmpty) {
      return Text(
        decodedText,
        style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
      );
    } else {
      for (final match in matches) {
        if (match.start > currentPos) {
          spans.add(TextSpan(
            text: decodedText.substring(currentPos, match.start),
            style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
          ));
        }

        spans.add(TextSpan(
          text: match.group(1),
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.bold,
          ),
        ));

        currentPos = match.end;
      }

      if (currentPos < decodedText.length) {
        spans.add(TextSpan(
          text: decodedText.substring(currentPos),
          style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
        ));
      }

      return RichText(
        text: TextSpan(children: spans),
      );
    }
  }

  Widget buildTableCell(String cellText) {
    final decodedText = _decodeHtmlEntities(cellText);

    if (decodedText.toLowerCase().endsWith('.png') ||
        decodedText.toLowerCase().endsWith('.jpg') ||
        decodedText.toLowerCase().endsWith('.jpeg') ||
        decodedText.toLowerCase().endsWith('.gif')) {
      return GestureDetector(
        onTap: () => _showFullScreenImage(context, decodedText),
        child: Image.network(
          decodedText,
          width: 150,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.broken_image, size: 40),
        ),
      );
    }

    final anchorPattern =
        RegExp(r'<a\s+(?:[^>]*?\s+)?href="([^"]*)"[^>]*>(.*?)<\/a>');
    final anchorMatch = anchorPattern.firstMatch(decodedText);

    if (anchorMatch != null) {
      final url = anchorMatch.group(1)!;
      final linkText =
          anchorMatch.group(2)!.isNotEmpty ? anchorMatch.group(2)! : url;

      if (url.toLowerCase().endsWith('.png') ||
          url.toLowerCase().endsWith('.jpg') ||
          url.toLowerCase().endsWith('.jpeg') ||
          url.toLowerCase().endsWith('.gif')) {
        return GestureDetector(
          onTap: () => _showFullScreenImage(context, url),
          child: Image.network(
            url,
            width: 150,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image, size: 40),
          ),
        );
      } else {
        return InkWell(
          onTap: () => _showFullScreenImage(context, url),
          child: Text(
            linkText,
            style: const TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
              fontSize: 14,
            ),
          ),
        );
      }
    }

    return _buildTextWithFormatting(decodedText);
  }

  final screenWidth = MediaQuery.of(context).size.width;
  final columnCount = content.isNotEmpty ? content[0].length : 0;
  final maxColumnWidth = screenWidth * 0.6; // 60% of screen width
  final minColumnWidth = 120.0; // Minimum width for columns

  // Calculate the total content width needed
  double totalContentWidth = 0;
  final columnWidths = <int, double>{};

  // First pass: Calculate natural column widths
  for (int col = 0; col < columnCount; col++) {
    double maxWidth = minColumnWidth;
    for (int row = 0; row < content.length; row++) {
      final cellText = content[row][col];
      final textPainter = TextPainter(
        text: TextSpan(
          text:
              _decodeHtmlEntities(cellText.replaceAll(RegExp(r'<[^>]*>'), '')),
          style: const TextStyle(fontSize: 14),
        ),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout();
      maxWidth = math.max(maxWidth, textPainter.width + 16); // Add padding
    }
    columnWidths[col] = math.min(maxWidth, maxColumnWidth);
    totalContentWidth += columnWidths[col]!;
  }

  return ConstrainedBox(
    constraints: BoxConstraints(
      maxWidth: screenWidth,
      minWidth:
          stretched ? screenWidth : math.min(totalContentWidth, screenWidth),
    ),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        constraints: BoxConstraints(
          minWidth: stretched ? screenWidth : totalContentWidth,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Table(
          columnWidths: columnWidths
              .map((index, width) => MapEntry(index, FixedColumnWidth(width))),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          border: TableBorder(
            horizontalInside: BorderSide(color: Colors.grey.shade300),
            verticalInside: BorderSide(color: Colors.grey.shade300),
          ),
          children: [
            if (withHeadings && content.isNotEmpty)
              TableRow(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                ),
                children: content[0].map((cell) {
                  return Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      _decodeHtmlEntities(
                          cell.replaceAll('<b>', '').replaceAll('</b>', '')),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
              ),
            ...content
                .sublist(withHeadings ? 1 : 0)
                .map((row) => TableRow(
                      children: row.map((cell) {
                        return Padding(
                          padding: const EdgeInsets.all(8),
                          child: buildTableCell(cell),
                        );
                      }).toList(),
                    ))
                .toList(),
          ],
        ),
      ),
    ),
  );
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
    // Add text before the image
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
    // Add the image as a WidgetSpan
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
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image, size: 40),
          ),
        ),
      ),
    ));
    lastEnd = match.end;
  }
  // Add any remaining text after the last image
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
    case 1:
      return 24;
    case 2:
      return 20;
    case 3:
      return 18;
    default:
      return 16;
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
            // Glassmorphism background
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
              child: Container(
                color: const Color.fromRGBO(255, 255, 255, 0.2),
              ),
            ),
            // Centered zoomable image
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
            // Close button
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

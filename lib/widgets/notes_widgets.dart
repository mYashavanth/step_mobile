import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ghastep/views/urlconfig.dart';
import 'package:ghastep/widgets/course_screen_widgets.dart'; // For NoteItem

class NotesWidgets extends StatefulWidget {
  const NotesWidgets({super.key});

  @override
  State<NotesWidgets> createState() {
    return _NotesWidget();
  }
}

class _NotesWidget extends State<NotesWidgets>
    with SingleTickerProviderStateMixin {
  final storage = const FlutterSecureStorage();
  List<Map<String, dynamic>> subjectsData = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchSubjectsAndNotes();
  }

  Future<void> _fetchSubjectsAndNotes() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      String? token = await storage.read(key: 'token');
      String? courseId = await storage.read(key: 'selectedCourseId');

      if (token == null || courseId == null) {
        setState(() {
          errorMessage = 'Missing token or course ID';
          isLoading = false;
        });
        return;
      }

      // Fetch subjects for the selected course
      final subjectsResponse = await http.get(
        Uri.parse(
            '$baseurl/app/get-all-subjects-by-course-id/$token/$courseId'),
      );

      if (subjectsResponse.statusCode == 200) {
        final List<dynamic> subjects = json.decode(subjectsResponse.body);
        List<Map<String, dynamic>> tempSubjectsData = [];

        // Fetch notes for each subject
        for (var subject in subjects) {
          final subjectId = subject['id'].toString();
          final notesResponse = await http.get(
            Uri.parse(
                '$baseurl/mobile/notes/get-by-course-subject/$courseId/$subjectId/$token'),
          );

          List<dynamic> notes = [];
          if (notesResponse.statusCode == 200) {
            final notesData = jsonDecode(notesResponse.body);
            if (notesData['errFlag'] == 0) {
              notes = notesData['notes'];
            }
          }

          tempSubjectsData.add({
            'title': subject['subject_name'],
            'enlarge': false,
            'subNotes': notes
                .map((note) => {
                      'notes_title': note['notes_title'],
                      'no_of_pages': note['no_of_pages'],
                      'id': note['id'],
                      'document_url': note['document_url'],
                    })
                .toList(),
          });
        }

        setState(() {
          subjectsData = tempSubjectsData;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage =
              'Failed to fetch subjects: ${subjectsResponse.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching data: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorMessage.isNotEmpty) {
      return Center(child: Text(errorMessage));
    }
    if (subjectsData.isEmpty) {
      return const Center(child: Text('No subjects available'));
    }

    return Column(
      children: List.generate(subjectsData.length, (index) {
        Map data = subjectsData[index];
        String title = data['title'];
        List subNotes = data['subNotes'];
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(12),
          color: Colors.white,
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    margin: const EdgeInsets.only(right: 20),
                    clipBehavior: Clip.antiAlias,
                    decoration: ShapeDecoration(
                      color: const Color(0x1931B5B9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(200),
                      ),
                      shadows: const [
                        BoxShadow(
                          color: Color(0x0C86F57F),
                          blurRadius: 10,
                          offset: Offset(0, 1),
                          spreadRadius: 0,
                        )
                      ],
                    ),
                    child: Center(
                      child: Text(
                        title[0],
                        style: TextStyle(
                          color: const Color(0xFF247E80),
                          fontSize: 20,
                          fontFamily: 'SF Pro Display',
                          fontWeight: FontWeight.w700,
                          height: 1.20,
                          shadows: [
                            Shadow(
                              offset: const Offset(0, 4),
                              blurRadius: 20,
                              color: const Color(0xFF000000).withOpacity(0.25),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 16,
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w500,
                      height: 1.50,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        data['enlarge'] = !data['enlarge'];
                      });
                    },
                    icon: data['enlarge']
                        ? const Icon(Icons.remove)
                        : const Icon(Icons.add),
                  ),
                ],
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: data['enlarge']
                    ? Column(
                        children: List.generate(subNotes.length, (subIndex) {
                          final note = subNotes[subIndex];
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: NoteItem(
                              docName: note['notes_title'],
                              page: note['no_of_pages'],
                              locked: false,
                              icon: 'adobe_pdf.svg',
                              noteId: note['id'],
                              documentUrl: note['document_url'],
                            ),
                          );
                        }),
                      )
                    : const SizedBox(),
              ),
            ],
          ),
        );
      }),
    );
  }
}

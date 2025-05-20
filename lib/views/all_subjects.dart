import 'package:flutter/material.dart';
import 'package:ghastep/widgets/homepage_widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ghastep/views/urlconfig.dart';

class AllSubjectsScreen extends StatefulWidget {
  const AllSubjectsScreen({super.key});

  @override
  State<AllSubjectsScreen> createState() => _AllSubjectsScreenState();
}

class _AllSubjectsScreenState extends State<AllSubjectsScreen> {
  final storage = const FlutterSecureStorage();
  List<Map<String, dynamic>> subjects = [];
  bool isLoadingSubjects = true;
  String subjectError = '';
  String bannerImage = '';

  @override
  void initState() {
    super.initState();
    _fetchSubjects();
  }

  Future<void> _fetchSubjects() async {
    final storedCourseId = await storage.read(key: 'selectedCourseId');
    setState(() {
      isLoadingSubjects = true;
      subjectError = '';
    });

    try {
      String token = await storage.read(key: 'token') ?? '';
      int courseId = storedCourseId != null ? int.parse(storedCourseId) : 1;
      // ? selectedCourseIds.first
      // : storedCourseId != null
      //     ? int.parse(storedCourseId)
      //     : 1;

      final response = await http.get(
        Uri.parse(
            '$baseurl/app/get-all-subjects-by-course-id/$token/$courseId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          subjects = data
              .map((subject) => {
                    'id': subject['id'],
                    'name': subject['subject_name'],
                  })
              .toList();
        });
      } else {
        print('Failed to load subjects: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        subjectError = 'Failed to load subjects: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoadingSubjects = false;
      });
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
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
          ),
        ),
        title: const Text(
          'All subjects (crash course)',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 20,
            fontFamily: 'SF Pro Display',
            fontWeight: FontWeight.w500,
            height: 1.40,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              const SizedBox(
                height: 8,
              ),
              if (isLoadingSubjects)
                const Center(child: CircularProgressIndicator())
              else if (subjectError.isNotEmpty)
                Text(subjectError)
              else if (subjects.isEmpty)
                const Text('No subjects available')
              else
                ...subjects.asMap().entries.map((entry) {
                  int index = entry.key;
                  var subject = entry.value;
                  // print('value: ${subject}');
                  return Column(
                    children: [
                      buildStepWiseCourseCard(
                        (index + 1).toString().padLeft(2, '0'),
                        // index == 0 ? 1 : 0, // 0 is for unlocked, 1 is for locked , 2 is for completed
                        1,
                        subject['name'],
                        subject['id'].toString(),
                        context,
                      ),
                      const SizedBox(height: 8),
                    ],
                  );
                }).toList(),
              // buildStepWiseCourseCard("01", 2, "Anatomy", '1', context),
              // const SizedBox(
              //   height: 8,
              // ),
              // buildStepWiseCourseCard("02", 1, "Physiology", '1', context),
              // const SizedBox(
              //   height: 8,
              // ),
              // buildStepWiseCourseCard("03", 0, "Biochemistry", '1', context),
              // const SizedBox(
              //   height: 8,
              // ),
              // buildStepWiseCourseCard("04", 0, "Pathology", '1', context),
              // const SizedBox(
              //   height: 8,
              // ),
              // buildStepWiseCourseCard("05", 0, "Parmacology", '1', context),
              // const SizedBox(
              //   height: 8,
              // ),
              // buildStepWiseCourseCard(
              //     "06", 0, "Comunity Medicine", '1', context),
              // const SizedBox(
              //   height: 8,
              // ),
              // buildStepWiseCourseCard(
              //     "07", 0, "Forensic Medicine", '1', context),
              // const SizedBox(
              //   height: 24,
              // ),
              // buildStepWiseCourseCard(
              //     "08", 0, "General Medicine", '1', context),
              // const SizedBox(
              //   height: 24,
              // ),
              // buildStepWiseCourseCard("09", 0, "Pediatrics", '1', context),
              // const SizedBox(
              //   height: 24,
              // ),
              // buildStepWiseCourseCard(
              //     "10", 0, "Dermatology, Venereol...", '1', context),
              // const SizedBox(
              //   height: 24,
              // ),
              // buildStepWiseCourseCard("11", 0, "Psychiatry", '1', context),
              // const SizedBox(
              //   height: 24,
              // ),
              // buildStepWiseCourseCard("12", 0, "Orthopedics", '1', context),
              // const SizedBox(
              //   height: 24,
              // ),
              // buildStepWiseCourseCard("13", 0, "Anesthesiology", '1', context),
              // const SizedBox(
              //   height: 24,
              // ),
              // buildStepWiseCourseCard("14", 0, "Radiology", '1', context),
              // const SizedBox(
              //   height: 24,
              // ),
              // buildStepWiseCourseCard(
              //     "15", 0, "Obstetrics & Gynecology", '1', context),
              // const SizedBox(
              //   height: 24,
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

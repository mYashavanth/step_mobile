import 'package:flutter/material.dart';
import 'package:step_mobile/widgets/inputs.dart';
import 'package:step_mobile/widgets/select_course_widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:step_mobile/views/urlconfig.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SelectCourse extends StatefulWidget {
  const SelectCourse({super.key});

  @override
  State<SelectCourse> createState() => _SelectCourseState();
}

class _SelectCourseState extends State<SelectCourse> {
  bool graduate = false;
  TextEditingController yearOfStudy = TextEditingController();
  bool isLoading = false;
  List<dynamic> courses = [];
  int? selectedCourseId;
  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    fetchCourses();
  }

  Future<void> fetchCourses() async {
    setState(() {
      isLoading = true;
    });

    try {
      String token = await storage.read(key: 'token') ?? '';
      final response = await http.get(
        Uri.parse('$baseurl/app/get-all-course-names/$token'),
      );

      if (response.statusCode == 200) {
        setState(() {
          courses = json.decode(response.body);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching courses: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateUGGStatus() async {
    if (yearOfStudy.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter year of study')),
      );
      return;
    }

    if (selectedCourseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a course')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      String token = await storage.read(key: 'token') ?? '';
      await storage.write(
          key: 'selectedCourseId', value: selectedCourseId.toString());

      final response = await http.post(
        Uri.parse('$baseurl/app-users/update-app-users-ug-g-status'),
        body: {
          'isUG': graduate ? '0' : '1',
          'isGraduated': graduate ? '1' : '0',
          'yearOfGraduation': yearOfStudy.text,
          'token': token,
        },
      );

      if (response.statusCode == 200) {
        Navigator.pushNamed(context, "/home_page");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Select your course',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 20,
            fontFamily: 'SF Pro Display',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.maxFinite,
                height: 48,
                decoration: ShapeDecoration(
                  color: const Color(0xFFD2F7FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          graduate = false;
                          setState(() {});
                        },
                        child: Container(
                          height: 48,
                          decoration: ShapeDecoration(
                            color: graduate ? Colors.transparent : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                            shadows: graduate
                                ? null
                                : [
                                    const BoxShadow(
                                      color: Color(0x3F9396AE),
                                      blurRadius: 10,
                                      offset: Offset(0, 2),
                                      spreadRadius: 0,
                                    )
                                  ],
                          ),
                          child: const Center(
                            child: Text(
                              'Undergraduate',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF1A1A1A),
                                fontSize: 14,
                                fontFamily: 'SF Pro Display',
                                fontWeight: FontWeight.w500,
                                height: 1.57,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          graduate = true;
                          setState(() {});
                        },
                        child: Container(
                          height: 48,
                          decoration: ShapeDecoration(
                              color:
                                  graduate ? Colors.white : Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                              shadows: graduate
                                  ? [
                                      const BoxShadow(
                                        color: Color(0x3F9396AE),
                                        blurRadius: 10,
                                        offset: Offset(0, 2),
                                        spreadRadius: 0,
                                      )
                                    ]
                                  : null),
                          child: const Center(
                            child: Text(
                              'Graduate',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF1A1A1A),
                                fontSize: 14,
                                fontFamily: 'SF Pro Display',
                                fontWeight: FontWeight.w500,
                                height: 1.57,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              formInputWithLabel(
                  yearOfStudy, "Enter Year Of Study", "Year Of Study"),
              const SizedBox(height: 16),
              const Text(
                'Select course',
                style: TextStyle(
                  color: Color(0xFF323836),
                  fontSize: 16,
                  fontFamily: 'SF Pro Display',
                  fontWeight: FontWeight.w400,
                  height: 1.38,
                ),
              ),
              const SizedBox(height: 16),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      children: courses.map((course) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedCourseId = course['id'];
                              });
                            },
                            child: createSelectCourseCard(
                              course['course_name'],
                              "Critical steps (crash course)", // Added the static subtitle here
                              "microscope.svg", // Default icon
                              selectedCourseId == course['id'],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: isLoading ? null : updateUGGStatus,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: const Color(0xFF247E80),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Proceed',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.w500,
                        height: 1.50,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

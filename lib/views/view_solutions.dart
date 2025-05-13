import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ghastep/widgets/common_widgets.dart';
import 'package:ghastep/widgets/view_solutions_widgets.dart';
import 'package:http/http.dart' as http;
import 'package:ghastep/views/urlconfig.dart';

class ViewSolution extends StatefulWidget {
  const ViewSolution({super.key});

  @override
  State<ViewSolution> createState() => _ViewSolutionState();
}

class _ViewSolutionState extends State<ViewSolution> {
  List<Map<String, dynamic>> solutionData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSolutionData();
  }

  Future<void> fetchSolutionData() async {
    bool isPreCourse = false;
    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'token');
      String? isPreCourseFlag = await storage.read(key: "isPreCourse");
    setState(() {
      isPreCourse = isPreCourseFlag == "true";
    });

    String? courseTestTransactionId = isPreCourse
        ? await storage.read(key: 'preCourseTestTransactionId'):
        await storage.read(key: 'postCourseTestTransactionId');


    if (token != null && courseTestTransactionId != null) {
      final url = isPreCourse
          ? '$baseurl/app/get-pre-course-test-user-reponses/$token/$courseTestTransactionId':
          '$baseurl/app/get-post-course-test-user-reponses/$token/$courseTestTransactionId';
      print('Fetching solution data from: $url');
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          print('Response body for solution data: ${response.body}');
          setState(() {
            solutionData =
                List<Map<String, dynamic>>.from(json.decode(response.body));
            isLoading = false;
          });
        } else {
          // Handle error
          print('Failed to fetch data: ${response.statusCode}');
        }
      } catch (e) {
        print('Error: $e');
      }
    } else {
      print('Token or Transaction ID is missing');
    }
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
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
                        buildTopSelectCards(false, "Correct"),
                        buildTopSelectCards(false, "Incorrect"),
                        buildTopSelectCards(false, "Unanswered"),
                      ],
                    ),
                  ),
                  Container(height: 12, color: Colors.white),
                  borderHorizontal(),
                  QuestAnsSolWidget(solutionData: solutionData),
                ],
              ),
            ),
    );
  }
}

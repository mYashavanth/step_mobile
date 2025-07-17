import 'dart:convert'; // For JSON decoding
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ghastep/widgets/common_widgets.dart';
import 'package:ghastep/widgets/test_result_widgets.dart';

class ResultScreenTest extends StatefulWidget {
  const ResultScreenTest({super.key});

  @override
  State<ResultScreenTest> createState() => _ResultScreenTestState();
}

class _ResultScreenTestState extends State<ResultScreenTest> {
  final storage = const FlutterSecureStorage();
  Map<String, dynamic>? resultData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (_isLoading) {
      _loadResultData();
    }
  }

  Future<void> _loadResultData() async {
    print("Loading result data...++++++++++++++++++++++++++++++++++++++++++");
    try {
      // Wait for the next frame to ensure context is available
      await Future.delayed(Duration.zero);

      final args = ModalRoute.of(context)?.settings.arguments;
      print("Arguments received: $args");

      if (args != null && args is Map<String, dynamic>) {
        if (args['resultData'] != null) {
          setState(() {
            resultData = args['resultData'] as Map<String, dynamic>;
            _isLoading = false;
          });
          return;
        }
      }
      print("No valid result data found in arguments.");
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading result data: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) return;
        // Remove all previous pages and navigate to home_page
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/home_page', (route) => false);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          surfaceTintColor: Colors.white,
          backgroundColor: Colors.white,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/home_page', (route) => false);
            },
            icon: const Icon(Icons.arrow_back_ios_new_outlined),
          ),
          title: const Text(
            'Results',
            style: TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 20,
              fontFamily: 'SF Pro Display',
              fontWeight: FontWeight.w500,
              height: 1.40,
            ),
          ),
          // actions: [
          //   Container(
          //     margin: const EdgeInsets.only(right: 12),
          //     padding: const EdgeInsets.all(8),
          //     decoration: ShapeDecoration(
          //       color: const Color(0xFFF9FAFB),
          //       shape: RoundedRectangleBorder(
          //         side: const BorderSide(
          //           width: 1,
          //           color: Color(0xFFDDDDDD),
          //         ),
          //         borderRadius: BorderRadius.circular(8),
          //       ),
          //     ),
          //     child: const Row(
          //       children: [
          //         Text(
          //           'View attempts',
          //           style: TextStyle(
          //             color: Color(0xFF1A1A1A),
          //             fontSize: 14,
          //             fontFamily: 'SF Pro Display',
          //             fontWeight: FontWeight.w400,
          //             height: 1.71,
          //           ),
          //         ),
          //         Icon(Icons.keyboard_arrow_down_outlined)
          //       ],
          //     ),
          //   )
          // ],
        ),
        body: resultData == null
            ? const Center(
                child:
                    CircularProgressIndicator()) // Show loader until data is loaded
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    borderHorizontal(),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Anatomy Challenge: Ace the Basics',
                            style: TextStyle(
                              color: Color(0xFF1A1A1A),
                              fontSize: 20,
                              fontFamily: 'SF Pro Display',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Pre course test - Step 1, Conducted on 23 Jan 25',
                            style: TextStyle(
                              color: Color(0xFF737373),
                              fontSize: 14,
                              fontFamily: 'SF Pro Display',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '50 Questions • 45 minutes • 200 marks',
                            style: TextStyle(
                              color: Color(0xFF737373),
                              fontSize: 14,
                              fontFamily: 'SF Pro Display',
                              fontWeight: FontWeight.w400,
                              height: 1.57,
                            ),
                          ),
                          const SizedBox(height: 16),
                          buildButton(
                              context, "View solutions", '/view_solutions'),
                          const SizedBox(height: 12),
                          // buildBorderButton(context, "Re-attempt test", '')
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    borderHorizontal(),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Overview',
                            style: TextStyle(
                              color: Color(0xFF1A1A1A),
                              fontSize: 20,
                              fontFamily: 'SF Pro Display',
                              fontWeight: FontWeight.w500,
                              height: 1.40,
                            ),
                          ),
                          // const SizedBox(height: 8),
                          // const Text(
                          //   'Summary of marks scored in “ Attempt 1 “ of the pre-course test attempted on 23 Jan',
                          //   style: TextStyle(
                          //     color: Color(0xFF737373),
                          //     fontSize: 14,
                          //     fontFamily: 'SF Pro Display',
                          //     fontWeight: FontWeight.w400,
                          //     height: 1.57,
                          //   ),
                          // ),
                          const SizedBox(height: 8),
                          buildResultScreenOverviewtable(
                              resultData!), // Pass resultData to the table
                        ],
                      ),
                    ),
                    borderHorizontal(),
                    const SizedBox(height: 12),
                    // Padding(
                    //   padding: const EdgeInsets.all(16),
                    //   child: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       const Text(
                    //         'Leaderboard',
                    //         style: TextStyle(
                    //           color: Color(0xFF1A1A1A),
                    //           fontSize: 20,
                    //           fontFamily: 'SF Pro Display',
                    //           fontWeight: FontWeight.w500,
                    //           height: 1.40,
                    //         ),
                    //       ),
                    //       const SizedBox(height: 8),
                    //       const Text(
                    //         'Ranking is based on marks. Time taken to answer the test is used to break the tie, incase marks are the same for learners',
                    //         style: TextStyle(
                    //           color: Color(0xFF737373),
                    //           fontSize: 14,
                    //           fontFamily: 'SF Pro Display',
                    //           fontWeight: FontWeight.w400,
                    //           height: 1.57,
                    //         ),
                    //       ),
                    //       const SizedBox(height: 8),
                    //       buildUserRow(1, "Sushanth Raj"),
                    //       borderHorizontal(),
                    //       buildUserRow(2, "Suhas R"),
                    //       borderHorizontal(),
                    //       buildUserRow(3, "Deepthi"),
                    //       borderHorizontal(),
                    //       buildUserRow(420, "You"),
                    //       borderHorizontal(),
                    //       TextButton(
                    //         onPressed: () {
                    //           Navigator.pushNamed(
                    //               context, "/leader_board_screen");
                    //         },
                    //         child: const Text(
                    //           'See full leaderboard',
                    //           style: TextStyle(
                    //             color: Color(0xFF007AFF),
                    //             fontSize: 16,
                    //             fontFamily: 'SF Pro Display',
                    //             fontWeight: FontWeight.w700,
                    //             height: 1.50,
                    //           ),
                    //         ),
                    //       )
                    //     ],
                    //   ),
                    // )
                  ],
                ),
              ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Color(0x0C000000),
                blurRadius: 100,
                offset: Offset(0, -1),
                spreadRadius: 0,
              )
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () {
              Navigator.pushNamed(context, "/home_page");
            },
            child: Container(
              height: 52,
              decoration: ShapeDecoration(
                color: const Color(0xFFC7F3F4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Center(
                child: Text(
                  'Go home',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF247E80),
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
      ),
    );
  }
}

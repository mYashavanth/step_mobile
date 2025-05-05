import 'package:flutter/material.dart';
import 'package:ghastep/widgets/common_widgets.dart';

class ReportProblem extends StatefulWidget {
  const ReportProblem({super.key});

  @override
  State<ReportProblem> createState() => _ReportProblemState();
}

class _ReportProblemState extends State<ReportProblem> {
  TextEditingController reportProblemController = TextEditingController();
  List<Map> feedbackReviewData = [
    {"name": "Course Vedios", "id": 1},
    {"name": "Weekly test", "id": 2},
    {"name": "Step wise test", "id": 3},
    {"name": "Others", "id": 4},
  ];

  List<int> selectedProblem = [0];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
          ),
        ),
        title: const Text(
          'Report a problem',
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 12,
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'What are you facing problem with?',
                    style: TextStyle(
                      color: Color(0xFF737373),
                      fontSize: 14,
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w400,
                      height: 1.43,
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  buildReportFeedbackRow(
                      setState, feedbackReviewData[0], selectedProblem),
                  buildReportFeedbackRow(
                      setState, feedbackReviewData[1], selectedProblem),
                  buildReportFeedbackRow(
                      setState, feedbackReviewData[2], selectedProblem),
                  buildReportFeedbackRow(
                      setState, feedbackReviewData[3], selectedProblem),
                  const SizedBox(
                    height: 12,
                  ),
                  // const Text(
                  //   'Additional feedback',
                  //   style: TextStyle(
                  //     color: Color(0xFF737373),
                  //     fontSize: 14,
                  //     fontFamily: 'SF Pro Display',
                  //     fontWeight: FontWeight.w400,
                  //     height: 1.57,
                  //   ),
                  // ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                            width: 1, color: Color(0xFFDDDDDD)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: TextFormField(
                      maxLines: 5,
                      controller: reportProblemController,
                      style: const TextStyle(
                        color: Color(0xFF1A1A1A),
                        fontSize: 16,
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.w400,
                        height: 1.50,
                      ),
                      decoration: const InputDecoration(
                          // labelText: labelText,
                          hintText:
                              "Please describe the problem you are facing...",
                          hintStyle: TextStyle(
                            color: Color(0xFF737373),
                            fontSize: 16,
                            fontFamily: 'SF Pro Display',
                            fontWeight: FontWeight.w400,
                            height: 1.25,
                          ),
                          border: InputBorder.none
                          // const OutlineInputBorder(
                          //   gapPadding: 0,
                          //   borderRadius: BorderRadius.all(
                          //     Radius.circular(8),
                          //   ),
                          //   borderSide: BorderSide(
                          //     width: 1,
                          //     color: Color(0xFFDDDDDD),
                          //   ),
                          // ),
                          ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 12),
              color: Colors.white,
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Supporting screenshot (optional)',
                    style: TextStyle(
                      color: Color(0xFF737373),
                      fontSize: 14,
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w400,
                      height: 1.43,
                    ),
                  ),
                  InkWell(
                    onTap: () {},
                    child: Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                              width: 1, color: Color(0xFF1A1A1A)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_outlined),
                          SizedBox(
                            width: 12,
                          ),
                          Text(
                            'Upload image • max 10 MB',
                            style: TextStyle(
                              color: Color(0xFF1A1A1A),
                              fontSize: 16,
                              fontFamily: 'SF Pro Display',
                              fontWeight: FontWeight.w400,
                              height: 1.25,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(12),
        child: buildButton(context, "Submit", null),
      ),
    );
  }
}

Widget buildReportFeedbackRow(
    StateSetter modalSetState, Map value, List<int> selected) {
  return Row(
    children: [
      Radio(
        focusColor: const Color(0xFF247E80),
        fillColor: getMaterialStateThemeColor(),
        value: value["id"],
        groupValue: selected[0],
        onChanged: (value) {
          modalSetState(() {
            selected[0] = value;
          });
        },
      ),
      const SizedBox(
        width: 12,
      ),
      Text(
        value['name'],
        style: const TextStyle(
          color: Color(0xFF1A1A1A),
          fontSize: 16,
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w400,
          height: 1.25,
        ),
      ),
    ],
  );
}

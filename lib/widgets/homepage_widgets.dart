import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ghastep/views/dry.dart';
import 'package:ghastep/widgets/common_widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ghastep/views/urlconfig.dart';
import 'package:ghastep/widgets/full_screen_video_player.dart';

Widget buildStatusCard(
    bool complete, String icon, bool selected, String title) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: ShapeDecoration(
      color: selected
          ? const Color(0xFF247E80)
          : Colors.white, // Color(0xFF247E80)
      shape: RoundedRectangleBorder(
        side: const BorderSide(width: 1, color: Color(0xFFDDDDDD)),
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    child: Row(
      children: [
        SvgPicture.asset(
          "assets/icons/$icon",
          color: selected ? Colors.white : Colors.black,
        ), //list2.svg
        const SizedBox(
          width: 12,
        ),
        Text(
          title,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black,
            fontSize: 16,
            fontFamily: 'SF Pro Display',
            fontWeight: FontWeight.w500,
            height: 1.50,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: ShapeDecoration(
            color: complete ? const Color(0xFF34C759) : const Color(0xCCFE860A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(
            complete ? "Complete" : "Pending",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontFamily: 'SF Pro Display',
              fontWeight: FontWeight.w400,
              height: 1.67,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget buildVedioLearnCard({
  required String imagePath,
  required String title,
  required String teacherName,
  required String duration,
  required int? videoId, // Changed to int? to match FullScreenVideoPlayer
  required String videoUrl,
  String? videoPauseTime,
  required String subjectName,
  required BuildContext context,
}) {
  // Calculate remaining time
  final totalSeconds = (double.tryParse(duration) ?? 1) * 60;
  final pausedSeconds = double.tryParse(videoPauseTime ?? '0') ?? 0;
  final remainingMinutes = ((totalSeconds - pausedSeconds) / 60).ceil();

  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FullScreenVideoPlayer(
            videoUrl: videoUrl,
            videoTitle: title,
            videoId: videoId, // Now passing the correct type
            resumeFrom: videoPauseTime,
          ),
        ),
      );
    },
    child: Column(
      children: [
        Container(
          margin: const EdgeInsets.only(left: 5, right: 5),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            shadows: const [
              BoxShadow(
                color: Color(0x19000000),
                blurRadius: 30,
                offset: Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    height: 150,
                    width: 270,
                    clipBehavior: Clip.antiAlias,
                    decoration: ShapeDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/image/$imagePath"),
                        fit: BoxFit.cover,
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  if (videoPauseTime != null && videoPauseTime.isNotEmpty)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: ShapeDecoration(
                          color: const Color(0xFFFE7D14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        child: const Text(
                          'Resume',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontFamily: 'SF Pro Display',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: ShapeDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: Text(
                        '$duration min',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontFamily: 'SF Pro Display',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 60,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: ShapeDecoration(
                        color: const Color(0xFF289799),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          subjectName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontFamily: 'SF Pro Display',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF1A1A1A),
                        fontSize: 16,
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.w500,
                        height: 1.38,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      teacherName,
                      style: const TextStyle(
                        color: Color(0xFF737373),
                        fontSize: 14,
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.w400,
                        height: 1.57,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$remainingMinutes mins remaining',
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 12,
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.w400,
                        height: 1.67,
                      ),
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: pausedSeconds / totalSeconds,
                      backgroundColor: const Color(0xFFE6E6E6),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFFFE7D14)),
                      minHeight: 4,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget buildStepWiseCourseCard(
    String num, int unlocked, String title, String id, BuildContext context) {
  String icon = "locked.svg";
  Color color = Colors.transparent;
  String status = '';
  if (unlocked == 1) {
    icon = "exm2.svg";
    status = "Ongoing";
    color = const Color(0xFFFF9500);
  }
  if (unlocked == 2) {
    icon = "unlocked.svg";
    status = "Completed";
    color = const Color(0xFF34C759);
  }

  Future<void> _makeApiCallAndNavigate() async {
    const storage = FlutterSecureStorage();
    String token = await storage.read(key: 'token') ?? '';
    String selectedCourseId = await storage.read(key: 'selectedCourseId') ?? '';
    print('variables sending: ${{
      'token': token,
      'courseId': selectedCourseId,
      'subjectId': id,
    }}');

    try {
      final response = await http.post(
        Uri.parse('$baseurl/app/insert-course-subject-selection'),
        body: {
          'token': token,
          'courseId': selectedCourseId,
          'subjectId': id,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Response data: $data');
        if (data['errFlag'] == 0) {
          Navigator.pushNamed(context, "/course_screen", arguments: {
            'courseId': selectedCourseId,
            'subjectId': id,
          });
          await storage.write(key: "selectedSubjectId", value: id);
          showCustomSnackBar(
            context: context,
            message: data['message'],
            isSuccess: true,
          );
        } else if (data['errFlag'] == 2) {
          Navigator.pushNamed(context, "/course_screen", arguments: {
            'courseId': selectedCourseId,
            'subjectId': id,
          });
          await storage.write(key: "selectedSubjectId", value: id);
          showCustomSnackBar(
            context: context,
            message: data['message'],
            isSuccess: true,
          );
        } else {
          showCustomSnackBar(
            context: context,
            message: "Failed to update selection, please try again",
            isSuccess: false,
          );
        }
      } else {
        showCustomSnackBar(
          context: context,
          message: "Failed to update selection, please try again",
          isSuccess: false,
        );
      }
    } catch (e) {
      showCustomSnackBar(
        context: context,
        message: "An error occurred: $e",
        isSuccess: false,
      );
    }
  }

  return Container(
    height: 80,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: unlocked > 0
          ? const Border(
              left: BorderSide(width: 2, color: Color(0xFFA9DDEA)),
              top: BorderSide(width: 2, color: Color(0xFFA9DDEA)),
              right: BorderSide(width: 2, color: Color(0xFFA9DDEA)),
              bottom: BorderSide(width: 6, color: Color(0xFFA9DDEA)),
            )
          : const Border(
              left: BorderSide(width: 1, color: Color(0xFFDDDDDD)),
              top: BorderSide(width: 1, color: Color(0xFFDDDDDD)),
              right: BorderSide(width: 1, color: Color(0xFFDDDDDD)),
              bottom: BorderSide(width: 1, color: Color(0xFFDDDDDD)),
            ),
    ),
    child: Row(
      children: [
        Stack(
          children: [
            SvgPicture.asset("assets/icons/$icon"),
            SizedBox(
              width: 60,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    num,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(
          width: 12,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IntrinsicWidth(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.5,
                    ),
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF1A1A1A),
                        fontSize: 16,
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.w500,
                        height: 1.50,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: ShapeDecoration(
                    color: color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w400,
                      height: 1.67,
                    ),
                  ),
                ),
              ],
            ),
            const Text(
              '4 hr 30 mins • 10 steps',
              style: TextStyle(
                color: Color(0xFF737373),
                fontSize: 12,
                fontFamily: 'SF Pro Display',
                fontWeight: FontWeight.w400,
                height: 1.67,
              ),
            )
          ],
        ),
        const Spacer(),
        Container(
          margin: const EdgeInsets.only(right: 16),
          width: 30,
          height: 30,
          decoration: ShapeDecoration(
            color: unlocked == 0
                ? const Color(0xFFEAEAEA)
                : const Color(0xFFD2F7FF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Center(
            child: unlocked == 0
                ? const Icon(
                    Icons.lock,
                    color: Color(0xFF737373),
                    size: 20,
                  )
                : GestureDetector(
                    onTap: () async {
                      await _makeApiCallAndNavigate(); // Make API call before navigating
                    },
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Color(0xFF247E80),
                      size: 20,
                    ),
                  ),
          ),
        ),
      ],
    ),
  );
}

Widget buidSelectCourseBottomSheet(
    BuildContext context,
    StateSetter modalSetState,
    List<Map> selectCourseList,
    List<int> selected,
    String bottomSheetTitle) {
  return Stack(clipBehavior: Clip.none, children: [
    Container(
      padding: const EdgeInsets.only(top: 16, left: 20, right: 20, bottom: 16),
      clipBehavior: Clip.antiAlias,
      decoration: const ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            bottomSheetTitle,
            style: const TextStyle(
              color: Color(0xFF323836),
              fontSize: 20,
              fontFamily: 'SF Pro Display',
              fontWeight: FontWeight.w500,
              height: 1.10,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 358,
            decoration: const ShapeDecoration(
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: 1,
                  strokeAlign: BorderSide.strokeAlignCenter,
                  color: Color(0xFFEAEAEA),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Column(
            children: List.generate(selectCourseList.length, (int index) {
              return buildSelectCourseRow(
                  modalSetState, selectCourseList[index], selected);
            }),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () async {
              const storage = FlutterSecureStorage();
              // Get the selected course's ID
              Map selectedCourse = selectCourseList
                  .firstWhere((course) => course['id'] == selected[0]);
              String selectedCourseId = selectedCourse['id'].toString();

              // Store the selected course ID in secure storage
              await storage.write(
                  key: "selectedCourseId", value: selectedCourseId);
              selected[0] = int.parse(selectedCourseId);
              // Update the UI with the step name

              print(
                  "Printing selected after multi selection course ++++++++++: $selected");

              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: const Color(0xFF247E80),
            ),
            child: const Text(
              'Apply',
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
    Positioned(
      right: 15,
      top: -50,
      child: CircleAvatar(
        backgroundColor: Colors.white,
        child: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    ),
  ]);
}

Widget buidSelectCourseBottomSheetStep(
    BuildContext context,
    StateSetter modalSetState,
    List<Map> selectStepList,
    List<int> selected,
    String bottomSheetTitle,
    Function(String) onStepSelected) {
  return Stack(clipBehavior: Clip.none, children: [
    Container(
      padding: const EdgeInsets.only(top: 16, left: 20, right: 20, bottom: 16),
      clipBehavior: Clip.antiAlias,
      decoration: const ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            bottomSheetTitle,
            style: const TextStyle(
              color: Color(0xFF323836),
              fontSize: 20,
              fontFamily: 'SF Pro Display',
              fontWeight: FontWeight.w500,
              height: 1.10,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 358,
            decoration: const ShapeDecoration(
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: 1,
                  strokeAlign: BorderSide.strokeAlignCenter,
                  color: Color(0xFFEAEAEA),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Column(
            children: List.generate(selectStepList.length, (int index) {
              return buildSelectCourseRow(
                  modalSetState, selectStepList[index], selected);
            }),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () async {
              const storage = FlutterSecureStorage();
              // Get the selected step's id and name
              Map selectedStep = selectStepList
                  .firstWhere((step) => step['id'] == selected[0]);
              String selectedStepId = selectedStep['id'].toString();
              String selectedStepName = selectedStep['name'];
              // Store the step id in Flutter Secure Storage
              await storage.write(key: "selectedStepNo", value: selectedStepId);
              selected[0] = int.parse(selectedStepId);
              // Update the UI with the step name

              print(
                  "Printing selected after multi selection step ++++++++++: $selected");
              onStepSelected(selectedStepName);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: const Color(0xFF247E80),
            ),
            child: const Text(
              'Apply',
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
    Positioned(
      right: 15,
      top: -50,
      child: CircleAvatar(
        backgroundColor: Colors.white,
        child: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    ),
  ]);
}

enum CoursesEnum { neet, jefferson }

Widget buildSelectCourseRow(
    StateSetter modalSetState, Map value, List<int> selected) {
  return Container(
    margin: const EdgeInsets.only(top: 8, bottom: 8),
    child: Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value['name'],
              style: const TextStyle(
                color: Color(0xFF247E80),
                fontSize: 16,
                fontFamily: 'SF Pro Display',
                fontWeight: FontWeight.w500,
                height: 1.50,
              ),
            ),
            const Text(
              'Critical steps (crash course)',
              style: TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 12,
                fontFamily: 'SF Pro Display',
                fontWeight: FontWeight.w400,
                height: 1.67,
              ),
            ),
          ],
        ),
        const Spacer(),
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
      ],
    ),
  );
}

Widget homeStepsCard(String title, String subTitle, String icon) {
  return Container(
    padding: const EdgeInsets.only(top: 12, left: 12),
    clipBehavior: Clip.antiAlias,
    decoration: ShapeDecoration(
      shape: RoundedRectangleBorder(
        side: const BorderSide(width: 1, color: Color(0xFFDDDDDD)),
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF737373),
            fontSize: 12,
            fontFamily: 'SF Pro Display',
            fontWeight: FontWeight.w500,
            height: 1.67,
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subTitle,
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 14,
                fontFamily: 'SF Pro Display',
                fontWeight: FontWeight.w500,
                height: 1.57,
              ),
            ),
            const Spacer(),
            SvgPicture.asset("assets/icons/$icon"),
          ],
        )
      ],
    ),
  );
}

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ghastep/services/iap_payment_screen.dart';
import 'package:ghastep/services/phonepe_payment_screen.dart';
import 'package:ghastep/widgets/pyment_validation.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart'; // Add this import
import 'package:url_launcher/url_launcher.dart';
import 'package:ghastep/views/urlconfig.dart';
import 'package:http/http.dart' as http; // Add this import
import 'package:ghastep/widgets/full_screen_video_player.dart';

Widget buildTabBarCourse(
  BuildContext context,
  TabController tabController,
  List<int> stepTabSelectedIndex,
  StateSetter setState,
  List<dynamic> videoData,
  List<int> chooseStepList,
  int selectedStepId,
  Function(int) onStepChanged,
  String courseId,
  String subjectId,
  SubscriptionStatus paymentStatus,
  int totalNumberOfSteps,
) {
  print("videoData in widget page: $videoData");
  print("course and subject ids: $courseId, $subjectId");
  // Filter videos based on selected step

  final filteredVideos = videoData.isEmpty
      ? []
      : videoData
          .where((video) => video['step_no'] == stepTabSelectedIndex[0] + 1)
          .toList();
  List<String> stepTabCourse = !paymentStatus.isValid
      ? ['Step 1', "Step 2", "Notes", "Subject test"]
      : List.generate(
          totalNumberOfSteps + 2,
          (index) => index < totalNumberOfSteps
              ? 'Step ${index + 1}'
              : index == totalNumberOfSteps
                  ? 'Notes'
                  : 'Subject Test',
        );
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      buildStepTabButton(
        setState,
        stepTabSelectedIndex,
        chooseStepList,
        selectedStepId,
        onStepChanged,
        stepTabCourse,
      ),
      Container(
        padding: const EdgeInsets.only(left: 12, right: 12),
        child: !paymentStatus.isValid
            ? Column(
                children: [
                  Visibility(
                    visible: stepTabSelectedIndex[0] == 0,
                    child: StepContent(videos: filteredVideos),
                  ),
                  Visibility(
                    visible: stepTabSelectedIndex[0] == 1,
                    child: SizedBox(
                      height: 200,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Please subscribe to our paid plan"),
                            const SizedBox(height: 20),
                            InkWell(
                              borderRadius: BorderRadius.circular(24),
                              onTap: () {
                                // if (Theme.of(context).platform ==
                                //     TargetPlatform.android) {
                                //   Navigator.push(
                                //     context,
                                //     MaterialPageRoute(
                                //       builder: (context) =>
                                //           const PhonePePaymentScreen(),
                                //     ),
                                //   );
                                // } else if (Theme.of(context).platform ==
                                //     TargetPlatform.iOS) {
                                //   Navigator.push(
                                //     context,
                                //     MaterialPageRoute(
                                //       builder: (context) => const IAPPage(),
                                //     ),
                                //   );
                                // }
                                Navigator.pushNamed(context, "/subscribe");
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                // Adjust the width to 50% of the screen width
                                width: MediaQuery.of(context).size.width * 0.5,
                                decoration: ShapeDecoration(
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(
                                      width: 1,
                                      color: Color(0xFF247E80),
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.lock,
                                      color: Color(0xFF247E80),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Subscribe Now',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Color(0xFF247E80),
                                        fontSize: 16,
                                        fontFamily: 'SF Pro Display',
                                        fontWeight: FontWeight.w500,
                                        height: 1.50,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: stepTabSelectedIndex[0] == 2,
                    child: Column(
                      children: [
                        NotesListWidget(
                            courseId: courseId, subjectId: subjectId),
                        const SizedBox(height: 28),
                        InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: () {},
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                  width: 1,
                                  color: Color(0xFF247E80),
                                ),
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.lock,
                                  color: Color(0xFF247E80),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Enroll for ₹1000 to unlock',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFF247E80),
                                    fontSize: 16,
                                    fontFamily: 'SF Pro Display',
                                    fontWeight: FontWeight.w500,
                                    height: 1.50,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: stepTabSelectedIndex[0] == 3,
                    child: const SizedBox(
                      height: 200,
                      child: Center(
                        child: Text("Subject Test Content"),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  ...List.generate(
                    totalNumberOfSteps,
                    (i) => Visibility(
                      visible: stepTabSelectedIndex[0] == i,
                      child: StepContent(videos: filteredVideos),
                    ),
                  ),
                  Visibility(
                    visible: stepTabSelectedIndex[0] == totalNumberOfSteps,
                    child: Column(
                      children: [
                        NotesListWidget(
                            courseId: courseId, subjectId: subjectId),
                        const SizedBox(height: 28),
                        InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: () {},
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                  width: 1,
                                  color: Color(0xFF247E80),
                                ),
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.lock,
                                  color: Color(0xFF247E80),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Enroll for ₹1000 to unlock',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFF247E80),
                                    fontSize: 16,
                                    fontFamily: 'SF Pro Display',
                                    fontWeight: FontWeight.w500,
                                    height: 1.50,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: stepTabSelectedIndex[0] == totalNumberOfSteps + 1,
                    child: const SizedBox(
                      height: 200,
                      child: Center(
                        child: Text("Subject Test Content"),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    ],
  );
}

// List stepTabCourse = ['Step 1', "Step 2", "Step 3", "Notes", "Subject test"];

Widget buildStepTabButton(
  StateSetter setState,
  List<int> stepTabSelectedIndex,
  List<int> chooseStepList,
  int selectedStepId,
  Function(int) onStepChanged,
  List<String> stepTabCourse,
) {
  final storage = FlutterSecureStorage();
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: List.generate(stepTabCourse.length, (i) {
        return GestureDetector(
          onTap: () {
            setState(() {
              stepTabSelectedIndex[0] = i;
              chooseStepList[0] = i + 1;
            });
            storage.write(
              key: "selectedStepNo",
              value: (i + 1).toString(),
            );
            onStepChanged(i + 1);

            // if (i == 1 || i == 2 || i == 4) {
            //   // If Step 2 or Step 3 is tapped, show a message
            //   print("Step ${i + 1} tab selected");
            // } else {
            //   setState(() {
            //     stepTabSelectedIndex[0] = i; // Update selected tab index
            //     chooseStepList[0] = i + 1; // Update chosen step
            //   });
            //   storage.write(
            //     key: "selectedStepNo",
            //     value: (i + 1).toString(), // Store the new selection
            //   );
            // }
            // if (i == 0) {
            //   // Step 1, Step 2, Step 3 (indices 0, 1, 2)
            //   onStepChanged(i + 1); // Trigger step-related logic
            // } else if (i == 1) {
            //   // Step 2 tab (index 1)
            //   print("Step 2 tab selected");
            // } else if (i == 2) {
            //   // Step 3 tab (index 2)
            //   print("Step 3 tab selected");
            // } else if (i == 3) {
            //   // Notes tab (index 3)
            //   print(
            //       "Notes tab selected,"); // Optional: Add notes-specific logic here
            // } else if (i == 4) {
            //   // Subject Test tab (index 4)
            //   print(
            //       "Subject Test tab selected"); // Optional: Add test-specific logic here
            // }
          },
          child: Container(
            margin: EdgeInsets.only(right: 12),
            padding: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              border: stepTabSelectedIndex[0] == i
                  ? const Border(
                      bottom: BorderSide(width: 2, color: Color(0xFF1A1A1A)),
                    )
                  : null,
            ),
            child: Text(
              stepTabCourse[i],
              style: TextStyle(
                color: stepTabSelectedIndex[0] == i
                    ? const Color(0xFF1A1A1A)
                    : const Color(0xFF737373),
                fontSize: 16,
                fontFamily: 'SF Pro Display',
                fontWeight: stepTabSelectedIndex[0] == i
                    ? FontWeight.w500
                    : FontWeight.w400,
                height: 1.50,
              ),
            ),
          ),
        );
      }),
    ),
  );
}

Widget courseNotes(String docName, int page, bool locked, String icon) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 4),
    padding: const EdgeInsets.all(8),
    decoration: ShapeDecoration(
      color: const Color(0xFFF9FAFB),
      shape: RoundedRectangleBorder(
        side: const BorderSide(width: 1, color: Color(0xFFDDDDDD)),
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    child: ListTile(
      leading: Container(
        width: 40,
        height: 40,
        padding: const EdgeInsets.all(10),
        decoration: ShapeDecoration(
          color: const Color(0xFFEAEAEA),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        child: SvgPicture.asset("assets/icons/$icon"),
      ),
      title: Text(
        docName,
        style: const TextStyle(
          color: Color(0xFF1A1A1A),
          fontSize: 16,
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w400,
          height: 1.50,
        ),
      ),
      subtitle: Text(
        '$page pages',
        style: const TextStyle(
          color: Color(0xFF737373),
          fontSize: 12,
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w400,
          height: 1.67,
        ),
      ),
      trailing: locked
          ? const Icon(Icons.lock, color: Color(0xFF1A1A1A), size: 24)
          : null,
    ),
  );
}

Widget NotesList(String docName, int page, bool locked, String icon) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 4),
    padding: const EdgeInsets.all(8),
    decoration: ShapeDecoration(
      color: const Color(0xFFF9FAFB),
      shape: RoundedRectangleBorder(
        side: const BorderSide(width: 1, color: Color(0xFFDDDDDD)),
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    child: ListTile(
      leading: Container(
        width: 40,
        height: 40,
        padding: const EdgeInsets.all(10),
        decoration: ShapeDecoration(
          color: const Color(0xFFEAEAEA),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        child: SvgPicture.asset("assets/icons/$icon"),
      ),
      title: Text(
        docName,
        style: const TextStyle(
          color: Color(0xFF1A1A1A),
          fontSize: 16,
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w400,
          height: 1.50,
        ),
      ),
      subtitle: Text(
        '$page pages',
        style: const TextStyle(
          color: Color(0xFF737373),
          fontSize: 12,
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w400,
          height: 1.67,
        ),
      ),
      trailing: locked
          ? const Icon(Icons.lock, color: Color(0xFF1A1A1A), size: 24)
          : null,
    ),
  );
}

Widget preCourseCard(bool pending, BuildContext context, bool isPreCourse) {
  return InkWell(
    borderRadius: BorderRadius.circular(8),
    onTap: () async {
      final storage = FlutterSecureStorage();
      await storage.write(key: "isPreCourse", value: isPreCourse.toString());
      Navigator.pushNamed(context, "/before_enter_test");
    },
    child: Container(
      decoration: ShapeDecoration(
        color: isPreCourse ? const Color(0x1A31B5B9) : const Color(0x1AFE860A),
        shape: RoundedRectangleBorder(
          side: BorderSide(
              width: 1,
              color: isPreCourse
                  ? const Color(0xFF31B5B9)
                  : const Color(0xFFFE860A)),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: ListTile(
        leading: Container(
            width: 40,
            height: 40,
            // margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.all(10),
            decoration: ShapeDecoration(
              color: isPreCourse
                  ? const Color(0xFFC7F3F4)
                  : const Color(0x29FE840A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            child: SvgPicture.asset(
              "assets/icons/list_icon.svg",
              colorFilter: isPreCourse
                  ? const ColorFilter.mode(Color(0xFF31B5B9), BlendMode.srcIn)
                  : const ColorFilter.mode(Color(0xFFFE860A), BlendMode.srcIn),
            )),
        title: Text(
          isPreCourse ? "PYQ based test" : "Practice test",
          style: const TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 16,
            fontFamily: 'SF Pro Display',
            fontWeight: FontWeight.w400,
            height: 1.50,
          ),
        ),
        subtitle: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '1h 30m • 35 MCQS',
              style: TextStyle(
                color: Color(0xFF737373),
                fontSize: 12,
                fontFamily: 'SF Pro Display',
                fontWeight: FontWeight.w400,
                height: 1.67,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 75,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: ShapeDecoration(
                color:
                    pending ? const Color(0xFFFF9500) : const Color(0xFF34C759),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Center(
                child: Text(
                  pending ? 'Pending' : "Completed",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontFamily: 'SF Pro Display',
                    fontWeight: FontWeight.w400,
                    height: 1.67,
                  ),
                ),
              ),
            )
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    ),
  );
}

Widget collapseStepClassCard(
  int num,
  BuildContext context,
  List<bool> showList,
  StateSetter setState, {
  required String videoTitle,
  required String videoDescription,
  required String videoDuration,
  required bool isLocked,
  required String videoUrl,
  required int videoId,
}) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 4),
    padding: const EdgeInsets.all(8),
    decoration: ShapeDecoration(
      color: const Color(0xFFF9FAFB),
      shape: RoundedRectangleBorder(
        side: const BorderSide(width: 1, color: Color(0xFFDDDDDD)),
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(10),
          decoration: ShapeDecoration(
            color: const Color(0xFFEAEAEA),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
          ),
          child:
              Center(child: SvgPicture.asset("assets/icons/video_player.svg")),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        // 'Video $num: $videoTitle',
                        videoTitle,
                        style: const TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 16,
                          fontFamily: 'SF Pro Display',
                          fontWeight: FontWeight.w400,
                          height: 1.50,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        showList[num - 1] = !showList[num - 1];
                        setState(() {});
                      },
                      child: Icon(
                        !showList[num - 1]
                            ? Icons.keyboard_arrow_down
                            : Icons.keyboard_arrow_up,
                        color: const Color(0xFF737373),
                      ),
                    ),
                  ],
                ),
                Visibility(
                  visible: showList[num - 1],
                  child: Text(
                    videoDescription,
                    style: const TextStyle(
                      color: Color(0xFF737373),
                      fontSize: 12,
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w400,
                      height: 1.67,
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_filled_rounded,
                      color: Color(0xFF737373),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      videoDuration,
                      style: const TextStyle(
                        color: Color(0xFF737373),
                        fontSize: 12,
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.w400,
                        height: 1.67,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        !isLocked
            ? IconButton(
                icon: const Icon(
                  Icons.play_circle_filled_rounded,
                  size: 40,
                  color: Color(0xFF737373),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullScreenVideoPlayer(
                        videoUrl: videoUrl,
                        videoTitle: videoTitle,
                        videoId: videoId, // <-- Pass the video id here
                      ),
                    ),
                  );
                },
              )
            : Container(
                width: 40,
                height: 40,
                decoration: ShapeDecoration(
                  color: const Color(0xFFEAEAEA),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.lock,
                    color: Color(0xFF737373),
                  ),
                ),
              ),
      ],
    ),
  );
}

class StepContent extends StatefulWidget {
  final List<dynamic> videos;
  const StepContent({super.key, required this.videos});

  @override
  State<StepContent> createState() => _StepContentState();
}

class _StepContentState extends State<StepContent> {
  late List<bool> showCardBoolList;

  @override
  void initState() {
    super.initState();
    showCardBoolList = List<bool>.filled(widget.videos.length, false);
  }

  @override
  void didUpdateWidget(StepContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.videos.length != showCardBoolList.length) {
      showCardBoolList = List<bool>.filled(widget.videos.length, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20),
        preCourseCard(true, context, true),
        const SizedBox(height: 20),
        if (widget.videos.isEmpty)
          const SizedBox()
        // const Center(
        //   child: Padding(
        //     padding: EdgeInsets.symmetric(vertical: 20),
        //     child: Text(
        //       "No videos available for this step",
        //       style: TextStyle(
        //         color: Color(0xFF737373),
        //         fontSize: 16,
        //         fontFamily: 'SF Pro Display',
        //         fontWeight: FontWeight.w400,
        //       ),
        //     ),
        //   ),
        // )
        else
          Column(
            children: List.generate(widget.videos.length, (i) {
              final video = widget.videos[i];
              return collapseStepClassCard(
                i + 1,
                context,
                showCardBoolList,
                setState,
                videoTitle: video['video_title'] ?? 'No title',
                videoDescription:
                    video['video_description'] ?? 'No description',
                videoDuration: '${video['video_duration_in_mins'] ?? 0} mins',
                isLocked: false,
                videoUrl: video['video_link'] ?? '',
                videoId: video['id'] ?? 0,
              );
            }),
          ),
        const SizedBox(height: 20),
        preCourseCard(true, context, false),
      ],
    );
  }
}

class NoteItem extends StatefulWidget {
  final String docName;
  final int page;
  final bool locked;
  final String icon;
  final int noteId;
  final String documentUrl;

  const NoteItem({
    required this.docName,
    required this.page,
    required this.locked,
    required this.icon,
    required this.noteId,
    required this.documentUrl,
    Key? key,
  }) : super(key: key);

  @override
  _NoteItemState createState() => _NoteItemState();
}

class _NoteItemState extends State<NoteItem> {
  bool isDownloading = false;
  bool isDownloaded = false;
  String? localFilePath;

  Future<void> downloadNote() async {
    setState(() {
      isDownloading = true;
    });
    try {
      final storage = FlutterSecureStorage();
      String? token = await storage.read(key: "token");
      if (token == null) {
        print("Missing token");
        setState(() {
          isDownloading = false;
        });
        return;
      }
      String apiUrl =
          "$baseurl/mobile/notes/get-download-url/${widget.noteId}/$token";
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['errFlag'] == 0) {
          String downloadUrl = data['downloadUrl'];
          final fileResponse = await http.get(Uri.parse(downloadUrl));
          if (fileResponse.statusCode == 200) {
            final directory = await getTemporaryDirectory();
            final filePath = '${directory.path}/${widget.documentUrl}';
            final file = File(filePath);
            await file.writeAsBytes(fileResponse.bodyBytes);
            setState(() {
              isDownloaded = true;
              isDownloading = false;
              localFilePath = filePath;
            });
          } else {
            print("Failed to download file: ${fileResponse.statusCode}");
            setState(() {
              isDownloading = false;
            });
          }
        } else {
          print("Error getting download URL: ${data['message']}");
          setState(() {
            isDownloading = false;
          });
        }
      } else {
        print("Failed to get download URL: ${response.statusCode}");
        setState(() {
          isDownloading = false;
        });
      }
    } catch (e) {
      print("Error downloading note: $e");
      setState(() {
        isDownloading = false;
      });
    }
  }

  Future<void> openNote() async {
    if (localFilePath != null) {
      await OpenFile.open(localFilePath!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: ShapeDecoration(
        color: const Color(0xFFF9FAFB),
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFDDDDDD)),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          padding: const EdgeInsets.all(10),
          decoration: ShapeDecoration(
            color: const Color(0xFFEAEAEA),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
          ),
          child: SvgPicture.asset("assets/icons/${widget.icon}"),
        ),
        title: Text(
          widget.docName,
          style: const TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 16,
            fontFamily: 'SF Pro Display',
            fontWeight: FontWeight.w400,
            height: 1.50,
          ),
        ),
        subtitle: Text(
          '${widget.page} pages',
          style: const TextStyle(
            color: Color(0xFF737373),
            fontSize: 12,
            fontFamily: 'SF Pro Display',
            fontWeight: FontWeight.w400,
            height: 1.67,
          ),
        ),
        trailing: widget.locked
            ? const Icon(Icons.lock, color: Color(0xFF1A1A1A), size: 24)
            : isDownloading
                ? const CircularProgressIndicator()
                : isDownloaded
                    ? IconButton(
                        icon: const Icon(Icons.visibility),
                        onPressed: openNote,
                      )
                    : IconButton(
                        icon: const Icon(Icons.download),
                        onPressed: downloadNote,
                      ),
      ),
    );
  }
}

class NotesListWidget extends StatefulWidget {
  final String courseId;
  final String subjectId;

  const NotesListWidget({
    required this.courseId,
    required this.subjectId,
    Key? key,
  }) : super(key: key);

  @override
  _NotesListWidgetState createState() => _NotesListWidgetState();
}

class _NotesListWidgetState extends State<NotesListWidget> {
  List<dynamic> notes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNotes();
  }

  Future<void> fetchNotes() async {
    final storage = FlutterSecureStorage();
    String? token = await storage.read(key: "token");
    if (token == null) {
      print("Token not found");
      setState(() {
        isLoading = false;
      });
      return;
    }
    String apiUrl =
        "$baseurl/mobile/notes/get-by-course-subject/${widget.courseId}/${widget.subjectId}/$token";
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['errFlag'] == 0) {
          setState(() {
            notes = data['notes'];
            isLoading = false;
          });
        } else {
          print("Error fetching notes: ${data['message']}");
          setState(() {
            isLoading = false;
          });
        }
      } else {
        print("Failed to fetch notes: ${response.statusCode}");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching notes: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (notes.isEmpty) {
      return const Center(child: Text("No notes available"));
    }
    return Column(
      children: notes.map((note) {
        return NoteItem(
          docName: note['notes_title'],
          page: note['no_of_pages'],
          locked: false, // All fetched notes have status = 1 (unlocked)
          icon: "adobe_pdf.svg",
          noteId: note['id'],
          documentUrl: note['document_url'],
        );
      }).toList(),
    );
  }
}
// class VideoPlayerScreen extends StatefulWidget {
//   const VideoPlayerScreen({super.key});

//   @override
//   State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
// }

// class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
//   late VideoPlayerController _controller;

//   @override
//   void initState() {
//     super.initState();
//     const videoUrl =
//         "https://customer-bo58a3euqp8nmzzt.cloudflarestream.com/b524deed1bb964475f330a704f5b0b31/iframe?poster=https%3A%2F%2Fcustomer-bo58a3euqp8nmzzt.cloudflarestream.com%2Fb524deed1bb964475f330a704f5b0b31%2Fthumbnails%2Fthumbnail.jpg%3Ftime%3D%26height%3D600";

//     _controller = VideoPlayerController.network(videoUrl)
//       ..initialize().then((_) {
//         setState(() {});
//         _controller.play();
//       });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Video Player"),
//       ),
//       body: Center(
//         child: _controller.value.isInitialized
//             ? AspectRatio(
//                 aspectRatio: _controller.value.aspectRatio,
//                 child: VideoPlayer(_controller),
//               )
//             : const CircularProgressIndicator(),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           setState(() {
//             _controller.value.isPlaying
//                 ? _controller.pause()
//                 : _controller.play();
//           });
//         },
//         child: Icon(
//           _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
//         ),
//       ),
//     );
//   }
// }

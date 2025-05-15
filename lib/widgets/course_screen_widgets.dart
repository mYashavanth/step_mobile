import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart'; // Add this import
import 'package:url_launcher/url_launcher.dart';
import 'package:ghastep/views/urlconfig.dart';
import 'package:http/http.dart' as http; // Add this import
import 'package:ghastep/widgets/full_screen_video_player.dart';

Widget buildTabBarCourse(
  TabController tabController,
  List<int> stepTabSelectedIndex,
  StateSetter setState,
  List<dynamic> videoData,
) {
  print("videoData in widget page: $videoData");
  // Filter videos based on selected step
  final filteredVideos = videoData.isEmpty
      ? []
      : videoData
          .where((video) => video['step_no'] == stepTabSelectedIndex[0] + 1)
          .toList();
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      buildStepTabButton(setState, stepTabSelectedIndex),
      Container(
        padding: const EdgeInsets.only(left: 12, right: 12),
        child: Column(
          children: [
            Visibility(
              visible: stepTabSelectedIndex[0] == 0,
              child: StepContent(videos: filteredVideos),
            ),
            Visibility(
              visible: stepTabSelectedIndex[0] == 1,
              child: StepContent(videos: filteredVideos),
            ),
            Visibility(
              visible: stepTabSelectedIndex[0] == 2,
              child: const SizedBox(
                height: 200,
                child: Center(
                  child: Text("Step 3 Content"),
                ),
              ),
            ),
            Visibility(
              visible: stepTabSelectedIndex[0] == 3,
              child: Column(
                children: [
                  courseNotes(
                      "Name of document here", 25, false, "adobe_pdf.svg"),
                  courseNotes("Name of document here if it exceeds 1 lines", 27,
                      false, "adobe_pdf.svg"),
                  courseNotes("Name of document here", 29, false, "excel.svg"),
                  courseNotes("Name of document here if it exceeds 1 lines", 31,
                      true, "excel.svg"),
                  const SizedBox(
                    height: 28,
                  ),
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
                          SizedBox(
                            width: 8,
                          ),
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
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

List stepTabCourse = ['Step 1', "Step 2", "Step 3", "Notes", "Subject test"];

Widget buildStepTabButton(
  StateSetter setState,
  List<int> stepTabSelectedIndex,
) {
  return Row(
      children: List.generate(5, (i) {
    return GestureDetector(
      onTap: () {
        stepTabSelectedIndex[0] = i;
        setState(() {});
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
  }));
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
        leading: SvgPicture.asset("assets/icons/list_icon.svg"),
        title: Text(
          isPreCourse ? "Pre-course test" : "Post-course test",
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
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.all(10),
          decoration: ShapeDecoration(
            color: const Color(0xFFEAEAEA),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
          ),
          child: Center(
            child: Text(
              "$num",
              style: const TextStyle(
                color: Color(0xFF5C5C5C),
                fontSize: 16,
                fontFamily: 'SF Pro Display',
                fontWeight: FontWeight.w500,
                height: 1.50,
              ),
            ),
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      'Video $num: $videoTitle',
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
        const SizedBox(width: 8),
        !isLocked
            ? IconButton(
                icon: const Icon(
                  Icons.play_circle_filled_rounded,
                  size: 40,
                  color: Color(0xFF737373),
                ),
                onPressed: () async {
                  try {
                    // Fetch required data from Flutter Secure Storage
                    final storage = const FlutterSecureStorage();
                    String? token = await storage.read(key: "token");
                    String? courseStepDetailsId =
                        await storage.read(key: "courseStepDetailId");
                    String? stepNo = await storage.read(key: "selectedStepNo");

                    if (token == null ||
                        courseStepDetailsId == null ||
                        stepNo == null) {
                      print("Missing required data in Flutter Secure Storage.");
                      return;
                    }

                    // Construct the API URL
                    String apiUrl =
                        "$baseurl/app/get-video/$token/$courseStepDetailsId/$stepNo";

                    // Make the API call
                    final response = await http.get(Uri.parse(apiUrl));

                    if (response.statusCode == 200) {
                      // Print the API response
                      print("API Response for video api: ${response.body}");

                      // Navigate to full-screen player with Cloudflare URL
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullScreenVideoPlayer(
                            videoUrl:
                                "https://customer-bo58a3euqp8nmzzt.cloudflarestream.com/b524deed1bb964475f330a704f5b0b31/manifest/video.m3u8",
                            videoTitle: videoTitle,
                          ),
                        ),
                      );
                    } else {
                      print(
                          "Failed to fetch video data. Status code: ${response.statusCode}");
                    }
                  } catch (e) {
                    print("Error fetching video data: $e");
                  }
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
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                "No videos available for this step",
                style: TextStyle(
                  color: Color(0xFF737373),
                  fontSize: 16,
                  fontFamily: 'SF Pro Display',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          )
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
              );
            }),
          ),
        const SizedBox(height: 20),
        preCourseCard(true, context, false),
      ],
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

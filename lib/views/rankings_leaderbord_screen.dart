import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:step_mobile/widgets/common_widgets.dart';
import 'package:step_mobile/widgets/homepage_widgets.dart';
import 'package:step_mobile/widgets/navbar.dart';
import 'package:step_mobile/widgets/test_result_widgets.dart';

class RankingLeaderBoardScreen extends StatefulWidget {
  const RankingLeaderBoardScreen({super.key});

  @override
  State<RankingLeaderBoardScreen> createState() => _LeaderBoardScreenState();
}

class _LeaderBoardScreenState extends State<RankingLeaderBoardScreen> {
  List<Map> selectSubjetctData = [
    {"name": "Anatomy - subject name", "id": 1},
    {"name": "Subject name", "id": 2},
    {"name": "Subject name", "id": 3},
  ];
  List<int> selectedSubject = [1];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Text(
          'Rankings leaderboard',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 20,
            fontFamily: 'SF Pro Display',
            fontWeight: FontWeight.w500,
            height: 1.40,
          ),
        ),
        actions: [
          InkWell(
            onTap: () {
              showModalBottomSheet(
                  isScrollControlled: true,
                  context: context,
                  //  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) {
                    return StatefulBuilder(builder:
                        (BuildContext context, StateSetter modalSetState) {
                      return buidSubjectWiseRankingBottomSheet(
                          modalSetState,
                          selectSubjetctData,
                          selectedSubject,
                          "Choose Subject");
                    });
                  });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(8),
              decoration: ShapeDecoration(
                color: const Color(0xFFF9FAFB),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    width: 1,
                    color: Color(0xFFDDDDDD),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Row(
                children: [
                  Text(
                    'As per subject',
                    style: TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 14,
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w400,
                      height: 1.71,
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down_outlined)
                ],
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 250,
              child: Stack(
                children: [
                  Transform.translate(
                    offset: const Offset(0, -60),
                    child: Image.asset(
                      "assets/image/Clip_path_group.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(
                    // color: Colors.red,
                    height: 250,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              buildTopLeaderBoardUserCard(false),
                              buildTopLeaderBoardUserCard(true),
                              buildTopLeaderBoardUserCard(false),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  buildUserRow(1, "Sushanth Raj"),
                  borderHorizontal(),
                  buildUserRow(2, "Suhas R"),
                  borderHorizontal(),
                  buildUserRow(3, "Deepthi"),
                  borderHorizontal(),
                  buildUserRow(420, "You"),
                  borderHorizontal(),
                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: const StepNavigationBar(2),
    );
  }
}

Widget buidSubjectWiseRankingBottomSheet(StateSetter modalSetState,
    List<Map> selectCourseList, List<int> selected, String bottomSheetTitle) {
  return Stack(clipBehavior: Clip.none, children: [
    Container(
      padding: const EdgeInsets.only(top: 16, left: 20, right: 20, bottom: 16),
      // margin: EdgeInsets.only(top: 50),
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
          const SizedBox(
            height: 8,
          ),
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
          const SizedBox(
            height: 8,
          ),
          Column(
            children: List.generate(selectCourseList.length, (int) {
              return buildSelectCourseRow(
                  modalSetState, selectCourseList[int], selected);
            }),
          ),
          const SizedBox(
            height: 12,
          ),
          ElevatedButton(
            onPressed: () {},
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
          // onPressed: () => Navigator.pop(context),
          onPressed: () {
            if (kDebugMode) {
              print("clicked");
            }
          },
        ),
      ),
    ),
  ]);
}

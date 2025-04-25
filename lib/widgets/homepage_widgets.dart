import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:step_mobile/widgets/common_widgets.dart';

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

Widget buildVedioLearnCard(
    String image, String title, String teacherName, String category) {
  return Column(
    children: [
      Container(
        margin: const EdgeInsets.only(left: 5, right: 5),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
          // mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 150,
              width: 270,
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/image/$image"),
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
            const SizedBox(
              height: 4,
            ),
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
                        category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontFamily: 'SF Pro Display',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 16,
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w500,
                      height: 1.38,
                    ),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
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
                  const SizedBox(
                    height: 4,
                  ),
                  const Text(
                    '1 hr 45 mins remaining',
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
            ),
          ],
        ),
      ),
    ],
  );
}

Widget buildStepWiseCourseCard(
    String num, int unlocked, String title, BuildContext context) {
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
  return Container(
    // width: 358,
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
              // color: Colors.red,
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
                      // height: 1.20,
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
                const SizedBox(
                  width: 8,
                ),
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
              '4 hr 30 mins • 20 steps',
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
          // padding: const EdgeInsets.all(10),
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
                    onTap: () {
                      Navigator.pushNamed(context, "/course_screen");
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

Widget buidSelectCourseBottomSheet(StateSetter modalSetState,
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
            print("clicked");
          },
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

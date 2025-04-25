import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

Widget createSelectCourseCard(
    String title, String subTitle, String icon, bool selected) {
  return Container(
    clipBehavior: Clip.antiAlias,
    decoration: ShapeDecoration(
      color: selected ? const Color(0x0C31B5B9) : Colors.transparent,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          width: 1,
          color: selected ? const Color(0xFF31B5B9) : const Color(0xFFDDDDDD),
        ),
        borderRadius: BorderRadius.circular(6),
      ),
    ),
    padding: const EdgeInsets.fromLTRB(12.0, 8, 0.5, 0.5),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            const SizedBox(height: 4),
            Text(
              subTitle,
              style: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 12,
                fontFamily: 'SF Pro Display',
                fontWeight: FontWeight.w400,
                height: 1.67,
              ),
            ),
            SizedBox(
              height: 8,
            )
          ],
        ),
        SvgPicture.asset(
          'assets/icons/$icon', // Replace with your SVG file path
          // width: 24,
          // height: 24,
        ),
      ],
    ),
  );
}

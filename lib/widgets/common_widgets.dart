import 'package:flutter/material.dart';

Widget borderHorizontal() {
  return Container(
    // width: 390,
    decoration: const ShapeDecoration(
      shape: RoundedRectangleBorder(
        side: BorderSide(
          width: 0.5,
          strokeAlign: BorderSide.strokeAlignCenter,
          color: Color(0xFFDDDDDD),
        ),
      ),
    ),
  );
}

Widget buildButton(BuildContext context, String title, String? route) {
  return ElevatedButton(
    onPressed: () {
      // Handle login with mobile number
      route != null ? Navigator.pushNamed(context, route) : false ;
    },
    style: ElevatedButton.styleFrom(
      minimumSize: const Size(double.infinity, 50),
      backgroundColor: const Color(0xFF247E80),
    ),
    child: Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontFamily: 'SF Pro Display',
        fontWeight: FontWeight.w500,
        height: 1.50,
      ),
    ),
  );
}

Widget buildBorderButton(
  BuildContext context,
  String title,
  String route,
) {
  return InkWell(
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
      // ignore: prefer_const_constructors
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
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
  );
}

Widget buildBorderButtonRow(
  BuildContext context,
  String title,
  String route,
) {
  return InkWell(
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
      // ignore: prefer_const_constructors
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
  );
}

WidgetStateProperty<Color> getMaterialStateThemeColor() {
  return WidgetStateProperty.all(const Color(0xFF247E80));
}

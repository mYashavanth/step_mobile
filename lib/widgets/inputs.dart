import 'package:flutter/material.dart';

Widget formInputWithLabel(
  TextEditingController controller,
  String hintText,
  String labelText, {
  bool readOnly = false, // Added readOnly parameter
  String? Function(String?)? validator, // Added validator parameter
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        labelText,
        style: const TextStyle(
          color: Color(0xFF323836),
          fontSize: 16,
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w400,
          height: 1.38,
        ),
      ),
      const SizedBox(
        height: 8,
      ),
      Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: Color(0xFFDDDDDD)),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: TextFormField(
          controller: controller,
          readOnly: readOnly, // Set the readOnly property
          style: const TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 16,
            fontFamily: 'SF Pro Display',
            fontWeight: FontWeight.w400,
            height: 1.50,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 16,
              fontFamily: 'SF Pro Display',
              fontWeight: FontWeight.w400,
              height: 1.50,
            ),
            border: InputBorder.none,
          ),
          validator: validator, // Use the validator parameter
        ),
      ),
    ],
  );
}

Widget formInput(TextEditingController controller, String hintText) {
  return TextFormField(
    controller: controller,
    style: const TextStyle(
      color: Color(0xFF1A1A1A),
      fontSize: 16,
      fontFamily: 'SF Pro Display',
      fontWeight: FontWeight.w400,
      height: 1.50,
    ),
    decoration: InputDecoration(
      // labelText: labelText,
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Color(0xFF9CA3AF),
        fontSize: 16,
        fontFamily: 'SF Pro Display',
        fontWeight: FontWeight.w400,
        height: 1.50,
      ),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(
          width: 1,
          color: Color(0xFFDDDDDD),
        ),
      ),
    ),
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Please enter your name';
      }
      return null;
    },
  );
}

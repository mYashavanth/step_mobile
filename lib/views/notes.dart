import 'package:flutter/material.dart';
import 'package:step_mobile/widgets/navbar.dart';
import 'package:step_mobile/widgets/notes_widgets.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  State<NotesScreen> createState() {
    return _NotesScreen();
  }
}

class _NotesScreen extends State<NotesScreen> {
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.maxFinite,
              padding: EdgeInsets.only(
                top: MediaQuery.viewPaddingOf(context).top + 12,
                right: 12,
                left: 12,
                bottom: 12,
              ),
              color: Colors.white,
              child: const Text(
                'Notes',
                style: TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 20,
                  fontFamily: 'SF Pro Display',
                  fontWeight: FontWeight.w500,
                  height: 1.40,
                ),
              ),
            ),
            const SizedBox(
              height: 6,
            ),
            bannerNotes(),
            const SizedBox(
              height: 12,
            ),
            NotesWidgets(),
          ],
        ),
      ),
      bottomNavigationBar: const StepNavigationBar(1),
    );
  }
}

Widget bannerNotes() {
  return Container(
    color: Colors.white,
    padding: const EdgeInsets.symmetric(
      vertical: 16,
    ),
    child: Container(
      height: 240,
      width: double.maxFinite,
      decoration: const ShapeDecoration(
        image: DecorationImage(
          image: AssetImage("assets/image/subscribe-to-premium-package.jpg"),
        ),
        shape: RoundedRectangleBorder(),
      ),
      child: Column(
        children: [
          const SizedBox(
            height: 16,
          ),
          const Text(
            'Get Unlimited Access',
            style: TextStyle(
              color: Color(0xFFEB7700),
              fontSize: 20,
              fontFamily: 'SF Pro Display',
              fontWeight: FontWeight.w700,
              height: 1.40,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 64),
            child: Text(
              'Get access to 60+ recorded sessions, 200+ videos, Downloadable resources & 60+ practice tests',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xCCEC7800),
                fontSize: 14,
                fontFamily: 'SF Pro Display',
                fontWeight: FontWeight.w400,
                height: 1.43,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle login with mobile number
              // Navigator.pushNamed(context, "/otp_verify");
            },
            style: ElevatedButton.styleFrom(
              // minimumSize: const Size(double.infinity, 50),
              backgroundColor: const Color(0xFFFE860A),
            ),
            child: const Text(
              'Enroll Now @ ₹1000',
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
  );
}

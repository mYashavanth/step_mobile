import 'package:flutter/material.dart';
import 'package:ghastep/widgets/navbar.dart';
import 'package:ghastep/widgets/notes_widgets.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() {
    return _NotesScreen();
  }
}

class _NotesScreen extends State<NotesScreen> {
  @override
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
            bannerNotes(context),
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

Widget bannerNotes(BuildContext context) {
  // Get screen dimensions
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;

  // Calculate responsive values
  final bannerHeight = screenHeight * 0.3; // 30% of screen height
  final horizontalPadding = screenWidth * 0.05; // 5% of screen width
  final verticalSpacing = screenHeight * 0.02; // 2% of screen height
  final borderRadius = 8.0; // Border radius value

  return Container(
    color: Colors.white,
    padding: EdgeInsets.symmetric(vertical: verticalSpacing),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        height: bannerHeight,
        width: double.maxFinite,
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage("assets/image/subscribe-to-premium-package.jpg"),
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: verticalSpacing),
                const Text(
                  'Get Unlimited Access',
                  style: TextStyle(
                    color: Color(0xFFEB7700),
                    fontSize: 20,
                    fontFamily: 'SF Pro Display',
                    fontWeight: FontWeight.w700,
                    height: 1.40,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: verticalSpacing),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: const Text(
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
                SizedBox(height: verticalSpacing),
                SizedBox(
                  width: screenWidth * 0.6,
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle button press
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFE860A),
                      padding: EdgeInsets.symmetric(
                        vertical: verticalSpacing * 0.8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(borderRadius),
                      ),
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
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:step_mobile/widgets/course_screen_widgets.dart';

class NotesIndividual extends StatefulWidget {
  const NotesIndividual({super.key});

  @override
  State<NotesIndividual> createState() => _NotesIndividualState();
}

class _NotesIndividualState extends State<NotesIndividual> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              SafeArea(
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    const Text(
                      'Embryology',
                      style: TextStyle(
                        color: Color(0xFF1A1A1A),
                        fontSize: 20,
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.w500,
                        height: 1.40,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              Column(
                children: [
                  courseNotes(
                      "Name of document here if it exceeds 1 lines & not unlocked",
                      26,
                      true,
                      "adobe_pdf.svg"),
                  courseNotes("Name of document here", 32, true, "excel.svg"),
                  courseNotes(
                      "Name of document here if it exceeds 1 lines & not unlocked",
                      28,
                      true,
                      "adobe_pdf.svg"),
                  courseNotes(
                      "Name of document here if it exceeds 1 lines & not unlocked",
                      20,
                      true,
                      "excel.svg"),
                  courseNotes(
                      "Name of document here if it exceeds 1 lines & not unlocked",
                      26,
                      true,
                      "adobe_pdf.svg"),
                  courseNotes(
                      "Name of document here if it exceeds 1 lines & not unlocked",
                      22,
                      true,
                      "excel.svg"),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            Navigator.pushNamed(context, "/subscribe");
          },
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
        ),
      ),
    );
  }
}

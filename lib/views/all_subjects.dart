import 'package:flutter/material.dart';
import 'package:ghastep/widgets/homepage_widgets.dart';

class AllSubjectsScreen extends StatefulWidget {
  const AllSubjectsScreen({super.key});

  @override
  State<AllSubjectsScreen> createState() => _AllSubjectsScreenState();
}

class _AllSubjectsScreenState extends State<AllSubjectsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
          ),
        ),
        title: const Text(
          'All subjects (crash course)',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 20,
            fontFamily: 'SF Pro Display',
            fontWeight: FontWeight.w500,
            height: 1.40,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              const SizedBox(
                height: 8,
              ),
              buildStepWiseCourseCard("01", 2, "Anatomy", '1', context),
              const SizedBox(
                height: 8,
              ),
              buildStepWiseCourseCard("02", 1, "Physiology", '1', context),
              const SizedBox(
                height: 8,
              ),
              buildStepWiseCourseCard("03", 0, "Biochemistry", '1', context),
              const SizedBox(
                height: 8,
              ),
              buildStepWiseCourseCard("04", 0, "Pathology", '1', context),
              const SizedBox(
                height: 8,
              ),
              buildStepWiseCourseCard("05", 0, "Parmacology", '1', context),
              const SizedBox(
                height: 8,
              ),
              buildStepWiseCourseCard(
                  "06", 0, "Comunity Medicine", '1', context),
              const SizedBox(
                height: 8,
              ),
              buildStepWiseCourseCard(
                  "07", 0, "Forensic Medicine", '1', context),
              const SizedBox(
                height: 24,
              ),
              buildStepWiseCourseCard(
                  "08", 0, "General Medicine", '1', context),
              const SizedBox(
                height: 24,
              ),
              buildStepWiseCourseCard("09", 0, "Pediatrics", '1', context),
              const SizedBox(
                height: 24,
              ),
              buildStepWiseCourseCard(
                  "10", 0, "Dermatology, Venereol...", '1', context),
              const SizedBox(
                height: 24,
              ),
              buildStepWiseCourseCard("11", 0, "Psychiatry", '1', context),
              const SizedBox(
                height: 24,
              ),
              buildStepWiseCourseCard("12", 0, "Orthopedics", '1', context),
              const SizedBox(
                height: 24,
              ),
              buildStepWiseCourseCard("13", 0, "Anesthesiology", '1', context),
              const SizedBox(
                height: 24,
              ),
              buildStepWiseCourseCard("14", 0, "Radiology", '1', context),
              const SizedBox(
                height: 24,
              ),
              buildStepWiseCourseCard(
                  "15", 0, "Obstetrics & Gynecology", '1', context),
              const SizedBox(
                height: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

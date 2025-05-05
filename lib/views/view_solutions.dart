import 'package:flutter/material.dart';
import 'package:ghastep/widgets/common_widgets.dart';
import 'package:ghastep/widgets/view_solutions_widgets.dart';

class ViewSolution extends StatefulWidget {
  const ViewSolution({super.key});

  @override
  State<ViewSolution> createState() => _ViewSolutionState();
}

class _ViewSolutionState extends State<ViewSolution> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Color.fromARGB(255, 236, 234, 234),
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        title: const Text(
          'Solutions',
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
        child: Column(
          children: [
            Container(
              color: Colors.white,
              height: 42,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  buildTopSelectCards(true, "All Solutions"),
                  buildTopSelectCards(false, "Correct"),
                  buildTopSelectCards(false, "Incorrect"),
                  buildTopSelectCards(false, "Un answered"),
                ],
              ),
            ),
            // const SizedBox(height: 12,),
            Container(height: 12, color: Colors.white),
            borderHorizontal(),
            const QuestAnsSolWidget(),
          ],
        ),
      ),
    );
  }
}

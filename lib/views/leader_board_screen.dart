import 'package:flutter/material.dart';
import 'package:ghastep/widgets/common_widgets.dart';
import 'package:ghastep/widgets/test_result_widgets.dart';

class LeaderBoardScreen extends StatefulWidget {
  const LeaderBoardScreen({super.key});

  @override
  State<LeaderBoardScreen> createState() => _LeaderBoardScreenState();
}

class _LeaderBoardScreenState extends State<LeaderBoardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
        ),
        title: const Text(
          'Leaderboard',
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
            SizedBox(
              height: 250,
              // color: const Color.fromARGB(130, 76, 175, 79),
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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: buildButton(context, "Go home", "/home_page"),
      ),
    );
  }
}

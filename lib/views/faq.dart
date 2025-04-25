import 'package:flutter/material.dart';

class FAQ extends StatefulWidget {
  const FAQ({super.key});

  @override
  State<FAQ> createState() => _FAQState();
}

class _FAQState extends State<FAQ> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
          ),
        ),
        title: const Text(
          'FAQs',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             const SizedBox(height: 12,),
            buildFaqCard(),
            const SizedBox(height: 12,),
            buildFaqCard(),
            const SizedBox(height: 12,),
          ],
        ),
      ),
    );
  }
}

Widget buildFaqCard() {
  return Container(
    color: Colors.white,
    padding: const EdgeInsets.all(12),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What is Plus subscription?',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 16,
            fontFamily: 'SF Pro Display',
            fontWeight: FontWeight.w400,
            height: 1.50,
          ),
        ),
        SizedBox(
          height: 12,
        ),
        Text(
          'Plus subscription gives you access to all courses and tests launched every week within the goal you’ve subscribed for. Plus subscription is available for 1 month, 3 months, 6 months and 12 months.',
          style: TextStyle(
            color: Color(0xFF737373),
            fontSize: 16,
            fontFamily: 'SF Pro Display',
            fontWeight: FontWeight.w400,
            height: 1.50,
          ),
        ),
      ],
    ),
  );
}

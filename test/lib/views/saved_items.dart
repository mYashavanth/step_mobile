import 'package:flutter/material.dart';

class SavedItems extends StatefulWidget {
  const SavedItems({super.key});

  @override
  State<SavedItems> createState() => _SavedItemsState();
}

class _SavedItemsState extends State<SavedItems> {
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
          'Saved items',
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
            const SizedBox(
              height: 12,
            ),
            InkWell(
                onTap: () {
                  Navigator.pushNamed(context, "/bookmark_saved_question");
                },
                child: buildSavedItemcard()),
            const SizedBox(
              height: 12,
            ),
            InkWell(
                onTap: () {
                  Navigator.pushNamed(context, "/bookmark_saved_question");
                },
                child: buildSavedItemcard()),
            const SizedBox(
              height: 12,
            ),
            InkWell(
                onTap: () {
                  Navigator.pushNamed(context, "/bookmark_saved_question");
                },
                child: buildSavedItemcard()),
            const SizedBox(
              height: 12,
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildSavedItemcard() {
  return Container(
    color: Colors.white,
    padding: const EdgeInsets.all(12),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Question',
              style: TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 16,
                fontFamily: 'SF Pro Display',
                fontWeight: FontWeight.w500,
                height: 1.50,
              ),
            ),
            SizedBox(
              width: 12,
            ),
            Text(
              '1m ago',
              style: TextStyle(
                color: Color(0xFF737373),
                fontSize: 14,
                fontFamily: 'SF Pro Display',
                fontWeight: FontWeight.w400,
                height: 1.57,
              ),
            ),
            Spacer(),
            Icon(
              Icons.bookmark_outlined,
              color: Color(0xFF737373),
            )
          ],
        ),
        SizedBox(
          height: 8,
        ),
        Text(
          'Which of the following arteries is a direct branch of the external carotid artery?',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
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

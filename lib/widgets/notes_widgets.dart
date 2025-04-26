import 'package:flutter/material.dart';

class NotesWidgets extends StatefulWidget {
  const NotesWidgets({super.key});

  @override
  State<NotesWidgets> createState() {
    return _NotesWidget();
  }
}

class _NotesWidget extends State<NotesWidgets>
    with SingleTickerProviderStateMixin {
  List<Map> notesData = [
    {
      "title": 'Anatomy',
      "enlarge": false,
      "subNotes": [
        "Embryology",
        "Histology and osteology",
        "Neuroanatomy",
        "Head and Neck",
        "Thorax"
      ],
    },
    {
      "title": 'Physiology',
      "enlarge": false,
      "subNotes": [
        "Embryology",
        "Histology and osteology",
        "Neuroanatomy",
        "Head and Neck",
        "Thorax"
      ],
    },
    {
      "title": 'Biochemistry',
      "enlarge": false,
      "subNotes": [
        "Embryology",
        "Histology and osteology",
        "Neuroanatomy",
        "Head and Neck",
        "Thorax"
      ],
    },
    {
      "title": 'Physiology',
      "enlarge": false,
      "subNotes": [
        "Embryology",
        "Histology and osteology",
        "Neuroanatomy",
        "Head and Neck",
        "Thorax"
      ],
    },
    {
      "title": 'Pathology',
      "enlarge": false,
      "subNotes": [
        "Embryology",
        "Histology and osteology",
        "Neuroanatomy",
        "Head and Neck",
        "Thorax"
      ],
    },
    {
      "title": 'Pharmacology',
      "enlarge": false,
      "subNotes": [
        "Embryology",
        "Histology and osteology",
        "Neuroanatomy",
        "Head and Neck",
        "Thorax"
      ],
    },
    {
      "title": 'Microbiology',
      "enlarge": false,
      "subNotes": [
        "Embryology",
        "Histology and osteology",
        "Neuroanatomy",
        "Head and Neck",
        "Thorax"
      ],
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(notesData.length, (index) {
        Map data = notesData[index];
        String title = notesData[index]['title'];
        List subNotes = data["subNotes"];
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(12),
          color: Colors.white,
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    margin: const EdgeInsets.only(right: 20),
                    clipBehavior: Clip.antiAlias,
                    decoration: ShapeDecoration(
                      color: const Color(0x1931B5B9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(200),
                      ),
                      shadows: const [
                        BoxShadow(
                          color: Color(0x0C86F57F),
                          blurRadius: 10,
                          offset: Offset(0, 1),
                          spreadRadius: 0,
                        )
                      ],
                    ),
                    child: Center(
                      child: Text(
                        title[0],
                        style: TextStyle(
                          color: const Color(0xFF247E80),
                          fontSize: 20,
                          fontFamily: 'SF Pro Display',
                          fontWeight: FontWeight.w700,
                          height: 1.20,
                          shadows: [
                            Shadow(
                                offset: const Offset(0, 4),
                                blurRadius: 20,
                                color:
                                    const Color(0xFF000000).withOpacity(0.25))
                          ],
                        ),
                      ),
                    ),
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 16,
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w500,
                      height: 1.50,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      data["enlarge"] = !data["enlarge"];
                      setState(() {});
                    },
                    icon: data["enlarge"]
                        ? const Icon(Icons.add)
                        : const Icon(Icons.remove),
                  ),
                ],
              ),
              // Visibility(
              //   maintainAnimation: true,
              //   maintainState: true,
              //   visible: data["enlarge"],
              //   child: Column(
              //     children: List.generate(subNotes.length, (index) {
              //       return Container(
              //         // margin: const EdgeInsets.only(top: 4, bottom: 4),
              //         // padding: const EdgeInsets.all(4),
              //         child: Row(
              //           children: [
              //             Text(
              //               subNotes[index],
              //               style: const TextStyle(
              //                 color: Color(0xFF1A1A1A),
              //                 fontSize: 16,
              //                 fontFamily: 'SF Pro Display',
              //                 fontWeight: FontWeight.w400,
              //                 height: 1.50,
              //               ),
              //             ),
              //             const Spacer(),
              //             IconButton(
              //               onPressed: () {},
              //               icon: const Icon(
              //                 Icons.arrow_forward_ios_rounded,
              //                 size: 16,
              //                 color: Color(0xFF737373),
              //               ),
              //             )
              //           ],
              //         ),
              //       );
              //     }),
              //   ),
              // )
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: data["enlarge"]
                    ? Column(
                        children: List.generate(subNotes.length, (index) {
                          return Container(
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              children: [
                                Text(
                                  subNotes[index],
                                  style: const TextStyle(
                                    color: Color(0xFF1A1A1A),
                                    fontSize: 16,
                                    fontFamily: 'SF Pro Display',
                                    fontWeight: FontWeight.w400,
                                    height: 1.50,
                                  ),
                                ),
                                const Spacer(),

                                /// navigation to individual notes page
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, "/notes_individual");
                                  },
                                  child: const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 16,
                                    color: Color(0xFF737373),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      )
                    : const SizedBox(), // Avoid layout jumps when hidden
              ),
            ],
          ),
        );
      }),
    );
  }
}

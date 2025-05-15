import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';

class StepNavigationBar extends StatefulWidget {
  final int selected;
  const StepNavigationBar(this.selected, {super.key});

  @override
  State<StepNavigationBar> createState() => _StepNavigationBar();
}

class _StepNavigationBar extends State<StepNavigationBar> {
  int _selectedIndex = 0;
  @override
  void initState() {
    _selectedIndex = widget.selected;
    setState(() {});
    print("index : $_selectedIndex");
    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      if (_selectedIndex == index) {
        return;
      }

      switch (index) {
        case 0:
          Navigator.of(context).pushNamed('/home_page');
        case 1:
          Navigator.of(context).pushNamed('/notes');
        case 2:
          Navigator.of(context).pushNamed('/ranking_leader_board_screen');
        case 3:
          Navigator.of(context).pushNamed('/profile');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            width: 0.5,
            color: Color.fromARGB(138, 205, 203, 203),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          //first
          InkWell(
            onTap: () {
              _onItemTapped(0);
            },
            child: SizedBox(
              width: 70,
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 4,
                    decoration: ShapeDecoration(
                      color: _selectedIndex != 0
                          ? Colors.white
                          : const Color(0xFF247E80),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(4),
                          bottomRight: Radius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  SvgPicture.asset(
                    'assets/icons/home.svg',
                    colorFilter: ColorFilter.mode(
                        _selectedIndex != 0
                            ? const Color(0xFF8B8D98)
                            : const Color(0xFF247E80),
                        BlendMode.srcIn),
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  Text(
                    'Home',
                    style: TextStyle(
                      color: _selectedIndex != 0
                          ? const Color(0xFF8B8D98)
                          : const Color(0xFF247E80),
                      fontSize: 12,
                      fontFamily: "SF Pro Display",
                      fontWeight: _selectedIndex != 0
                          ? FontWeight.w400
                          : FontWeight.w600,
                      // height: 0.11,
                    ),
                  ),
                ],
              ),
            ),
          ),

          InkWell(
            onTap: () {
              _onItemTapped(1);
            },
            child: SizedBox(
              height: 70,
              child: Column(
                children: [
                  const SizedBox(
                    height: 9,
                  ),
                  SvgPicture.asset(
                    'assets/icons/notes.svg',
                    colorFilter: ColorFilter.mode(
                        _selectedIndex != 1
                            ? const Color(0xFF8B8D98)
                            : const Color(0xFF247E80),
                        BlendMode.srcIn),
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  Text(
                    'Notes',
                    style: TextStyle(
                      color: _selectedIndex != 1
                          ? const Color(0xFF8B8D98)
                          : const Color(0xFF247E80),
                      fontSize: 12,
                      fontFamily: "SF Pro Display",
                      fontWeight: _selectedIndex != 1
                          ? FontWeight.w400
                          : FontWeight.w600,
                      // height: 0.11,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // GestureDetector(
          //   onTap: () {
          //     _onItemTapped(2);
          //   },
          //   child: SizedBox(
          //     width: 70,
          //     child: Column(
          //       children: [
          //         Container(
          //           width: 56,
          //           height: 4,
          //           decoration: ShapeDecoration(
          //             color: _selectedIndex != 2
          //                 ? Colors.white
          //                 : const Color(0xFF247E80),
          //             shape: const RoundedRectangleBorder(
          //               borderRadius: BorderRadius.only(
          //                 bottomLeft: Radius.circular(4),
          //                 bottomRight: Radius.circular(4),
          //               ),
          //             ),
          //           ),
          //         ),
          //         const SizedBox(
          //           height: 5,
          //         ),
          //         SvgPicture.asset(
          //           'assets/icons/ranking.svg',
          //           colorFilter: ColorFilter.mode(
          //               _selectedIndex != 2
          //                   ? const Color(0xFF8B8D98)
          //                   : const Color(0xFF247E80),
          //               BlendMode.srcIn),
          //         ),
          //         const SizedBox(
          //           height: 6,
          //         ),
          //         Text(
          //           'Ranking',
          //           style: TextStyle(
          //             color: _selectedIndex != 2
          //                 ? const Color(0xFF8B8D98)
          //                 : const Color(0xFF247E80),
          //             fontSize: 12,
          //             fontFamily: "SF Pro Display",
          //             fontWeight: _selectedIndex != 2
          //                 ? FontWeight.w400
          //                 : FontWeight.w600,
          //             // height: 0.11,
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          GestureDetector(
            onTap: () {
              _onItemTapped(3);
            },
            child: SizedBox(
              width: 70,
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 4,
                    decoration: ShapeDecoration(
                      color: _selectedIndex != 3
                          ? Colors.white
                          : const Color(0xFF247E80),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(4),
                          bottomRight: Radius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  SvgPicture.asset(
                    'assets/icons/user.svg',
                    colorFilter: ColorFilter.mode(
                        _selectedIndex != 3
                            ? const Color(0xFF8B8D98)
                            : const Color(0xFF247E80),
                        BlendMode.srcIn),
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  Text(
                    'Profile',
                    style: TextStyle(
                      color: _selectedIndex != 3
                          ? const Color(0xFF8B8D98)
                          : const Color(0xFF247E80),
                      fontSize: 12,
                      fontFamily: "SF Pro Display",
                      fontWeight: _selectedIndex != 3
                          ? FontWeight.w400
                          : FontWeight.w600,
                      // height: 0.11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

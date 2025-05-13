import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
          ),
        ),
        title: const Text(
          'Settings',
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
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'My account',
                    style: TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 16,
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w500,
                      height: 1.50,
                    ),
                  ),
                  buildSettingsRow(const Icon(Icons.person_2_outlined),
                      "Profile", "/profile_details"),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Feedback',
                    style: TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 16,
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w500,
                      height: 1.50,
                    ),
                  ),
                  buildSettingsRow(
                      const Icon(Icons.star_border_purple500_outlined),
                      "Rate the app",
                      ""),
                  buildSettingsRow(const Icon(Icons.flag_outlined),
                      "Report a problem", "/report_problem"),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Step',
                    style: TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 16,
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w500,
                      height: 1.50,
                    ),
                  ),
                  buildSettingsRow(
                      const Icon(Icons.gavel), "Terms and conditions", ""),
                  buildSettingsRow(const Icon(Icons.privacy_tip_outlined),
                      "Privacy policy", ""),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'More',
                    style: TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 16,
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w500,
                      height: 1.50,
                    ),
                  ),
                  buildSettingsRow(
                      const Icon(Icons.logout), "Sign out", "log_out"),
                  buildSettingsRow(
                      const Icon(Icons.delete), "Delete account", ""),
                ],
              ),
            ),
            const SizedBox(
              height: 32,
            ),
            Center(
                child: Column(
              children: [
                SvgPicture.asset("assets/icons/dummy/logo_black.svg"),
                const SizedBox(
                  height: 12,
                ),
                const Text(
                  'Version 1.0.14b269',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF848F8B),
                    fontSize: 10,
                    fontFamily: 'Figtree',
                    fontWeight: FontWeight.w400,
                  ),
                )
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget buildSettingsRow(Icon iconWidget, String title, String route) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          width: 35,
          height: 35,
          margin: const EdgeInsets.only(right: 12),
          // padding: const EdgeInsets.all(10),
          decoration: ShapeDecoration(
            color: const Color(0xFFEDEEF0),
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
            child: iconWidget,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 16,
            fontFamily: 'SF Pro Display',
            fontWeight: FontWeight.w400,
            height: 1.50,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () {
            if (route == "log_out") {
              logOutPopUp(context);
              return;
            }
            Navigator.pushNamed(context, route);
          },
          icon: const Icon(Icons.arrow_forward_ios_rounded),
        ),
      ],
    );
  }
}

void logOutPopUp(BuildContext context) {
  final storage = const FlutterSecureStorage();
  showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      contentPadding: const EdgeInsets.all(0),
      content: Container(
        padding: const EdgeInsets.all(12),
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: ShapeDecoration(
                color: const Color(0xFFFEE3E1),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    width: 8,
                    strokeAlign: BorderSide.strokeAlignCenter,
                    color: Color(0xFFFEF2F1),
                  ),
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: Center(
                child:
                    SvgPicture.asset("assets/icons/profile/alert-circle.svg"),
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            const Text(
              'Wait, Before You Go!',
              style: TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 20,
                fontFamily: 'SF Pro Display',
                fontWeight: FontWeight.w500,
                height: 1.40,
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            const Text(
              'Ready to conquer more? Come back soon and keep stepping toward success!',
              style: TextStyle(
                color: Color(0xFF737373),
                fontSize: 16,
                fontFamily: 'SF Pro Display',
                fontWeight: FontWeight.w400,
                height: 1.25,
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: ShapeDecoration(
                        color: const Color(0xFFEDEEF0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Color(0xFF1A1A1A),
                            fontSize: 16,
                            fontFamily: 'SF Pro Display',
                            fontWeight: FontWeight.w500,
                            height: 1.50,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      storage.delete(key: "token");
                      Navigator.pushReplacementNamed(context, '/intro');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: ShapeDecoration(
                        color: const Color(0xFFD92C20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'Submit',
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
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    ),
  );
}

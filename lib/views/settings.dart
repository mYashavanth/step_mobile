import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
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
                  buildSettingsRow(
                    icon: Icons.person_2_outlined,
                    title: "Profile",
                    route: "/profile_details",
                  ),
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
                    icon: Icons.star_border_purple500_outlined,
                    title: "Rate the app",
                    route:
                        "https://play.google.com/store/apps/details?id=com.ghastep&hl=en",
                  ),
                  // buildSettingsRow(
                  //   icon: Icons.flag_outlined,
                  //   title: "Report a problem",
                  //   route: "/report_problem",
                  // ),
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
                    icon: Icons.gavel,
                    title: "Terms and conditions",
                    route: "/terms_and_conditions",
                  ),
                  buildSettingsRow(
                    icon: Icons.privacy_tip_outlined,
                    title: "Privacy policy",
                    route: "/privacy_policy",
                  ),
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
                    icon: Icons.payment_outlined,
                    title: "Payment History",
                    route: "/payment_logs",
                  ),
                  buildSettingsRow(
                    icon: Icons.logout,
                    title: "Sign out",
                    route: "log_out",
                    iconColor: Colors.black,
                  )
                  // buildSettingsRow(
                  //     const Icon(Icons.delete), "Delete account", ""),
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

  Widget buildSettingsRow({
    required IconData icon,
    required String title,
    required String route,
    Color iconColor = Colors.black,
    double iconSize = 20,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleRouteNavigation(route),
        borderRadius: BorderRadius.circular(12),
        splashColor: Colors.grey.withOpacity(0.1),
        highlightColor: Colors.grey.withOpacity(0.05),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
          child: Row(
            children: [
              // Icon Container
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDEEF0),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  size: iconSize,
                  color: iconColor,
                ),
              ),

              // Title
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 16,
                    fontFamily: 'SF Pro Display',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // Navigation Indicator
              Icon(
                route.startsWith('http')
                    ? Icons.open_in_new_rounded
                    : Icons.chevron_right_rounded,
                size: route.startsWith('http') ? 20 : 30,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleRouteNavigation(String route) async {
    if (route == "log_out") {
      logOutPopUp(context);
      return;
    }

    if (route.startsWith('http')) {
      final Uri url = Uri.parse(route);
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
      }
    } else if (route.isNotEmpty) {
      Navigator.pushNamed(context, route);
    }
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

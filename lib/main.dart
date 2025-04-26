import 'package:flutter/material.dart';
import 'package:step_mobile/views/all_subjects.dart';
import 'package:step_mobile/views/before_enter_test_screen.dart';
import 'package:step_mobile/views/bookmark_question_screen.dart';
import 'package:step_mobile/views/calendar_screen.dart';
import 'package:step_mobile/views/course_screen.dart';
import 'package:step_mobile/views/details_form.dart';
import 'package:step_mobile/views/faq.dart';
import 'package:step_mobile/views/home_page.dart';
import 'package:step_mobile/views/intro.dart';
import 'package:step_mobile/views/leader_board_screen.dart';
import 'package:step_mobile/views/mobile_login.dart';
import 'package:step_mobile/views/notes.dart';
import 'package:step_mobile/views/notes_individual.dart';
import 'package:step_mobile/views/otp_screen.dart';
import 'package:step_mobile/views/profile.dart';
import 'package:step_mobile/views/profile_detail.dart';
import 'package:step_mobile/views/rankings_leaderbord_screen.dart';
import 'package:step_mobile/views/report_problem.dart';
import 'package:step_mobile/views/saved_items.dart';
import 'package:step_mobile/views/select_course.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:step_mobile/views/settings.dart';
import 'package:step_mobile/views/subscription_page.dart';
import 'package:step_mobile/views/test_result.dart';
import 'package:step_mobile/views/test_screen.dart';
import 'package:step_mobile/views/updates.dart';
import 'package:step_mobile/views/view_solutions.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF247E80)),
        useMaterial3: true,
      ),
      // localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [
        Locale('en', ''),
        Locale('zh', ''),
        Locale('he', ''),
        Locale('es', ''),
        Locale('ru', ''),
        Locale('ko', ''),
        Locale('hi', ''),
      ],
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
      routes: {
        '/splash': (context) => const Splash(),
        '/intro': (context) => const Intro(),
        '/mobile_login': (context) => const MobileLogin(),
        '/otp_verify': (context) => const OTPScreen(),
        '/details_form': (context) => const DetailsForm(),
        '/select_course': (context) => const SelectCourse(),
        '/home_page': (context) => const HomePage(),
        '/calendar_view': (context) => const CalendarScreen(),
        '/course_screen': (context) => const CourseScreen(),
        '/before_enter_test': (context) => const BeforeEnterTestScreen(),
        '/notes': (context) => const NotesScreen(),
        '/notes_individual': (context) => const NotesIndividual(),
        '/test_screen': (context) => const TestScreen(),
        '/result_test_screen': (context) => const ResultScreenTest(),
        '/leader_board_screen': (context) => const LeaderBoardScreen(),
        '/ranking_leader_board_screen': (context) =>
            const RankingLeaderBoardScreen(),
        '/view_solutions': (context) => const ViewSolution(),
        '/profile': (context) => const Profile(),
        '/settings': (context) => const Settings(),
        '/profile_details': (context) => const ProfileDetails(),
        '/report_problem': (context) => const ReportProblem(),
        '/faq': (context) => const FAQ(),
        '/saved_items': (context) => const SavedItems(),
        '/bookmark_saved_question': (context) => const BookmarkQuestionScreen(),
        '/subscribe': (context) => const SubscribePage(),
        '/updates': (context) => const UpdatesScreen(),
        '/all_subjects': (context) => const AllSubjectsScreen(),
      },
      initialRoute: '/splash',
    );
  }
}

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _Splash();
}

class _Splash extends State<Splash> {
  @override
  void initState() {
    // TODO: implement initState
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushNamed(context, "/intro");
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF247E80),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 65),
            child: SizedBox(
              child: Image(
                image: AssetImage('assets/image/logo.png'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

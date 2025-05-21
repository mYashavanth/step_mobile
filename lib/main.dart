import 'package:flutter/material.dart';
import 'package:ghastep/views/all_subjects.dart';
import 'package:ghastep/views/before_enter_test_screen.dart';
import 'package:ghastep/views/bookmark_question_screen.dart';
import 'package:ghastep/views/calendar_screen.dart';
import 'package:ghastep/views/course_screen.dart';
import 'package:ghastep/views/details_form.dart';
import 'package:ghastep/views/faq.dart';
import 'package:ghastep/views/home_page.dart';
import 'package:ghastep/views/intro.dart';
import 'package:ghastep/views/leader_board_screen.dart';
import 'package:ghastep/views/mobile_login.dart';
import 'package:ghastep/views/notes.dart';
import 'package:ghastep/views/notes_individual.dart';
import 'package:ghastep/views/otp_screen.dart';
import 'package:ghastep/views/privacy_policy.dart';
import 'package:ghastep/views/profile.dart';
import 'package:ghastep/views/profile_detail.dart';
import 'package:ghastep/views/rankings_leaderbord_screen.dart';
import 'package:ghastep/views/report_problem.dart';
import 'package:ghastep/views/saved_items.dart';
import 'package:ghastep/views/select_course.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:ghastep/views/settings.dart';
import 'package:ghastep/views/subscription_page.dart';
import 'package:ghastep/views/terms_and_conditions.dart';
import 'package:ghastep/views/test_result.dart';
import 'package:ghastep/views/test_screen.dart';
import 'package:ghastep/views/updates.dart';
import 'package:ghastep/views/view_solutions.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ghastep/views/urlconfig.dart';
import 'package:ghastep/views/dry.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:flutter_microsoft_clarity/flutter_microsoft_clarity.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // FlutterMicrosoftClarity().init(projectId: 'rly2rlgrjp');
  try {
    await Firebase.initializeApp();
    runApp(const MyApp());
  } catch (e) {
    print('Firebase initialization error: $e');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // String _platformVersion = 'Unknown';
  // final _flutterMicrosoftClarityPlugin = FlutterMicrosoftClarity();
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  // @override
  // void initState() {
  //   super.initState();
  //   initPlatformState();
  // }

  // Future<void> initPlatformState() async {
  //   String platformVersion;

  //   try {
  //     platformVersion =
  //         await _flutterMicrosoftClarityPlugin.getPlatformVersion() ??
  //             'Unknown platform version';
  //   } catch (e) {
  //     print('Error: $e');
  //     platformVersion = 'Failed to get platform version.';
  //   }
  //   if (!mounted) return;

  //   setState(() {
  //     _platformVersion = platformVersion;
  //   });
  //   print(
  //       'Platform version: $_platformVersion +++++++++++++++++++++++++++++++++++++++++++++++++++++++');
  // }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GHAStep',
      navigatorObservers: [
        CustomNavigatorObserver(
          onPopNext: () {
            print("Navigated back to HomePage");
            // Call fetchItineraries when HomePage is shown again
            homePageKey.currentState?.fetchUserMetrics();
            homePageKey.currentState?.fetchResumeVideos();
          },
        ),
      ],
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
        '/home_page': (context) => HomePage(),
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
        '/terms_and_conditions': (context) => const TermsAndConditionsPage(),
        '/privacy_policy': (context) => const PrivacyPolicyPage(),
      },
      initialRoute: '/splash',
    );
  }
}

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  bool _isLoading = true;

  Future<void> _validateToken() async {
    try {
      final token = await _secureStorage.read(key: 'token');

      if (token == null || token.isEmpty) {
        // No token found, navigate to intro
        _navigateToIntro();
        return;
      }

      final response =
          await http.get(Uri.parse('$baseurl/app-users/validate-token/$token'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Response data: $data');
        if (data['errFlag'] == 0 && data['message'] == 'Valid Token') {
          // Token is valid, navigate to home
          Navigator.pushReplacementNamed(context, '/home_page');
        } else {
          // Token is invalid, navigate to intro
          _navigateToIntro();
        }
      } else {
        // API error, navigate to intro
        showCustomSnackBar(
          context: context,
          message: 'Authentication failed. Please login again.',
          isSuccess: false,
        );
        _navigateToIntro();
      }
    } catch (e) {
      // Handle any errors
      showCustomSnackBar(
        context: context,
        message: 'Connection error. Please try again.',
        isSuccess: false,
      );
      _navigateToIntro();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToIntro() {
    Navigator.pushReplacementNamed(context, '/intro');
  }

  @override
  void initState() {
    super.initState();
    _validateToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF247E80),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 65),
            child: SizedBox(
              child: Image(
                image: AssetImage('assets/image/logo.png'),
              ),
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 20),
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}

class CustomNavigatorObserver extends NavigatorObserver {
  final VoidCallback onPopNext;

  CustomNavigatorObserver({required this.onPopNext});

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    print("didPop called ${previousRoute?.settings.name}");
    if (previousRoute?.settings.name == '/home_page') {
      print("onPopNext called");
      onPopNext(); // Trigger the callback when navigating back to HomePage
    }
  }
}

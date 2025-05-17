import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ghastep/views/urlconfig.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ghastep/views/dry.dart';
import 'dart:async';
import 'package:flutter/gestures.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final storage = const FlutterSecureStorage();
  String? mobile;
  late String appUserId;
  String enteredOtp = "";
  bool clearOtpField = false;
  bool isResendingOtp = false;
  int resendCountdown = 30; // 30 seconds countdown for resend
  late Timer resendTimer;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    startResendTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args['fromProfileEdit'] == true) {
      print(
          'Navigated from profile edit in otp screen: ${args['fromProfileEdit']}');
    }
  }

  @override
  void dispose() {
    resendTimer.cancel();
    super.dispose();
  }

  void startResendTimer() {
    resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendCountdown > 0) {
        setState(() {
          resendCountdown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _loadUserData() async {
    mobile = await storage.read(key: 'mobile');
    appUserId = await storage.read(key: 'appUserId') ?? '';
    setState(() {});
  }

  Future<void> _verifyOtp(String otp) async {
    // Get navigation arguments
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    // Determine which URL to use
    String url;
    bool fromProfileEdit = args != null && args['fromProfileEdit'] == true;
    if (fromProfileEdit) {
      url = '$baseurl/app-users/confirm-update-mobile';
    } else {
      url = '$baseurl/app-users/verify-otp';
    }

    print('URL for verify otp: $url');

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'appUserId': appUserId,
          'otp': otp,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Response data for verify otp: $data');
        if (data['errFlag'] == 0) {
          setState(() {
            enteredOtp = "";
            clearOtpField = true;
          });

          // Store token in secure storage
          await storage.write(key: 'token', value: data['token']);

          // If fromProfileEdit and mobile updated successfully, update mobile and navigate
          if (fromProfileEdit &&
              data['message'] == 'Mobile updated successfully') {
            // Get the new mobile from arguments (sent from previous page)
            final newMobile = args['mobile'] as String?;
            if (newMobile != null) {
              await storage.write(key: 'mobile', value: newMobile);
            }
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/profile_details',
              (route) => false,
            );
            showCustomSnackBar(
              context: context,
              message: data['message'],
              isSuccess: true,
            );
            return;
          }

          // Extract user_fields
          if (data['user_fields'] != null && data['user_fields'].isNotEmpty) {
            final userFields = data['user_fields'][0];
            final userEmail = userFields['app_user_email'];
            final userName = userFields['app_user_name'];
            final college = userFields['college'];
            final isGraduated = userFields['is_graduated'];
            final isUg = userFields['is_ug'];
            final yearOfGraduation = userFields['year_of_graduation'];

            // Store user_fields in secure storage
            await storage.write(key: 'userEmail', value: userEmail);
            await storage.write(key: 'userName', value: userName);
            await storage.write(key: 'college', value: college);
            await storage.write(
                key: 'isGraduated', value: isGraduated.toString());
            await storage.write(key: 'isUg', value: isUg.toString());
            await storage.write(
                key: 'yearOfGraduation', value: yearOfGraduation ?? '');

            Navigator.pushNamed(context, "/select_course");

            // Navigation logic
            // if (userEmail == null || userName == null || college == null) {
            //   Navigator.pushNamed(context, "/details_form");
            // } else if ((isGraduated != 1 && isUg != 1) ||
            //     (yearOfGraduation == null || yearOfGraduation.isEmpty)) {
            //   Navigator.pushNamed(context, "/select_course");
            // } else {
            //   Navigator.pushNamed(context, "/home_page");
            // }
          } else {
            Navigator.pushNamed(context, "/details_form");
          }

          showCustomSnackBar(
            context: context,
            message: data['message'],
            isSuccess: true,
          );
        } else {
          showCustomSnackBar(
            context: context,
            message: data['message'],
            isSuccess: false,
          );
        }
      } else {
        showCustomSnackBar(
          context: context,
          message: 'Failed to verify OTP. Please try again.',
          isSuccess: false,
        );
      }
    } catch (e) {
      print('Error: $e');
      showCustomSnackBar(
        context: context,
        message: 'An error occurred: $e',
        isSuccess: false,
      );
    }
  }

  Future<void> _resendOtp() async {
    if (isResendingOtp || resendCountdown > 0) return;

    setState(() {
      isResendingOtp = true;
    });

    String url = '$baseurl/app-users/login-register-mobile';

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {'mobile': mobile},
      );

      print('Resend OTP Response status: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Resend OTP Response data: $data');

        if (data['errFlag'] == 0) {
          // Reset the countdown
          setState(() {
            resendCountdown = 30;
            isResendingOtp = false;
          });

          // Restart the timer
          startResendTimer();

          showCustomSnackBar(
            context: context,
            message: 'OTP resent successfully',
            isSuccess: true,
          );
        } else {
          setState(() {
            isResendingOtp = false;
          });
          showCustomSnackBar(
            context: context,
            message: data['message'],
            isSuccess: false,
          );
        }
      } else {
        setState(() {
          isResendingOtp = false;
        });
        showCustomSnackBar(
          context: context,
          message: 'Failed to resend OTP. Please try again.',
          isSuccess: false,
        );
      }
    } catch (e) {
      setState(() {
        isResendingOtp = false;
      });
      print('Error resending OTP: $e');
      showCustomSnackBar(
        context: context,
        message: 'An error occurred while resending OTP.',
        isSuccess: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'By using our services you are agreeing to our ',
                    style: TextStyle(
                      color: Color(0xFF737373),
                      fontSize: 12,
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w400,
                      height: 1.67,
                    ),
                  ),
                  TextSpan(
                    text: 'Terms',
                    style: const TextStyle(
                      color: Color(0xFF247E80),
                      fontSize: 14,
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w500,
                      height: 1.67,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.of(context)
                            .pushNamed('/terms_and_conditions');
                      },
                    mouseCursor: SystemMouseCursors.click,
                  ),
                  const TextSpan(
                    text: ' and ',
                    style: TextStyle(
                      color: Color(0xFF737373),
                      fontSize: 12,
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w400,
                      height: 1.67,
                    ),
                  ),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: const TextStyle(
                      color: Color(0xFF247E80),
                      fontSize: 14,
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w500,
                      height: 1.67,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.of(context).pushNamed('/privacy_policy');
                      },
                    mouseCursor: SystemMouseCursors.click,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'We have sent code to your number',
              style: TextStyle(
                color: Color(0xFF737373),
                fontSize: 16,
                fontFamily: 'SF Pro Display',
                fontWeight: FontWeight.w400,
                height: 1.50,
              ),
            ),
            Text(
              mobile ?? 'Loading...',
              style: const TextStyle(
                color: Color(0xFF737373),
                fontSize: 16,
                fontFamily: 'SF Pro Display',
                fontWeight: FontWeight.w400,
                height: 1.50,
              ),
            ),
            const SizedBox(height: 12),
            OtpTextField(
              textStyle: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 24,
                fontFamily: 'SF Pro Display',
                fontWeight: FontWeight.w500,
                height: 1.25,
              ),
              fieldWidth: MediaQuery.of(context).size.width * 0.12,
              numberOfFields: 6,
              showFieldAsBox: true,
              borderRadius: BorderRadius.circular(10),
              borderWidth: 1,
              borderColor: const Color(0xFFE1E1E1),
              focusedBorderColor: const Color(0xFF247E80),
              contentPadding: const EdgeInsets.all(15),
              clearText: clearOtpField,
              onCodeChanged: (value) {
                enteredOtp = value;
              },
              onSubmit: (value) {
                enteredOtp = value;
                print('Complete OTP: $enteredOtp');
              },
            ),
            const SizedBox(height: 12),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: resendCountdown == 0 ? _resendOtp : null,
              child: Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Didn\'t receive OTP? ',
                      style: TextStyle(
                        color: Color(0xFF1A1A1A),
                        fontSize: 16,
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.w400,
                        height: 1.50,
                      ),
                    ),
                    TextSpan(
                      text: resendCountdown > 0
                          ? 'Resend in $resendCountdown'
                          : 'Resend',
                      style: TextStyle(
                        color: resendCountdown > 0
                            ? const Color(0xFF737373)
                            : const Color(0xFF247E80),
                        fontSize: 16,
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.w500,
                        height: 1.50,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                print('Entered OTP: $enteredOtp');
                if (enteredOtp.length == 6) {
                  _verifyOtp(enteredOtp);
                  setState(() {
                    clearOtpField = false;
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please enter a valid 6-digit OTP.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'SF Pro Display',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16.0)),
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: const Color(0xFF247E80),
              ),
              child: const Text(
                'Proceed',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'SF Pro Display',
                  fontWeight: FontWeight.w500,
                  height: 1.50,
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'By using our services you are agreeing to our ',
                    style: TextStyle(
                      color: Color(0xFF737373),
                      fontSize: 12,
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w400,
                      height: 1.67,
                    ),
                  ),
                  TextSpan(
                    text: 'Terms',
                    style: TextStyle(
                      color: Color(0xFF247E80),
                      fontSize: 12,
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w500,
                      height: 1.67,
                    ),
                  ),
                  TextSpan(
                    text: ' and ',
                    style: TextStyle(
                      color: Color(0xFF737373),
                      fontSize: 12,
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w400,
                      height: 1.67,
                    ),
                  ),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: Color(0xFF247E80),
                      fontSize: 12,
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w500,
                      height: 1.67,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}

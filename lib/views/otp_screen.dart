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
  bool isLoading = false;

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
    if (otp.length != 6) {
      showCustomSnackBar(
        context: context,
        message: 'Please enter a valid 6-digit OTP',
        isSuccess: false,
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    // Get navigation arguments
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    try {
      // Determine which URL to use
      String url;
      bool fromProfileEdit = args != null && args['fromProfileEdit'] == true;
      if (fromProfileEdit) {
        url = '$baseurl/app-users/confirm-update-mobile';
      } else {
        url = '$baseurl/app-users/verify-otp';
      }

      print('URL for verify otp: $url');

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
          // Clear OTP field
          setState(() {
            enteredOtp = "";
            clearOtpField = true;
          });

          // Store token in secure storage
          await storage.write(key: 'token', value: data['token']);

          // Handle profile edit case
          if (fromProfileEdit) {
            if (data['message'] == 'Mobile updated successfully') {
              // Get the new mobile from arguments
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
            }
            return;
          }

          // Handle normal OTP verification flow
          if (data['user_fields'] != null && data['user_fields'].isNotEmpty) {
            final userFields = data['user_fields'][0];
            await _processUserFields(userFields);
          } else {
            // No user fields - navigate to details form
            Navigator.pushNamed(context, "/details_form");
          }
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
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _processUserFields(Map<String, dynamic> userFields) async {
    final userEmail = userFields['app_user_email'];
    final userName = userFields['app_user_name'];
    final college = userFields['college'];
    final isGraduated = userFields['is_graduated'] ?? 0;
    final isUg = userFields['is_ug'] ?? 0;
    final yearOfGraduation = userFields['year_of_graduation']?.toString() ?? '';
    final yearOfStudy = userFields['study_year']?.toString() ?? '';
    final selectedCourseId = await storage.read(key: 'selectedCourseId');

    // Store user fields in secure storage
    await storage.write(key: 'userEmail', value: userEmail);
    await storage.write(key: 'userName', value: userName);
    await storage.write(key: 'college', value: college);
    await storage.write(key: 'isGraduated', value: isGraduated.toString());
    await storage.write(key: 'isUg', value: isUg.toString());
    await storage.write(key: 'yearOfGraduation', value: yearOfGraduation);
    await storage.write(key: 'yearOfStudy', value: yearOfStudy);
    if (selectedCourseId != null) {
      await storage.write(key: 'selectedCourseId', value: selectedCourseId);
    }

    // Determine where to navigate based on user data completeness
    if (userEmail == null || userName == null || college == null) {
      // Missing basic profile info
      Navigator.pushNamed(context, "/details_form");
    } else if (selectedCourseId == null || selectedCourseId.isEmpty) {
      // Missing course selection
      Navigator.pushNamed(context, "/select_course");
    } else if ((isGraduated == 0 && isUg == 0) ||
        (isGraduated == 1 && (yearOfGraduation.isEmpty))) {
      // Missing graduation/year of study info
      Navigator.pushNamed(context, "/select_course");
    } else {
      // All data complete - go to home
      Navigator.pushNamed(context, "/home_page");
    }
  }

  Future<void> _resendOtp() async {
    if (isResendingOtp || resendCountdown > 0) return;

    setState(() {
      isResendingOtp = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$baseurl/app-users/login-register-mobile'),
        body: {'mobile': mobile},
      );

      print('Resend OTP Response status: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['errFlag'] == 0) {
          // Reset the countdown
          setState(() {
            resendCountdown = 30;
          });
          startResendTimer();
          showCustomSnackBar(
            context: context,
            message: 'OTP resent successfully',
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
          message: 'Failed to resend OTP. Please try again.',
          isSuccess: false,
        );
      }
    } catch (e) {
      print('Error resending OTP: $e');
      showCustomSnackBar(
        context: context,
        message: 'An error occurred while resending OTP.',
        isSuccess: false,
      );
    } finally {
      setState(() {
        isResendingOtp = false;
      });
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
                  TextSpan(
                    text: 'OTP',
                    style: const TextStyle(
                      color: Color(0xFF247E80),
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'SF Pro Display',
                      height: 1.67,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.of(context)
                            .pushNamed('/terms_and_conditions');
                      },
                  ),
                  const TextSpan(
                    text: ' Verification',
                    style: TextStyle(
                      fontSize: 30,
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w400,
                      height: 1.67,
                    ),
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
                _verifyOtp(enteredOtp);
              },
            ),
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
              onPressed: isLoading
                  ? null
                  : () {
                      if (enteredOtp.length == 6) {
                        _verifyOtp(enteredOtp);
                      } else {
                        showCustomSnackBar(
                          context: context,
                          message: 'Please enter a valid 6-digit OTP',
                          isSuccess: false,
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: isLoading
                    ? const Color(0xFF247E80).withOpacity(0.7)
                    : const Color(0xFF247E80),
                disabledBackgroundColor:
                    const Color(0xFF247E80).withOpacity(0.7),
              ),
              child: isLoading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Processing...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'SF Pro Display',
                            fontWeight: FontWeight.w500,
                            height: 1.50,
                          ),
                        ),
                      ],
                    )
                  : const Text(
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
            const SizedBox(height: 12),
            const Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'By using our services you are agreeing to our \n',
                    style: TextStyle(
                      color: Color(0xFF737373),
                      fontSize: 14,
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w400,
                      height: 1.67,
                    ),
                  ),
                  TextSpan(
                    text: 'Terms',
                    style: TextStyle(
                      color: Color(0xFF247E80),
                      fontSize: 14,
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w500,
                      height: 1.67,
                    ),
                  ),
                  TextSpan(
                    text: ' and ',
                    style: TextStyle(
                      color: Color(0xFF737373),
                      fontSize: 14,
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w400,
                      height: 1.67,
                    ),
                  ),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: Color(0xFF247E80),
                      fontSize: 14,
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

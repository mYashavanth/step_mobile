import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:step_mobile/views/urlconfig.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:step_mobile/views/dry.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final storage = const FlutterSecureStorage();
  String? mobile;
  late String appUserId;
  String enteredOtp = ""; // Variable to store the entered OTP
  bool clearOtpField = false; // Flag to clear the OTP field

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    mobile = await storage.read(key: 'mobile');
    appUserId = await storage.read(key: 'appUserId') ?? '';
    setState(() {});
  }

  Future<void> _verifyOtp(String otp) async {
    String url = '$baseurl/app-users/verify-otp';

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
        print('Response data: $data'); // Debug print
        if (data['errFlag'] == 0) {
          // OTP verification successful
          setState(() {
            enteredOtp = ""; // Clear the entered OTP
            clearOtpField = true; // Set the flag to clear the OTP field
          });
          await storage.write(key: 'token', value: data['token']);
          Navigator.pushNamed(context, "/details_form");

          showCustomSnackBar(
            context: context,
            message: data['message'],
            isSuccess: true,
          );
        } else {
          // OTP verification failed

          showCustomSnackBar(
            context: context,
            message: data['message'],
            isSuccess: false,
          );
        }
      } else {
        // Server error

        showCustomSnackBar(
          context: context,
          message: 'Failed to verify OTP. Please try again.',
          isSuccess: false,
        );
      }
    } catch (e) {
      // Exception handling
      print('Error: $e'); // Debug print
      showCustomSnackBar(
        context: context,
        message: 'An error occurred: $e',
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
            const Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'OTP',
                    style: TextStyle(
                      color: Color(0xFF247E80),
                      fontSize: 30,
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w700,
                      height: 1.20,
                    ),
                  ),
                  TextSpan(
                    text: ' ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 30,
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w700,
                      height: 1.20,
                    ),
                  ),
                  TextSpan(
                    text: 'Verification',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 30,
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w400,
                      height: 1.20,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 16,
            ),
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
              mobile ??
                  'Loading...', // Display a placeholder while mobile is null
              style: const TextStyle(
                color: Color(0xFF737373),
                fontSize: 16,
                fontFamily: 'SF Pro Display',
                fontWeight: FontWeight.w400,
                height: 1.50,
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            OtpTextField(
              textStyle: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 24,
                fontFamily: 'SF Pro Display',
                fontWeight: FontWeight.w500,
                height: 1.25,
              ),
              fieldWidth: MediaQuery.of(context).size.width *
                  0.12, // Adjusted width for 6 fields
              numberOfFields: 6, // Set to 6 for a 6-digit PIN
              showFieldAsBox: true,
              borderRadius: BorderRadius.circular(10),
              borderWidth: 1,
              borderColor: const Color(0xFFE1E1E1),
              focusedBorderColor: const Color(0xFF247E80),
              contentPadding: const EdgeInsets.all(15),
              clearText: clearOtpField, // Use the clearText parameter
              onCodeChanged: (value) {
                enteredOtp = value; // Update enteredOtp on every change
              },
              onSubmit: (value) {
                enteredOtp =
                    value; // Store the complete OTP when all fields are filled
                print('Complete OTP: $enteredOtp'); // Debug print
              },
            ),
            const SizedBox(
              height: 12,
            ),
            const SizedBox(
              height: 12,
            ),
            const Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Didn’t receive OTP? ',
                    style: TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 16,
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w400,
                      height: 1.50,
                    ),
                  ),
                  TextSpan(
                    text: 'Resend',
                    style: TextStyle(
                      color: Color(0xFF247E80),
                      fontSize: 16,
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w500,
                      height: 1.50,
                    ),
                  ),
                ],
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
                print('Entered OTP: $enteredOtp'); // Debug print
                if (enteredOtp.length == 6) {
                  _verifyOtp(enteredOtp); // Validate OTP on button click
                  setState(() {
                    clearOtpField = false; // Reset the clearText flag
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

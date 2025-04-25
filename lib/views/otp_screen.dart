import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
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
            const Text(
              '+91 9481418370',
              style: TextStyle(
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
              fieldWidth: MediaQuery.of(context).size.width * 0.165,
              // fieldHeight: MediaQuery.of(context).size.width * 0.165,
              numberOfFields: 5,
              showFieldAsBox: true,
              borderRadius: BorderRadius.circular(10),
              borderWidth: 1,
              borderColor: const Color(0xFFE1E1E1),
              // hasCustomInputDecoration: true,
              // decoration: const InputDecoration(
              //   contentPadding: EdgeInsets.only(left: 8, right: 8),
              // ),
              contentPadding: const EdgeInsets.all(15),
              onSubmit: (value) {},
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
                // Handle login with mobile number
                Navigator.pushNamed(context, "/details_form");
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

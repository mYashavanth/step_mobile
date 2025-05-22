import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class Intro extends StatefulWidget {
  const Intro({super.key});

  @override
  State<Intro> createState() => _IntroState();
}

class _IntroState extends State<Intro> {
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Hero(
                  tag: "intro1",
                  child: Image(
                    image: AssetImage("assets/image/intro1.jpg"),
                  ),
                ),
                const SizedBox(height: 16),
                const Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Welcome',
                        style: TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 32,
                          fontFamily: 'SF Pro Display',
                          fontWeight: FontWeight.w400,
                          height: 0.88,
                        ),
                      ),
                      TextSpan(
                        text: ' ',
                        style: TextStyle(
                          color: Color(0xFF247E80),
                          fontSize: 32,
                          fontFamily: 'SF Pro Display',
                          fontWeight: FontWeight.w700,
                          height: 0.88,
                        ),
                      ),
                      TextSpan(
                        text: 'to',
                        style: TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 32,
                          fontFamily: 'SF Pro Display',
                          fontWeight: FontWeight.w400,
                          height: 0.88,
                        ),
                      ),
                      TextSpan(
                        text: ' ',
                        style: TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 32,
                          fontFamily: 'SF Pro Display',
                          fontWeight: FontWeight.w500,
                          height: 0.88,
                        ),
                      ),
                      TextSpan(
                        text: 'STEP!',
                        style: TextStyle(
                          color: Color(0xFF247E80),
                          fontSize: 36,
                          fontStyle: FontStyle.italic,
                          fontFamily: 'SF Pro Display',
                          fontWeight: FontWeight.w900,
                          height: 0.78,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your trusted guide to ace NEET PG, FMGE, and INI-CET',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF737373),
                    fontSize: 14,
                    fontFamily: 'SF Pro Display',
                    fontWeight: FontWeight.w400,
                    height: 1.57,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading
                      ? null // This disables the button when loading
                      : () async {
                          setState(() => _isLoading = true);
                          try {
                            await Navigator.pushNamed(context, "/mobile_login");
                          } finally {
                            if (mounted) {
                              setState(() => _isLoading = false);
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: _isLoading
                        ? const Color(0xFF247E80).withOpacity(0.7)
                        : const Color(0xFF247E80),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFF247E80)
                        .withOpacity(0.7), // Disabled state color
                    disabledForegroundColor: Colors.white.withOpacity(0.9),
                  ),
                  child: _isLoading
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
                                fontSize: 16,
                                fontFamily: 'SF Pro Display',
                                fontWeight: FontWeight.w500,
                                height: 1.50,
                              ),
                            ),
                          ],
                        )
                      : const Text(
                          'Login with mobile number',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'SF Pro Display',
                            fontWeight: FontWeight.w500,
                            height: 1.50,
                          ),
                        ),
                ),
                // const SizedBox(height: 16),
                // OutlinedButton(
                //   onPressed: () {
                //     // Handle continue with Google
                //   },
                //   style: OutlinedButton.styleFrom(
                //     minimumSize: const Size(double.infinity, 50),
                //   ),
                //   child: const Row(
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     children: [
                //       Image(image: AssetImage('assets/icons/google1.png')),
                //       SizedBox(width: 24),
                //       Text(
                //         'Continue with Google',
                //         style: TextStyle(
                //           color: Color(0xFF1A1A1A),
                //           fontSize: 16,
                //           fontFamily: 'SF Pro Display',
                //           fontWeight: FontWeight.w500,
                //           height: 1.50,
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                const SizedBox(height: 32),
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
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

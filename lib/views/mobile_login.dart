import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ghastep/views/dry.dart';
import 'dart:convert';
import 'package:ghastep/views/urlconfig.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/gestures.dart';

class MobileLogin extends StatefulWidget {
  const MobileLogin({super.key});

  @override
  State<MobileLogin> createState() => _MobileLoginState();
}

class _MobileLoginState extends State<MobileLogin> {
  final storage = const FlutterSecureStorage();
  String selectedPrefix = '+91'; // Default prefix
  final List<String> prefixes = ['+91', '+1', '+44', '+81']; // List of prefixes
  final TextEditingController mobileController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false; // Add loading state

  Future<void> _submitMobileNumber() async {
    if (_formKey.currentState!.validate() && !_isLoading) {
      setState(() => _isLoading = true);

      try {
        String mobile = mobileController.text.trim();

        final args =
            ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

        bool fromProfileEdit = args != null && args['fromProfileEdit'] == true;
        String url = fromProfileEdit
            ? '$baseurl/app-users/request-update-mobile'
            : '$baseurl/app-users/login-register-mobile';

        Map<String, String> body;

        if (fromProfileEdit) {
          String? token = await storage.read(key: 'token');
          body = {
            'newMobile': mobile,
            if (token != null) 'token': token,
          };
        } else {
          body = {'mobile': mobile};
          print('Not from profile edit, body ++++++++++++++++++++++++++++++++++++++++++++: $body');
        }

        print('URL for request mobile login page: $url, and body is: $body');

        final response = await http.post(
          Uri.parse(url),
          body: body,
        );

          final data = jsonDecode(response.body);
        print('Response data ++++++++++++++++++++++++++++++++++++++++++++++++++++: ${data}');

        if (response.statusCode == 200) {
          print('Response data ++++++++++++++: $data');

          if (data['errFlag'] == 0) {
            await storage.write(key: 'mobile', value: mobile);

            if (!fromProfileEdit) {
              await storage.write(
                key: 'appUserId',
                value: data['appUserId'].toString(),
              );
            }

            // Handle success
            if (mounted) {
              Navigator.pushNamed(
                context,
                "/otp_verify",
                arguments: {
                  'mobile': mobile,
                  'fromProfileEdit': fromProfileEdit,
                },
              );
              showCustomSnackBar(
                context: context,
                message: data['message'],
                isSuccess: true,
              );
            }
          } else {
            if (mounted) {
              showCustomSnackBar(
                  context: context, message: data['message'], isSuccess: false);
            }
          }
        } else {
          if (mounted) {
            showCustomSnackBar(
              context: context,
              message: 'Failed to send mobile number.',
              isSuccess: false,
            );
          }
        }
      } catch (e) {
        print('Error: $e');
        if (mounted) {
          showCustomSnackBar(
            context: context,
            message: 'An error occurred. Please try again.',
            isSuccess: false,
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final bool fromProfileEdit =
        args != null && args['fromProfileEdit'] == true;
    if (fromProfileEdit) {
      print('Navigated from profile edit: $fromProfileEdit');
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(40),
                  child: Hero(
                    tag: "intro1",
                    child: Image(
                      width: MediaQuery.of(context).size.width * 0.4,
                      image: const AssetImage("assets/image/intro1.jpg"),
                    ),
                  ),
                ),
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
                const SizedBox(height: 16),
                TextFormField(
                  controller: mobileController,
                  decoration: InputDecoration(
                    hintText: "Mobile number",
                    hintStyle: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 16,
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w400,
                      height: 1.50,
                    ),
                    prefixIcon: Container(
                      decoration: const ShapeDecoration(
                        color: Color(0xFFF3F4F6),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(width: 1, color: Color(0xFFF3F4F6)),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                            topLeft: Radius.circular(8),
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.all(6),
                      margin: const EdgeInsets.fromLTRB(1, 1, 8, 1),
                      child: DropdownButton<String>(
                        value: selectedPrefix,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedPrefix = newValue!;
                          });
                        },
                        items: prefixes
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: const TextStyle(
                                color: Color(0xFF1A1A1A),
                                fontSize: 16,
                                fontFamily: 'SF Pro Display',
                                fontWeight: FontWeight.w500,
                                height: 1.50,
                              ),
                            ),
                          );
                        }).toList(),
                        underline: Container(),
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(width: 1, color: Colors.red),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your mobile number';
                    } else if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                      return 'Mobile number must be 10 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitMobileNumber,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: _isLoading
                            ? const Color(0xFF247E80).withOpacity(0.7)
                            : const Color(0xFF247E80),
                        disabledBackgroundColor:
                            const Color(0xFF247E80).withOpacity(0.7),
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
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
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
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 24.0),
        child: Text.rich(
          TextSpan(
            children: [
              const TextSpan(
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
                style: const TextStyle(
                  color: Color(0xFF247E80),
                  fontSize: 14,
                  fontFamily: 'SF Pro Display',
                  fontWeight: FontWeight.w500,
                  height: 1.67,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.of(context).pushNamed('/terms_and_conditions');
                  },
                mouseCursor: SystemMouseCursors.click,
              ),
              const TextSpan(
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
      ),
    );
  }
}

import 'package:flutter/material.dart';

class MobileLogin extends StatefulWidget {
  const MobileLogin({super.key});

  @override
  State<MobileLogin> createState() => _MobileLoginState();
}

class _MobileLoginState extends State<MobileLogin> {
  String selectedPrefix = '+91'; // Default prefix
  final List<String> prefixes = ['+91', '+1', '+44', '+81']; // List of prefixes
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
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
              'Your trusted guide to ace NEET PG, FMGE, and INI-DET',
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
            TextField(
              decoration: InputDecoration(
                // contentPadding: EdgeInsets.only(left: 8),
                // labelText: 'Mobile number',
                hintText: "Mobile number",
                hintStyle: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 16,
                  fontFamily: 'SF Pro Display',
                  fontWeight: FontWeight.w400,
                  height: 1.50,
                ),
                prefixIcon: Container(
                  // clipBehavior: Clip.hardEdge,
                  decoration: const ShapeDecoration(
                    color: const Color(0xFFF3F4F6),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 1, color: Color(0xFFDDDDDD)),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                        topLeft: Radius.circular(8),
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.all(6),
                  margin: EdgeInsets.fromLTRB(1, 1, 8, 1),
                  child: DropdownButton<String>(
                    value: selectedPrefix,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedPrefix = newValue!;
                      });
                    },
                    items:
                        prefixes.map<DropdownMenuItem<String>>((String value) {
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
                    underline: Container(), // Remove the underline
                  ),
                ),
                border: OutlineInputBorder(
                  borderSide: const BorderSide(width: 1, color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.phone,
              maxLength: 10,
            ),
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
                Navigator.pushNamed(context, "/otp_verify");
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

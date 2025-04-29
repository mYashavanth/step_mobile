import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:step_mobile/views/dry.dart';
import 'package:step_mobile/views/urlconfig.dart';
import 'package:step_mobile/widgets/inputs.dart';

class DetailsForm extends StatefulWidget {
  const DetailsForm({super.key});

  @override
  _DetailsFormState createState() => _DetailsFormState();
}

class _DetailsFormState extends State<DetailsForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  String mobile = ""; // To store the mobile number
  String token = ""; // To store the token
  String? _selectedCollege;

  final List<String> _colleges = [
    'College A',
    'College B',
    'College C',
    'College D',
    'College E',
  ];

  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    mobile = await storage.read(key: 'mobile') ?? '';
    token = await storage.read(key: 'token') ?? '';
    setState(() {});
  }

  Future<void> _updateUserDetails() async {
    if (_formKey.currentState!.validate()) {
      String url = '$baseurl/app-users/update-app-user-details';

      try {
        final response = await http.post(
          Uri.parse(url),
          body: {
            'token': token,
            'name': _nameController.text.trim(),
            'email': _emailController.text.trim(),
            'college': _selectedCollege,
          },
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['errFlag'] == 0) {
            // Success
            showCustomSnackBar(
              context: context,
              message: data['message'],
              isSuccess: true,
            );
            Navigator.pushNamed(context, "/select_course");
          } else {
            // Error from backend
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
            message: 'Failed to update details. Please try again.',
            isSuccess: false,
          );
        }
      } catch (e) {
        // Exception handling
        showCustomSnackBar(
          context: context,
          message: 'An error occurred: $e',
          isSuccess: false,
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Enter your details',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 20,
            fontFamily: 'SF Pro Display',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                formInputWithLabel(
                  _nameController,
                  "Enter your name",
                  "Name",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                formInputWithLabel(
                  TextEditingController(text: mobile),
                  "Mobile Number",
                  "Mobile",
                  readOnly: true, // Make the field non-editable
                ),
                const SizedBox(height: 20),
                formInputWithLabel(
                  _emailController,
                  "Enter your email",
                  "Email",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                        .hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  "College name",
                  style: TextStyle(
                    color: Color(0xFF323836),
                    fontSize: 16,
                    fontFamily: 'SF Pro Display',
                    fontWeight: FontWeight.w400,
                    height: 1.38,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.maxFinite,
                  height: 52,
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side:
                          const BorderSide(width: 1, color: Color(0xFFDDDDDD)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFF9CA3AF),
                    ),
                    value: _selectedCollege,
                    hint: const Text('Enter college name'),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCollege = newValue;
                      });
                    },
                    items:
                        _colleges.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    underline: Container(), // Remove the underline
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: _updateUserDetails,
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
          ],
        ),
      ),
    );
  }
}

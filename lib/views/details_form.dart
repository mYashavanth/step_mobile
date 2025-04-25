import 'package:flutter/material.dart';
import 'package:step_mobile/widgets/inputs.dart';

class DetailsForm extends StatefulWidget {
  const DetailsForm({super.key});

  @override
  _DetailsFormState createState() => _DetailsFormState();
}

class _DetailsFormState extends State<DetailsForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController(text: '9480428471');
  final _emailController = TextEditingController(text: 'rohank96@gmail.com');
  final _collegeController = TextEditingController();

  String? _selectedCollege;

  final List<String> _colleges = [
    'College A',
    'College B',
    'College C',
    'College D',
    'College E',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _collegeController.dispose();
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            formInputWithLabel(_nameController, "Enter your name", "Name"),
            const SizedBox(height: 20),
            formInputWithLabel(
                _mobileController, "Enter your mobile number", "Mobile"),
            const SizedBox(height: 20),
            formInputWithLabel(
                _emailController, "Enter your main id", "Email-ID"),
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
            const SizedBox(
              height: 8,
            ),
            Container(
              // padding: EdgeInsets.symmetric(vertical: 4,horizontal: 8),
              width: double.maxFinite,
              height: 52,
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 1, color: Color(0xFFDDDDDD)),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: DropdownButton<String>(
                isExpanded: true,
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFF9CA3AF),
                ),
                // menuWidth: double.maxFinite,
                value: _selectedCollege,
                hint: const Text('Enter college name'),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCollege = newValue;
                  });
                },
                items: _colleges.map<DropdownMenuItem<String>>((String value) {
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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                // Handle login with mobile number
                Navigator.pushNamed(context, "/select_course");
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
          ],
        ),
      ),
    );
  }
}

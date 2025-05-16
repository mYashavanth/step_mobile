import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ghastep/widgets/common_widgets.dart';
import 'package:ghastep/widgets/inputs.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProfileDetails extends StatefulWidget {
  const ProfileDetails({super.key});

  @override
  State<ProfileDetails> createState() => _ProfileDetailsState();
}

class _ProfileDetailsState extends State<ProfileDetails> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController collegeController = TextEditingController();

  final ImagePicker picker = ImagePicker();
  XFile? profileImage;

  final FlutterSecureStorage storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadProfileDetailsFromStorage();
    printAllSecureStorageItems();
  }

  Future<void> _loadProfileDetailsFromStorage() async {
    final mobile = await storage.read(key: 'mobile');
    final userEmail = await storage.read(key: 'userEmail');
    final userName = await storage.read(key: 'userName');
    final college = await storage.read(key: 'college');

    setState(() {
      mobileController.text = mobile ?? '';
      emailController.text = userEmail ?? '';
      nameController.text = userName ?? '';
      collegeController.text = college ?? '';
    });
  }

  Future<void> printAllSecureStorageItems() async {
    final allItems = await storage.readAll();
    print('All items in Flutter Secure Storage:');
    allItems.forEach((key, value) {
      print('$key: $value');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
          ),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 20,
            fontFamily: 'SF Pro Display',
            fontWeight: FontWeight.w500,
            height: 1.40,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: buildUserPicWidget(),
              ),
              formInputWithLabel(nameController, "Enter your name", "Name",
                  readOnly: true), //remove read only to make it editable
              const SizedBox(
                height: 12,
              ),
              formInputWithLabel(emailController, "Enter your name", "Email id",
                  readOnly: true), //remove read only to make it editable
              const SizedBox(
                height: 12,
              ),
              formInputWithLabel(
                  mobileController, "Enter mobile number", "Mobile number",
                  readOnly: true), //remove read only to make it editable
              const SizedBox(
                height: 12,
              ),
              formInputWithLabel(
                  collegeController, "Enter your college", "College",
                  readOnly: true), //remove read only to make it editable
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(12),
        child: buildButton(context, "Save Changes", null),
      ),
    );
  }

  Widget buildUserPicWidget() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(3),
      decoration: const ShapeDecoration(
        shape: OvalBorder(),
      ),
      child: Container(
        width: 150,
        height: 150,
        decoration: const ShapeDecoration(
          color: Color(0xFFE6E6E6),
          shape: OvalBorder(),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            profileImage == null
                ? const Center(
                    child: Icon(
                      Icons.person,
                      size: 150,
                      fill: 1,
                      color: Color(0xFFC6C3BD),
                    ),
                  )
                : Container(
                    decoration: ShapeDecoration(
                      shape: const OvalBorder(),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: FileImage(
                          File(profileImage!.path),
                        ),
                      ),
                    ),
                  ),
            Positioned(
              top: 120,
              left: 103,
              child: InkWell(
                onTap: () async {
                  profileImage =
                      await picker.pickImage(source: ImageSource.gallery);
                  setState(() {});
                },
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const ShapeDecoration(
                    color: Color(0xFF31B5B9),
                    shape: OvalBorder(
                      side: BorderSide(width: 2, color: Colors.white),
                    ),
                  ),
                  child: const Icon(
                    Icons.edit_outlined,
                    size: 15,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

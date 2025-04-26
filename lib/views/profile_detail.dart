import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:step_mobile/widgets/common_widgets.dart';
import 'package:step_mobile/widgets/inputs.dart';

class ProfileDetails extends StatefulWidget {
  const ProfileDetails({super.key});

  @override
  State<ProfileDetails> createState() => _ProfileDetailsState();
}

class _ProfileDetailsState extends State<ProfileDetails> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileController = TextEditingController();

  final ImagePicker picker = ImagePicker();
  XFile? profileImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          onPressed: () {},
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
              formInputWithLabel(nameController, "Enter your name", "Name"),
              const SizedBox(
                height: 12,
              ),
              formInputWithLabel(
                  emailController, "Enter your name", "Email id"),
              const SizedBox(
                height: 12,
              ),
              formInputWithLabel(
                  emailController, "Enter mobile number", "Mobile number"),
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
                    // child: SvgPicture.asset('assets/icons/profile_filled.svg'),
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

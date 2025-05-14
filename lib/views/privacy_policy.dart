import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
          ),
        ),
        title: const Text("Privacy Policy"),
        backgroundColor: Colors.blue,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text('Effective Date: 16-04-2025\n'),
            Text(
              'Please read this Policy carefully before using our services. If you do not agree, kindly refrain from using the Platform.\n'
              'This Privacy Policy outlines how GHA STEP ("we", "us", or "our") collects, uses, discloses, and protects your personal data when you use our website (ghastep.com) or our mobile application (“Platform”). By accessing or using the Platform, you agree to this Privacy Policy.\n',
            ),
            SectionHeader(title: 'Scope'),
            BulletPoint(
                text:
                    'Applies to users who browse our Platform, register for services, interact with support, or verify their identity.'),
            BulletPoint(
                text:
                    'Definitions:\n  - "User": any individual using the Platform.\n  - "We": GHA STEP.\n  - "Platform": Website and mobile apps.\n  - "SPDI": Sensitive Personal Data (e.g., biometrics, financial info).\n  - "Personal User Info": Name, email, device info, academic details, etc.'),
            SectionHeader(title: 'Consent'),
            BulletPoint(
                text:
                    'By sharing data, you consent to its collection, use, and lawful sharing.'),
            BulletPoint(
                text:
                    'You can withdraw consent by writing to support@ghastep.com (may affect service access).'),
            SectionHeader(title: 'Information We Collect'),
            SubSectionHeader(title: 'a. Personal Data'),
            BulletPoint(
                text:
                    'Collected when you visit offices, interact with us, or register.'),
            BulletPoint(
                text:
                    'Includes: name, contact, address, college, documents/photos, device info, IP, preferences, selfies/videos.'),
            BulletPoint(text: 'SPDI is collected only with explicit consent.'),
            SubSectionHeader(title: 'b. Third-Party Sources'),
            BulletPoint(
                text:
                    'We may collect data from public sources, partners, or Facebook (if used to sign in).'),
            SectionHeader(title: 'Data Storage & Account Security'),
            BulletPoint(
                text:
                    'Usernames, specialty, and country are stored in plain text.'),
            BulletPoint(text: 'Passwords are hashed; emails encrypted.'),
            BulletPoint(
                text:
                    'Users must safeguard their credentials. We are not liable for breaches due to negligence.'),
            SectionHeader(title: 'Use of Collected Information'),
            BulletPoint(
                text:
                    'Used for login, verification, personalization, updates, analytics, and legal compliance.'),
            BulletPoint(
                text:
                    'ID data is encrypted and only accessed for verification.'),
            SectionHeader(title: 'Cookies and Web Tracking'),
            BulletPoint(text: 'Used to analyze usage and improve experience.'),
            BulletPoint(
                text:
                    'Third-party cookies may be used. Cookies can be disabled in browser settings.'),
            SectionHeader(title: 'Information Sharing and Disclosure'),
            BulletPoint(
                text:
                    'Shared with payment gateways, regulators, analytics/marketing partners, or in business transfers.'),
            BulletPoint(text: 'We do not sell or rent personal data.'),
            SectionHeader(title: 'Data Retention'),
            BulletPoint(
                text:
                    'Retained only as long as needed for legal/business purposes.'),
            BulletPoint(
                text: 'You can request deletion at support@ghastep.com.'),
            SectionHeader(title: 'Information Security'),
            BulletPoint(
                text:
                    'Includes password protection, encryption, and role-based access.'),
            BulletPoint(
                text:
                    'Despite efforts, 100% internet security cannot be guaranteed.'),
            SectionHeader(title: 'Cross-Border Data Transfer'),
            BulletPoint(
                text:
                    'We use security contracts with third parties to ensure protection during international transfers.'),
            SectionHeader(title: 'Your Choices & Opt-Out'),
            BulletPoint(
                text: 'Opt out of marketing emails or data collection.'),
            BulletPoint(text: 'Request deletion or correction of data.'),
            BulletPoint(
                text:
                    'Disable cookies through your browser. Some services may be limited as a result.'),
            SectionHeader(title: 'Third-Party Links'),
            BulletPoint(
                text:
                    'We are not responsible for third-party sites linked on our Platform. Review their privacy policies separately.'),
            SectionHeader(title: 'Employee Data'),
            BulletPoint(
                text:
                    'This policy does not apply to GHA STEP employees. Separate internal policies exist.'),
            SectionHeader(title: 'Policy Updates'),
            BulletPoint(
                text:
                    'We may revise this policy at any time. Continued use implies consent to the latest version.'),
            SectionHeader(title: 'Contact & Grievance Redressal'),
            Text('Email: support@ghastep.com / info@ghastep.com'),
            SizedBox(height: 12),
            Text(
              'This Privacy Policy is governed by the laws of India, including the Information Technology Act, 2000 and SPDI Rules, 2011.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 4.0),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}

class SubSectionHeader extends StatelessWidget {
  final String title;

  const SubSectionHeader({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 4.0),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
    );
  }
}

class BulletPoint extends StatelessWidget {
  final String text;

  const BulletPoint({required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, top: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 14)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}

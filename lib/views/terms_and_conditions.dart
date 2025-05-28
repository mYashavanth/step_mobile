import 'package:flutter/material.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

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
        title: const Text("Terms and Conditions"),
        backgroundColor: Colors.blue,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms and Conditions',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text('Last Updated: 16-04-2025\n'),
            Text(
              'Welcome to GHA STEP. These Terms and Conditions (“Terms of Use”) '
              'constitute a binding agreement between GHA STEP (a brand of GLOBAL HEALTHCARE ACADEMY PRIVATE LIMITED) '
              'and you (“User”), governing your access to and use of our website, mobile applications, digital content, '
              'and all associated services (collectively, the “Platform”).\n',
            ),
            Text(
              'By accessing, registering for, or using the Platform and services provided by GHA STEP, you acknowledge '
              'that you have read, understood, and agree to be bound by these Terms of Use.\n',
            ),
            SectionHeader(title: '1. User Eligibility and Registration'),
            BulletPoint(
                text:
                    'Users must be at least 18 years old or access the platform under the supervision of a legal guardian.'),
            BulletPoint(
                text:
                    'Users must be pursuing or have completed a recognized medical degree to be eligible for paid subscriptions.'),
            BulletPoint(
                text:
                    'Registration requires accurate information including email ID, phone number, and KYC documentation (Aadhar, Passport, etc.).'),
            BulletPoint(
                text:
                    'Only one user per subscription is allowed. Sharing account details will lead to termination.'),
            SectionHeader(title: '2. Services and Access'),
            BulletPoint(
                text:
                    'Access to NEET PG preparation resources like video lectures, question banks, notes, and test series.'),
            BulletPoint(
                text:
                    'Services are offered on Android, iOS, and Web with system requirements specified.'),
            BulletPoint(
                text:
                    'GHA STEP may modify, update, or discontinue any service without prior notice.'),
            SectionHeader(title: '3. Fair Usage and Restrictions'),
            BulletPoint(text: 'Maximum usage: 1200 hours per subscription.'),
            BulletPoint(
                text:
                    'Account suspension for more than 2 devices, rooted/jailbroken use, emulators, or screen recording.'),
            BulletPoint(
                text:
                    'Content is strictly for personal use. Reproduction or resale is prohibited.'),
            SectionHeader(title: '4. Payments and Refunds'),
            BulletPoint(
                text: 'Prices include GST @18% and may change without notice.'),
            BulletPoint(
                text:
                    'No responsibility for third-party payment gateway failures.'),
            BulletPoint(
                text: 'No refunds unless decided otherwise by GHA STEP.'),
            BulletPoint(text: 'Notes are bundled only with video courses.'),
            BulletPoint(
                text:
                    'Approved Refunds will be credited to your original method of payment within 8-10 business days.'),
            SectionHeader(title: '5. Privacy and Data Use'),
            BulletPoint(
                text:
                    'Data is securely stored per Indian IT laws and Privacy Policy.'),
            BulletPoint(text: 'Anonymized data may be used for improvement.'),
            BulletPoint(
                text: 'Account deletion requests via: support@ghastep.com.'),
            SectionHeader(title: '6. Content and Intellectual Property'),
            BulletPoint(
                text:
                    'All platform materials are GHA STEP’s intellectual property.'),
            BulletPoint(text: 'Unauthorized use may lead to legal action.'),
            BulletPoint(
                text: 'Testimonials are real but do not guarantee results.'),
            SectionHeader(title: '7. User Conduct'),
            BulletPoint(
                text: 'Respectful language must be used on all channels.'),
            BulletPoint(
                text: 'Do not post illegal, harassing, or infringing content.'),
            BulletPoint(
                text: 'No impersonation, malware, or unauthorized access.'),
            SectionHeader(title: '8. Modifications and Termination'),
            BulletPoint(
                text:
                    'Terms may change anytime; continued use implies acceptance.'),
            BulletPoint(
                text: 'Accounts may be terminated for violations or fraud.'),
            SectionHeader(title: '9. Limitation of Liability'),
            BulletPoint(text: 'Not liable for device/internet issues.'),
            BulletPoint(text: 'No responsibility for account misuse.'),
            BulletPoint(
                text: 'No liability for rank, exam outcome, or advice.'),
            SectionHeader(title: '10. Jurisdiction and Grievance Redressal'),
            BulletPoint(
                text:
                    'Governing law: India. Jurisdiction: Courts of Bangalore.'),
            BulletPoint(
                text:
                    'For grievances, email: support@ghastep.com / info@ghastep.com.'),
            SizedBox(height: 20),
            Text('Contact Details',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text('📍 Website: https://www.ghastep.com'),
            Text('📧 Email: support@ghastep.com / info@ghastep.com'),
            Text('📞 Contact: +91 89517 70313'),
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

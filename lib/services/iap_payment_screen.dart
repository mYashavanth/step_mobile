import 'package:flutter/material.dart';
import 'iap_service.dart';

class IAPPage extends StatefulWidget {
  const IAPPage({super.key});

  @override
  State<IAPPage> createState() => _IAPPageState();
}

class _IAPPageState extends State<IAPPage> {
  final IAPService iapService = IAPService();

  @override
  void initState() {
    super.initState();
    iapService.initConnection();
  }

  @override
  void dispose() {
    iapService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('In-App Purchase')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                iapService.buyProduct();
              },
              child: const Text('Buy Premium Access'),
            ),
            ElevatedButton(
              onPressed: () {
                iapService.restorePurchases();
              },
              child: const Text('Restore Purchases'),
            ),
          ],
        ),
      ),
    );
  }
}

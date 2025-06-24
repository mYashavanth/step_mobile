import 'package:flutter/material.dart';
import 'iap_service.dart';

class IAPPage extends StatefulWidget {
  const IAPPage({super.key});

  @override
  State<IAPPage> createState() => _IAPPageState();
}

class _IAPPageState extends State<IAPPage> {
  final IAPService iapService = IAPService();
  bool _isPremiumUser = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() => _isLoading = true);
    await iapService.initConnection();
    // Check if user already has premium access
    final hasPremium = await iapService.checkPurchases();
    setState(() {
      _isPremiumUser = hasPremium;
      _isLoading = false;
    });
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isPremiumUser)
                    const Text(
                      'Premium Access Active!',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green),
                    )
                  else
                    ElevatedButton(
                      onPressed: () async {
                        setState(() => _isLoading = true);
                        final success = await iapService.buyProduct();
                        if (success) {
                          setState(() => _isPremiumUser = true);
                        }
                        setState(() => _isLoading = false);
                      },
                      child: const Text('Buy Premium Access'),
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      setState(() => _isLoading = true);
                      final success = await iapService.restorePurchases();
                      if (success) {
                        setState(() => _isPremiumUser = true);
                      }
                      setState(() => _isLoading = false);
                    },
                    child: const Text('Restore Purchases'),
                  ),
                  const SizedBox(height: 20),
                  if (_isLoading) const CircularProgressIndicator(),
                ],
              ),
            ),
    );
  }
}

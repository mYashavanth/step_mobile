import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class IAPService {
  static final IAPService _instance = IAPService._internal();
  factory IAPService() => _instance;
  IAPService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  final String _productID = 'stepneetpg'; // Match App Store product ID
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  bool isAvailable = false;
  List<ProductDetails> products = [];
  List<PurchaseDetails> _pastPurchases = [];

  Future<void> initConnection() async {
    isAvailable = await _iap.isAvailable();
    if (!isAvailable) {
      debugPrint('IAP not available');
      return;
    }

    await _getProducts();

    _subscription = _iap.purchaseStream.listen(
      (List<PurchaseDetails> purchaseDetailsList) {
        _onPurchaseUpdated(purchaseDetailsList);
        _pastPurchases.addAll(purchaseDetailsList
            .where((purchase) => purchase.status == PurchaseStatus.purchased));
      },
      onDone: () => _subscription.cancel(),
      onError: (error) {
        debugPrint('Purchase error: $error');
      },
    );
  }

  Future<void> _getProducts() async {
    final response = await _iap.queryProductDetails({_productID});
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('Product not found: ${response.notFoundIDs}');
    }
    products = response.productDetails;
  }

  Future<bool> buyProduct() async {
    if (products.isEmpty) {
      debugPrint('No products available');
      return false;
    }

    try {
      final purchaseParam = PurchaseParam(productDetails: products.first);
      final purchaseResult =
          await _iap.buyNonConsumable(purchaseParam: purchaseParam);

      return purchaseResult != null;
    } catch (e) {
      debugPrint('Purchase failed: $e');
      return false;
    }
  }

  void _onPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    for (var purchaseDetails in purchaseDetailsList) {
      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          debugPrint('Purchase pending...');
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _verifyAndComplete(purchaseDetails);
          break;
        case PurchaseStatus.error:
          debugPrint('Error: ${purchaseDetails.error}');
          if (purchaseDetails.error != null) {
            await _iap.completePurchase(purchaseDetails);
          }
          break;
        default:
          break;
      }
    }
  }

  Future<void> _verifyAndComplete(PurchaseDetails purchaseDetails) async {
    // Verify receipt with your backend or Apple server
    final bool isValid = await _verifyReceipt(purchaseDetails);

    if (isValid && purchaseDetails.pendingCompletePurchase) {
      await _iap.completePurchase(purchaseDetails);
    }

    debugPrint('Purchase successful: ${purchaseDetails.productID}');
  }

  Future<bool> _verifyReceipt(PurchaseDetails purchaseDetails) async {
    try {
      // First try production verification
      bool isValid = await _verifyWithServer(
          purchaseDetails.verificationData.serverVerificationData,
          isSandbox: false);

      // If production fails with 21007 (sandbox receipt in production), try sandbox
      if (!isValid) {
        isValid = await _verifyWithServer(
            purchaseDetails.verificationData.serverVerificationData,
            isSandbox: true);
      }

      return isValid;
    } catch (e) {
      debugPrint('Receipt verification error: $e');
      return false;
    }
  }

  Future<bool> _verifyWithServer(String receiptData,
      {required bool isSandbox}) async {
    // Implement your server verification logic here
    // Use isSandbox to determine which endpoint to use
    // Return true if receipt is valid
    return true; // Placeholder - implement actual verification
  }

  void dispose() {
    _subscription.cancel();
  }

  Future<bool> restorePurchases() async {
    try {
      await _iap.restorePurchases();
      debugPrint('Restore initiated.');
      return true;
    } catch (e) {
      debugPrint('Restore failed: $e');
      return false;
    }
  }

  Future<bool> checkPurchases() async {
    // Check our locally tracked purchases first
    if (_pastPurchases.any((p) =>
        p.productID == _productID &&
        (p.status == PurchaseStatus.purchased ||
            p.status == PurchaseStatus.restored))) {
      return true;
    }

    // For iOS, restorePurchases will trigger the purchase stream
    // with any existing purchases
    return false;
  }
}

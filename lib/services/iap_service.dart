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

  Future<void> initConnection() async {
    isAvailable = await _iap.isAvailable();
    if (!isAvailable) {
      debugPrint('IAP not available');
      return;
    }

    await _getProducts();

    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdated,
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

  void buyProduct() {
    if (products.isEmpty) return;

    final purchaseParam = PurchaseParam(productDetails: products.first);
    _iap.buyConsumable(purchaseParam: purchaseParam); // Or buyNonConsumable()
  }

  void _onPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchaseDetails in purchaseDetailsList) {
      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          debugPrint('Purchase pending...');
          break;
        case PurchaseStatus.purchased:
          _verifyAndComplete(purchaseDetails);
          break;
        case PurchaseStatus.error:
          debugPrint('Error: ${purchaseDetails.error}');
          break;
        case PurchaseStatus.restored:
          _verifyAndComplete(purchaseDetails);
          break;
        default:
          break;
      }
    }
  }

  Future<void> _verifyAndComplete(PurchaseDetails purchaseDetails) async {
    // TODO: Verify receipt with your backend or Apple server here

    if (purchaseDetails.pendingCompletePurchase) {
      await _iap.completePurchase(purchaseDetails);
    }

    debugPrint('Purchase successful: ${purchaseDetails.productID}');
  }

  void dispose() {
    _subscription.cancel();
  }

  Future<void> restorePurchases() async {
    try {
      await _iap.restorePurchases();
      debugPrint('Restore initiated.');
    } catch (e) {
      debugPrint('Restore failed: $e');
    }
  }
}

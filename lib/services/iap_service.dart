import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IAPManager extends ChangeNotifier {
  final InAppPurchase _iap = InAppPurchase.instance;
  static const String _proProductId = 'com.chat.jarvis_copi';
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  bool _isPro = false;
  DateTime? _purchaseTimestamp;
  bool _canPurchase = true;

  bool get isPro => _isPro;
  bool get canPurchase => _canPurchase;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isPro = prefs.getBool('is_pro_user') ?? false;
    final purchaseTimeMillis = prefs.getInt('purchase_timestamp');
    if (purchaseTimeMillis != null) {
      _purchaseTimestamp = DateTime.fromMillisecondsSinceEpoch(purchaseTimeMillis);
      _checkPurchaseExpiry();
    } else {
      _canPurchase = true;
    }

    final bool available = await _iap.isAvailable();
    if (!available) {
      print('IAP not available');
      return;
    }

    // Listen to purchase updates
    final Stream<List<PurchaseDetails>> purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen(
          (purchaseDetailsList) {
        _listenToPurchaseUpdated(purchaseDetailsList);
      },
      onDone: () => _subscription?.cancel(),
      onError: (error) => print('Purchase error: $error'),
    );

    // Restore purchases
    await _restorePurchases();
  }

  void _checkPurchaseExpiry() {
    if (_purchaseTimestamp != null) {
      final expiryDate = _purchaseTimestamp!.add(Duration(days: 30));
      final now = DateTime.now();
      if (now.isAfter(expiryDate)) {
        _isPro = false;
        _canPurchase = true;
        _purchaseTimestamp = null;
        _savePurchaseState();
      } else {
        _canPurchase = false;
      }
      notifyListeners();
    }
  }

  Future<void> _savePurchaseState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_pro_user', _isPro);
    if (_purchaseTimestamp != null) {
      await prefs.setInt('purchase_timestamp', _purchaseTimestamp!.millisecondsSinceEpoch);
    } else {
      await prefs.remove('purchase_timestamp');
    }
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        if (purchaseDetails.productID == _proProductId) {
          await _verifyPurchase(purchaseDetails);
          _isPro = true;
          _purchaseTimestamp = DateTime.now();
          _canPurchase = false;
          await _savePurchaseState();
          notifyListeners();
        }
      }

      if (purchaseDetails.status == PurchaseStatus.error) {
        print('Purchase error: ${purchaseDetails.error}');
      }

      if (purchaseDetails.pendingCompletePurchase) {
        await _iap.completePurchase(purchaseDetails);
      }
    }
  }

  Future<void> _restorePurchases() async {
    await _iap.restorePurchases();
  }

  Future<bool> buyProUpgrade() async {
    final ProductDetailsResponse response =
    await _iap.queryProductDetails({_proProductId});
    if (response.productDetails.isEmpty) {
      print('Product not found');
      return false;
    }

    final ProductDetails productDetails = response.productDetails.first;
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);
    return await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    // Save PRO status into SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_pro_user', true);
    // TODO: If you have a backend, send purchaseDetails.verificationData for verification
    print('Purchase verified for ${purchaseDetails.productID}');
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
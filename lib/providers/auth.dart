import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hirome_rental_shop_web/common/functions.dart';
import 'package:hirome_rental_shop_web/models/cart.dart';
import 'package:hirome_rental_shop_web/models/product.dart';
import 'package:hirome_rental_shop_web/models/shop.dart';
import 'package:hirome_rental_shop_web/services/cart.dart';
import 'package:hirome_rental_shop_web/services/shop.dart';
import 'package:hirome_rental_shop_web/services/shop_login.dart';

enum AuthStatus {
  authenticated,
  uninitialized,
  authenticating,
  unauthenticated,
}

class Auth2Provider with ChangeNotifier {
  AuthStatus _status = AuthStatus.uninitialized;
  AuthStatus get status => _status;
  FirebaseAuth? auth;
  User? _authUser;
  User? get authUser => _authUser;
  CartService cartService = CartService();
  ShopService shopService = ShopService();
  ShopLoginService shopLoginService = ShopLoginService();
  ShopModel? _shop;
  List<CartModel> _carts = [];
  ShopModel? get shop => _shop;
  List<CartModel> get carts => _carts;

  TextEditingController number = TextEditingController();
  TextEditingController requestName = TextEditingController();

  void clearController() {
    number.clear();
    requestName.clear();
  }

  Auth2Provider.initialize() : auth = FirebaseAuth.instance {
    auth?.authStateChanges().listen(_onStateChanged);
  }

  Future<String?> signIn() async {
    String? error;
    String numberText = number.text.trim();
    String requestNameText = requestName.text.trim();
    if (numberText == '') return '店舗番号をご入力ください';
    if (requestNameText == '') return 'あなたの名前をご入力ください';
    try {
      _status = AuthStatus.authenticating;
      notifyListeners();
      await auth?.signInAnonymously().then((value) async {
        _authUser = value.user;
        ShopModel? tmpShop = await shopService.select(number: numberText);
        if (tmpShop != null) {
          _shop = tmpShop;
          DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
          final webInfo = await deviceInfo.webBrowserInfo;
          String deviceName = webInfo.browserName.name;
          shopLoginService.create({
            'id': value.user?.uid,
            'shopNumber': tmpShop.number,
            'shopName': tmpShop.name,
            'requestName': requestNameText,
            'deviceName': deviceName,
            'accept': false,
            'acceptedAt': DateTime.now(),
            'createdAt': DateTime.now(),
          });
          await setPrefsString('shopNumber', tmpShop.number);
        } else {
          await auth?.signOut();
          error = 'ログインに失敗しました';
        }
      });
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      error = 'ログインに失敗しました';
    }
    return error;
  }

  Future<String?> updateFavorites(List<String> favorites) async {
    String? error;
    try {
      shopService.update({
        'id': shop?.id,
        'favorites': favorites,
      });
    } catch (e) {
      error = 'お気に入り設定に失敗しました';
    }
    return error;
  }

  Future deleteShopLogin() async {
    shopLoginService.delete({'id': _authUser?.uid});
  }

  Future signOut() async {
    await auth?.signOut();
    _status = AuthStatus.unauthenticated;
    await allRemovePrefs();
    _shop = null;
    _carts = [];
    notifyListeners();
    return Future.delayed(Duration.zero);
  }

  Future _onStateChanged(User? authUser) async {
    if (authUser == null) {
      _status = AuthStatus.unauthenticated;
    } else {
      _authUser = authUser;
      String? tmpShopNumber = await getPrefsString('shopNumber');
      ShopModel? tmpShop = await shopService.select(number: tmpShopNumber);
      if (tmpShop == null) {
        _status = AuthStatus.unauthenticated;
      } else {
        _shop = tmpShop;
        await initCarts();
        _status = AuthStatus.authenticated;
      }
    }
    notifyListeners();
  }

  Future initCarts() async {
    _carts = await cartService.get();
    notifyListeners();
  }

  Future addCarts(ProductModel product, int requestQuantity) async {
    await cartService.add(product, requestQuantity);
  }

  Future removeCart(CartModel cart) async {
    await cartService.remove(cart);
  }

  Future clearCart() async {
    await cartService.clear();
  }
}

import 'dart:html';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:hirome_rental_shop_web/common/functions.dart';
import 'package:hirome_rental_shop_web/models/cart.dart';
import 'package:hirome_rental_shop_web/models/center.dart';
import 'package:hirome_rental_shop_web/models/order.dart';
import 'package:hirome_rental_shop_web/models/shop.dart';
import 'package:hirome_rental_shop_web/services/center.dart';
import 'package:hirome_rental_shop_web/services/messaging.dart';
import 'package:hirome_rental_shop_web/services/order.dart';

class OrderProvider with ChangeNotifier {
  CenterService centerService = CenterService();
  MessagingService messagingService = MessagingService();
  OrderService orderService = OrderService();

  DateTime searchStart = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  );
  DateTime searchEnd = DateTime(
    DateTime.now().year,
    DateTime.now().month + 1,
    1,
  ).add(const Duration(days: -1));

  void searchChange(DateTime start, DateTime end) {
    searchStart = start;
    searchEnd = end;
    notifyListeners();
  }

  Future<String?> create({
    ShopModel? shop,
    List<CartModel>? carts,
    String createdUserName = '',
  }) async {
    String? error;
    if (shop == null) return '注文に失敗しました';
    if (carts == null) return '注文に失敗しました';
    if (carts.isEmpty) return '注文に失敗しました';
    try {
      String id = orderService.id();
      String dateTime = dateText('yyyyMMddHHmmss', DateTime.now());
      String number = '${shop.number}-$dateTime';
      List<Map> newCarts = [];
      for (CartModel cart in carts) {
        newCarts.add(cart.toMap());
      }
      orderService.create({
        'id': id,
        'number': number,
        'shopId': shop.id,
        'shopNumber': shop.number,
        'shopName': shop.name,
        'shopInvoiceName': shop.invoiceName,
        'carts': newCarts,
        'status': 0,
        'createdUserName': createdUserName,
        'updatedAt': DateTime.now(),
        'createdAt': DateTime.now(),
      });
      List<CenterModel> centers = await centerService.selectList();
      for (CenterModel center in centers) {
        messagingService.fcmSend(center.token);
      }
    } catch (e) {
      error = '注文に失敗しました';
    }
    return error;
  }

  Future<String?> reCreate(OrderModel order) async {
    String? error;
    try {
      String id = orderService.id();
      String dateTime = dateText('yyyyMMddHHmmss', DateTime.now());
      String number = '${order.shopNumber}-$dateTime';
      List<Map> newCarts = [];
      for (CartModel cart in order.carts) {
        newCarts.add(cart.toMap());
      }
      orderService.create({
        'id': id,
        'number': number,
        'shopId': order.shopId,
        'shopNumber': order.shopNumber,
        'shopName': order.shopName,
        'shopInvoiceName': order.shopInvoiceName,
        'carts': newCarts,
        'status': 0,
        'createdUserName': order.createdUserName,
        'updatedAt': DateTime.now(),
        'createdAt': DateTime.now(),
      });
      List<CenterModel> centers = await centerService.selectList();
      for (CenterModel center in centers) {
        messagingService.fcmSend(center.token);
      }
    } catch (e) {
      error = '再注文に失敗しました';
    }
    return error;
  }

  Future<String?> cancel(OrderModel order) async {
    String? error;
    try {
      orderService.update({
        'id': order.id,
        'status': 9,
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      error = 'キャンセルに失敗しました';
    }
    return error;
  }

  Future csvDownload(DateTime month, String shopNumber) async {
    final fileName = '${dateText('yyyyMMddHHmmss', DateTime.now())}.csv';
    List<String> header = [
      '注文日時',
      '注文番号',
      '発注元店舗番号',
      '発注元店舗名',
      '商品番号',
      '商品名',
      '単価',
      '単位',
      '希望数量',
      '納品数量',
      '合計金額',
      'ステータス',
    ];
    DateTime monthStart = DateTime(month.year, month.month, 1);
    DateTime monthEnd = DateTime(month.year, month.month + 1, 1).add(
      const Duration(days: -1),
    );
    List<OrderModel> orders = await orderService.selectList(
      shopNumber: shopNumber,
      searchStart: monthStart,
      searchEnd: monthEnd,
    );
    List<List<String>> rows = [];
    for (OrderModel order in orders) {
      for (CartModel cart in order.carts) {
        List<String> row = [];
        row.add(dateText('yyyy/MM/dd HH:mm', order.createdAt));
        row.add(order.number);
        row.add(order.shopNumber);
        row.add(order.shopName);
        row.add(cart.number);
        row.add(cart.name);
        row.add('${cart.price}');
        row.add(cart.unit);
        row.add('${cart.requestQuantity}');
        row.add('${cart.deliveryQuantity}');
        int totalPrice = cart.price * cart.deliveryQuantity;
        row.add('$totalPrice');
        row.add(order.statusText());
        rows.add(row);
      }
    }
    String csv = const ListToCsvConverter().convert(
      [header, ...rows],
    );
    String bom = '\uFEFF';
    String csvText = bom + csv;
    csvText = csvText.replaceAll('[', '');
    csvText = csvText.replaceAll(']', '');
    AnchorElement(href: 'data:text/plain;charset=utf-8,$csvText')
      ..setAttribute('download', fileName)
      ..click();
  }
}

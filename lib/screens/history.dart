import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hirome_rental_shop_web/common/functions.dart';
import 'package:hirome_rental_shop_web/common/style.dart';
import 'package:hirome_rental_shop_web/models/order.dart';
import 'package:hirome_rental_shop_web/providers/auth.dart';
import 'package:hirome_rental_shop_web/providers/order.dart';
import 'package:hirome_rental_shop_web/services/order.dart';
import 'package:hirome_rental_shop_web/widgets/cart_list.dart';
import 'package:hirome_rental_shop_web/widgets/custom_sm_button.dart';
import 'package:hirome_rental_shop_web/widgets/date_range_field.dart';
import 'package:hirome_rental_shop_web/widgets/history_list_tile.dart';
import 'package:provider/provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  OrderService orderService = OrderService();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);

    return Scaffold(
      backgroundColor: kWhiteColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: kWhiteColor,
        title: Text(
          '${authProvider.shop?.name} : 注文履歴',
          style: const TextStyle(color: kBlackColor),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: kGreenColor,
              ),
              onPressed: () {},
              child: const Text(
                'ダウンロード',
                style: TextStyle(color: kWhiteColor),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: kBlackColor),
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 400),
        child: Column(
          children: [
            DateRangeField(
              start: orderProvider.searchStart,
              end: orderProvider.searchEnd,
              onTap: () async {
                var selected = await showDataRangePickerDialog(
                  context,
                  orderProvider.searchStart,
                  orderProvider.searchEnd,
                );
                if (selected != null &&
                    selected.first != null &&
                    selected.last != null) {
                  orderProvider.searchChange(selected.first!, selected.last!);
                }
              },
            ),
            const Divider(height: 0, color: kGreyColor),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: orderService.streamList(
                  shop: authProvider.shop!,
                  searchStart: orderProvider.searchStart,
                  searchEnd: orderProvider.searchEnd,
                ),
                builder: (context, snapshot) {
                  List<OrderModel> orders = [];
                  if (snapshot.hasData) {
                    for (DocumentSnapshot<Map<String, dynamic>> doc
                        in snapshot.data!.docs) {
                      orders.add(OrderModel.fromSnapshot(doc));
                    }
                  }
                  if (orders.isEmpty) {
                    return const Center(
                      child: Text('注文がありません'),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      OrderModel order = orders[index];
                      return HistoryListTile(
                        order: order,
                        onTap: () => showDialog(
                          context: context,
                          builder: (context) => OrderDetailsDialog(
                            orderProvider: orderProvider,
                            order: order,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderDetailsDialog extends StatefulWidget {
  final OrderProvider orderProvider;
  final OrderModel order;

  const OrderDetailsDialog({
    required this.orderProvider,
    required this.order,
    super.key,
  });

  @override
  State<OrderDetailsDialog> createState() => _OrderDetailsDialogState();
}

class _OrderDetailsDialogState extends State<OrderDetailsDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(16),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '注文日時 : ${dateText('yyyy/MM/dd HH:mm', widget.order.createdAt)}',
              style: const TextStyle(
                color: kGreyColor,
                fontSize: 16,
              ),
            ),
            Text(
              'ステータス : ${widget.order.statusText()}',
              style: const TextStyle(
                color: kGreyColor,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '注文した商品 : ',
              style: TextStyle(
                color: kGreyColor,
                fontSize: 16,
              ),
            ),
            Column(
              children: widget.order.carts.map((cart) {
                return CartList(cart: cart, viewDelivery: true);
              }).toList(),
            ),
            const SizedBox(height: 16),
            widget.order.status == 0
                ? CustomSmButton(
                    label: 'キャンセルする',
                    labelColor: kWhiteColor,
                    backgroundColor: kOrangeColor,
                    onPressed: () async {
                      String? error =
                          await widget.orderProvider.cancel(widget.order);
                      if (error != null) {
                        if (!mounted) return;
                        showMessage(context, error, false);
                        return;
                      }
                      if (!mounted) return;
                      showMessage(context, 'キャンセルに成功しました', true);
                      Navigator.pop(context);
                    },
                  )
                : Container(),
            widget.order.status == 1
                ? CustomSmButton(
                    label: '再注文する',
                    labelColor: kWhiteColor,
                    backgroundColor: kBlueColor,
                    onPressed: () async {
                      String? error =
                          await widget.orderProvider.reCreate(widget.order);
                      if (error != null) {
                        if (!mounted) return;
                        showMessage(context, error, false);
                        return;
                      }
                      if (!mounted) return;
                      showMessage(context, '再注文に成功しました', true);
                      Navigator.pop(context);
                    },
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}

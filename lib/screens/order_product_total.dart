import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hirome_rental_shop_web/common/functions.dart';
import 'package:hirome_rental_shop_web/common/style.dart';
import 'package:hirome_rental_shop_web/models/cart.dart';
import 'package:hirome_rental_shop_web/models/order.dart';
import 'package:hirome_rental_shop_web/models/product.dart';
import 'package:hirome_rental_shop_web/providers/auth.dart';
import 'package:hirome_rental_shop_web/providers/order.dart';
import 'package:hirome_rental_shop_web/services/order.dart';
import 'package:hirome_rental_shop_web/services/product.dart';
import 'package:hirome_rental_shop_web/widgets/date_range_field.dart';
import 'package:hirome_rental_shop_web/widgets/order_product_total_list.dart';
import 'package:provider/provider.dart';

class OrderProductTotalScreen extends StatefulWidget {
  const OrderProductTotalScreen({super.key});

  @override
  State<OrderProductTotalScreen> createState() =>
      _OrderProductTotalScreenState();
}

class _OrderProductTotalScreenState extends State<OrderProductTotalScreen> {
  OrderService orderService = OrderService();
  ProductService productService = ProductService();
  List<ProductModel> products = [];

  void _init() async {
    List<ProductModel> tmpProducts = await productService.selectList();
    setState(() {
      products = tmpProducts;
    });
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

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
          '${authProvider.shop?.name} : 注文商品集計',
          style: const TextStyle(color: kBlackColor),
        ),
        actions: [
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
                  var diff = selected.last!.difference(selected.first!);
                  int diffDays = diff.inDays;
                  if (diffDays > 31) {
                    if (!mounted) return;
                    showMessage(context, '1ヵ月以上の範囲が選択されています', false);
                    return;
                  }
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
                  Map<String, int> totalMap = {};
                  if (snapshot.hasData) {
                    for (DocumentSnapshot<Map<String, dynamic>> doc
                        in snapshot.data!.docs) {
                      OrderModel order = OrderModel.fromSnapshot(doc);
                      if (order.status == 1) {
                        for (CartModel cart in order.carts) {
                          totalMap[cart.number] = cart.deliveryQuantity;
                        }
                      }
                    }
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      ProductModel product = products[index];
                      return OrderProductTotalList(
                        product: product,
                        total: totalMap[product.number],
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hirome_rental_shop_web/common/functions.dart';
import 'package:hirome_rental_shop_web/common/style.dart';
import 'package:hirome_rental_shop_web/models/product.dart';
import 'package:hirome_rental_shop_web/providers/auth.dart';
import 'package:hirome_rental_shop_web/services/product.dart';
import 'package:hirome_rental_shop_web/widgets/product_checkbox_list_tile.dart';

class FavoritesScreen extends StatefulWidget {
  final Auth2Provider authProvider;

  const FavoritesScreen({
    required this.authProvider,
    super.key,
  });

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  ProductService productService = ProductService();
  List<String> favorites = [];

  void _init() {
    setState(() {
      favorites = widget.authProvider.shop?.favorites ?? [];
    });
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhiteColor,
      appBar: AppBar(
        backgroundColor: kWhiteColor,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left,
            color: kBlackColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${widget.authProvider.shop?.name} : 注文商品設定',
          style: const TextStyle(color: kBlackColor),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              String? error = await widget.authProvider.updateFavorites(
                favorites,
              );
              if (error != null) {
                if (!mounted) return;
                showMessage(context, error, false);
                return;
              }
              if (!mounted) return;
              showMessage(context, '注文商品設定を変更しました', true);
            },
            child: const Text('保存'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 400),
        child: Column(
          children: [
            const Text(
              'チェックをいれた商品が注文可能になります',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1, color: kGreyColor),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: productService.streamList(),
                builder: (context, snapshot) {
                  List<ProductModel> products = [];
                  if (snapshot.hasData) {
                    for (DocumentSnapshot<Map<String, dynamic>> doc
                        in snapshot.data!.docs) {
                      products.add(ProductModel.fromSnapshot(doc));
                    }
                  }
                  if (products.isEmpty) {
                    return const Center(
                      child: Text('商品がありません'),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      ProductModel product = products[index];
                      var contain = favorites.where((e) => e == product.number);
                      return ProductCheckboxListTile(
                        product: product,
                        value: contain.isNotEmpty,
                        onChanged: (value) {
                          setState(() {
                            if (contain.isEmpty) {
                              favorites.add(product.number);
                            } else {
                              favorites.remove(product.number);
                            }
                          });
                        },
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hirome_rental_shop_web/common/functions.dart';
import 'package:hirome_rental_shop_web/common/style.dart';
import 'package:hirome_rental_shop_web/models/cart.dart';
import 'package:hirome_rental_shop_web/models/product.dart';
import 'package:hirome_rental_shop_web/models/shop_login.dart';
import 'package:hirome_rental_shop_web/providers/auth.dart';
import 'package:hirome_rental_shop_web/screens/history.dart';
import 'package:hirome_rental_shop_web/screens/login.dart';
import 'package:hirome_rental_shop_web/screens/order_cart.dart';
import 'package:hirome_rental_shop_web/screens/order_product_total.dart';
import 'package:hirome_rental_shop_web/screens/settings.dart';
import 'package:hirome_rental_shop_web/services/product.dart';
import 'package:hirome_rental_shop_web/services/shop_login.dart';
import 'package:hirome_rental_shop_web/widgets/animation_background.dart';
import 'package:hirome_rental_shop_web/widgets/cart_next_button.dart';
import 'package:hirome_rental_shop_web/widgets/custom_header.dart';
import 'package:hirome_rental_shop_web/widgets/custom_image.dart';
import 'package:hirome_rental_shop_web/widgets/custom_lg_button.dart';
import 'package:hirome_rental_shop_web/widgets/link_text.dart';
import 'package:hirome_rental_shop_web/widgets/login_title.dart';
import 'package:hirome_rental_shop_web/widgets/product_card.dart';
import 'package:hirome_rental_shop_web/widgets/quantity_button.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ProductService productService = ProductService();
  ShopLoginService shopLoginService = ShopLoginService();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<Auth2Provider>(context);

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: shopLoginService.streamList(authProvider.authUser?.uid),
      builder: (context, snapshot) {
        ShopLoginModel? shopLogin;
        if (snapshot.hasData) {
          shopLogin = ShopLoginModel.fromSnapshot(snapshot.requireData);
        }
        if (shopLogin == null || shopLogin.id == '') {
          return Scaffold(
            backgroundColor: kRedColor,
            body: Stack(
              children: [
                const AnimationBackground(),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const LoginTitle(),
                        const Text(
                          '管理者からログインをブロックされました。\nログイン申請から始めてください。',
                          style: TextStyle(
                            color: kYellowColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        LinkText(
                          label: 'ログイン申請から始める',
                          labelColor: kWhiteColor,
                          onTap: () async {
                            await authProvider.signOut();
                            authProvider.clearController();
                            if (!mounted) return;
                            pushReplacementScreen(context, const LoginScreen());
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        if (shopLogin.accept == false) {
          return Scaffold(
            body: Stack(
              children: [
                const AnimationBackground(),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const LoginTitle(),
                        const Text(
                          '管理者へログイン申請を送信しました。\n承認まで今しばらくお待ちくださいませ。',
                          style: TextStyle(
                            color: kWhiteColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        LinkText(
                          label: 'ログイン申請をキャンセルする',
                          labelColor: kWhiteColor,
                          onTap: () async {
                            await authProvider.deleteShopLogin();
                            await authProvider.signOut();
                            authProvider.clearController();
                            if (!mounted) return;
                            pushReplacementScreen(context, const LoginScreen());
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return Scaffold(
          body: Stack(
            children: [
              const AnimationBackground(),
              SafeArea(
                child: Column(
                  children: [
                    CustomHeader(
                      title: '${authProvider.shop?.name} : 注文',
                      actions: [
                        GestureDetector(
                          onTap: () => showBottomUpScreen(
                            context,
                            const HistoryScreen(),
                          ),
                          child: const Text(
                            '注文履歴',
                            style: TextStyle(
                              color: kWhiteColor,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        GestureDetector(
                          onTap: () => showBottomUpScreen(
                            context,
                            const OrderProductTotalScreen(),
                          ),
                          child: const Text(
                            '注文商品集計',
                            style: TextStyle(
                              color: kWhiteColor,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        GestureDetector(
                          onTap: () => showBottomUpScreen(
                            context,
                            const SettingsScreen(),
                          ),
                          child: const Text(
                            '設定',
                            style: TextStyle(
                              color: kWhiteColor,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '注文したい商品をタップしてください',
                      style: TextStyle(
                        color: kWhiteColor,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: productService.streamList(),
                        builder: (context, snapshot) {
                          List<ProductModel> products = [];
                          List<String> favorites =
                              authProvider.shop?.favorites ?? [];
                          if (snapshot.hasData) {
                            for (DocumentSnapshot<Map<String, dynamic>> doc
                                in snapshot.data!.docs) {
                              ProductModel product =
                                  ProductModel.fromSnapshot(doc);
                              var contain =
                                  favorites.where((e) => e == product.number);
                              if (contain.isNotEmpty) {
                                products.add(product);
                              }
                            }
                          }
                          if (products.isEmpty) {
                            return const Center(
                              child: Text(
                                '注文できる商品がありません\n注文商品設定をご確認ください',
                                style: TextStyle(
                                  color: kWhiteColor,
                                  fontSize: 16,
                                ),
                              ),
                            );
                          }
                          return GridView.builder(
                            gridDelegate: kProductGrid,
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              ProductModel product = products[index];
                              return ProductCard(
                                product: product,
                                carts: authProvider.carts,
                                onTap: () => showDialog(
                                  context: context,
                                  builder: (context) => ProductDetailsDialog(
                                    authProvider: authProvider,
                                    product: product,
                                  ),
                                ).then((value) {
                                  authProvider.initCarts();
                                }),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: CartNextButton(
            carts: authProvider.carts,
            onPressed: () => showBottomUpScreen(
              context,
              const OrderCartScreen(),
            ),
          ),
        );
      },
    );
  }
}

class ProductDetailsDialog extends StatefulWidget {
  final Auth2Provider authProvider;
  final ProductModel product;

  const ProductDetailsDialog({
    required this.authProvider,
    required this.product,
    super.key,
  });

  @override
  State<ProductDetailsDialog> createState() => _ProductDetailsDialogState();
}

class _ProductDetailsDialogState extends State<ProductDetailsDialog> {
  int requestQuantity = 0;
  CartModel? cart;

  void _init() async {
    int tmpRequestQuantity = 0;
    for (CartModel cartModel in widget.authProvider.carts) {
      if (cartModel.number == widget.product.number) {
        tmpRequestQuantity = cartModel.requestQuantity;
        cart = cartModel;
      }
    }
    setState(() {
      requestQuantity = tmpRequestQuantity;
    });
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(16),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: CustomImage(widget.product.image),
          ),
          const SizedBox(height: 8),
          Text(
            '商品番号 : ${widget.product.number}',
            style: const TextStyle(
              color: kGreyColor,
              fontSize: 14,
            ),
          ),
          Text(
            widget.product.name,
            style: const TextStyle(
              color: kBlackColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          QuantityButton(
            quantity: requestQuantity,
            unit: widget.product.unit,
            onRemoved: () {
              if (requestQuantity == 0) return;
              setState(() {
                requestQuantity -= 1;
              });
            },
            onRemoved10: () {
              if (requestQuantity == 0) return;
              setState(() {
                if (requestQuantity <= 10) {
                  requestQuantity = 0;
                } else {
                  requestQuantity -= 10;
                }
              });
            },
            onAdded: () {
              setState(() {
                requestQuantity += 1;
              });
            },
            onAdded10: () {
              setState(() {
                requestQuantity += 10;
              });
            },
          ),
          const SizedBox(height: 8),
          CustomLgButton(
            label: cart != null ? '数量を変更する' : 'カートに入れる',
            labelColor: kWhiteColor,
            backgroundColor: kBlueColor,
            onPressed: () async {
              if (requestQuantity > 0) {
                await widget.authProvider.addCarts(
                  widget.product,
                  requestQuantity,
                );
              } else if (cart != null) {
                await widget.authProvider.removeCart(cart!);
              }
              if (!mounted) return;
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 16),
          cart != null
              ? Center(
                  child: LinkText(
                    label: 'カートから削除する',
                    labelColor: kRedColor,
                    onTap: () async {
                      if (cart == null) return;
                      await widget.authProvider.removeCart(cart!);
                      if (!mounted) return;
                      Navigator.pop(context);
                    },
                  ),
                )
              : Container(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

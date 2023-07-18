import 'package:flutter/material.dart';
import 'package:hirome_rental_shop_web/common/style.dart';
import 'package:hirome_rental_shop_web/models/cart.dart';
import 'package:hirome_rental_shop_web/models/product.dart';
import 'package:hirome_rental_shop_web/widgets/custom_image.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final List<CartModel> carts;
  final Function()? onTap;

  const ProductCard({
    required this.product,
    required this.carts,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var contain = carts.where((e) => e.number == product.number);

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Card(
            elevation: 5,
            child: Container(
              height: 500,
              margin: const EdgeInsets.all(4),
              padding: const EdgeInsets.all(4),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: CustomImage(product.image)),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.all(4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '商品番号 : ${product.number}',
                              style: const TextStyle(
                                color: kGreyColor,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              product.name,
                              style: const TextStyle(
                                color: kBlackColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          contain.isNotEmpty
              ? Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: kBlackColor.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${contain.first.requestQuantity}${contain.first.unit}',
                          style: const TextStyle(
                            color: kWhiteColor,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          '選択中',
                          style: TextStyle(
                            color: kWhiteColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}

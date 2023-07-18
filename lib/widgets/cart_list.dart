import 'package:flutter/material.dart';
import 'package:hirome_rental_shop_web/common/style.dart';
import 'package:hirome_rental_shop_web/models/cart.dart';

class CartList extends StatelessWidget {
  final CartModel cart;
  final bool viewDelivery;

  const CartList({
    required this.cart,
    this.viewDelivery = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: kGreyColor)),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '商品番号 : ${cart.number}',
                style: const TextStyle(
                  color: kGreyColor,
                  fontSize: 12,
                ),
              ),
              Text(
                cart.name,
                style: const TextStyle(
                  color: kBlackColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '希望数量',
                    style: TextStyle(
                      color: kGreyColor,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '${cart.requestQuantity}${cart.unit}',
                    style: const TextStyle(
                      color: kBlackColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              viewDelivery == true ? const SizedBox(width: 10) : Container(),
              viewDelivery == true
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '納品数量',
                          style: TextStyle(
                            color: kGreyColor,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '${cart.deliveryQuantity}${cart.unit}',
                          style: const TextStyle(
                            color: kBlackColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  : Container(),
            ],
          ),
        ],
      ),
    );
  }
}

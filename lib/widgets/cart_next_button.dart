import 'package:flutter/material.dart';
import 'package:hirome_rental_shop_web/models/cart.dart';

class CartNextButton extends StatelessWidget {
  final List<CartModel> carts;
  final Function() onPressed;

  const CartNextButton({
    required this.carts,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (carts.isNotEmpty) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        label: const Text('注文に進む'),
        icon: const Icon(Icons.shopping_cart_checkout),
      );
    } else {
      return Container();
    }
  }
}

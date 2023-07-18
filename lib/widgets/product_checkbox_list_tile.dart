import 'package:flutter/material.dart';
import 'package:hirome_rental_shop_web/common/style.dart';
import 'package:hirome_rental_shop_web/models/product.dart';
import 'package:hirome_rental_shop_web/widgets/custom_image.dart';

class ProductCheckboxListTile extends StatelessWidget {
  final ProductModel product;
  final bool value;
  final Function(bool?)? onChanged;

  const ProductCheckboxListTile({
    required this.product,
    required this.value,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: kGreyColor)),
      ),
      child: CheckboxListTile(
        secondary: CustomImage(product.image),
        title: Text(
          product.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '商品番号 : ${product.number}',
          style: const TextStyle(
            color: kGreyColor,
            fontSize: 12,
          ),
        ),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

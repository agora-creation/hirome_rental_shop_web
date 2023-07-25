import 'package:flutter/material.dart';
import 'package:hirome_rental_shop_web/common/style.dart';

class CustomHeader extends StatelessWidget {
  final String title;
  final List<Widget> actions;

  const CustomHeader({
    required this.title,
    required this.actions,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: kWhiteColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(children: actions),
        ],
      ),
    );
  }
}

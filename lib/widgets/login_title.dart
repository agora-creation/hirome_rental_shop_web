import 'package:flutter/material.dart';
import 'package:hirome_rental_shop_web/common/style.dart';

class LoginTitle extends StatelessWidget {
  const LoginTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          kCompanyName,
          style: TextStyle(
            color: kWhiteColor,
            fontSize: 20,
          ),
        ),
        Text(
          kSystemName,
          style: TextStyle(
            color: kWhiteColor,
            fontSize: 22,
          ),
        ),
        SizedBox(height: 4),
        Text(
          kForName,
          style: TextStyle(
            color: kWhiteColor,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

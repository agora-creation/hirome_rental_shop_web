import 'package:flutter/material.dart';
import 'package:hirome_rental_shop_web/common/functions.dart';
import 'package:hirome_rental_shop_web/common/style.dart';
import 'package:hirome_rental_shop_web/providers/auth.dart';
import 'package:hirome_rental_shop_web/screens/home.dart';
import 'package:hirome_rental_shop_web/widgets/animation_background.dart';
import 'package:hirome_rental_shop_web/widgets/custom_lg_button.dart';
import 'package:hirome_rental_shop_web/widgets/custom_text_form_field.dart';
import 'package:hirome_rental_shop_web/widgets/login_title.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          const AnimationBackground(),
          GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 320),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const LoginTitle(),
                  Card(
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          const Text(
                            '『店舗番号』と『あなたの名前』を入力して、『ログイン』ボタンをタップしてください',
                            style: TextStyle(
                              color: kGrey2Color,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          CustomTextFormField(
                            controller: authProvider.number,
                            textInputType: TextInputType.number,
                            maxLines: 1,
                            label: '店舗番号',
                            color: kBlackColor,
                            prefix: Icons.food_bank,
                          ),
                          const SizedBox(height: 8),
                          CustomTextFormField(
                            controller: authProvider.requestName,
                            textInputType: TextInputType.name,
                            maxLines: 1,
                            label: 'あなたの名前',
                            color: kBlackColor,
                            prefix: Icons.person,
                          ),
                          const SizedBox(height: 16),
                          CustomLgButton(
                            label: 'ログイン',
                            labelColor: kWhiteColor,
                            backgroundColor: kBlueColor,
                            onPressed: () async {
                              String? error = await authProvider.signIn();
                              if (error != null) {
                                if (!mounted) return;
                                showMessage(context, error, false);
                                return;
                              }
                              authProvider.clearController();
                              if (!mounted) return;
                              showMessage(context, 'ログイン申請を送信しました', true);
                              pushReplacementScreen(
                                context,
                                const HomeScreen(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

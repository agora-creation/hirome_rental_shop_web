import 'package:flutter/material.dart';
import 'package:hirome_rental_shop_web/common/functions.dart';
import 'package:hirome_rental_shop_web/common/style.dart';
import 'package:hirome_rental_shop_web/providers/auth.dart';
import 'package:hirome_rental_shop_web/screens/login.dart';
import 'package:hirome_rental_shop_web/widgets/link_text.dart';
import 'package:hirome_rental_shop_web/widgets/setting_list_tile.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: kWhiteColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: kWhiteColor,
        title: Text(
          '${authProvider.shop?.name} : 設定',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SettingListTile(
              iconData: Icons.key,
              label: 'パスワード変更',
              topBorder: true,
              onTap: () {},
            ),
            SettingListTile(
              iconData: Icons.favorite,
              label: '注文商品設定',
              onTap: () {},
            ),
            const SizedBox(height: 32),
            Center(
              child: LinkText(
                label: 'ログアウト',
                labelColor: kRedColor,
                onTap: () async {
                  await authProvider.signOut();
                  authProvider.clearController();
                  if (!mounted) return;
                  pushReplacementScreen(context, const LoginScreen());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

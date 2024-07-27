import 'package:flutter/material.dart';
import 'package:hirome_rental_shop_web/common/functions.dart';
import 'package:hirome_rental_shop_web/common/style.dart';
import 'package:hirome_rental_shop_web/providers/auth.dart';
import 'package:hirome_rental_shop_web/screens/favorites.dart';
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
    final authProvider = Provider.of<Auth2Provider>(context);

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
              iconData: Icons.favorite,
              label: '注文商品設定',
              topBorder: true,
              onTap: () => pushScreen(
                context,
                FavoritesScreen(authProvider: authProvider),
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: LinkText(
                label: '初期化する(店舗ログイン申請から始める)',
                labelColor: kRedColor,
                onTap: () async {
                  await authProvider.deleteShopLogin();
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

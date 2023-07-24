import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hirome_rental_shop_web/models/shop.dart';

class ShopService {
  String collection = 'shop';
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  void update(Map<String, dynamic> values) {
    firestore.collection(collection).doc(values['id']).update(values);
  }

  Future<ShopModel?> select({String? number, String? password}) async {
    ShopModel? ret;
    await firestore
        .collection(collection)
        .where('number', isEqualTo: number ?? 'error')
        .where('authority', isEqualTo: 0)
        .get()
        .then((value) {
      for (DocumentSnapshot<Map<String, dynamic>> map in value.docs) {
        ret = ShopModel.fromSnapshot(map);
      }
    });
    return ret;
  }
}

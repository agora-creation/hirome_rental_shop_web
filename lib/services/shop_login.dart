import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hirome_rental_shop_web/models/shop_login.dart';

class ShopLoginService {
  String collection = 'shopLogin';
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  void create(Map<String, dynamic> values) {
    firestore.collection(collection).doc(values['id']).set(values);
  }

  void delete(Map<String, dynamic> values) {
    firestore.collection(collection).doc(values['id']).delete();
  }

  Future<ShopLoginModel?> select({String? id}) async {
    ShopLoginModel? ret;
    await firestore
        .collection(collection)
        .doc(id ?? 'error')
        .get()
        .then((value) {
      ret = ShopLoginModel.fromSnapshot(value);
    });
    return ret;
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> streamList(String? id) {
    return FirebaseFirestore.instance
        .collection(collection)
        .doc(id ?? 'error')
        .snapshots();
  }
}

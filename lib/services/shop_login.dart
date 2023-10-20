import 'package:cloud_firestore/cloud_firestore.dart';

class ShopLoginService {
  String collection = 'shopLogin';
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  void create(Map<String, dynamic> values) {
    firestore.collection(collection).doc(values['id']).set(values);
  }

  void delete(Map<String, dynamic> values) {
    firestore.collection(collection).doc(values['id']).delete();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> streamList(String? id) {
    return FirebaseFirestore.instance
        .collection(collection)
        .doc(id ?? 'error')
        .snapshots();
  }
}

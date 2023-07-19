import 'package:cloud_firestore/cloud_firestore.dart';

class ProductService {
  String collection = 'product';
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>>? streamList() {
    return FirebaseFirestore.instance
        .collection(collection)
        .where('category', isNotEqualTo: 9)
        .orderBy('category')
        .orderBy('priority', descending: false)
        .snapshots();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hirome_rental_shop_web/common/functions.dart';
import 'package:hirome_rental_shop_web/models/order.dart';
import 'package:hirome_rental_shop_web/models/shop.dart';

class OrderService {
  String collection = 'order';
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  String id() {
    return firestore.collection(collection).doc().id;
  }

  void create(Map<String, dynamic> values) {
    firestore.collection(collection).doc(values['id']).set(values);
  }

  void update(Map<String, dynamic> values) {
    firestore.collection(collection).doc(values['id']).update(values);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>? streamList({
    required ShopModel shop,
    required DateTime searchStart,
    required DateTime searchEnd,
  }) {
    Timestamp startAt = convertTimestamp(searchStart, false);
    Timestamp endAt = convertTimestamp(searchEnd, true);
    return FirebaseFirestore.instance
        .collection(collection)
        .where('shopNumber', isEqualTo: shop.number)
        .orderBy('createdAt', descending: true)
        .startAt([endAt]).endAt([startAt]).snapshots();
  }

  Future<List<OrderModel>> selectList({
    String? shopNumber,
    required DateTime searchStart,
    required DateTime searchEnd,
  }) async {
    List<OrderModel> ret = [];
    Timestamp startAt = convertTimestamp(searchStart, false);
    Timestamp endAt = convertTimestamp(searchEnd, true);
    await firestore
        .collection(collection)
        .where('shopNumber', isEqualTo: shopNumber)
        .orderBy('createdAt', descending: true)
        .startAt([endAt])
        .endAt([startAt])
        .get()
        .then((value) {
          for (DocumentSnapshot<Map<String, dynamic>> map in value.docs) {
            ret.add(OrderModel.fromSnapshot(map));
          }
        });
    return ret;
  }
}

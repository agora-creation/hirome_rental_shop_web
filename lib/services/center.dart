import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hirome_rental_shop_web/models/center.dart';

class CenterService {
  String collection = 'center';
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<List<CenterModel>> selectList() async {
    List<CenterModel> ret = [];
    await firestore
        .collection(collection)
        .orderBy('createdAt', descending: true)
        .get()
        .then((value) {
      for (DocumentSnapshot<Map<String, dynamic>> map in value.docs) {
        ret.add(CenterModel.fromSnapshot(map));
      }
    });
    return ret;
  }
}

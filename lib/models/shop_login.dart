import 'package:cloud_firestore/cloud_firestore.dart';

class ShopLoginModel {
  String _id = '';
  String _shopNumber = '';
  String _shopName = '';
  String _requestName = '';
  String _deviceName = '';
  bool _accept = false;
  DateTime _acceptedAt = DateTime.now();
  DateTime _createdAt = DateTime.now();

  String get id => _id;
  String get shopNumber => _shopNumber;
  String get shopName => _shopName;
  String get requestName => _requestName;
  String get deviceName => _deviceName;
  bool get accept => _accept;
  DateTime get acceptedAt => _acceptedAt;
  DateTime get createdAt => _createdAt;

  ShopLoginModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    Map<String, dynamic> map = snapshot.data() ?? {};
    _id = map['id'] ?? '';
    _shopNumber = map['shopNumber'] ?? '';
    _shopName = map['shopName'] ?? '';
    _requestName = map['requestName'] ?? '';
    _deviceName = map['deviceName'] ?? '';
    _accept = map['accept'] ?? false;
    if (map['acceptedAt'] != null) {
      _acceptedAt = map['acceptedAt'].toDate() ?? DateTime.now();
    }
    if (map['createdAt'] != null) {
      _createdAt = map['createdAt'].toDate() ?? DateTime.now();
    }
  }
}

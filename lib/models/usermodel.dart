import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String name;
  final String sex;
  final DateTime birth;
  final String email;
  final double tall;
  final double weight;
  final String uid;
  final String platform;

  UserModel({
    required this.name,
    required this.sex,
    required this.birth,
    required this.email,
    required this.tall,
    required this.weight,
    required this.uid,
    required this.platform,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      name: data['name'] ?? '',
      sex: data['sex'] ?? '',
      birth: (data['birth'] as Timestamp).toDate(),
      email: data['e-mail'] ?? '',
      tall: (data['tall'] as num).toDouble(),
      weight: (data['weight'] as num).toDouble(),
      uid: data['uid'] ?? '',
      platform: data['platform'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'sex': sex,
      'birth': Timestamp.fromDate(birth),
      'e-mail': email,
      'tall': tall,
      'weight': weight,
      'uid': uid,
      'platform': platform,
    };
  }
}

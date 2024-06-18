import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:android_id/android_id.dart';
import 'package:flutter/services.dart';
import '../api/firestoreupdate.dart';
import '../api/loginchecker.dart';
import '../models/usermodel.dart';

class MultiSectionFormViewModel {
  final FirestoreService _firestoreService = FirestoreService();
  static const _androidIdPlugin = AndroidId();
  User? user;
  late StreamSubscription<User?> _authSubscription;
  var _androidId = 'Unknown';

  Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
    user = FirebaseAuth.instance.currentUser;
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((User? currentUser) {
      user = currentUser;
    });
  }

  Future<void> dispose() async {
    _authSubscription.cancel();
  }

  Future<void> _initAndroidId() async {
    try {
      _androidId = await _androidIdPlugin.getId() ?? 'Unknown ID';
    } on PlatformException {
      _androidId = 'Failed to get Android ID.';
    }
  }

  Future<void> saveForm(Map<String, dynamic> formData, String? selectedGender, DateTime? selectedBirthdate) async {
    if (user == null) {
      throw Exception('User is not authenticated.');
    }

    await _initAndroidId();

    try {
      String uid = user!.uid;
      Map<String, dynamic>? oldData = await _firestoreService.loadUserData(_androidId);
      bool isGoogleSignedIn = await LoginChecker().checkGoogleLoginStatus();
      bool isKakaoSignedIn = await LoginChecker().checkKakaoLoginStatus();

      UserModel userModel = UserModel(
        name: formData['이름'],
        sex: selectedGender ?? '',
        birth: selectedBirthdate ?? DateTime.now(),
        email: formData['이메일'],
        tall: double.tryParse(formData['키'].toString()) ?? 0.0,
        weight: double.tryParse(formData['몸무게'].toString()) ?? 0.0,
        uid: uid,
        platform: isGoogleSignedIn ? 'google' : isKakaoSignedIn ? 'kakao' : 'none',
      );

      Map<String, dynamic> selectedData = {
        ...userModel.toMap(),
        ...?oldData,
      };

      await FirebaseFirestore.instance.collection('realusers').doc(_androidId).set(selectedData);
      await FirebaseFirestore.instance.collection('users').doc(_androidId).delete();
    } catch (e) {
      throw Exception('Error saving data to Firestore: $e');
    }
  }
}

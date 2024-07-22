import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../api/firestoreupdate.dart';
import '../api/loginchecker.dart';
import '../models/usermodel.dart';

class MultiSectionFormViewModel {
  final FirestoreService _firestoreService = FirestoreService();
  User? user;
  late StreamSubscription<User?> _authSubscription;

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

  Future<void> saveForm(Map<String, dynamic> formData, String? selectedGender, DateTime? selectedBirthdate) async {
    if (user == null) {
      throw Exception('User is not authenticated.');
    }

    try {
      bool isGoogleSignedIn = await LoginChecker().checkGoogleLoginStatus();
      bool isKakaoSignedIn = await LoginChecker().checkKakaoLoginStatus();

      UserModel userModel = UserModel(
        name: formData['이름'],
        sex: selectedGender ?? '',
        birth: selectedBirthdate ?? DateTime.now(),
        email: formData['이메일'],
        tall: double.tryParse(formData['키'].toString()) ?? 0.0,
        weight: double.tryParse(formData['몸무게'].toString()) ?? 0.0,
        uid: user!.uid, // 사용자의 UID를 문서 이름으로 설정
        platform: isGoogleSignedIn ? 'google' : isKakaoSignedIn ? 'kakao' : 'none', // 플랫폼 정보는 필요에 따라 저장
      );

      Map<String, dynamic> userData = userModel.toMap();

      // Save user data to 'users' collection with user's UID as document name
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set(userData); // 문서 이름을 사용자의 UID로 설정

    } catch (e) {
      throw Exception('Error saving data to Firestore: $e');
    }
  }

  Future<UserModel?> getUserData() async {
    if (user == null) {
      throw Exception('User is not authenticated.');
    }

    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      throw Exception('Error fetching data from Firestore: $e');
    }
    return null;
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../api/google_login.dart';
import '../api/kakao_login.dart' as kakao;
import '../views/member_information_write_screen.dart';

class LoginDialogHelper {
  static Future<void> showLoginDialog(BuildContext context) async {
    try {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('로그인을 하고 일지를 더 많이 작성해보세요!', style: TextStyle(fontSize: 15)),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () async {
                    await signInWithGoogleAndNavigate(context);
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Image.asset('assets/Google.png'),
                  ),
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () async {
                    await signInWithKakaoAndNavigate(context);
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Image.asset('assets/KakaoTalk.png'),
                  ),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      print('로그인 중 오류 발생: $e');
    }
  }

  static Future<void> signInWithGoogleAndNavigate(BuildContext context) async {
    try {
      await GoogleLogin.signInWithGoogle(context);
      // 구글 로그인 후 Firestore에서 문서 확인
      await checkFirestoreDocumentAndNavigate(context);
    } catch (e) {
      print('구글 로그인 중 오류 발생: $e');
    }
  }

  static Future<void> signInWithKakaoAndNavigate(BuildContext context) async {
    try {
      bool loginSuccess = await kakao.KakaoLogin().login();
      if (loginSuccess) {
        // 카카오 로그인 후 Firestore에서 문서 확인
        await checkFirestoreDocumentAndNavigate(context);
      }
    } catch (e) {
      print('카카오 로그인 중 오류 발생: $e');
    }
  }

  static Future<void> checkFirestoreDocumentAndNavigate(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Firestore에서 해당 사용자의 문서를 가져옵니다.
        final docSnapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

        if (docSnapshot.exists) {
          Navigator.of(context).pop();
          print('문서가 이미 존재합니다.');
          // 예를 들어 다른 화면으로 이동하도록 처리할 수 있습니다.
        } else {
          // 문서가 존재하지 않는 경우 MultiSectionForm 화면으로 이동
          print('문서가 존재하지 않습니다. MultiSectionForm으로 이동합니다.');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MultiSectionForm()),
          );
        }
      } else {
        print('사용자가 인증되지 않았습니다.');
      }
    } catch (e) {
      print('Firestore에서 문서 확인 중 오류 발생: $e');
    }
  }
}

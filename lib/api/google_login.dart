import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class GoogleLogin {
  static Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleSignInAccount = await GoogleSignIn().signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

        final firebase_auth.AuthCredential credential =
        firebase_auth.GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        // 구글 로그인 사용자로 인증
        await FirebaseAuth.instance.signInWithCredential(credential);

        // 현재 사용자 재확인
        firebase_auth.User? currentUser = FirebaseAuth.instance.currentUser;

        assert(await currentUser!.getIdToken() != null);

        // 추가로 원하는 동작 수행

      } else {
        // 구글 로그인 실패 시 처리
        // 이곳에 실패 시 처리 코드 추가
      }
    } catch (e) {
      // 에러 처리 코드 추가
    }
  }
}

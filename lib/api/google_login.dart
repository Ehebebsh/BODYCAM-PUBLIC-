import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class GoogleLogin {
  static Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
      await GoogleSignIn().signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

        final firebase_auth.AuthCredential credential =
        firebase_auth.GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        // 기존 익명 사용자가 있는지 확인
        firebase_auth.User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null && currentUser.isAnonymous) {
          // 익명 사용자를 구글 로그인 사용자로 전환
          await currentUser.linkWithCredential(credential);
        } else {
          // 아니면 새로운 구글 로그인 사용자 생성
          await FirebaseAuth.instance.signInWithCredential(credential);
        }

        // 현재 사용자 재확인
        currentUser = FirebaseAuth.instance.currentUser;

        assert(!currentUser!.isAnonymous);
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



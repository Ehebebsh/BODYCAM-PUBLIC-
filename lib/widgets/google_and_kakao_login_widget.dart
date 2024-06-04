import 'package:flutter/material.dart';
import 'package:miniproject_exercise/api/google_login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/kakao_login.dart' as kakao;
import '../views/member_information_write_screen.dart';

class LoginDialogHelper {
  static Future<void> showLoginDialog(BuildContext context) async {
    try {
      // SharedPreferences를 사용하여 최초 로그인 여부 확인
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool isFirstLogin = prefs.getBool('isFirstLogin') ?? true;

      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('로그인을 하고 일지를 더 많이 작성해보세요!'
                ,style: TextStyle(fontSize: 15)),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () async {
                    await GoogleLogin.signInWithGoogle(context);
                    // 로그인 성공 후 페이지 전환
                    Navigator.of(context).pop(); // 다이얼로그 닫기
                    if (isFirstLogin) {
                      prefs.setBool('isFirstLogin', false); // 최초 로그인 여부 갱신
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MultiSectionForm()),
                      );
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Image.asset('assets/Google.png'),
                  ),
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () async {
                    bool loginSuccess = await kakao.KakaoLogin().login();
                    if (loginSuccess) {
                      Navigator.of(context).pop(); // 다이얼로그 닫기
                      if (isFirstLogin) {
                        prefs.setBool('isFirstLogin', false); // 최초 로그인 여부 갱신
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MultiSectionForm()),
                        );
                      }
                    }
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
      // 로그인 중 오류 발생 시 처리
    }
  }
}

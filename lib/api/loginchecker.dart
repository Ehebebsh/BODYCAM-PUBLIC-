import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

class LoginChecker {
  Future<bool> checkKakaoLoginStatus() async {
    try {
      await UserApi.instance.accessTokenInfo();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkGoogleLoginStatus() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    bool isSignedIn = await googleSignIn.isSignedIn();
    return isSignedIn;
  }

  Future<bool> checkLoginStatus() async {
    bool isGoogleLoggedIn = await checkGoogleLoginStatus();
    bool isKakaoLoggedIn = await checkKakaoLoginStatus();
    return isGoogleLoggedIn || isKakaoLoggedIn;
  }
}

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:miniproject_exercise/utils/colors.dart';
import 'screens/calendar_screen.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:miniproject_exercise/utils/constant.dart' as cons;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  KakaoSdk.init(nativeAppKey: cons.KAKAO_NATIVE_APP_KEY);
  MobileAds.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    return MaterialApp(
        debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Ownglyph_Dailyokja-Rg',
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          onSecondary: onSecondaryColor,
          secondary: secondaryColor,
        ),
        brightness: Brightness.light,
      ),
      title: 'My App',
        home: CalendarScreen(onDateSelected: (DateTime? date){
          // TODO: Handle date selection
        }),
      );
  }
}

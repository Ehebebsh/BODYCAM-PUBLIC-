import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:miniproject_exercise/utils/colors.dart';
import 'package:miniproject_exercise/view%20models/diary_modelview.dart';
import 'package:miniproject_exercise/view%20models/diary_video_modelview.dart';
import 'package:miniproject_exercise/view%20models/workoutsearch_viewmodel.dart';
import 'package:miniproject_exercise/views/calendar_screen.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:miniproject_exercise/utils/constant.dart' as cons;
import 'package:provider/provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'assets/config/.env');
  await Firebase.initializeApp();
  KakaoSdk.init(nativeAppKey: cons.KAKAO_NATIVE_APP_KEY);
  MobileAds.instance.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => DiaryViewModel()),
        ChangeNotifierProvider(create: (context) => DiaryVideoViewModel()),
        ChangeNotifierProvider(create: (context) => WorkOutViewModel()), // WorkOutViewModel의 Provider를 추가합니다.

      ],
      child: MaterialApp(
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
        home: const CalendarScreen(),
      ),
    );
  }
}

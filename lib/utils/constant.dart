import 'package:flutter_dotenv/flutter_dotenv.dart';

final List<String> workouts =
['전체보기', '데드리프트', '바벨 로우',
  '덤벨 로우', '벤치프레스', '인클라인 벤치프레스',
  '덤벨 벤치프레스','바벨 백 스쿼트', '에어 스쿼트', '점프 스쿼트'];

final String KAKAO_NATIVE_APP_KEY = dotenv.env['KAKAO_NATIVE_APP_KEY'] ?? '';
final String videoadUnitId = dotenv.env['youtubeapikey'] ?? '';
final String youtubeapikey = dotenv.env['videoadUnitId'] ?? '';
final String adUnitId = dotenv.env['adUnitId'] ?? '';
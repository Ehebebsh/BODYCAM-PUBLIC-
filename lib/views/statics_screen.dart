import 'package:flutter/material.dart';
import '../providers/statistics_provider.dart';
import '../widgets/workoutpiechart.dart';
import '../models/indicator.dart';

class StaticsScreen extends StatefulWidget {
  @override
  _StaticsScreenState createState() => _StaticsScreenState();
}

class _StaticsScreenState extends State<StaticsScreen> {
  List<Map<String, dynamic>> _diaries = [];
  final DiaryLoader _diaryLoader = DiaryLoader();
  int _diaryCount = 0; // 새로운 변수: 일지의 개수
  DateTime? _firstDiaryDate;

  @override
  void initState() {
    super.initState();
    _diaryLoader.loadDiaries('exampleOption').then((diaries) {
      setState(() {
        _diaries = diaries;
        _diaryCount = diaries.length;
        _firstDiaryDate = _calculateFirstDiaryDate(diaries);// 일지의 개수 업데이트
      });
    });
  }

  DateTime? _calculateFirstDiaryDate(List<Map<String, dynamic>> diaries) {
    if (diaries.isEmpty) return null;
    diaries.sort((a, b) => a['formattedDate'].compareTo(b['formattedDate']));
    return DateTime.parse(diaries.first['formattedDate']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.black87,
        title: Text('통계',
            style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: Colors.white38,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.all(10),
              child: Text(
                '일지 개수: $_diaryCount',
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 10,),
            Container(
              decoration: BoxDecoration(
                color: Colors.white38,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.all(10),
              child: _firstDiaryDate != null
                  ? Text(
                '첫 일지 작성 날짜: ${_firstDiaryDate?.year}년 ${_firstDiaryDate?.month}월 ${_firstDiaryDate?.day}일',
                style: TextStyle(color: Colors.white),
              )
                  : Text(
                '저장된 일지가 없습니다.',
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 20,),
            Divider(
              color: Colors.white,
              thickness: 1.0,
            ),
            SizedBox(
              height: 20,
            ),// 새로운 텍스트 위젯: 첫 일지의 날짜
            SizedBox(
              height: MediaQuery
                  .of(context)
                  .size
                  .width > 600 ? 400 : 200,
              width: MediaQuery
                  .of(context)
                  .size
                  .width > 600 ? 400 : 200,
              child: WorkoutPieChart(diaries: _diaries),
            ),
            SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Indicator(
                      color: Color(0xffff0000),
                      text: '데드리프트',
                      isSquare: true,
                    ),
                    Indicator(
                      color: Color(0xff00ff00),
                      text: '바벨 로우',
                      isSquare: true,
                    ),
                    Indicator(
                      color: Color(0xff0000ff),
                      text: '덤벨 로우',
                      isSquare: true,
                    ),
                  ],
                ),
                Column(
                  children: [
                    Indicator(
                      color: Color(0xffffff00),
                      text: '벤치프레스',
                      isSquare: true,
                    ),
                    Indicator(
                      color: Color(0xffff00ff),
                      text: '인클라인 벤치프레스',
                      isSquare: true,
                    ),
                    Indicator(
                      color: Color(0xff00ffff),
                      text: '덤벨 벤치프레스',
                      isSquare: true,
                    ),
                  ],
                ),
                Column(
                  children: [
                    Indicator(
                      color: Color(0xffff8000),
                      text: '바벨 백 스쿼트',
                      isSquare: true,
                    ),
                    Indicator(
                      color: Color(0xff800080),
                      text: '에어 스쿼트',
                      isSquare: true,
                    ),
                    Indicator(
                      color: Color(0xff008080),
                      text: '점프 스쿼트',
                      isSquare: true,
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

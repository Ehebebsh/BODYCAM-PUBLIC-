import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:miniproject_exercise/models/diarymodel.dart';
import 'package:miniproject_exercise/utils/constant.dart' as cons;
import 'package:miniproject_exercise/widgets/navigation_widget.dart';
import 'package:miniproject_exercise/widgets/buildmarked_date_icon_widget.dart';
import 'package:miniproject_exercise/widgets/buildCalendarViewWidget.dart';
import 'dart:io';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/admob_helper.dart';
import '../api/authenticationmanager.dart';
import '../widgets/drawer_widget.dart';
import 'dart:async';
import 'package:flutter/services.dart';


class CalendarScreen extends StatefulWidget {
  final Function(DateTime)? onDateSelected;

  const CalendarScreen({Key? key, this.onDateSelected}) : super(key: key);

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>
    with SingleTickerProviderStateMixin {
  AdMobHelper adManager = AdMobHelper(
    nativeAdUnitId: cons.adUnitId,
    nativeFactoryId: 'adFactoryExample',
    rewardAdUnitId: cons.videoadUnitId,
  );
  RewardedAd? _rewardedAd;
  late Future<NativeAd> _adFuture;
  // late Future<NativeAd> _adFuture1;
  late DateTime _selectedDate;
  late DiaryModel _diaryModel;
  String? _selectedOption;
  List<String> _selectedDateWorkouts = [];
  List<Tab>? myTabs;
  TabController? tabController;
  EventList<Event> _markedDateMap = EventList<Event>(events: {});
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late UserAuthManager _authManager;

  @override
  void initState() {
    super.initState();
    adManager.loadRewardAd();
    _adFuture=AdMobHelper(
        nativeAdUnitId: cons.adUnitId,
        nativeFactoryId: 'adFactoryExample',
        rewardAdUnitId: cons.videoadUnitId
    ).createNativeAd();
    // _adFuture1=AdMobHelper(
    //     nativeAdUnitId: cons.adUnitId,
    //     nativeFactoryId: 'adFactoryExample',
    //     rewardAdUnitId: cons.videoadUnitId
    // ).createNativeAd();
    _authManager = UserAuthManager(); // 추가
    _authManager.init(); // 추가
    tabController = TabController(vsync: this, length: cons.workouts.length);
    myTabs = cons.workouts.map((String workout) {
      return Tab(text: workout);
    }).toList();
    _selectedOption = cons.workouts[0];
    _selectedDate = DateTime.now();
    _diaryModel = DiaryModel();
    tabController?.addListener(() {
      _selectedDateWorkouts.clear();
      _updateSelectedDateWorkouts();
      _updateMarkedDateMap();
    });
    _updateSelectedDateWorkouts();
    _updateMarkedDateMap();
  }

  @override
  void dispose() {
    _rewardedAd?.dispose();
    _adFuture.then((ad) => ad.dispose());
    // _adFuture1.then((ad) => ad.dispose());
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      drawer: const MyDrawer(),
      backgroundColor: Colors.black87,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Builder(
            builder: (BuildContext context) {
              return Column(
                children: [
                  Stack(
                    children: [
                      TabBar(
                        dividerColor: Colors.white,
                        isScrollable: true,
                        tabs: myTabs!,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.grey,
                        controller: tabController,
                        onTap: (index) {
                          _selectedOption = cons.workouts[index];
                          _updateMarkedDateMap();
                          _updateSelectedDateWorkouts();
                        },
                      ),
                      Container(
                        color: Colors.black87,
                        child: IconButton(
                          onPressed: () {
                            Scaffold.of(context).openDrawer();
                          },
                          icon: const Icon(Icons.menu,
                            color: Colors.white,),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 3,
                  ),
                  FutureBuilder<NativeAd>(
                    future: _adFuture,
                    builder: (BuildContext context, AsyncSnapshot<NativeAd> snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return Container(
                          height: 32,
                          child: AdWidget(ad: snapshot.data!),
                        );
                      } else {
                        return CircularProgressIndicator();
                      }
                    },
                  ),
                  _buildCalendarView(),
                  const Divider(color: Colors.white),
                  _buildDiaryList(),
                ],
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MyHomePageBottomNavigationBar(
            size: MediaQuery.of(context).size,
          ),
          // FutureBuilder<NativeAd>(
          //   future: _adFuture1,
          //   builder: (BuildContext context, AsyncSnapshot<NativeAd> snapshot) {
          //     if (snapshot.connectionState == ConnectionState.done) {
          //       return Container(
          //         height: 32,
          //         child: AdWidget(ad: snapshot.data!),
          //       );
          //     } else {
          //       return CircularProgressIndicator();
          //     }
          //   },
          // ),
        ],
      ),
    );
  }



  Widget _buildCalendarView() {
    return BuildCalendarViewWidget(
      selectedDate: _selectedDate,
      markedDateMap: _markedDateMap,
      onDayPressed: (DateTime date, List<Event> events) {
        setState(() {
          _selectedDate = date;
          _updateSelectedDateWorkouts();
        });
        if (widget.onDateSelected != null) {
          widget.onDateSelected!(_selectedDate);
        }
      },
      // 람다 함수를 사용하여 항상 널이 아닌 함수를 전달합니다.
      onDateSelected: (date) => widget.onDateSelected?.call(date),
    );
  }



  Widget _buildDiaryList() {
    if (_selectedDateWorkouts.isNotEmpty) {
      return SingleChildScrollView(
        child: Column(
          children: [
            for (String workout in _selectedDateWorkouts)
              ListTile(
                title: Text(
                  workout,
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  _readWorkoutDiary(_selectedDate, workout, context);
                },
              ),
          ],
        ),
      );
    } else {
      return Container();
    }
  }


  Future<void> _readWorkoutDiary(
      DateTime selectedDate, String workout, BuildContext context) async {
    try {
      String filePath =
          await _diaryModel.getFilePathForDate(selectedDate, workout);
      File file = File(filePath);

      if (await file.exists()) {
        String fileContent = await file.readAsString();
        Map<String, dynamic> diaryData = json.decode(fileContent);

        String formattedDate = DateFormat('yyyy/MM/dd').format(selectedDate);

        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text(
                '운동일지 내용',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('날짜: $formattedDate'),
                    Text('운동 종류: ${diaryData['selectedOption']}'),
                    Text('중량: ${diaryData['weight']}'),
                    Text('일지 내용: ${diaryData['diaryText']}'),
                  ],
                ),
              ),
              actions: <Widget>[
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('닫기'),
                    ),
                    TextButton(
                      onPressed: () async {
                        adManager.loadRewardAd();
                        adManager.showRewardAd();
                        Navigator.of(context).pop(); // Close the read dialog
                        // Open the edit dialog
                        await _editWorkoutDiary(selectedDate, workout, context, diaryData);
                        setState(() {});
                      },
                      child: const Text('수정'),
                    ),
                    TextButton(
                      onPressed: () async {
                        await file.delete();
                        setState(() {
                          _selectedDateWorkouts.remove(workout); // _selectedDateWorkouts에서 삭제된 일지 제거
                        });
                        _updateMarkedDateMap();
                        Navigator.of(context).pop();
                      },
                      child: const Text('삭제'),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      } else {
        // 파일이 존재하지 않는 경우
      }

      _updateMarkedDateMap();
    } catch (e) {
      // 오류 처리
    }
  }

  Future<void> _editWorkoutDiary(DateTime selectedDate, String workout,
      BuildContext context, Map<String, dynamic> diaryData) async {
    TextEditingController textEditingController = TextEditingController()
      ..text = diaryData['diaryText'];

    String selectedOption = diaryData['selectedOption'];
    double weight = diaryData['weight'] as double;

    List<String> workoutOptions = List.from(cons.workouts);
    workoutOptions.remove('전체보기');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return WillPopScope(
              onWillPop: () async => false,
              child: AlertDialog(
                title: const Text('운동일지 내용 수정',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          '날짜: ${DateFormat('yyyy-MM-dd').format(selectedDate)}'),
                      DropdownButton<String>(
                        value: selectedOption,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedOption = newValue!;
                          });
                        },
                        items: workoutOptions.map((String workout) {
                          return DropdownMenuItem<String>(
                            value: workout,
                            child: Text(workout),
                          );
                        }).toList(),
                      ),
                      const Text('중량:'),
                      TextField(
                        controller: TextEditingController()
                          ..text = weight.toString(),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            try {
                              weight = double.parse(value);
                            } catch (e) {
                              weight = 0.0;
                            }
                          } else {
                            weight = 0.0;
                          }
                        },
                      ),
                      const Text('일지 내용:'),
                      TextField(
                        controller: textEditingController,
                        maxLines: null,
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('닫기'),
                  ),
                  TextButton(
                    onPressed: () async {
                      diaryData['selectedOption'] = selectedOption;
                      diaryData['weight'] = weight;
                      diaryData['diaryText'] = textEditingController.text;
                      String existingFilePath = await _diaryModel.getFilePathForDate(selectedDate, workout);
                      String newWorkoutFilePath = await _diaryModel.getFilePathForDate(selectedDate, selectedOption);

                      if (existingFilePath != newWorkoutFilePath) {
                        File(existingFilePath).deleteSync();
                      }
                      File file = File(newWorkoutFilePath);
                      await file.writeAsString(json.encode(diaryData));

                      // _selectedDateWorkouts를 업데이트하고 화면을 갱신
                      await _updateMarkedDateMap();

                      // _selectedDateWorkouts를 업데이트하고 화면을 갱신하기 위해 setState 호출
                      setState(() {
                        _selectedDateWorkouts.clear(); // 기존 데이터를 지우고
                        _updateSelectedDateWorkouts(); // 새로운 데이터로 업데이트
                      });

                      Navigator.of(context).pop();
                    },
                    child: const Text('수정하기'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }



  void _updateSelectedDateWorkouts() async {
    List<String> selectedDateWorkouts = [];

    if (_selectedOption == '전체보기') {
      for (String workout in cons.workouts) {
        bool hasDiary = await _hasDiaryForDate(_selectedDate, workout);
        if (hasDiary) {
          selectedDateWorkouts.add(workout);
        }
      }
    } else {
      bool hasDiary = await _hasDiaryForDate(_selectedDate, _selectedOption!);
      if (hasDiary) {
        selectedDateWorkouts.add(_selectedOption!);
      }
    }

    setState(() {
      _selectedDateWorkouts = selectedDateWorkouts;
    });
  }

  Future<void> _updateMarkedDateMap() async {
    EventList<Event> newMarkedDateMap = EventList<Event>(
      events: {},
    );

    DateTime startDate = DateTime(2024, 1, 1);
    DateTime endDate = DateTime.now();

    while (startDate.isBefore(endDate)) {
      bool hasDiary = false;

      if (_selectedOption == '전체보기') {
        for (String workout in cons.workouts) {
          hasDiary = await _hasDiaryForDate(startDate, workout);
          if (hasDiary) break;
        }
      } else {
        hasDiary = await _hasDiaryForDate(startDate, _selectedOption!);
      }

      if (hasDiary) {
        newMarkedDateMap.add(
          startDate,
          Event(
            date: startDate,
            title: '일지 기록됨',
            icon: const BuildMarkedDateIconWidget(),
          ),
        );
      }
      startDate = startDate.add(const Duration(days: 1));
    }

    // dispose() 이후에 setState()가 호출되지 않도록 상태가 확인된 후에만 setState() 호출
    if (mounted) {
      setState(() {
        _markedDateMap = newMarkedDateMap;
      });
    }
  }


  Future<bool> _hasDiaryForDate(DateTime date, String workout) async {
    String filePath = await _diaryModel.getFilePathForDate(date, workout);
    File file = File(filePath);
    return file.existsSync();
  }
}


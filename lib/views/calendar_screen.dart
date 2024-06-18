import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import '../api/authenticationmanager.dart';
import '../utils/constant.dart' as cons;
import '../widgets/navigation_widget.dart';
import '../widgets/buildCalendarViewWidget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../view models/diary_modelview.dart';
import '../widgets/drawer_widget.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import '../utils/admob_helper.dart';

class CalendarScreen extends StatefulWidget {
  final Function(DateTime)? onDateSelected;

  const CalendarScreen({Key? key, this.onDateSelected}) : super(key: key);

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> with SingleTickerProviderStateMixin {
  AdMobHelper adManager = AdMobHelper(
    nativeAdUnitId: cons.adUnitId,
    nativeFactoryId: 'adFactoryExample',
    rewardAdUnitId: cons.videoadUnitId,
  );
  RewardedAd? _rewardedAd;
  late Future<NativeAd> _adFuture;
  late DateTime _selectedDate;
  String? _selectedOption;
  List<Tab>? myTabs;
  TabController? tabController;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late UserAuthManager _authManager;

  @override
  void initState() {
    super.initState();
    adManager.loadRewardAd();
    _adFuture = AdMobHelper(
      nativeAdUnitId: cons.adUnitId,
      nativeFactoryId: 'adFactoryExample',
      rewardAdUnitId: cons.videoadUnitId,
    ).createNativeAd();
    _authManager = UserAuthManager();
    _authManager.init();
    tabController = TabController(vsync: this, length: cons.workouts.length);
    myTabs = cons.workouts.map((String workout) {
      return Tab(text: workout);
    }).toList();
    _selectedOption = cons.workouts[0];
    _selectedDate = DateTime.now();
    tabController?.addListener(() {
    });
    final viewModel = Provider.of<DiaryViewModel>(context, listen: false);
    viewModel.selectedDate = _selectedDate;
    viewModel.selectedOption = _selectedOption;
    viewModel.updateSelectedDateWorkouts();
    viewModel.updateMarkedDateMap();
  }

  @override
  void dispose() {
    _rewardedAd?.dispose();
    _adFuture.then((ad) => ad.dispose());
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
                          final viewModel = Provider.of<DiaryViewModel>(context, listen: false);
                          viewModel.selectedOption = cons.workouts[index];
                          viewModel.updateMarkedDateMap();
                          viewModel.updateSelectedDateWorkouts();
                        },
                      ),
                      Container(
                        color: Colors.black87,
                        child: IconButton(
                          onPressed: () {
                            Scaffold.of(context).openDrawer();
                          },
                          icon: const Icon(Icons.menu, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
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
        ],
      ),
    );
  }

  Widget _buildCalendarView() {
    final viewModel = Provider.of<DiaryViewModel>(context);
    return BuildCalendarViewWidget(
      selectedDate: viewModel.selectedDate,
      markedDateMap: viewModel.markedDateMap,
      onDayPressed: (DateTime date, List<Event> events) {
        setState(() {
          viewModel.selectedDate = date;
          viewModel.updateSelectedDateWorkouts();
        });
        if (widget.onDateSelected != null) {
          widget.onDateSelected!(date);
        }
      },
      onDateSelected: (date) => widget.onDateSelected?.call(date),
    );
  }

  Widget _buildDiaryList() {
    final viewModel = Provider.of<DiaryViewModel>(context);
    if (viewModel.selectedDateWorkouts.isNotEmpty) {
      return SingleChildScrollView(
        child: Column(
          children: [
            for (String workout in viewModel.selectedDateWorkouts)
              ListTile(
                title: Text(
                  workout,
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  _readWorkoutDiary(viewModel.selectedDate, workout, context);
                },
              ),
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  Future<void> _readWorkoutDiary(DateTime selectedDate, String workout, BuildContext context) async {
    final viewModel = Provider.of<DiaryViewModel>(context, listen: false);
    try {
      Map<String, dynamic>? diaryData = await viewModel.readWorkoutDiary(selectedDate, workout);
      if (diaryData != null) {
        String formattedDate = DateFormat('yyyy/MM/dd').format(selectedDate);

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('운동일지 내용', style: TextStyle(fontWeight: FontWeight.bold)),
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
                        Navigator.of(context).pop();
                        await _editWorkoutDiary(selectedDate, workout, context, diaryData);
                        setState(() {});
                      },
                      child: const Text('수정'),
                    ),
                    TextButton(
                      onPressed: () async {
                        String filePath = await viewModel.getFilePathForDate(selectedDate, workout);
                        File(filePath).deleteSync();
                        setState(() {
                          viewModel.selectedDateWorkouts.remove(workout);
                        });
                        viewModel.updateMarkedDateMap();
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
      }
    } catch (e) {
      // 오류 처리
    }
  }

  Future<void> _editWorkoutDiary(DateTime selectedDate, String workout, BuildContext context, Map<String, dynamic> diaryData) async {
    final viewModel = Provider.of<DiaryViewModel>(context, listen: false);
    TextEditingController textEditingController = TextEditingController()..text = diaryData['diaryText'];

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
                title: const Text('운동일지 내용 수정', style: TextStyle(fontWeight: FontWeight.bold)),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('날짜: ${DateFormat('yyyy-MM-dd').format(selectedDate)}'),
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
                        controller: TextEditingController()..text = weight.toString(),
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

                      await viewModel.editWorkoutDiary(selectedDate, workout, diaryData);

                      setState(() {
                        viewModel.updateSelectedDateWorkouts();
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
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:miniproject_exercise/views/workoutplay_screen.dart';
import 'dart:convert';
import '../utils/admob_helper.dart';
import '../utils/constant.dart';

class WorkOutSearch extends SearchDelegate<String> {
  final List<dynamic> workoutData;

  WorkOutSearch(this.workoutData);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List results = workoutData
        .expand((item) => item['small_wo'].map((wo) => wo).toList())
        .where((wo) => wo.contains(query))
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(
            results[index],
            style: TextStyle(color: Colors.black),
          ),
          onTap: () {
            // Handle onTap for search results
            _navigateToWorkout(context, results[index]);
          },
        );
      },
    );
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    assert(context != null);
    final ThemeData theme = Theme.of(context);
    assert(theme != null);
    return theme.copyWith(
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.black87), // 힌트 텍스트의 색상을 변경합니다.
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.black87),
        ),
        filled: true,
        fillColor: Colors.white, // 검색 필드의 배경색을 변경합니다.
        contentPadding: EdgeInsets.only(left: 20),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87, // 검색 화면의 배경색을 설정합니다.
      body: ListView(
        children: workoutData
            .expand((item) => item['small_wo'].map((wo) => wo).toList())
            .where((wo) => wo.contains(query))
            .map((wo) => ListTile(
          title: Text(
            wo,
            style: TextStyle(color: Colors.white),
          ),
          onTap: () {
            _navigateToWorkout(context, wo);
          },
        ))
            .toList(),
      ),
    );
  }

  void _navigateToWorkout(BuildContext context, String query) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => WorkoutPlayerScreen(query: query),
    ));
  }
}

class WorkOutLearning extends StatefulWidget {
  @override
  _WorkOutLearningState createState() => _WorkOutLearningState();
}

class _WorkOutLearningState extends State<WorkOutLearning> {
  List<dynamic> workoutData = [];

  @override
  void initState() {
    super.initState();
    _loadWorkoutData();
  }

  Future<void> _loadWorkoutData() async {
    String data = await rootBundle.loadString('assets/workout.json');
    setState(() {
      workoutData = jsonDecode(data);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: workoutData.isEmpty
          ? Center(child: CircularProgressIndicator())
          : DefaultTabController(
        length: workoutData.length,
        child: Column(
          children: [
            Stack(
              children: [
                TabBar(
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey,
                  isScrollable: true,
                  tabs: List.generate(workoutData.length, (index) {
                    return Tab(
                      text: workoutData[index]['big_wo'],
                    );
                  }),
                ),
                Container(
                  color: Colors.black87,
                  child: IconButton(
                    icon: Icon(Icons.search, color: Colors.white),
                    onPressed: () {
                      showSearch(
                        context: context,
                        delegate: WorkOutSearch(workoutData),
                      );
                    },
                  ),
                ),
              ],
            ),
            FutureBuilder<NativeAd>(
              future: AdMobHelper(
                  nativeAdUnitId: adUnitId,
                  nativeFactoryId: 'adFactoryExample',
                  rewardAdUnitId: videoadUnitId
              ).createNativeAd(),
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
            Expanded(
              child: TabBarView(
                children: List.generate(workoutData.length, (index) {
                  return ListView.builder(
                    itemCount: workoutData[index]['small_wo'].length,
                    itemBuilder: (context, idx) {
                      String exercise = workoutData[index]['small_wo'][idx];
                      return ListTile(
                        title: Text(
                          exercise,
                          style: TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  WorkoutPlayerScreen(query: exercise),
                            ),
                          );
                        },
                      );
                    },
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



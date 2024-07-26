import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../utils/constant.dart' as cons;
import '../widgets/navigation_widget.dart';
import '../widgets/buildCalendarViewWidget.dart';
import '../view models/diary_modelview.dart';
import '../widgets/drawer_widget.dart';
import '../utils/admob_helper.dart';
import 'diary_detail_screen.dart';

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


  @override
  void initState() {
    super.initState();
    adManager.loadRewardAd();
    _adFuture = AdMobHelper(
      nativeAdUnitId: cons.adUnitId,
      nativeFactoryId: 'adFactoryExample',
      rewardAdUnitId: cons.videoadUnitId,
    ).createNativeAd();
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
                onTap: () async {
                  final bool? isDeleted = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => DiaryDetailScreen(
                        selectedDate: viewModel.selectedDate,
                        workout: workout,
                      ),
                    ),
                  );

                  if (isDeleted == true) {
                    viewModel.updateSelectedDateWorkouts();
                    viewModel.updateMarkedDateMap();
                  }
                },
              ),
          ],
        ),
      );
    } else {
      return Container();
    }
  }
}

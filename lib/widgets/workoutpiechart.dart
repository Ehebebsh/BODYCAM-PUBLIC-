import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/colors.dart';

class WorkoutPieChart extends StatelessWidget {
  final List<Map<String, dynamic>> diaries;

  const WorkoutPieChart({Key? key, required this.diaries}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (diaries.isEmpty) {
      return Center(
        child: Text(
          '작성된 일지가 없습니다.',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      );
    } else {
      Map<String, int> workoutData = _getWorkoutData(diaries);

      List<PieChartSectionData> sections = workoutData.entries.map((entry) {
        return PieChartSectionData(
          value: entry.value.toDouble(),
          color: workoutColors[entry.key],
          title: entry.value.toString(),
        );
      }).toList();

      return PieChart(
        PieChartData(
          sections: sections,
          centerSpaceRadius: 70,
          startDegreeOffset: 180,
        ),
      );
    }
  }

  Map<String, int> _getWorkoutData(List<Map<String, dynamic>> diaries) {
    Map<String, int> workoutData = {};
    for (var diary in diaries) {
      String workoutType = diary['selectedOption'];
      workoutData[workoutType] = workoutData.containsKey(workoutType)
          ? workoutData[workoutType]! + 1
          : 1;
    }
    return workoutData;
  }
}

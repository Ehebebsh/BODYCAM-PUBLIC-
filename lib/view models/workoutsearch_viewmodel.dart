import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../models/workoutmodel.dart';



class WorkOutViewModel extends ChangeNotifier {
  List<WorkoutModel> _workoutData = [];

  List<WorkoutModel> get workoutData => _workoutData;

  Future<void> loadWorkoutData() async {
    String data = await rootBundle.loadString('assets/workout.json');
    List<dynamic> decodedData = jsonDecode(data);
    _workoutData = decodedData
        .map((item) => WorkoutModel(
      bigWo: item['big_wo'],
      smallWo: List<String>.from(item['small_wo']),
    ))
        .toList();
    notifyListeners();
  }

  List<String> searchResults(String query) {
    return _workoutData
        .expand((item) => item.smallWo)
        .where((wo) => wo.contains(query))
        .toList();
  }
}

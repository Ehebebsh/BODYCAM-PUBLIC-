import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/diarymodel.dart';
import '../utils/constant.dart' as cons;
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';

import '../widgets/buildmarked_date_icon_widget.dart';

class DiaryViewModel extends ChangeNotifier {
  late DateTime selectedDate;
  String? selectedOption;
  List<String> selectedDateWorkouts = [];
  EventList<Event> markedDateMap = EventList<Event>(events: {});

  Future<void> saveVideoAndDiary(String videoPath, DateTime onDateSelected,
      String selectedOption, String diaryText, {double weight = 0.0}) async {
    try {
      String videoFolder = await _getFolderPath(onDateSelected, 'videos');
      String diaryFolder = await _getFolderPath(onDateSelected, 'diaries');

      await _createFolderIfNotExists(videoFolder);
      await _createFolderIfNotExists(diaryFolder);

      String videoFileName = _getFileName(onDateSelected, selectedOption, 'mp4');
      await _copyVideoFile(videoPath, videoFolder, videoFileName);

      DiaryEntry diaryEntry = DiaryEntry(
        formattedDate: _getFormattedDate(onDateSelected),
        selectedOption: selectedOption,
        weight: weight,
        diaryText: diaryText,
        videoFileName: videoFileName,
      );

      await _saveDiary(diaryEntry, diaryFolder);
    } catch (e) {
      print('Error in saveVideoAndDiary: $e');
    }
  }

  Future<void> _saveDiary(DiaryEntry diaryEntry, String diaryFolder) async {
    try {
      String fileName = _getDiaryFileName(diaryEntry.selectedOption, diaryEntry.formattedDate);
      String filePath = '$diaryFolder/$fileName';

      String content = json.encode(diaryEntry.toJson());
      File file = File(filePath);
      await file.writeAsString(content);
    } catch (e) {
      print('Error in _saveDiary: $e');
    }
  }

  Future<String> _getFolderPath(DateTime selectedDate, String folderType) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String formattedFolder = DateFormat('yyyy-MM').format(selectedDate);
    return '${appDocDir.path}/$folderType/$formattedFolder';
  }

  Future<void> _createFolderIfNotExists(String folderPath) async {
    Directory folder = Directory(folderPath);
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }
  }

  String _getFileName(DateTime selectedDate, String selectedOption, String extension) {
    String formattedDate = _getFormattedDate(selectedDate);
    return '$selectedOption-$formattedDate.$extension';
  }

  String _getDiaryFileName(String selectedOption, String formattedDate) {
    return 'diary_${selectedOption}_$formattedDate.json';
  }

  String _getFormattedDate(DateTime dateTime) {
    return DateFormat('yyyyMMdd').format(dateTime);
  }

  Future<void> _copyVideoFile(String videoPath, String videoFolder, String videoFileName) async {
    File videoFile = File(videoPath);
    String newPath = '$videoFolder/$videoFileName';
    try {
      await videoFile.copy(newPath);
      await videoFile.delete();
    } catch (e) {
      print('Error copying or deleting video file: $e');
    }
  }

  Future<String> getFilePathForDate(DateTime selectedDate, String selectedOption) async {
    String diaryFolder = await _getFolderPath(selectedDate, 'diaries');
    String formattedDate = _getFormattedDate(selectedDate);
    String fileName = _getDiaryFileName(selectedOption, formattedDate);
    return '$diaryFolder/$fileName';
  }

  Future<void> updateSelectedDateWorkouts() async {
    selectedDateWorkouts.clear();

    if (selectedOption == '전체보기') {
      for (String workout in cons.workouts) {
        bool hasDiary = await _hasDiaryForDate(selectedDate, workout);
        if (hasDiary) {
          selectedDateWorkouts.add(workout);
        }
      }
    } else {
      bool hasDiary = await _hasDiaryForDate(selectedDate, selectedOption!);
      if (hasDiary) {
        selectedDateWorkouts.add(selectedOption!);
      }
    }

    notifyListeners();
  }

  Future<void> updateMarkedDateMap() async {
    EventList<Event> newMarkedDateMap = EventList<Event>(events: {});

    DateTime startDate = DateTime(2024, 1, 1);
    DateTime endDate = DateTime.now();

    while (startDate.isBefore(endDate)) {
      bool hasDiary = false;

      if (selectedOption == '전체보기') {
        for (String workout in cons.workouts) {
          hasDiary = await _hasDiaryForDate(startDate, workout);
          if (hasDiary) break;
        }
      } else {
        hasDiary = await _hasDiaryForDate(startDate, selectedOption!);
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

    markedDateMap = newMarkedDateMap;
    notifyListeners();
  }

  Future<bool> _hasDiaryForDate(DateTime date, String workout) async {
    String filePath = await getFilePathForDate(date, workout);
    File file = File(filePath);
    return file.existsSync();
  }

  Future<Map<String, dynamic>?> readWorkoutDiary(DateTime selectedDate, String workout) async {
    try {
      String filePath = await getFilePathForDate(selectedDate, workout);
      File file = File(filePath);

      if (await file.exists()) {
        String fileContent = await file.readAsString();
        return json.decode(fileContent) as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error in readWorkoutDiary: $e');
    }
    return null;
  }

  Future<void> editWorkoutDiary(DateTime selectedDate, String workout, Map<String, dynamic> diaryData) async {
    try {
      String existingFilePath = await getFilePathForDate(selectedDate, workout);
      String newWorkoutFilePath = await getFilePathForDate(selectedDate, diaryData['selectedOption']);

      if (existingFilePath != newWorkoutFilePath) {
        File(existingFilePath).deleteSync();
      }

      File file = File(newWorkoutFilePath);
      await file.writeAsString(json.encode(diaryData));

      await updateMarkedDateMap();
      await updateSelectedDateWorkouts();
    } catch (e) {
      print('Error in editWorkoutDiary: $e');
    }
  }
}

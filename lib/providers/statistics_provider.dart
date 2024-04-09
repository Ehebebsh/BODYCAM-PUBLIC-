import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';

class DiaryLoader {
  Future<List<Map<String, dynamic>>> loadDiaries(String selectedOption) async {
    return await _readDiaries(selectedOption);
  }

  Future<List<Map<String, dynamic>>> _readDiaries(String selectedOption) async {
    List<Map<String, dynamic>> diaries = [];
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    String diariesPath = '$appDocPath/diaries';

    try {
      List<FileSystemEntity> fileList = Directory(diariesPath).listSync(recursive: true);

      for (FileSystemEntity fileEntity in fileList) {
        if (fileEntity is File && fileEntity.path.endsWith('.json')) {
          String content = await fileEntity.readAsString();
          Map<String, dynamic> diaryData = json.decode(content);
          diaries.add(diaryData);
        }
      }
    } catch (e) {
    }

    return diaries;
  }

  Future<List<Map<String, dynamic>>> readDiariesForDateRange(DateTime startDate, DateTime endDate, String selectedOption) async {
    List<Map<String, dynamic>> diaries = [];
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    String diariesPath = '$appDocPath/diaries';

    List<DateTime> uniqueDates = [];

    try {
      List<FileSystemEntity> fileList = Directory(diariesPath).listSync(recursive: true);

      for (FileSystemEntity fileEntity in fileList) {
        if (fileEntity is File && fileEntity.path.endsWith('.json')) {
          String content = await fileEntity.readAsString();
          Map<String, dynamic> diaryData = json.decode(content);
          diaries.add(diaryData);

          String fileName = fileEntity.path.split('/').last;
          String dateString = fileName.split('_')[1].split('.')[0];
          DateTime date = DateFormat('yyyyMMdd').parse(dateString);
          uniqueDates.add(date);
        }
      }
    } catch (e) {
    }

    uniqueDates = uniqueDates.toSet().toList();
    uniqueDates.sort((a, b) => a.compareTo(b));

    return diaries;
  }
}

import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class DiaryModel {
  Future<void> saveVideoAndDiary(String videoPath, DateTime onDateSelected,
      String selectedOption, String diaryText, {double weight = 0.0}) async {
    await _saveVideoAndDiaryToAppStorage(
        videoPath, onDateSelected, selectedOption, diaryText, weight: weight);
  }

  Future<void> _saveVideoAndDiaryToAppStorage(String videoPath,
      DateTime onDateSelected, String selectedOption, String diaryText,
      {double weight = 0.0}) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();

    String formattedFolder = DateFormat('yyyy-MM').format(onDateSelected);
    String videoFolder = '${appDocDir.path}/videos/$formattedFolder';
    String diaryFolder = '${appDocDir.path}/diaries/$formattedFolder';

    Directory newVideoFolder = Directory(videoFolder);
    if (!newVideoFolder.existsSync()) {
      newVideoFolder.createSync(recursive: true);
    }

    Directory newDiaryFolder = Directory(diaryFolder);
    if (!newDiaryFolder.existsSync()) {
      newDiaryFolder.createSync(recursive: true);
    }

    String formattedDate = DateFormat('yyyyMMdd').format(onDateSelected);
    String videoFileName = '$selectedOption-$formattedDate.mp4';

    File videoFile = File(videoPath);
    String newPath = '${newVideoFolder.path}/$videoFileName';
    await videoFile.copy(newPath);

    await videoFile.delete();
    await _saveDiary(onDateSelected, selectedOption, diaryText, videoFileName, newDiaryFolder, weight: weight);
  }

  Future<void> _saveDiary(DateTime selectedDate, String selectedOption,
      String diaryText, String videoFileName, Directory newDiaryFolder, {double weight = 0.0}) async {
    Map<String, dynamic> diaryData = {
      'formattedDate': DateFormat('yyyyMMdd').format(selectedDate),
      'selectedOption': selectedOption,
      'weight': weight,
      'diaryText': diaryText,
      'videoFileName': videoFileName,
    };

    await _saveToFile(diaryData, newDiaryFolder);
  }

  Future<void> _saveToFile(Map<String, dynamic> diaryData, Directory newDiaryFolder) async {
    String formattedDate = DateFormat('yyyyMMdd').format(DateTime.now());
    String fileName = 'diary_${diaryData['selectedOption']}_$formattedDate.json';
    String filePath = '${newDiaryFolder.path}/$fileName';

    String content = json.encode(diaryData);

    File file = File(filePath);
    await file.writeAsString(content);
  }

  Future<String> getFilePathForDate(DateTime selectedDate,
      String selectedOption) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String formattedFolder = DateFormat('yyyy-MM').format(selectedDate);

    String diaryFolder = '${appDocDir.path}/diaries/$formattedFolder';
    Directory newDiaryFolder = Directory(diaryFolder);

    String formattedDate = DateFormat('yyyyMMdd').format(selectedDate);
    String fileName = 'diary_${selectedOption}_$formattedDate.json';
    String filePath = '${newDiaryFolder.path}/$fileName';

    return filePath;
  }
}

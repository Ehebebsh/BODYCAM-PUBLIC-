import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_thumbnail/video_thumbnail.dart' as video_thumbnail;
import '../utils/constant.dart' as cons;

class DiaryVideoViewModel extends ChangeNotifier {
  List<String> videoPaths = [];
  String? selectedWorkout;

  DiaryVideoViewModel() {
    _loadVideoList(cons.workouts[0]);
  }

  Future<void> _loadVideoList(String exercise) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    try {
      Directory videoDirectory = Directory('$appDocPath/videos');
      if (!videoDirectory.existsSync()) {
        videoDirectory.createSync(recursive: true);
      }
      List<FileSystemEntity> files = videoDirectory.listSync(recursive: true);
      videoPaths = files
          .where((file) {
        var fileName = file.path.split('/').last;
        var exerciseNameInFile = fileName.split('-')[0];
        return (exercise == '전체보기' ||
            exerciseNameInFile == exercise) &&
            fileName.endsWith('.mp4');
      })
          .map((file) => file.path)
          .toList();
      notifyListeners();
    } catch (e) {
      // Handle error
      print('Error loading video list: $e');
    }
  }

  Future<void> deleteVideo(String videoPath) async {
    try {
      File(videoPath).deleteSync();
      videoPaths.remove(videoPath);
      notifyListeners(); // Notify listeners after deleting video
    } catch (e) {
      // Handle error
      print('Error deleting video: $e');
    }
  }

  Future<void> shareVideo(String videoPath) async {
    final file = File(videoPath);
    if (await file.exists()) {
      await Share.shareFiles([videoPath], text: 'Check out this video!');
    }
  }

  Future<String?> renameVideo(String videoPath, String newWorkout) async {
    try {
      File oldFile = File(videoPath);
      String directory = oldFile.parent.path;
      String oldFileName = oldFile.path.split('/').last;
      List<String> nameParts = oldFileName.split('.');
      String extension = nameParts.length > 1 ? nameParts.last : '';
      String newFileName =
          '$newWorkout-${DateFormat('yyyyMMdd').format(DateTime.now())}.$extension';
      File newFile = oldFile.renameSync('$directory/$newFileName');
      videoPaths.remove(videoPath);
      videoPaths.add(newFile.path);
      notifyListeners(); // Notify listeners after renaming video
      return newFile.path;
    } catch (e) {
      // Handle error
      print('Error renaming video: $e');
      return null;
    }
  }

  Future<Uint8List?> getThumbnail(String videoPath) async {
    final uint8list = await video_thumbnail.VideoThumbnail.thumbnailData(
      video: videoPath,
      imageFormat: video_thumbnail.ImageFormat.JPEG,
      maxWidth: 128,
      quality: 25,
    );
    return uint8list;
  }

  void setSelectedWorkout(String workout) {
    selectedWorkout = workout;
    _loadVideoList(workout);
  }
}

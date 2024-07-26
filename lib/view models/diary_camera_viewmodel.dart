// view_models/camera_view_model.dart
import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../api/loginchecker.dart';
import '../views/camera_screen.dart';
import '../widgets/google_and_kakao_login_widget.dart';
import '../widgets/opendiary_dialog_widget.dart';
import '../widgets/show_alert_dialog_widget.dart';

class CameraViewModel extends ChangeNotifier {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  bool isRecording = false;
  bool isFrontCamera = false;
  String? selectedOption;
  DateTime? onDateSelected;
  bool isTimerEnabled = false;
  Timer? recordingTimer;
  List<CameraDescription>? cameras;
  int countdown = 5;
  final ConfirmDialog _confirmDialog = ConfirmDialog();

  CameraController? get controller => _controller;
  Future<void>? get initializeControllerFuture => _initializeControllerFuture;
  List<CameraDescription>? get cameraList => cameras;

  CameraViewModel() {
    _initializeController();
  }

  Future<void> _initializeController() async {
    cameras = await availableCameras();
    _controller = CameraController(
      cameras![0],
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller!.initialize();
    notifyListeners();
  }

  void openDiaryDialog(BuildContext context, String videoPath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DiaryDialog(
          onComplete: () {},
          selectedOption: selectedOption,
          videoPath: videoPath,
          selectedDate: onDateSelected,
        );
      },
    );
  }

  Future<int> getDiaryCount() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String diaryPath = '${appDocDir.path}/diaries';

    int count = 0;

    try {
      if (await Directory(diaryPath).exists()) {
        List<FileSystemEntity> yearMonthDirectories = Directory(diaryPath).listSync();
        for (FileSystemEntity yearMonthDirectory in yearMonthDirectories) {
          if (yearMonthDirectory is Directory) {
            List<FileSystemEntity> diaryFiles = yearMonthDirectory.listSync();
            count += diaryFiles
                .where((file) => file.path.endsWith('.json'))
                .toList()
                .length;
          }
        }
      }
    } catch (e) {}

    return count;
  }

  Future<bool> checkLoginAndDiary() async {
    bool isLoggedIn = await LoginChecker().checkLoginStatus();
    int diaryCount = await getDiaryCount();
    if (!isLoggedIn && diaryCount >= 10) {
      return false;
    }
    return true;
  }

  Future<void> toggleRecording(BuildContext context) async {
    if (selectedOption == null) {
      AlertDialogHelper.showAlertDialog(
        context,
        '알림',
        '운동 종류를 선택해주세요.',
      );
      return;
    }

    bool canRecord = await checkLoginAndDiary();
    if (!canRecord) {
      LoginDialogHelper.showLoginDialog(context);
      return;
    }

    if (isRecording) {
      await stopRecording(context);
    } else {
      bool diaryExists = await _checkDiaryExists(selectedOption!, DateTime.now());
      if (diaryExists) {
        bool continueRecording = await _confirmDialog.show(context, '이미 해당 운동의 일지가 존재합니다. 계속 작성하시겠습니까?');
        if (!continueRecording) {
          return;
        }
      }

      await _initializeControllerFuture;
      if (isTimerEnabled) {
        await _startCountdown();
      } else {
        await _controller!.startVideoRecording();
        isRecording = true;
        notifyListeners();
      }
    }
  }

  Future<bool> _checkDiaryExists(String exercise, DateTime date) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String diaryPath = '${appDocDir.path}/diaries';

    String searchStr = 'diary_${exercise.toLowerCase()}_${DateFormat('yyyyMMdd').format(date)}';
    try {
      if (await Directory(diaryPath).exists()) {
        List<FileSystemEntity> yearMonthDirectories = Directory(diaryPath).listSync();
        for (FileSystemEntity yearMonthDirectory in yearMonthDirectories) {
          if (yearMonthDirectory is Directory) {
            List<FileSystemEntity> diaryFiles = yearMonthDirectory.listSync();
            for (FileSystemEntity file in diaryFiles) {
              if (file.path.contains(searchStr)) {
                return true;
              }
            }
          }
        }
      }
    } catch (e) {}

    return false;
  }

  Future<void> stopRecording(BuildContext context) async {
    if (isRecording) {
      try {
        final XFile videoFile = await _controller!.stopVideoRecording();
        isRecording = false;
        notifyListeners();
        openDiaryDialog(context, videoFile.path);
      } catch (e) {
        // 예외 처리 로직 추가
      }
    }
  }

  Future<void> toggleCamera() async {
    final CameraDescription selectedCamera = isFrontCamera
        ? cameras!.firstWhere((camera) => camera.lensDirection == CameraLensDirection.back)
        : cameras!.firstWhere((camera) => camera.lensDirection == CameraLensDirection.front);

    await _controller!.dispose();
    _controller = CameraController(
      selectedCamera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller!.initialize();
    isFrontCamera = !isFrontCamera;
    notifyListeners();
  }

  Future<void> _startCountdown() async {
    for (int i = 5; i >= 1; i--) {
      countdown = i;
      notifyListeners();
      await Future.delayed(const Duration(seconds: 1));
    }

    await _controller!.startVideoRecording();
    isRecording = true;
    isTimerEnabled = false;
    countdown = 5;
    notifyListeners();
  }

  void toggleTimer() {
    isTimerEnabled = !isTimerEnabled;
    notifyListeners();
  }

  void selectOption(String? option) {
    selectedOption = option;
    notifyListeners();
  }
}



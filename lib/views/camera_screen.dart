// ignore_for_file: empty_catches, use_build_context_synchronously, library_private_types_in_public_api
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import '../api/loginchecker.dart';
import '../widgets/confirmdialog_widget.dart';
import '../widgets/google_and_kakao_login_widget.dart';
import '../widgets/opendiary_dialog_widget.dart';
import '../widgets/show_alert_dialog.dart';
import 'calendar_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ConfirmDialog _confirmDialog = ConfirmDialog();
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool isRecording = false;
  bool isFrontCamera = false;
  String? selectedOption;
  DateTime? onDateSelected;
  bool isTimerEnabled = false;
  Timer? recordingTimer;
  late List<CameraDescription> cameras;
  int countdown = 5;

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = _initializeController();
    LoginChecker().checkGoogleLoginStatus();  // 앱 시작 시 로그인 상태 확인
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeController() async {
    cameras = await availableCameras();
    _controller = CameraController(
      cameras[0],
      ResolutionPreset.medium,
    );
    return _controller.initialize();
  }



  Future<void> _openDiaryDialog(String videoPath) async {
    _showDiaryDialog(videoPath);
  }

  void _showDiaryDialog(String videoPath) {
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

  Future<int> _getDiaryCount() async {
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
    } catch (e) {
    }

    return count;
  }


  Future<void> _toggleRecording() async {
    if (selectedOption == null) {
      AlertDialogHelper.showAlertDialog(
        context,
        '알림',
        '운동 종류를 선택해주세요.',
      );
      return;
    }

    // 로그인 상태 확인
    bool isLoggedIn = await LoginChecker().checkLoginStatus();
    int diaryCount = await _getDiaryCount();
    if (!isLoggedIn && diaryCount >= 10) {
      LoginDialogHelper.showLoginDialog(context);
      return;
    }

    if (isRecording) {
      await _stopRecording();
    } else {
      // 벤치프레스 운동일지가 이미 존재하는지 확인
      bool DiaryExists = await _checkDiaryExists(selectedOption!, DateTime.now());
      if (DiaryExists) {
        bool continueRecording = await _confirmDialog.show(context, '이미 해당 운동의 일지가 존재합니다. 계속 작성하시겠습니까?');
        if (!continueRecording) {
          return; // 녹화 중지
        }
      }

      await _initializeControllerFuture;
      if (isTimerEnabled) {
        await _startCountdown();
      } else {
        await _controller.startVideoRecording();
        if (mounted) {
          setState(() {
            isRecording = true;
          });
        }
      }
    }
  }


  Future<bool> _checkDiaryExists(String exercise, DateTime date) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String diaryPath = '${appDocDir.path}/diaries';

    // 운동 이름과 날짜를 결합하여 검색 문자열을 만듭니다.
    String searchStr = 'diary_${exercise.toLowerCase()}_${DateFormat('yyyyMMdd').format(date)}';
    try {
      if (await Directory(diaryPath).exists()) {
        List<FileSystemEntity> yearMonthDirectories = Directory(diaryPath).listSync();
        for (FileSystemEntity yearMonthDirectory in yearMonthDirectories) {
          if (yearMonthDirectory is Directory) {
            List<FileSystemEntity> diaryFiles = yearMonthDirectory.listSync();
            for (FileSystemEntity file in diaryFiles) {
              // 파일 이름이 검색 문자열을 포함하면, 일지가 존재합니다.
              if (file.path.contains(searchStr)) {
                return true; // 다이어리가 이미 존재함
              }
            }
          }
        }
      }
    } catch (e) {
    }

    return false; // 다이어리가 존재하지 않음
  }



  Future<void> _stopRecording() async {
    if (isRecording) {
      try {
        final XFile videoFile = await _controller.stopVideoRecording();
        if (mounted) {
          setState(() {
            isRecording = false;
          });
          _openDiaryDialog(videoFile.path);
        }
      } catch (e) {
        // 추가적인 예외 처리 또는 디버깅 로직 추가
      }
    }
  }

  // Future<void> _navigateToCalendarScreen() async {
  //   DateTime? selectedDate = await Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => CalendarScreen(
  //         onDateSelected: (date) {
  //           setState(() {
  //             onDateSelected = date;
  //           });
  //         },
  //       ),
  //     ),
  //   );
  //
  //   if (selectedDate != null) {
  //     _openDiaryDialog(selectedDate.toString());
  //   }
  // }

  Future<void> _toggleCamera() async {
    final CameraDescription selectedCamera = isFrontCamera
        ? cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.back)
        : cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.front);

    await _controller.dispose();
    _controller = CameraController(
      selectedCamera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();

    if (mounted) {
      setState(() {
        isFrontCamera = !isFrontCamera;
      });
    }
  }

  Future<void> _startCountdown() async {
    for (int i = 5; i >= 1; i--) {
      await Future.microtask(() {});
      if (!mounted) return;
      setState(() {
        countdown = i;
      });
      await Future.delayed(const Duration(seconds: 1));
    }

    await _controller.startVideoRecording();
    if (mounted) {
      setState(() {
        isRecording = true;
        isTimerEnabled = false;
        countdown = 5;
      });
    }
  }


  void _toggleTimer() {
    setState(() {
      isTimerEnabled = !isTimerEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                // CameraPreview를 AspectRatio로 감싸서 카메라 출력의 비율을 4:3으로 고정
                return AspectRatio(
                  aspectRatio: 4 / 3,
                  child: CameraPreview(_controller),
                );
              } else if (snapshot.hasError) {
                return const Center(child: Text('Error initializing camera'));
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),

          Positioned(
            top: MediaQuery.of(context).size.height * 0.02,
            right: MediaQuery.of(context).size.width * 0.05,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: _toggleCamera,
                  icon: Icon(isFrontCamera ? Icons.sync : Icons.sync),
                  color: Colors.white,
                ),
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.02,
            left: MediaQuery.of(context).size.width * 0.05,
            child: IconButton(
              onPressed: _toggleTimer,
              icon: Icon(
                isTimerEnabled ? Icons.timer : Icons.timer_off,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.02,
            left: MediaQuery.of(context).size.width * 0.01,
            right: 0,
            child: Center(
              child: SingleChildScrollView(
                child: DropdownButton<String>(
                  value: selectedOption,
                  hint: const Text(
                    '운동 종류',
                    style: TextStyle(color: Colors.white,
                        fontFamily:'Ownglyph_Dailyokja-Rg'),
                  ),
                  style: const TextStyle(color: Colors.white),
                  dropdownColor: Colors.black,
                  iconEnabledColor: Colors.white,
                  items: const [
                    DropdownMenuItem<String>(
                      value: '데드리프트',
                      child: Text('데드리프트', style: TextStyle(color: Colors.white,
                      fontFamily:'Ownglyph_Dailyokja-Rg')),
                    ),
                    DropdownMenuItem<String>(
                      value: '바벨 로우',
                      child: Text('바벨 로우', style: TextStyle(color: Colors.white,
                          fontFamily:'Ownglyph_Dailyokja-Rg')),
                    ),
                    DropdownMenuItem<String>(
                      value: '덤벨 로우',
                      child: Text('덤벨 로우', style: TextStyle(color: Colors.white,
                          fontFamily:'Ownglyph_Dailyokja-Rg')),
                    ),
                    DropdownMenuItem<String>(
                      value: '벤치프레스',
                      child: Text('벤치프레스', style: TextStyle(color: Colors.white,
                          fontFamily:'Ownglyph_Dailyokja-Rg')),
                    ),
                    DropdownMenuItem<String>(
                      value: '인클라인 벤치프레스',
                      child: Text('인클라인 벤치프레스', style: TextStyle(color: Colors.white,
                          fontFamily:'Ownglyph_Dailyokja-Rg')),
                    ),
                    DropdownMenuItem<String>(
                      value: '덤벨 벤치프레스',
                      child: Text('덤벨 벤치프레스', style: TextStyle(color: Colors.white,
                          fontFamily:'Ownglyph_Dailyokja-Rg')),
                    ),
                    DropdownMenuItem<String>(
                      value: '바벨 백 스쿼트',
                      child: Text('바벨 백 스쿼트', style: TextStyle(color: Colors.white,
                          fontFamily:'Ownglyph_Dailyokja-Rg')),
                    ),
                    DropdownMenuItem<String>(
                      value: '에어 스쿼트',
                      child: Text('에어 스쿼트', style: TextStyle(color: Colors.white,
                          fontFamily:'Ownglyph_Dailyokja-Rg')),
                    ),
                    DropdownMenuItem<String>(
                      value: '점프 스쿼트',
                      child: Text('점프 스쿼트', style: TextStyle(color: Colors.white,
                          fontFamily:'Ownglyph_Dailyokja-Rg')),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedOption = value;
                    });
                  },
                  underline: Container(
                    height: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.05,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // IconButton(
                //   onPressed: () {
                //     _navigateToCalendarScreen();
                //   },
                //   icon: const Icon(Icons.calendar_today),
                //   color: Colors.white,
                // ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white,
                      width: 3.0,
                    ),
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _toggleRecording,
                    icon: Icon(
                      isRecording ? Icons.stop : Icons.fiber_manual_record,
                      color: isRecording ? Colors.white : Colors.red,
                    ),
                    iconSize: 40.0,
                  ),
                ),
                // IconButton(
                //   onPressed: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(builder: (context) => const CustomGalleryScreen()),
                //     );
                //   },
                //   icon: const Icon(Icons.photo_library),
                //   color: Colors.white,
                // ),
              ],
            ),
          ),
          if (isTimerEnabled && countdown > 0)
            Center(
              child: Text(
                countdown.toString(),
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width /5,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

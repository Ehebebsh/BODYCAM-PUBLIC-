import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:miniproject_exercise/utils/constant.dart' as cons;

import '../utils/admob_helper.dart';

class VideoListScreen extends StatefulWidget {
  @override
  _VideoListScreenState createState() => _VideoListScreenState();
}

class _VideoListScreenState extends State<VideoListScreen> {
  List<String> videoPaths = []; // 비디오 경로들을 관리하는 상태

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: videoPaths.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(videoPaths[index]),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => DeleteVideoDialog(
                  videoPath: videoPaths[index],
                  onVideoDeleted: () {
                    setState(() {
                      videoPaths.removeAt(index); // 삭제된 비디오를 목록에서 제거
                    });
                  },
                  onVideoRenamed: (newPath) {
                    setState(() {
                      videoPaths[index] = newPath; // 새로운 파일 경로로 업데이트
                    });
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class DeleteVideoDialog extends StatefulWidget {
  final String videoPath;
  final VoidCallback onVideoDeleted;
  final Function(String) onVideoRenamed;

  DeleteVideoDialog(
      {Key? key, required this.videoPath, required this.onVideoDeleted, required this.onVideoRenamed,})
      : super(key: key);

  @override
  State<DeleteVideoDialog> createState() => _DeleteVideoDialogState();
}

class _DeleteVideoDialogState extends State<DeleteVideoDialog> {
  AdMobHelper adManager = AdMobHelper(
    nativeAdUnitId: cons.adUnitId,
    nativeFactoryId: 'adFactoryExample',
    rewardAdUnitId: cons.videoadUnitId,
  );

  @override void initState() {
    // TODO: implement initState
    super.initState();
    adManager.loadRewardAd();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: const Text(
        "정말로 이 영상을 삭제하시겠습니까?",
        style: TextStyle(fontSize: 20),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // 다이얼로그 닫기
          },
          child: const Text("취소"),
        ),
        TextButton(
          onPressed: () {
            _deleteVideo(widget.videoPath, context); // 영상 삭제 함수 호출
          },
          child: const Text("삭제"),
        ),
        TextButton(
          onPressed: () {
            _shareVideo(widget.videoPath); // 영상 공유 함수 호출
          },
          child: const Text("공유"),
        ),
        TextButton(
          onPressed: () {
            adManager.loadRewardAd();
            adManager.showRewardAd();
            _editVideoName(widget.videoPath, context); // 파일명 변경 함수 호출
          },
          child: const Text("수정"),
        ),
      ],
    );
  }

  void _deleteVideo(String videoPath, BuildContext context) {
    try {
      File(videoPath).deleteSync();
      widget.onVideoDeleted(); // 삭제 이벤트를 외부로 전달
      Navigator.pop(context); // 다이얼로그 닫기
    } catch (e) {}
  }

  Future<void> _shareVideo(String videoPath) async {
    final file = File(videoPath);
    if (await file.exists()) {
      await Share.shareFiles([videoPath], text: 'Check out this video!');
    }
  }

  Future<void> _editVideoName(String videoPath, BuildContext context) async {
    List<String> workoutOptions = List.from(cons.workouts); // 복사본 생성
    workoutOptions.remove('전체보기'); // '전체보기' 옵션 제거

    // 파일명에서 운동명 추출
    String fileName = videoPath
        .split('/')
        .last
        .split('-')[0];
    String selectedWorkout = workoutOptions.contains(fileName)
        ? fileName
        : workoutOptions[0];

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('운동 종류 선택'),
              content: DropdownButton<String>(
                value: selectedWorkout,
                onChanged: (String? newValue) {
                  setState(() { // setState를 사용해 실시간으로 반영
                    selectedWorkout = newValue!;
                  });
                },
                items: workoutOptions.map((String workout) {
                  return DropdownMenuItem<String>(
                    value: workout,
                    child: Text(workout),
                  );
                }).toList(),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('취소'),
                ),
                TextButton(
                  onPressed: () {
                    _renameVideo(
                        videoPath, selectedWorkout, context);
                    Navigator.pop(context);// 파일명 변경 함수 호출
                  },

                  child: const Text('확인'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _renameVideo(String videoPath, String newWorkout, BuildContext context) {
    try {
      File oldFile = File(videoPath);
      String directory = oldFile.parent.path;
      String oldFileName = oldFile.path
          .split('/')
          .last;

      // 확장자를 포함한 기존 파일명에서 확장자를 분리합니다.
      List<String> nameParts = oldFileName.split('.');
      String extension = nameParts.length > 1 ? nameParts.last : '';
      String newFileName = newWorkout + '-' +
          DateFormat('yyyyMMdd').format(DateTime.now()) + '.' + extension;

      // 전체보기가 아닐 때만 새 파일명으로 파일을 이동시킵니다.
      if (newWorkout != '전체보기') {
        // 새 파일명으로 파일을 이동시킵니다.
        File newFile = oldFile.renameSync('$directory/$newFileName');
        widget.onVideoRenamed(newFile.path);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}


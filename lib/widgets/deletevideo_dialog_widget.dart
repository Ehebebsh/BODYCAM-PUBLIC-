import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constant.dart' as cons;
import '../view models/diary_video_modelview.dart';

class DeleteVideoDialog extends StatelessWidget {
  final String videoPath;

  const DeleteVideoDialog({
    Key? key,
    required this.videoPath,
    required Null Function() onVideoDeleted,
    required Null Function(dynamic newPath) onVideoRenamed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<DiaryVideoViewModel>(context, listen: false);

    return AlertDialog(
      title: Text(
        "영상 삭제",
        style: TextStyle(fontSize: 20),
      ),
      content: Text(
        "정말로 이 영상을 삭제하시겠습니까?",
        style: TextStyle(fontSize: 16),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("취소"),
        ),
        TextButton(
          onPressed: () {
            viewModel.deleteVideo(videoPath);
            Navigator.pop(context);
          },
          child: const Text("삭제"),
        ),
        TextButton(
          onPressed: () {
            _showRenameDialog(context, viewModel);
          },
          child: const Text("수정"),
        ),
        TextButton(
          onPressed: () {
            _shareVideo(context, viewModel, videoPath);
          },
          child: const Text("공유"),
        ),
      ],
    );
  }

  void _showRenameDialog(BuildContext context, DiaryVideoViewModel viewModel) async {
    String? selectedWorkout = viewModel.selectedWorkout;

    selectedWorkout = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("운동 선택"),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedWorkout,
                    hint: Text("운동 선택"),
                    items: cons.workouts.where((workout) => workout != '전체보기').map((workout) {
                      return DropdownMenuItem<String>(
                        value: workout,
                        child: Text(workout),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedWorkout = value;
                      });
                    },
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (selectedWorkout != null) {
                        Navigator.pop(context, selectedWorkout);
                        // 변경된 내용을 반영하기 위해 화면을 갱신합니다.
                        await viewModel.renameVideo(videoPath, selectedWorkout!);
                        // 파일 경로가 변경되었으므로 UI를 갱신합니다.
                        Provider.of<DiaryVideoViewModel>(context, listen: false).notifyListeners();
                      }
                    },
                    child: Text("저장"),
                  ),
                ],
              );
            },
          ),
        );
      },
    );

    // 선택된 운동이 null이 아니고 다이얼로그가 닫혔을 때 실행됩니다.
    if (selectedWorkout != null) {
      // 파일 경로가 변경되었으므로 UI를 갱신합니다.
      Provider.of<DiaryVideoViewModel>(context, listen: false).notifyListeners();
    }
  }





  void _shareVideo(BuildContext context, DiaryVideoViewModel viewModel, String videoPath) {
    viewModel.shareVideo(videoPath);
  }
}

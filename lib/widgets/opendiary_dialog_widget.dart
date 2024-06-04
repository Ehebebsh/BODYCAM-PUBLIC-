import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/diarymodel.dart';
import 'package:flutter/services.dart';

import '../views/calendar_screen.dart';


// ignore: must_be_immutable
class DiaryDialog extends StatefulWidget {
  DiaryDialog({
    Key? key,
    required this.onComplete,
    required this.selectedOption,
    this.imagePath,
    this.cameraController,
    this.videoPath,
    this.selectedDate,
  }) : super(key: key);

  final VoidCallback onComplete;
  DateTime? selectedDate;
  String? selectedOption;
  String? imagePath;
  CameraController? cameraController;
  String? videoPath;

  @override
  // ignore: library_private_types_in_public_api
  _DiaryDialogState createState() => _DiaryDialogState();
}


class _DiaryDialogState extends State<DiaryDialog> {
  final TextEditingController _diaryTextController = TextEditingController();
  final TextEditingController _weightController = TextEditingController(); // 추가된 부분
  final DiaryModel _diaryModel = DiaryModel();

  DateTime get selectedDate => _selectedDate ?? DateTime.now();
  DateTime? _selectedDate;



  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: AlertDialog(
        content: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                DateFormat('yyyy/MM/dd').format(selectedDate),
                style: const TextStyle(fontSize: 16),
              ),
              if (widget.selectedOption != null) ...[
                const SizedBox(height: 16),
                Text(
                  widget.selectedOption!,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
              if (widget.selectedOption != null) ...[
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _weightController, // 추가된 부분
                decoration: const InputDecoration(
                  labelText: '중량 (기본값: kg)',
                  hintText: '중량을 입력하세요.',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '중량을 입력하세요.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _diaryTextController,
                decoration: const InputDecoration(
                  labelText: '운동 일지',
                  hintText: '운동 내용을 기록해 보세요.',
                ),
                maxLines: null,
                keyboardType: TextInputType.text,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedDate = null;
                widget.selectedOption = null;
              });
              _diaryTextController.clear();
              _weightController.clear(); // 추가된 부분
              Navigator.pop(context);
            },
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              _saveDiary();
              if (_validateForm()) {
                // 키보드를 내립니다.
                FocusScope.of(context).unfocus();

                // CircularIndicator 표시
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                );

                // 작성 완료 동작을 3초 딜레이 시킵니다.
                await Future.delayed(Duration(seconds: 3));

                // CircularIndicator 닫기
                Navigator.pop(context);

                // Diary 저장 및 페이지 이동
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const CalendarScreen()),
                      (route) => false,
                );
              }
            },
            child: const Text('작성 완료'),
          )
        ],
      ),
    );
  }


  bool _validateForm() {
    if (_weightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('중량을 입력하세요.'),
      ));
      return false;
    }
    return true;
  }

  void _saveDiary() {
    _diaryModel.saveVideoAndDiary(
      widget.videoPath ?? '',
      selectedDate,
      widget.selectedOption ?? '',
      _diaryTextController.text,
      weight: double.tryParse(_weightController.text) ?? 0.0, // 추가된 부분
    );
  }
}



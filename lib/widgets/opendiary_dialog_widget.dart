
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../view models/diary_modelview.dart';
import '../views/calendar_screen.dart';


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
  _DiaryDialogState createState() => _DiaryDialogState();
}

class _DiaryDialogState extends State<DiaryDialog> {
  final TextEditingController _diaryTextController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  late final DiaryViewModel _diaryViewModel = DiaryViewModel();

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
                controller: _weightController,
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
              _weightController.clear();
              Navigator.pop(context);
            },
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              _saveDiary();
              if (_validateForm()) {
                FocusScope.of(context).unfocus();
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                );
                await Future.delayed(Duration(seconds: 3));
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CalendarScreen()),
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
    _diaryViewModel.saveVideoAndDiary(
      widget.videoPath ?? '',
      selectedDate,
      widget.selectedOption ?? '',
      _diaryTextController.text,
      weight: double.tryParse(_weightController.text) ?? 0.0,
    );
  }
}




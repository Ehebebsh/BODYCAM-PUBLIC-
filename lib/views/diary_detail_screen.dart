import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../view models/diary_modelview.dart';
import '../utils/constant.dart' as cons;

class DiaryDetailScreen extends StatefulWidget {
  final DateTime selectedDate;
  final String workout;

  const DiaryDetailScreen({
    Key? key,
    required this.selectedDate,
    required this.workout,
  }) : super(key: key);

  @override
  _DiaryDetailScreenState createState() => _DiaryDetailScreenState();
}

class _DiaryDetailScreenState extends State<DiaryDetailScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  late String _selectedOption;
  late double _weight;
  Map<String, dynamic>? _diaryData;
  bool _isEditMode = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final viewModel = Provider.of<DiaryViewModel>(context, listen: false);
    viewModel
        .readWorkoutDiary(widget.selectedDate, widget.workout)
        .then((data) {
      setState(() {
        _diaryData = data!;
        _textEditingController.text = _diaryData!['diaryText'];
        _selectedOption = _diaryData!['selectedOption'];
        _weight = _diaryData!['weight'];
      });
    });
  }

  Future<void> _confirmDelete() async {
    final bool? isConfirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text('삭제 확인',
              style: TextStyle(color: Colors.white, fontSize: 18)),
          content: const Text(
            '정말로 이 일지를 삭제하시겠습니까?',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('네',
                  style: TextStyle(color: Colors.blue, fontSize: 16)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('아니요',
                  style: TextStyle(color: Colors.red, fontSize: 16)),
            ),
          ],
        );
      },
    );

    if (isConfirmed == true) {
      final viewModel = Provider.of<DiaryViewModel>(context, listen: false);
      String filePath = await viewModel.getFilePathForDate(
          widget.selectedDate, widget.workout);
      File(filePath).deleteSync();
      viewModel.updateMarkedDateMap();
      Navigator.of(context).pop(true); // 삭제 후 true 반환
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // 배경 색상
      appBar: AppBar(
        backgroundColor: Colors.grey[850], // 어두운 배경 색상
        title: const Text('운동일지 상세',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        actions: [
          if (!_isEditMode)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white, size: 24),
              onPressed: () {
                setState(() {
                  _isEditMode = true;
                });
              },
            ),
          if (!_isEditMode)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white, size: 24),
              onPressed: () {
                _confirmDelete();
              },
            ),
        ],
      ),
      body: _diaryData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '날짜: ${DateFormat('yyyy/MM/dd').format(widget.selectedDate)}',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  if (_isEditMode)
                    DropdownButton<String>(
                      dropdownColor: Colors.grey[800], // 드롭다운 배경 색상
                      value: _selectedOption,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedOption = newValue!;
                        });
                      },
                      items: cons.workouts
                          .where((workout) => workout != '전체보기') // "전체보기" 제외
                          .map((String workout) {
                        return DropdownMenuItem<String>(
                          value: workout,
                          child: Text(workout,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16)),
                        );
                      }).toList(),
                    )
                  else
                    Text(
                      '운동 종류: $_selectedOption',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500),
                    ),
                  const SizedBox(height: 12),
                  const Text(
                    '중량:',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500),
                  ),
                  if (_isEditMode)
                    TextField(
                      controller: TextEditingController()
                        ..text = _weight.toString(),
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                      decoration: InputDecoration(
                        fillColor: Colors.grey[800],
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        hintText: '중량을 입력하세요',
                        hintStyle:
                            TextStyle(color: Colors.grey[400], fontSize: 16),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          try {
                            _weight = double.parse(value);
                          } catch (e) {
                            _weight = 0.0;
                          }
                        } else {
                          _weight = 0.0;
                        }
                      },
                    )
                  else
                    Text(
                      '$_weight kg',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500),
                    ),
                  const SizedBox(height: 12),
                  const Text(
                    '일지 내용:',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500),
                  ),
                  if (_isEditMode)
                    TextField(
                      controller: _textEditingController,
                      maxLines: null,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                      decoration: InputDecoration(
                        fillColor: Colors.grey[800],
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        hintText: '일지 내용을 입력하세요',
                        hintStyle:
                            TextStyle(color: Colors.grey[400], fontSize: 16),
                      ),
                    )
                  else
                    Text(
                      _textEditingController.text,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  const SizedBox(height: 20),
                  if (_isEditMode)
                    _isSaving
                        ? Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                _isSaving = true; // 저장 시작
                              });
                              final viewModel = Provider.of<DiaryViewModel>(
                                  context,
                                  listen: false);
                              _diaryData!['selectedOption'] = _selectedOption;
                              _diaryData!['weight'] = _weight;
                              _diaryData!['diaryText'] =
                                  _textEditingController.text;

                              await viewModel.editWorkoutDiary(
                                  widget.selectedDate,
                                  widget.workout,
                                  _diaryData!);

                              viewModel.updateSelectedDateWorkouts();

                              setState(() {
                                _isSaving = false; // 저장 완료
                                _isEditMode = false;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.blueGrey,
                              // 버튼 텍스트 색상
                              padding: EdgeInsets.symmetric(
                                  vertical: 16.0, horizontal: 24.0),
                              textStyle: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'Ownglyph_Dailyokja-Rg'),
                            ),
                            child: const Text('저장'),
                          ),
                ],
              ),
            ),
    );
  }
}

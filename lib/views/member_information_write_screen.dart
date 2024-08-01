import 'package:flutter/material.dart';
import 'package:gsform/gs_form/widget/field.dart';
import 'package:gsform/gs_form/widget/form.dart';
import 'package:gsform/gs_form/widget/section.dart';
import '../view models/user_viewmodel.dart';
import '../widgets/gsdatepicker.dart';
import '../widgets/gsradio.dart';
import 'calendar_screen.dart';

class MultiSectionForm extends StatefulWidget {
  @override
  _MultiSectionFormState createState() => _MultiSectionFormState();
}

class _MultiSectionFormState extends State<MultiSectionForm> {
  final MultiSectionFormViewModel _viewModel = MultiSectionFormViewModel();
  GSForm? form;
  String? selectedGender;
  DateTime? selectedBirthdate;

  bool canPop = false;

  @override
  void initState() {
    super.initState();
    _viewModel.initializeFirebase();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    if (form == null || !form!.isValid()) {
      debugPrint('Form is not valid. Not saving data to Firestore.');
      return;
    }

    final formData = form!.onSubmit();
    try {
      await _viewModel.saveForm(formData, selectedGender, selectedBirthdate);
      setState(() {
        canPop = true;
      });
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => CalendarScreen()),
              (route) => false
      );
    } catch (e) {
      debugPrint(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving data: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    form ??= GSForm.multiSection(context, sections: [
      GSSection(
        sectionTitle: '회원정보',
        fields: [
          GSField.text(
            tag: '이름',
            title: '이름',
            minLine: 1,
            maxLine: 1,
            required: true,
          ),
          GSRadio(
            tag: '성별',
            title: '성별',
            items: ['남자', '여자'],
            value: selectedGender,
            onChanged: (String? value) {
              setState(() {
                selectedGender = value;
              });
            },
          ),
          GSDatePicker(
            tag: '생년월일',
            title: '생년월일',
            selectedDate: selectedBirthdate,
            onDateChanged: (DateTime date) {
              setState(() {
                selectedBirthdate = date;
              });
            },
          ),
          GSField.text(
            tag: '이메일',
            title: '이메일',
            minLine: 1,
            maxLine: 1,
            required: true,
          ),
          GSField.number(
            tag: '키',
            title: '키',
            weight: 12,
            required: true,
          ),
          GSField.number(
            tag: '몸무게',
            title: '몸무게',
            weight: 12,
            required: true,
          ),
        ],
      ),
    ]);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('회원정보입력'),
      ),
      body: WillPopScope(
        onWillPop: () async => canPop,
        child: Padding(
          padding: const EdgeInsets.only(left: 12.0, right: 12, top: 24),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: form,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveForm,
                        child: const Text('저장'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

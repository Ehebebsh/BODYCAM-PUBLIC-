import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gsform/gs_form/widget/field.dart';
import 'package:gsform/gs_form/widget/form.dart';
import 'package:gsform/gs_form/widget/section.dart';
import '../api/firestoreupdate.dart';
import '../api/loginchecker.dart';
import '../models/gsdatepicker.dart';
import '../models/gsradio.dart';
import 'package:android_id/android_id.dart';
import 'package:flutter/services.dart';

class MultiSectionForm extends StatefulWidget {
  @override
  _MultiSectionFormState createState() => _MultiSectionFormState();
}

class _MultiSectionFormState extends State<MultiSectionForm> {
  final FirestoreService _firestoreService = FirestoreService();
  static const _androidIdPlugin = AndroidId();
  GSForm? form;
  String? selectedGender;
  DateTime? selectedBirthdate;
  late User? user; // Firebase 사용자 객체
  late StreamSubscription<User?> _authSubscription;
  var _androidId = 'Unknown';

  bool canPop = false; // 뒤로가기 허용 여부를 저장하는 변수

  @override
  void initState() {
    super.initState();
    _initAndroidId();
    initializeFirebase();
  }

  Future<void> _initAndroidId() async {
    String androidId;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      androidId = await _androidIdPlugin.getId() ?? 'Unknown ID';
    } on PlatformException {
      androidId = 'Failed to get Android ID.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() => _androidId = androidId);
  }

  Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
    user = FirebaseAuth.instance.currentUser;
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((User? currentUser) {
      setState(() {
        user = currentUser;
      });
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel(); // Auth 상태 변경 감지 중지
    super.dispose();
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
        onWillPop: () async => canPop, // 뒤로가기 이벤트를 핸들링하여 변수에 따라 허용/차단
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
                      flex: 1,
                      child: ElevatedButton(
                        onPressed: () async {
                          bool isValid = form!.isValid();
                          if (isValid) {
                            Map<String, dynamic> formData = form!.onSubmit();
                            debugPrint(isValid.toString());
                            debugPrint(formData.toString());

                            try {
                              if (user != null) {
                                // Firebase Authentication으로부터 UID를 가져옵니다.
                                String uid = user!.uid;

                                // Firestore에서 기존 사용자 데이터를 불러옵니다.
                                Map<String, dynamic>? oldData = await _firestoreService.loadUserData(_androidId);
                                bool isGoogleSignedIn = await LoginChecker().checkGoogleLoginStatus();
                                bool isKakaoSignedIn = await LoginChecker().checkKakaoLoginStatus();
                                Map<String, dynamic> selectedData = {
                                  'name': formData['이름'],
                                  'sex': selectedGender,
                                  'birth': Timestamp.fromDate(selectedBirthdate!),
                                  'e-mail': formData['이메일'],
                                  'tall': formData['키'],
                                  'weight': formData['몸무게'],
                                  'uid': uid,
                                  'platform': isGoogleSignedIn ? 'google' : isKakaoSignedIn ? 'kakao' : 'none',
                                  ...?oldData, // 기존 데이터를 새로운 데이터에 병합합니다.
                                };

                                // UserData 객체를 업데이트합니다.

                                // Firestore에 'googleusers' 컬렉션으로 문서를 추가하고, 문서 이름을 사용자 UID로 설정합니다.
                                await FirebaseFirestore.instance.collection('realusers').doc(_androidId).set(selectedData);
                                debugPrint('Data saved to Firestore successfully');

                                // 'users' 컬렉션에서 해당 사용자의 데이터를 삭제합니다.
                                await FirebaseFirestore.instance.collection('users').doc(_androidId).delete();
                                debugPrint('Data deleted from Firestore successfully');

                                // 저장 버튼을 누르면 뒤로가기 허용
                                setState(() {
                                  canPop = true;
                                });

                                // Navigate back to the previous screen
                                Navigator.pop(context);
                              } else {
                                debugPrint('User is not authenticated.');
                              }
                            } catch (e) {
                              debugPrint('Error saving data to Firestore: $e');
                            }
                          } else {
                            debugPrint('Form is not valid. Not saving data to Firestore.');
                          }
                        },
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





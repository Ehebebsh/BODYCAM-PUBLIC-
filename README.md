# <img src="https://github.com/user-attachments/assets/bodycam-logo" width="30 " height="30"> Bodycam

> **운동 영상을 기록하고 학습할 수 있는 앱**

---

## 📅 **제작 기간 & 참여 인원**
- **기간**: 2024년 6월 1일 ~ 7월 15일
- **참여 인원**: 개인 프로젝트

## 📜 **기획 문서**
- [기획서 보기](https://docs.google.com/presentation/d/your-plan-link)

## 🛠 **사용 기술**

### Back-end
- Firebase (유저 인증 및 데이터 저장)

### Front-end
- Flutter

## 🎯 **프로젝트 목표**

1. 사용자가 자신의 운동 영상을 기록하고 리뷰할 수 있는 기능 구현
2. YouTube 연동을 통해 다양한 운동 방법을 학습할 수 있도록 지원
3. 사용자 친화적인 UI/UX 디자인 제공
4. **MVVM 아키텍처**를 통한 코드 구조화

## 🗝 **핵심 기능**

1. **운동 영상 기록 기능**  
   - 사용자는 앱을 통해 직접 운동 영상을 찍고 기록할 수 있음.
   
2. **YouTube 영상 학습 기능**  
   - 유튜브에서 운동 영상을 찾아보고, 해당 운동을 학습할 수 있음.

## 🚧 **핵심 트러블 슈팅**

1. **카카오 소셜 로그인 기능**
   - 공식 문서를 참고하여 카카오톡 소셜 로그인 구현  
   - [카카오 로그인 방법 보기](https://velog.io/@gwi060722/Flutter-%EC%B9%B4%EC%B9%B4%EC%98%A4%ED%86%A1-%EB%A1%9C%EA%B7%B8%EC%9D%B8-%EB%B0%A9%EB%B2%95)

2. **AdMob Native 광고 설정**
   - 공식 문서를 참고하여 AdMob Native 광고를 설정  
   - [AdMob 광고 설정 방법 보기](https://velog.io/@gwi060722/%EC%9A%B4%EB%8F%99%EC%9D%BC%EC%A7%80-%EC%95%B1-%EB%A7%8C%EB%93%A4%EA%B8%B0Native-%EA%B4%91%EA%B3%A0)

3. **일지 수정 및 삭제 시 화면 리빌딩 문제**
   - setState 호출로 인해 발생한 화면 리빌딩 문제를 Provider를 사용하여 해결

4. **회원 정보 입력 페이지 문제**
   - 앱을 재다운로드할 때 기존 회원도 정보 입력을 강제하게 되는 문제를 Firestore 문서 확인을 통해 해결  
<details>
<summary>💻 코드</summary>
<div markdown="1">

 
dart
  static Future<void> signInWithGoogleAndNavigate(BuildContext context) async {
    try {
      await GoogleLogin.signInWithGoogle(context);
      // 구글 로그인 후 Firestore에서 문서 확인
      await checkFirestoreDocumentAndNavigate(context);
    } catch (e) {
    }
  }

  static Future<void> signInWithKakaoAndNavigate(BuildContext context) async {
    try {
      bool loginSuccess = await kakao.KakaoLogin().login();
      if (loginSuccess) {
        // 카카오 로그인 후 Firestore에서 문서 확인
        await checkFirestoreDocumentAndNavigate(context);
      }
    } catch (e) {
    }
  }

  static Future<void> checkFirestoreDocumentAndNavigate(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Firestore에서 해당 사용자의 문서를 가져옵니다.
        final docSnapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

        if (docSnapshot.exists) {
          Navigator.of(context).pop();
          // 예를 들어 다른 화면으로 이동하도록 처리할 수 있습니다.
        } else {
          // 문서가 존재하지 않는 경우 MultiSectionForm 화면으로 이동
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MultiSectionForm()),
          );
        }
      } else {
      }
    } catch (e) {
    }
  }
}


</div>
</details>

5. **회원 정보 가져오기 문제**
   - firebase auth에서 인증된 사용자의 유무를 확인하여 정보를 가져오게 하여 해결
<details>
<summary>💻 코드</summary>
<div markdown="1">

 
dart
Future<UserModel?> getUserData() async {
    if (user == null) {
      throw Exception('User is not authenticated.');
    }

    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      throw Exception('Error fetching data from Firestore: $e');
    }
    return null;
  }
}


</div>
</details>

## 🔧 **그 외 트러블 슈팅**

1. **fl_chart 패키지 이용하기**
   - 공식 문서를 참고하여 운동 기록을 시각적으로 표시하기 위해 fl_chart 패키지를 사용

2. **운동 배우기 TapBar에 많은 운동 넣기**
   - 부위별 운동 종류가 많아 JSON 파일을 만들어 사용하여 효율적으로 TapBar에 운동 데이터를 관리

3. **카메라 Timer 설정하기**
   - 운동 촬영 시 사용자가 편리하게 녹화를 시작할 수 있도록 카메라 타이머 기능 추가

4. **같은 날짜에 똑같은 운동 기록 작성 문제**
   - 사용자가 동일한 날짜에 동일한 운동을 중복 기록하려는 경우, 녹화 버튼을 누를 때 경고 다이얼로그를 표시하여 중복 기록 방지

5. **영상 갤러리에서 운동별 영상 필터링 오류**
   - 유사한 운동명(예: 벤치프레스, 인클라인 벤치프레스)으로 인해 발생한 중복 필터링 문제를 해결하여, 같은 운동으로 처리되지 않도록 개선

  
dart
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
    }
  }


## **앱 실행 화면**
<img src=""  width="200">
<img src=""  width="200">
<img src=""  width="200">
<img src=""  width="200">
<img src=""  width="200">
<img src=""  width="200">


## 📥 **다운로드 링크**

- [Google Play Store에서 다운로드](https://play.google.com/store/apps/details?id=com.junhajeonghoon.bodycam&pli=1)

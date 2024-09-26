# <img src="https://github.com/user-attachments/assets/23c90a90-e1f6-4e5f-9927-43db17b5570c" width="30 " height="30"> Bodycam

> **운동 영상을 기록하고 학습할 수 있는 앱**

---

## 📥 **다운로드 링크**

- [Google Play Store에서 다운로드](https://play.google.com/store/apps/details?id=com.junhajeonghoon.bodycam&pli=1)

## 📅 **제작 기간 & 참여 인원**
- **기간**: 2024년 1월 10일 ~ 3월 14일
- **참여 인원**: 개인 프로젝트

## 📜 **기획 문서**
- [기획서 보기](https://docs.google.com/presentation/d/1DVgyMomPgWympdMpRhiSHV0duIjlyKPEhIpxy5Tyw1w/edit#slide=id.g30555caeb2d_0_0)

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

**1. 카카오 소셜 로그인 기능**
   - 공식 문서를 참고하여 카카오톡 소셜 로그인 구현  
   - [카카오 로그인 방법 보기](https://velog.io/@gwi060722/Flutter-%EC%B9%B4%EC%B9%B4%EC%98%A4%ED%86%A1-%EB%A1%9C%EA%B7%B8%EC%9D%B8-%EB%B0%A9%EB%B2%95)

**2. AdMob Native 광고 설정**
   - 공식 문서를 참고하여 AdMob Native 광고를 설정  
   - [AdMob 광고 설정 방법 보기](https://velog.io/@gwi060722/%EC%9A%B4%EB%8F%99%EC%9D%BC%EC%A7%80-%EC%95%B1-%EB%A7%8C%EB%93%A4%EA%B8%B0Native-%EA%B4%91%EA%B3%A0)

**3. 일지 수정 및 삭제 시 화면 리빌딩 문제**
   - setState 호출로 인해 발생한 화면 리빌딩 문제를 Provider를 사용하여 해결
<details>
<summary>💻 코드</summary>
<div markdown="1">
   
```dart
if (isConfirmed == true) {
      final viewModel = Provider.of<DiaryViewModel>(context, listen: false);
      String filePath = await viewModel.getFilePathForDate(
          widget.selectedDate, widget.workout);
      File(filePath).deleteSync();
      viewModel.updateMarkedDateMap();
      Navigator.of(context).pop(true); // 삭제 후 true 반환
    }
  } 
```
설명: 
1. 조건문: `isConfirmed`가 `true`인 경우에만 코드 블록이 실행됩니다. 이는 사용자가 삭제를 확인했음을 의미합니다.
2. `ViewModel` 접근: `Provider`를 사용하여 `DiaryViewModel` 인스턴스를 가져옵니다. `listen: false`로 설정하여 이 위젯이 `ViewModel`의 변화에 반응하지 않도록 합니다. 이는 삭제 작업을 수행할 때 UI 업데이트가 필요하지 않기 때문입니다.
3. 파일 경로 가져오기: `getFilePathForDate` 메서드를 호출하여 선택된 날짜와 운동에 해당하는 파일의 경로를 비동기적으로 가져옵니다.
4. 파일 삭제: 가져온 파일 경로를 사용하여 해당 파일을 동기적으로 삭제합니다. `deleteSync()` 메서드는 파일을 즉시 삭제합니다.
5. 날짜 맵 업데이트: `updateMarkedDateMap` 메서드를 호출하여 삭제된 파일에 대한 정보를 업데이트합니다. 이는 사용자 인터페이스에 반영될 수 있도록 합니다.
6. 화면 닫기: `Navigator.of(context).pop(true)`를 호출하여 현재 화면을 닫고, true 값을 반환하여 삭제 작업이 성공적으로 완료되었음을 알립니다.
</div>
</details>




**4. 회원 정보 입력 페이지 문제**
   - 앱을 재다운로드할 때 기존 회원도 정보 입력을 강제하게 되는 문제를 Firestore 문서 확인을 통해 해결  
<details>
<summary>💻 코드</summary>
<div markdown="1">
   
```dart
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
```
설명: 
1. `signInWithGoogleAndNavigate`: 구글 소셜 로그인을 처리한 후, Firestore에서 해당 사용자의 데이터를 확인하여 기존 사용자라면 홈 화면으로, 신규 사용자라면 정보 입력 화면으로 이동시킵니다.\
2. `signInWithKakaoAndNavigate`: 카카오 로그인 성공 후, 동일하게 Firestore에서 사용자 데이터를 확인하여 필요한 화면으로 이동시킵니다.
3. `checkFirestoreDocumentAndNavigate`: 로그인 후 Firestore에서 사용자의 문서를 확인하여, 기존 회원인지 여부를 판별합니다. 문서가 존재하면 홈 화면으로, 없으면 정보 입력 화면으로 안내합니다.

</div>
</details>

**5. 회원 정보 가져오기 문제**
   - firebase auth에서 인증된 사용자의 유무를 확인하여 정보를 가져오게 하여 해결
<details>
<summary>💻 코드</summary>
<div markdown="1">

 ```dart
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
```
설명:
1. 이 코드는 Firebase Firestore에서 로그인된 사용자의 정보를 가져오는 기능을 담당합니다. 인증된 사용자의 문서를 찾아서 해당 데이터를 반환하고, 문제가 발생할 경우 예외 처리를 통해 오류 메시지를 표시합니다.
2. `user`가 인증되지 않은 상태라면 예외를 던져서 사용자 정보가 없음을 알립니다.

</div>
</details>

## 🔧 **그 외 트러블 슈팅**

**1. 운동 배우기 TapBar에 많은 운동 넣기**
   - 부위별 운동 종류가 많아 JSON 파일을 만들어 사용하여 효율적으로 TapBar에 운동 데이터를 관리

**2. 카메라 Timer 설정하기**
   - 운동 촬영 시 사용자가 편리하게 녹화를 시작할 수 있도록 카메라 타이머 기능 추가
<details>
<summary>💻 코드</summary>
<div markdown="1">
   
```dart
  Future<void> _startCountdown() async {
  for (int i = 5; i >= 1; i--) {
    countdown = i; // 카운트다운 값 업데이트
    notifyListeners(); // UI 업데이트
    await Future.delayed(const Duration(seconds: 1)); // 1초 대기
  }

  await _controller!.startVideoRecording(); // 5초 카운트가 끝난 후 녹화 시작
  isRecording = true; // 녹화 상태 변경
  isTimerEnabled = false; // 타이머 모드 종료
  countdown = 5; // 카운트다운 초기화
  notifyListeners(); // UI 업데이트
}
```
설명:
1. 카운트다운 루프: `for (int i = 5; i >= 1; i--)`에서 5부터 1까지 카운트다운을 수행합니다.
2. 카운트 업데이트: `countdown = i;`로 카운트다운 값을 업데이트합니다.
3. UI 업데이트: `notifyListeners();`로 UI를 업데이트하여 카운트다운 표시를 갱신합니다.
4. 1초 대기: `await Future.delayed(const Duration(seconds: 1));`로 1초씩 대기하여 카운트다운을 구현합니다.
5. 녹화 시작: 카운트다운이 끝나면 `_controller!.startVideoRecording();`로 비디오 녹화를 시작합니다.
   
 - 따라서, 녹화 버튼이 눌릴 때 `toggleRecording` 메서드에서 `isTimerEnabled`가 `true`일 경우 `_startCountdown` 메서드가 호출되어 이 과정이 실행됩니다.


</div>
</details>

**3. 같은 날짜에 똑같은 운동 기록 작성 문제**
   - 사용자가 동일한 날짜에 동일한 운동을 중복 기록하려는 경우, 녹화 버튼을 누를 때 경고 다이얼로그를 표시하여 중복 기록 방지
<details>
<summary>💻 코드</summary>
<div markdown="1">
   
```dart
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
```
설명: 
1. 메서드 정의: `_checkDiaryExists` 메서드는 특정 운동과 날짜에 대한 일기 파일이 존재하는지를 확인합니다.
2. 디렉토리 경로 설정: 애플리케이션의 문서 디렉토리를 가져와서, 일기 파일이 저장될 경로를 설정합니다.
3. 파일 이름 생성: `exercise`와 `date`를 기반으로 검색할 파일 이름을 생성합니다. 형식은 `diary_[운동명]_[날짜]`입니다.
4. 디렉토리 존재 확인: 지정한 경로에 일기 디렉토리가 존재하는지 확인합니다.
5. 연도-월 디렉토리 목록 가져오기: 디렉토리 내에 있는 연도-월 디렉토리 목록을 가져옵니다.
6. 파일 존재 확인: 각 연도-월 디렉토리 내의 파일을 확인하며, 생성한 검색 문자열이 포함된 파일이 있는지 확인합니다. 일기가 존재할 경우 
   `true`를 반환합니다.
7. 예외 처리: 예외가 발생할 경우 현재는 무시합니다.
8. 결과 반환: 해당 운동과 날짜에 대한 일기가 존재하지 않으면 `false`를 반환합니다.


</div>
</details>

**4. 영상 갤러리에서 운동별 영상 필터링 오류**
   - 유사한 운동명(예: 벤치프레스, 인클라인 벤치프레스)으로 인해 발생한 중복 필터링 문제를 해결하여, 같은 운동으로 처리되지 않도록 개선
<details>
<summary>💻 코드</summary>
<div markdown="1">
   
```dart
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
```
설명: 
1. `Future<void> _loadVideoList(String exercise)`:

  - 비동기 함수로, 특정 운동에 대한 비디오 목록을 로컬 파일 시스템에서 불러옵니다.
  반환 타입이 `void`이므로, 호출하는 곳에서 반환값을 기대하지 않습니다.
  
2. `Directory appDocDir = await getApplicationDocumentsDirectory();`:
 - `getApplicationDocumentsDirectory()`는 애플리케이션의 문서 디렉토리를 반환하는 함수로, 이는 애플리케이션이 기기에 저장한 데이터를 접근할 수 있는 경로를 가져옵니다.
    이 디렉토리는 일반적으로 앱의 데이터를 안전하게 저장할 수 있는 위치입니다.

3.  비디오 디렉토리 확인 및 생성:

 - `Directory videoDirectory = Directory('$appDocPath/videos');`로 비디오 파일들이 저장된 경로를 정의합니다.
    만약 비디오 디렉토리가 존재하지 않으면 `videoDirectory.createSync(recursive: true);`로 디렉토리를 재귀적으로 생성합니다.

4. 파일 목록 가져오기:
 - `videoDirectory.listSync(recursive: true)`는 지정된 디렉토리 안의 모든 파일을 비동기적으로 가져오는 함수입니다. `recursive: true`는 하위 디렉토리도 포함해서 탐색한다는 뜻입니다.

5. 비디오 파일 필터링:

 - `where` 조건문을 통해 특정 운동과 관련된 파일만 필터링합니다:
 - `file.path.split('/').last:` 파일 경로에서 파일 이름을 추출합니다.
 - `fileName.split('-')[0]:` 파일 이름에서 운동 이름을 추출합니다. 파일 이름은 운동이름-기타정보.mp4 형식인 것으로 보입니다.
 - `exercise == '전체보기': '전체보기'`를 선택했을 경우 모든 비디오 파일을 보여줍니다.
 - `fileName.endsWith('.mp4'):` 파일이 .mp4 확장자일 경우만 선택합니다.

6.  비디오 경로 목록 업데이트:

 - 필터링된 파일들의 경로를 `file.path`로 변환하여 `videoPaths` 리스트에 저장합니다.
 - `notifyListeners()`는 화면을 갱신하기 위한 함수로, 비디오 경로 리스트가 변경되었음을 UI에 알립니다.
   
7. 오류 처리:
 - `try-catch` 블록으로 파일 시스템 접근 시 발생할 수 있는 오류를 잡습니다. 이 블록 안에서 발생한 오류는 적절히 처리됩니다.


</div>
</details>


## **앱 실행 화면**
<img src="https://github.com/user-attachments/assets/8a8c0371-7e5f-459f-823e-dff400485a72"  width="200">
<img src="https://github.com/user-attachments/assets/aa9c3c45-4cf8-4eac-acf5-dcf58b576322"  width="200">
<img src="https://github.com/user-attachments/assets/cdcc6f93-5342-47e3-b6a6-a360212d1d18"  width="200">
<img src="https://github.com/user-attachments/assets/4efcb169-a226-42d8-b301-2af79750f720"  width="200">
<img src="https://github.com/user-attachments/assets/feebf3ed-7c76-4e65-89ef-4a580819260d"  width="200">
<img src="https://github.com/user-attachments/assets/43639874-122d-4a48-b306-320eb718c5f5"  width="200">
<img src="https://github.com/user-attachments/assets/47ce42ad-a809-4075-9d1a-836538c2b42d"  width="200">


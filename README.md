# <img src="https://github.com/user-attachments/assets/5a54321b-13e7-47b2-b879-6d499d5b3e9c" width="30 " height="30"> Bodycam

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
   - 사용자는 앱을 통해 직접 운동 영상을 찍고 기록할 수 있다.
   
2. **YouTube 영상 학습 기능**  
   - 유튜브에서 운동 영상을 찾아보고, 해당 운동을 학습할 수 있다다.

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
      Navigat다.


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


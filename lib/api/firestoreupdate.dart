import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  Future<Map<String, dynamic>?> loadUserData(String? androidId) async {
    if (androidId != null) {
      try {
        // Firestore에 접근
        FirebaseFirestore firestore = FirebaseFirestore.instance;

        // 사용자의 데이터를 가져올 컬렉션 및 문서 경로
        String collectionPath = 'users';
        String documentPath = androidId;

        // Firestore에서 데이터 불러오기
        DocumentSnapshot snapshot =
        await firestore.collection(collectionPath).doc(documentPath).get();

        if (snapshot.exists) {
          // 데이터가 있다면 Map 형태로 변환하여 반환
          return snapshot.data() as Map<String, dynamic>;
        } else {
          // 데이터가 없다면 null 반환
          return null;
        }
      } catch (e) {
        // 에러 발생 시 null 반환
        return null;
      }
    } else {
      // androidId가 제공되지 않았다면 null 반환
      return null;
    }
  }
}

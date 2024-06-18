import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../api/kakao_login.dart';
import '../views/calendar_screen.dart';
import '../views/camera_screen.dart';
import '../views/gallery_screen.dart';
import '../views/statics_screen.dart';
import 'bnbcustome_painter_widget.dart';

class MyHomePageBottomNavigationBar extends StatelessWidget {
  final Size size;

  const MyHomePageBottomNavigationBar({
    Key? key,
    required this.size,
  }) : super(key: key);

  Future<void> _logout(BuildContext context) async {
    bool logoutConfirmed = await _showLogoutConfirmationDialog(context);

    if (logoutConfirmed) {
      await GoogleSignIn().signOut();
      await KakaoLogin().logout();
      // Firebase에서도 로그아웃 처리

      // 필요한 추가 로그아웃 로직을 여기에 추가할 수 있습니다.
    }
  }

  Future<bool> _showLogoutConfirmationDialog(BuildContext context) async {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text('정말 로그아웃 하시겠습니까?',
          style:TextStyle(
            fontSize: 20
          )
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // 네 선택 시 다이얼로그 닫기
              },
              child: const Text('네'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // 아니요 선택 시 다이얼로그 닫기
              },
              child: const Text('아니요'),
            ),
          ],
        );
      },
    );

    return result ?? false; // 다이얼로그가 닫힐 때까지 기다렸을 때 선택이 없으면 false 반환
  }


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: Stack(
        children: [
          CustomPaint(
            size: Size(size.width, 80),
            painter: BNBCustomePainter(),
          ),
          Center(
            heightFactor: 0.6,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CameraScreen(),
                  ),
                );
              },
              backgroundColor: Colors.grey,
              elevation: 0.1,
              child: const Icon(Icons.add_a_photo, color: Colors.white),
            ),
          ),
          SizedBox(
            width: size.width,
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>StaticsScreen())
                    );
                  },
                  icon: const Icon(Icons.bar_chart, color: Colors.white),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CalendarScreen(onDateSelected: (DateTime selectedDate) {})),
                    );
                  },
                  icon: const Icon(Icons.calendar_today, color: Colors.white),
                ),
                Container(width: size.width * .20),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CustomGalleryScreen()),
                    );
                  },
                  icon: const Icon(Icons.photo_library, color: Colors.white),
                ),
                IconButton(
                  onPressed: () async {
                    await _logout(context);
                  },
                  icon: const Icon(Icons.logout, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

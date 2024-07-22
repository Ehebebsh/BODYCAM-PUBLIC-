import 'package:flutter/material.dart';
import '../views/calendar_screen.dart';
import '../views/camera_screen.dart';
import '../views/gallery_screen.dart';
import '../views/statics_screen.dart';
import '../views/userinfo_screen.dart';
import 'bnbcustome_painter_widget.dart';

class MyHomePageBottomNavigationBar extends StatelessWidget {
  final Size size;

  const MyHomePageBottomNavigationBar({
    Key? key,
    required this.size,
  }) : super(key: key);



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
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>UserProfilePage())
                    );
                  },
                  icon: const Icon(Icons.person, color: Colors.white),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => StaticsScreen()),
                    );
                  },
                  icon: const Icon(Icons.bar_chart, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

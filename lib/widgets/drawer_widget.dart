import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:url_launcher/url_launcher.dart';
import '../views/workout_learning_screen.dart';


class MyDrawer extends StatelessWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(
            height: 80, // 크기 조절
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.black87,
              ),
              child: Text(
                '메뉴',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18, // 폰트 크기 조절
                ),
              ),
            ),
          ),
          MyDrawerItem(title: '앱 문의', onTap: _sendEmail),
          MyDrawerItem(title: '개인정보취급방침', onTap: () {
            launch('https://sites.google.com/view/bodycamprivacy/%ED%99%88');
          },),
          MyDrawerItem(title: '운동 배우기', onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context)=>WorkOutLearningView())
            );
          }),
          MyDrawerItem(title: '앱 버전 : 1.0.0', onTap: () {}),
        ],
      ),
    );
  }
  void _sendEmail() async {
    final Email email = Email(
      body: '',
      subject: '[BODYCAM 문의하기]',
      recipients: ['gwi060722@gmail.com'],
      cc: [],
      bcc: [],
      attachmentPaths: [],
      isHTML: false,
    );

    await FlutterEmailSender.send(email);
  }
}

class MyDrawerItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const MyDrawerItem({
    Key? key,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          const Icon(Icons.keyboard_arrow_right), // 화살표 아이콘
        ],
      ),
      onTap: onTap,
    );
  }
}


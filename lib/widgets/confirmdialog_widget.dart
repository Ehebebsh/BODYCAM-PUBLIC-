import 'package:flutter/material.dart';

class ConfirmDialog {
  Future<bool> show(BuildContext context, String content) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // 계속 작성
              },
              child: Text('네'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // 작성 중지
              },
              child: Text('아니오'),
            ),
          ],
        );
      },
    ) ?? false;
  }
}

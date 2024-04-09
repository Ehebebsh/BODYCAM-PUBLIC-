import 'package:flutter/material.dart';

class BuildMarkedDateIconWidget extends StatelessWidget {
  const BuildMarkedDateIconWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4),
      width: 6,
      height: 6,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue,
      ),
    );
  }
}

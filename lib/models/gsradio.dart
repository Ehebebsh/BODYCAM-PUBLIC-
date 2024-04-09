import 'package:flutter/material.dart';

class GSRadio extends StatefulWidget {
  final String tag;
  final String title;
  final List<String> items;
  final String? value;
  final Function(String?) onChanged;

  GSRadio({
    required this.tag,
    required this.title,
    required this.items,
    required this.value,
    required this.onChanged,
  });

  @override
  _GSRadioState createState() => _GSRadioState();
}

class _GSRadioState extends State<GSRadio> {
  String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.value;  // 초기값을 설정합니다.
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        ),
        const SizedBox(
          height: 10,
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            InputDecorator(
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: const BorderSide(color: Colors.white),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: const BorderSide(color: Colors.white), // 포커스를 받지 않았을 때의 테두리 색상
                ),
                filled: true,
                fillColor: const Color(0xfff5f5f5),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (String item in widget.items)
                    Row(
                      children: [
                        Radio<String>(
                          value: item,
                          groupValue: _selectedValue,  // _selectedValue를 사용합니다.
                          onChanged: (String? value) {
                            setState(() {
                              _selectedValue = value;  // _selectedValue를 업데이트합니다.
                            });
                            widget.onChanged(value);
                          },
                        ),
                        Text(item),
                        const SizedBox(width: 16),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

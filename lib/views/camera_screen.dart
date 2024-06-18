import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import '../view models/diary_camera_viewmodel.dart';


class CameraScreen extends StatelessWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CameraViewModel(),
      child: Scaffold(
        body: Consumer<CameraViewModel>(
          builder: (context, viewModel, child) {
            return Stack(
              fit: StackFit.expand,
              children: [
                FutureBuilder<void>(
                  future: viewModel.initializeControllerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return AspectRatio(
                        aspectRatio: 4 / 3,
                        child: CameraPreview(viewModel.controller!),
                      );
                    } else if (snapshot.hasError) {
                      return const Center(child: Text('Error initializing camera'));
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.02,
                  right: MediaQuery.of(context).size.width * 0.05,
                  child: IconButton(
                    onPressed: () => viewModel.toggleCamera(),
                    icon: Icon(viewModel.isFrontCamera ? Icons.sync : Icons.sync),
                    color: Colors.white,
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.02,
                  left: MediaQuery.of(context).size.width * 0.05,
                  child: IconButton(
                    onPressed: () => viewModel.toggleTimer(),
                    icon: Icon(
                      viewModel.isTimerEnabled ? Icons.timer : Icons.timer_off,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.02,
                  left: MediaQuery.of(context).size.width * 0.01,
                  right: 0,
                  child: Center(
                    child: SingleChildScrollView(
                      child: DropdownButton<String>(
                        value: viewModel.selectedOption,
                        hint: const Text(
                          '운동 종류',
                          style: TextStyle(color: Colors.white, fontFamily: 'Ownglyph_Dailyokja-Rg'),
                        ),
                        style: const TextStyle(color: Colors.white),
                        dropdownColor: Colors.black,
                        iconEnabledColor: Colors.white,
                        items: const [
                          DropdownMenuItem<String>(
                            value: '데드리프트',
                            child: Text(
                              '데드리프트',
                              style: TextStyle(color: Colors.white, fontFamily: 'Ownglyph_Dailyokja-Rg'),
                            ),
                          ),
                          DropdownMenuItem<String>(
                            value: '바벨 로우',
                            child: Text(
                              '바벨 로우',
                              style: TextStyle(color: Colors.white, fontFamily: 'Ownglyph_Dailyokja-Rg'),
                            ),
                          ),
                          DropdownMenuItem<String>(
                            value: '덤벨 로우',
                            child: Text(
                              '덤벨 로우',
                              style: TextStyle(color: Colors.white, fontFamily: 'Ownglyph_Dailyokja-Rg'),
                            ),
                          ),
                          DropdownMenuItem<String>(
                            value: '벤치프레스',
                            child: Text(
                              '벤치프레스',
                              style: TextStyle(color: Colors.white, fontFamily: 'Ownglyph_Dailyokja-Rg'),
                            ),
                          ),
                          DropdownMenuItem<String>(
                            value: '인클라인 벤치프레스',
                            child: Text(
                              '인클라인 벤치프레스',
                              style: TextStyle(color: Colors.white, fontFamily: 'Ownglyph_Dailyokja-Rg'),
                            ),
                          ),
                          DropdownMenuItem<String>(
                            value: '덤벨 벤치프레스',
                            child: Text(
                              '덤벨 벤치프레스',
                              style: TextStyle(color: Colors.white, fontFamily: 'Ownglyph_Dailyokja-Rg'),
                            ),
                          ),
                          DropdownMenuItem<String>(
                            value: '바벨 백 스쿼트',
                            child: Text(
                              '바벨 백 스쿼트',
                              style: TextStyle(color: Colors.white, fontFamily: 'Ownglyph_Dailyokja-Rg'),
                            ),
                          ),
                          DropdownMenuItem<String>(
                            value: '에어 스쿼트',
                            child: Text(
                              '에어 스쿼트',
                              style: TextStyle(color: Colors.white, fontFamily: 'Ownglyph_Dailyokja-Rg'),
                            ),
                          ),
                          DropdownMenuItem<String>(
                            value: '점프 스쿼트',
                            child: Text(
                              '점프 스쿼트',
                              style: TextStyle(color: Colors.white, fontFamily: 'Ownglyph_Dailyokja-Rg'),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          viewModel.selectOption(value);
                        },
                        underline: Container(
                          height: 2,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: MediaQuery.of(context).size.height * 0.05,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.white,
                            width: 3.0,
                          ),
                          color: Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () => viewModel.toggleRecording(context),
                          icon: Icon(
                            viewModel.isRecording ? Icons.stop : Icons.fiber_manual_record,
                            color: viewModel.isRecording ? Colors.white : Colors.red,
                          ),
                          iconSize: 40.0,
                        ),
                      ),
                    ],
                  ),
                ),
                if (viewModel.isTimerEnabled && viewModel.countdown > 0)
                  Center(
                    child: Text(
                      viewModel.countdown.toString(),
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width / 5,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

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

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:miniproject_exercise/widgets/drawer_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart' as video_thumbnail;
import 'dart:io';
import 'dart:typed_data';
import '../utils/admob_helper.dart';
import '../utils/constant.dart';
import '../widgets/deletevideo_dialog_widget.dart';

class CustomGalleryScreen extends StatefulWidget {
  const CustomGalleryScreen({Key? key});

  @override
  CustomGalleryScreenState createState() => CustomGalleryScreenState();
}

class CustomGalleryScreenState extends State<CustomGalleryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<NativeAd> _adFuture;
  // late Future<NativeAd> _adFuture1;
  List<String> videoList = [];
  String? _selectedWorkout;
  List<String> videoPaths = [];

  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    super.initState();
    _adFuture=AdMobHelper(
        nativeAdUnitId: adUnitId,
        nativeFactoryId: 'adFactoryExample',
        rewardAdUnitId: videoadUnitId
    ).createNativeAd();
    // _adFuture1=AdMobHelper(
    //     nativeAdUnitId: adUnitId,
    //     nativeFactoryId: 'adFactoryExample',
    //     rewardAdUnitId: videoadUnitId
    // ).createNativeAd();
    _tabController = TabController(length: workouts.length, vsync: this);
    _loadVideoList(workouts[0]); // 초기 선택값 설정
    _tabController.addListener(_handleTabSelection);
  }

  @override
  void dispose() {
    _adFuture.then((ad) => ad.dispose());
    // _adFuture1.then((ad) => ad.dispose());
    super.dispose();
  }

  void _handleTabSelection() {
    if (!_tabController.indexIsChanging) {
      final selectedWorkout = workouts[_tabController.index];

      if (selectedWorkout != _selectedWorkout) {
        setState(() {
          _loadVideoList(selectedWorkout); // 현재 선택된 탭의 운동에 맞게 호출
          _selectedWorkout = selectedWorkout;
        });
      }
    }
  }
  

  void _loadVideoList(String exercise) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;

    try {
      Directory videoDirectory = Directory('$appDocPath/videos');

      // 디렉토리가 없는 경우 생성
      if (!videoDirectory.existsSync()) {
        videoDirectory.createSync(recursive: true);
      }

      List<FileSystemEntity> files = videoDirectory.listSync(recursive: true);

      videoList = files
          .where((file) {
        var fileName = file.path.split('/').last;
        var exerciseNameInFile = fileName.split('-')[0];
        return (exercise == '전체보기' || exerciseNameInFile == exercise) && fileName.endsWith('.mp4');
      })
          .map((file) => file.path)
          .toList();

      setState(() {});
    } catch (e) {
    }
  }



  Future<Uint8List?> _getThumbnail(String videoPath) async {
    final uint8list = await video_thumbnail.VideoThumbnail.thumbnailData(
      video: videoPath,
      imageFormat: video_thumbnail.ImageFormat.JPEG,
      maxWidth: 128,
      quality: 25,
    );
    return uint8list;
  }

  void _initializeVideoPlayer(String videoPath) {
    _videoPlayerController = VideoPlayerController.file(File(videoPath));

    _videoPlayerController?.addListener(() {
      if (_videoPlayerController?.value.hasError ?? false) {
        // 오류 처리
      }
    });

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: true,
      looping: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Builder(
            builder: (BuildContext context) {
              return Column(
                children: [
                  Stack(
                    children: [
                      TabBar(
                        isScrollable: true,
                        dividerColor: Colors.transparent,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.grey,
                        controller: _tabController,
                        tabs: workouts.map((String workout) {
                          return Tab(text: workout);
                        }).toList(),
                      ),
                      Container(
                        color: Colors.black87,
                        child: IconButton(
                          onPressed: () {
                            Scaffold.of(context).openDrawer();
                          },
                          icon: const Icon(Icons.menu,
                            color: Colors.white,),
                        ),
                      ),
                    ],
                  ),
                  FutureBuilder<NativeAd>(
                    future: _adFuture,
                    builder: (BuildContext context,
                        AsyncSnapshot<NativeAd> snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return Container(
                          height: 32,
                          child: AdWidget(ad: snapshot.data!),
                        );
                      } else {
                        return CircularProgressIndicator();
                      }
                    },
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: workouts.map((String workout) {
                        return videoList.isEmpty
                            ? Center(
                          child: Text(
                            '아직 저장된 영상이 없습니다.',
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                            : GridView.builder(
                          padding: const EdgeInsets.only(top: 10),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8.0,
                            mainAxisSpacing: 8.0,
                          ),
                          itemCount: videoList.length,
                          itemBuilder: (context, index) {
                            return FutureBuilder<Uint8List?>(
                              future: _getThumbnail(videoList[index]),
                              builder: (context, snapshot) {
                                Widget widget;
                                if (snapshot.connectionState ==
                                    ConnectionState.done && snapshot.hasData) {
                                  widget = Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Image.memory(
                                        snapshot.data!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                      const Icon(
                                        Icons.play_circle_outline,
                                        color: Colors.white,
                                        size: 50.0,
                                      ),
                                    ],
                                  );
                                } else {
                                  widget = const Center(
                                    child: Icon(
                                      Icons.play_circle_outline,
                                      color: Colors.white,
                                      size: 50.0,
                                    ),
                                  );
                                }
                                return GestureDetector(
                                  onTap: () {
                                    _showVideoDialog(videoList[index]);
                                  },
                                  onLongPress: () {
                                    _showDeleteDialog(videoList[index]);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.0),
                                      color: Colors
                                          .grey, // Placeholder color or use an image
                                    ),
                                    child: widget,
                                  ),
                                );
                              },
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );
            }
        ),
      ),
      // bottomNavigationBar: FutureBuilder<NativeAd>(
      //   future: _adFuture1,
      //   builder: (BuildContext context, AsyncSnapshot<NativeAd> snapshot) {
      //     if (snapshot.connectionState == ConnectionState.done) {
      //       return Container(
      //         height: 32,
      //         child: AdWidget(ad: snapshot.data!),
      //       );
      //     } else {
      //       return CircularProgressIndicator();
      //     }
      //   },
      // ),
    );
  }

  void _showVideoDialog(String videoPath) {
    _initializeVideoPlayer(videoPath);
    if (_chewieController != null) {
      showDialog(
        context: context,
        builder: (context) =>
            Dialog(
              child: Chewie(controller: _chewieController!),
            ),
      ).then((_) {
        // 컨트롤러 디스포즈는 다이얼로그 닫힐 때 수행
      });
    }
  }

  void _showDeleteDialog(String videoPath) {
    showDialog(
      context: context,
      builder: (context) =>
          DeleteVideoDialog(
            videoPath: videoPath,
            onVideoDeleted: () {
              setState(() {
                videoList.remove(videoPath); // videoList에서 삭제된 비디오 경로 제거
              });
            },
            onVideoRenamed: (newPath) {
              setState(() {
                // 기존 파일 경로 삭제
                videoList.remove(videoPath);
                // 새 파일 경로 추가
                videoList.add(newPath);
              });
              // 화면을 리로드하여 새로운 비디오 파일이 표시되도록 함
              _loadVideoList(_selectedWorkout!);
            },
          ),
    );
  }
}
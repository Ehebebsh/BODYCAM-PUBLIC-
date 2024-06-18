import 'dart:io';
import 'dart:typed_data';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../utils/constant.dart' as cons;
import '../view models/diary_video_modelview.dart';
import '../widgets/deletevideo_dialog_widget.dart';
import '../widgets/drawer_widget.dart';

class CustomGalleryScreen extends StatefulWidget {
  const CustomGalleryScreen({Key? key}) : super(key: key);

  @override
  _CustomGalleryScreenState createState() => _CustomGalleryScreenState();
}

class _CustomGalleryScreenState extends State<CustomGalleryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: cons.workouts.length, vsync: this);
    _tabController.addListener(() {
      _handleTabSelection(_tabController.index);
    });
    _handleTabSelection(0); // Load videos for the initial tab
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabSelection(int index) {
    setState(() {
      final selectedWorkout = cons.workouts[index];
      Provider.of<DiaryVideoViewModel>(context, listen: false)
          .setSelectedWorkout(selectedWorkout);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: MyDrawer(),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                TabBar(
                  isScrollable: true,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey,
                  controller: _tabController,
                  tabs: cons.workouts.map((String workout) {
                    return Tab(text: workout);
                  }).toList(),
                ),
                Container(
                  color: Colors.black87,
                  child: IconButton(
                    onPressed: () {
                      _scaffoldKey.currentState?.openDrawer();
                    },
                    icon: const Icon(Icons.menu, color: Colors.white),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Consumer<DiaryVideoViewModel>(
                builder: (context, viewModel, child) {
                  return viewModel.videoPaths.isEmpty
                      ? Center(
                    child: Text(
                      '저장된 영상이 없습니다.',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                      : GridView.builder(
                    padding: const EdgeInsets.only(top: 10),
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemCount: viewModel.videoPaths.length,
                    itemBuilder: (context, index) {
                      return FutureBuilder<Uint8List?>(
                        future:
                        viewModel.getThumbnail(viewModel.videoPaths[index]),
                        builder: (context, snapshot) {
                          Widget widget;
                          if (snapshot.connectionState ==
                              ConnectionState.done &&
                              snapshot.hasData) {
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
                              showDialog(
                                context: context,
                                builder: (context) => Dialog(
                                  child: Chewie(
                                    controller: ChewieController(
                                      videoPlayerController:
                                      VideoPlayerController.file(
                                        File(viewModel.videoPaths[index]),
                                      ),
                                      autoPlay: true,
                                      looping: false,
                                    ),
                                  ),
                                ),
                              );
                            },
                            onLongPress: () {
                              showDialog(
                                context: context,
                                builder: (context) => DeleteVideoDialog(
                                  videoPath: viewModel!.videoPaths[index],
                                  onVideoDeleted: () {
                                    Provider.of<DiaryVideoViewModel>(
                                      context,
                                      listen: false,
                                    ).deleteVideo(viewModel.videoPaths[index]);
                                  },
                                  onVideoRenamed: (newPath) {
                                    Provider.of<DiaryVideoViewModel>(
                                      context,
                                      listen: false,
                                    ).renameVideo(
                                      viewModel.videoPaths[index],
                                      newPath,
                                    );
                                  },
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                color: Colors.grey,
                              ),
                              child: widget,
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

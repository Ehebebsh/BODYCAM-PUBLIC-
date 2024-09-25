import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:miniproject_exercise/views/video_screen.dart';

import '../utils/constant.dart' as cons;

class WorkoutPlayerScreen extends StatefulWidget {
  final String query;

  WorkoutPlayerScreen({required this.query});

  @override
  _WorkoutPlayerScreenState createState() => _WorkoutPlayerScreenState();
}

class _WorkoutPlayerScreenState extends State<WorkoutPlayerScreen> {
  late List<dynamic> _videos;

  @override
  void initState() {
    _videos = [];
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    // Fetch videos related to workout using YouTube Data API
    // Replace 'YOUR_API_KEY' with your actual YouTube API key
    String apiKey = cons.youtubeapikey;
    String url =
        'https://www.googleapis.com/youtube/v3/search?part=snippet&maxResults=10&q=${Uri
        .encodeComponent(widget.query)}&key=$apiKey';

    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      setState(() {
        _videos = data['items'];
      });
    } else {
      throw Exception('Failed to load videos');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: Text(
          widget.query,
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _videos == null
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery
              .of(context)
              .size
              .width > 600 ? 4 : 2,
          // Adjust the cross axis count based on screen size
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
        ),
        itemCount: _videos.length,
        itemBuilder: (context, index) {
          var video = _videos[index];
          var videoId = video['id']['videoId'];
          var title = video['snippet']['title'];
          var thumbnailUrl = video['snippet']['thumbnails']['medium']['url'];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoScreen(videoId: videoId),
                ),
              );
            },
            child: Container(
              height: 200, // Set a fixed height for the Card
              child: Card(
                color: Colors.white,
                elevation: 4.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Image.network(
                        thumbnailUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
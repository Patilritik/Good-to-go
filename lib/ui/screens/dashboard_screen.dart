import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class DashboardScreen extends StatelessWidget {
  final String username;
  final String userImage;
  final List<String> videoUrls;

  const DashboardScreen({
    super.key,
    required this.username,
    required this.userImage,
    required this.videoUrls,
  });

  void _navigateToFullScreen(BuildContext context, String videoUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenVideoPlayer(videoUrl: videoUrl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome, $username"),
        centerTitle: true,
        actions: [
          CircleAvatar(
            backgroundImage: NetworkImage(userImage),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: videoUrls.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => _navigateToFullScreen(context, videoUrls[index]),
              child: VideoThumbnail(),
            );
          },
        ),
      ),
    );
  }
}

class VideoThumbnail extends StatelessWidget {
  const VideoThumbnail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 3,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey),
        image: const DecorationImage(
          image: AssetImage('assets/images/03c78e1fb5cca1e01a30.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.play_circle_outline_outlined,
          color: Color.fromRGBO(255, 255, 255, 0.8),
          size: 40,
        ),
      ),
    );
  }
}

class FullScreenVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const FullScreenVideoPlayer({super.key, required this.videoUrl});

  @override
  _FullScreenVideoPlayerState createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  late VideoPlayerController _controller;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {
          _controller.play();
          _controller.setLooping(true);
        });
      }).catchError((_) {
        setState(() {
          _hasError = true;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: _hasError
                ? const Text(
                    "Failed to load video",
                    style: TextStyle(color: Colors.red),
                  )
                : _controller.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      )
                    : const CircularProgressIndicator(),
          ),
          Positioned(
            top: 30,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}

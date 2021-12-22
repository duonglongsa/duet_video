import 'package:flutter_video_duet/duet_screen/duet_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

class VideoApp extends StatefulWidget {
  const VideoApp({Key? key}) : super(key: key);

  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network("https://firebasestorage.googleapis.com/v0/b/first-prj-66a8e.appspot.com/o/zoom_0.mp4?alt=media")
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _controller!.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: VideoPlayer(_controller!),
              )
            : Container(
              height: 200,
              child: const Center(child: CircularProgressIndicator(),),
            ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            heroTag: "btn_play",
            onPressed: () async {
              
              setState(() {
                _controller!.value.isPlaying
                    ? _controller!.pause()
                    : _controller!.play();
              });
            },
            child: Icon(
              _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
            ),
          ),
          const SizedBox(
            width: 50,
          ),
          FloatingActionButton(
            heroTag: "btn_duet",
            backgroundColor: Colors.transparent,
            onPressed: () {    
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CameraApp(
                  videoSource: 'https://firebasestorage.googleapis.com/v0/b/first-prj-66a8e.appspot.com/o/zoom_0.mp4?alt=media',
                  videoSubtitle: "https://pastebin.com/raw/pkZ3STDk",
                  recordScript: "https://pastebin.com/raw/XXcYcPA6",
                )),
              ).then((value) => _controller!.pause());
            },
            child: const Text('Duet video'),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller!.dispose();
  }
}

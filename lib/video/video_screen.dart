import 'dart:io';

import 'package:flutter/foundation.dart';
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
  bool finishedPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
        "https://firebasestorage.googleapis.com/v0/b/first-prj-66a8e.appspot.com/o/video-1640226777.mp4?alt=media")
      ..addListener(() {
        setState(() {});
        if (_controller!.value.duration == _controller!.value.position) {
          setState(() {
            finishedPlaying = true;
          });
        }
      })
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Center(
              child: _controller!.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio,
                      child: VideoPlayer(_controller!),
                    )
                  : Container(
                      height: 200,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 10, 0),
                child: TextButton(
                    style: TextButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () {
                      _controller!.pause();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CameraApp(
                                  videoSource: _controller!.dataSource,
                                  videoSubtitle:
                                      "https://pastebin.com/raw/pkZ3STDk",
                                  recordScript:
                                      "https://pastebin.com/raw/XXcYcPA6",
                                )),
                      ).then((value) {
                        setState(() {});
                        () {};
                      });
                    },
                    child: const Text(
                      "Duet",
                      style: TextStyle(color: Colors.white),
                    )),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 50),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 20,
                      children: [
                        IconButton(
                          color: Colors.white,
                          icon: _controller!.value.isPlaying
                              ? const Icon(Icons.pause)
                              : const Icon(Icons.play_arrow),
                          onPressed: () {
                            setState(() {
                              if (_controller!.value.isPlaying) {
                                _controller!.pause();
                              } else {
                                _controller!.play();
                              }
                            });
                          },
                        ),
                        VideoProgressIndicator(
                          _controller!,
                          allowScrubbing: true,
                          colors: const VideoProgressColors(
                            playedColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller!.dispose();
  }
}

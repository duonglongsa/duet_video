import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_video_duet/duet_screen/duet_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

class PreviewVideo extends StatefulWidget {
  XFile videoPath;

  PreviewVideo({Key? key, required this.videoPath}) : super(key: key);

  @override
  _PreviewVideoState createState() => _PreviewVideoState();
}

class _PreviewVideoState extends State<PreviewVideo> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath.path))
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
    _controller!.setLooping(true);
    _controller!.play();
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: WillPopScope(
          onWillPop: _willPopCallback,
          child: Stack(
            children: [
              Center(
                child: _controller!.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: _controller!.value.aspectRatio,
                        child: VideoPlayer(_controller!),
                      )
                    : Container(),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 10, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        color: Colors.white,
                        icon: const Icon(Icons.arrow_back_ios),
                        onPressed: () {
                          showModalBottomSheet(
                              context: context,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                ),
                              ),
                              backgroundColor: Colors.white,
                              builder: (BuildContext context) {
                                return Wrap(
                                  children: [
                                    Column(
                                      children: [
                                        ListTile(
                                          title: const Center(
                                            child: Text(
                                              "Delete this recording",
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          ),
                                          onTap: () {
                                            _deleteCacheDir();
                                            Navigator.pop(context);
                                            Navigator.pop(context);
                                          },
                                        ),
                                        ListTile(
                                          title: const Center(
                                            child: Text(
                                              "Cancel",
                                              style: TextStyle(
                                                  color: Colors.black87),
                                            ),
                                          ),
                                          onTap: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              });
                        }),
                    TextButton(
                        style:
                            TextButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: () {},
                        child: const Text(
                          "Continue",
                          style: TextStyle(color: Colors.white),
                        )),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 50),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(15)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 20,
                        children: [
                          IconButton(
                            color: Colors.white70,
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
                              playedColor: Colors.white70,
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
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {
        //     setState(() {
        //       _controller!.value.isPlaying
        //           ? _controller!.pause()
        //           : _controller!.play();
        //     });
        //   },
        //   child: Icon(
        //     _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
        //   ),
        // ),
        // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Future<void> _deleteCacheDir() async {
    final cacheDir = await getTemporaryDirectory();

    if (cacheDir.existsSync()) {
      cacheDir.deleteSync(recursive: true);
    }
    print("clean cache");
  }

  Future<bool> _willPopCallback() async {
    bool _isPop = false;
    await showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        backgroundColor: Colors.white,
        builder: (BuildContext context) {
          return Wrap(
            children: [
              Column(
                children: [
                  ListTile(
                    title: const Center(
                      child: Text(
                        "Delete this recording",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    onTap: () {
                      _deleteCacheDir();
                      Navigator.pop(context);
                      _isPop = true;
                    },
                  ),
                  ListTile(
                    title: const Center(
                      child: Text(
                        "Cancel",
                        style: TextStyle(color: Colors.black87),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          );
        });

    return Future.value(_isPop);
  }
}

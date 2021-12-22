import 'dart:async';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_video_duet/duet_screen/ffmpeg_config.dart';
import 'package:flutter_video_duet/preview_screen/preview_screen.dart';
import 'package:flutter_video_duet/video/video_screen.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:subtitle_wrapper_package/data/models/style/subtitle_border_style.dart';
import 'package:subtitle_wrapper_package/data/models/style/subtitle_position.dart';
import 'package:subtitle_wrapper_package/data/models/style/subtitle_style.dart';
import 'package:subtitle_wrapper_package/subtitle_controller.dart';
import 'package:subtitle_wrapper_package/subtitle_wrapper_package.dart';
import 'package:video_player/video_player.dart';

class CameraApp extends StatefulWidget {
  final String videoSource;
  final String recordScript;
  final String videoSubtitle;

  const CameraApp(
      {Key? key,
      required this.videoSource,
      required this.recordScript,
      required this.videoSubtitle})
      : super(key: key);

  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  FFmpegConfig ffmpegConfig = FFmpegConfig();

  List<CameraDescription>? cameras;
  CameraController? cameraController;
  bool isInitCamera = false;
  bool isInitVideo = false;
  XFile? videoFile;
  String? cache;

  //listen to duet video
  VideoPlayerController? duetVideoController;
  bool _isPlaying = false;
  Duration? _duration;
  Duration? _position;
  bool _isEnd = false;

  //show loading when process video
  bool _showLoading = false;

  //subtitle
  SubtitleController? teacherSub;
  SubtitleController? studentSub;

  Future<void> initCamera() async {
    cameras = await availableCameras();
    cache = (await getTemporaryDirectory()).path;
    cameraController = CameraController(cameras![1], ResolutionPreset.max);
    cameraController!.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        isInitCamera = true;
      });
    });
  }

  void initVideo() {
    duetVideoController = VideoPlayerController.network(widget.videoSource)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {
          isInitVideo = true;
        });
      })
      ..addListener(() {
        final bool isPlaying = duetVideoController!.value.isPlaying;
        if (isPlaying != _isPlaying) {
          setState(() {
            _isPlaying = isPlaying;
          });
        }
        Timer.run(() {
          setState(() {
            _position = duetVideoController!.value.position;
          });
        });
        setState(() {
          _duration = duetVideoController!.value.duration;
        });
        if (_position != null) {
          _duration?.compareTo(_position!) == 0 ||
                  _duration?.compareTo(_position!) == -1
              ? setState(() {
                  //stop when the duetvideo end
                  print("video end");
                  _isEnd = true;
                  onStopButtonPressed();
                })
              : setState(() {
                  _isEnd = false;
                });
        }
      });
  }

  void initSubtitle() {
    teacherSub = SubtitleController(
      subtitleUrl: widget.videoSubtitle,
      subtitleType: SubtitleType.srt,
    );
    studentSub = SubtitleController(
      subtitleUrl: widget.recordScript,
      subtitleType: SubtitleType.srt,
    );
  }

  @override
  void initState() {
    super.initState();
    initVideo();
    initCamera();
    initSubtitle();
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: Colors.black,
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: isInitCamera && isInitVideo
                          ? Row(
                              children: [
                                Expanded(
                                    child: AspectRatio(
                                        aspectRatio: 1 /
                                            cameraController!.value.aspectRatio,
                                        child: SubTitleWrapper(
                                            subtitleController: studentSub!,
                                            videoPlayerController:
                                                duetVideoController!,
                                            subtitleStyle: const SubtitleStyle(
                                              textColor: Colors.white,
                                              hasBorder: true,
                                              position: SubtitlePosition(
                                                bottom: 0,
                                              ),
                                            ),
                                            videoChild: CameraPreview(
                                                cameraController!)))),
                                Expanded(
                                  child: SubTitleWrapper(
                                    subtitleController: teacherSub!,
                                    videoPlayerController: duetVideoController!,
                                    subtitleStyle: const SubtitleStyle(
                                      textColor: Colors.white,
                                      hasBorder: true,
                                      position: SubtitlePosition(
                                        bottom: 0,
                                      ),
                                    ),
                                    videoChild: AspectRatio(
                                        aspectRatio: 1 /
                                            cameraController!.value.aspectRatio,
                                        child: Center(
                                          child: AspectRatio(
                                            aspectRatio: duetVideoController!
                                                .value.aspectRatio,
                                            child: VideoPlayer(
                                                duetVideoController!),
                                          ),
                                        )),
                                  ),
                                ),
                              ],
                            )
                          : const Center(child: CircularProgressIndicator()),
                    ),
                  ),
                  VideoProgressIndicator(
                    duetVideoController!,
                    allowScrubbing: false,
                  ),
                ],
              ),
            ),
            Positioned(
                top: 20,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  iconSize: 30,
                  color: Colors.white,
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
                                  leading: const Icon(
                                    Icons.refresh,
                                    color: Colors.black,
                                  ),
                                  title: const Text(
                                    "Re-make recording",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  onTap: () {
                                    remakeRecording();
                                    Navigator.pop(context);
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  title: const Text(
                                    "Cancle recording",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    );
                  },
                )),
            Positioned(
                bottom: 20,
                right: 0,
                left: 0,
                child: _captureControlRowWidget()),
            if (_showLoading)
              Center(
                child: Container(
                    width: 130,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: const [
                        CircularProgressIndicator(),
                        Text(
                          "Processing...",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ],
                    )),
              ),
          ],
        ),
      ),
    );
  }

  Widget _captureControlRowWidget() {
    if (cameraController != null && cameraController!.value.isInitialized) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          IconButton(
              icon: studentSub!.showSubtitles
                  ? const Icon(Icons.subtitles)
                  : const Icon(Icons.subtitles_off),
              color: Colors.white,
              iconSize: 30,
              onPressed: () {
                setState(() {
                  onSubtitlePressed();
                  print(studentSub!.showSubtitles);
                });
              }),
          IconButton(
              iconSize: 100,
              color: Colors.red,
              icon: cameraController!.value.isRecordingVideo &&
                      !cameraController!.value.isRecordingPaused
                  ? const Icon(
                      Icons.stop_circle_outlined,
                    )
                  : const Icon(
                      Icons.radio_button_on,
                    ),
              onPressed: () {
                if (cameraController!.value.isRecordingVideo) {
                  if (cameraController!.value.isRecordingPaused) {
                    onResumeButtonPressed();
                  } else {
                    onPauseButtonPressed();
                  }
                } else {
                  onVideoRecordButtonPressed();
                }
              }),
          IconButton(
              icon: const Icon(Icons.check_circle),
              color: Colors.red,
              iconSize: 30,
              onPressed: () {
                if (cameraController!.value.isRecordingVideo) {
                  onStopButtonPressed(isEnd: false);
                }
              }),
        ],
      );
    } else {
      return Container();
    }
  }

  void onSubtitlePressed() {
    studentSub!.showSubtitles = !studentSub!.showSubtitles;
    teacherSub!.showSubtitles = !teacherSub!.showSubtitles;
  }

  void onVideoRecordButtonPressed() {
    startVideoRecording().then((_) {
      if (mounted) setState(() {});
      print('Video recording start');
    });
  }

  void onResumeButtonPressed() {
    resumeVideoRecording().then((_) {
      if (mounted) setState(() {});
      print('Video recording resumed');
    });
  }

  void onPauseButtonPressed() {
    pauseVideoRecording().then((_) {
      if (mounted) setState(() {});
      print('Video recording paused');
    });
  }

  void onStopButtonPressed({bool isEnd = true}) {
    if (!isEnd) duetVideoController!.pause();
    stopVideoRecording().then((file) async {
      if (mounted) setState(() {});
      if (file != null) {
        setState(() {
          _showLoading = true;
        });
        ffmpegConfig.resizeInput(duetVideoController!.value.size.width,
            duetVideoController!.value.size.height);

        await ffmpegConfig
            .excute(file.path, duetVideoController!.dataSource,
                "$cache/duetvideo.mp4")
            .then((_) => {
                  setState(() {
                    _showLoading = false;
                  })
                });

        //await GallerySaver.saveVideo("$cache/duetvideo.mp4");

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  PreviewVideo(videoPath: XFile("$cache/duetvideo.mp4"))),
        ).then((_) {
          remakeRecording();
        });
      }
    });
  }

  void remakeRecording() {
    cameraController!.stopVideoRecording();
    duetVideoController!.pause();
    duetVideoController!.seekTo(const Duration(seconds: 0));
  }

  Future<void> startVideoRecording() async {
    if (cameraController!.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return;
    }
    try {
      await cameraController!.startVideoRecording();
      duetVideoController!.play();
    } on CameraException catch (e) {
      print(e);
      return;
    }
  }

  Future<void> resumeVideoRecording() async {
    if (cameraController == null || !cameraController!.value.isRecordingVideo) {
      return null;
    }

    try {
      await cameraController!.resumeVideoRecording();
      duetVideoController!.play();
    } on CameraException catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> pauseVideoRecording() async {
    if (cameraController == null || !cameraController!.value.isRecordingVideo) {
      return null;
    }

    try {
      await cameraController!.pauseVideoRecording();
      duetVideoController!.pause();
    } on CameraException catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<XFile?> stopVideoRecording() async {
    if (cameraController == null || !cameraController!.value.isRecordingVideo) {
      return null;
    }

    try {
      return cameraController!.stopVideoRecording();
    } on CameraException catch (e) {
      print(e);
      return null;
    }
  }
}

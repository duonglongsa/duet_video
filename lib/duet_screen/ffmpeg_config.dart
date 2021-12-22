import 'dart:math';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';

class FFmpegConfig {
  static const VERTICAL_DUET_WIDTH = 360;
  static const VERTICAL_DUET_HEIGHT = 640;
  late double videoWidth, videoHeight, paddingVer, paddingHoz = 0;
  String? filter;

  void resizeInput(double orginalWidth, double orginalHeight) {
    double resizeFactor = min(VERTICAL_DUET_WIDTH / orginalWidth,
        VERTICAL_DUET_HEIGHT / orginalHeight);

    videoWidth = orginalWidth * resizeFactor;
    videoHeight = orginalHeight * resizeFactor;
    paddingHoz = (VERTICAL_DUET_WIDTH - videoWidth) / 2;
    paddingVer = (VERTICAL_DUET_HEIGHT - videoHeight) / 2;
  }

  Future<void> excute(
      String leftVideoPath, String rightVideoPath, String outputPath) async {
    filter =
        " [0:v]hflip,setpts=PTS-STARTPTS,scale=$VERTICAL_DUET_WIDTH:$VERTICAL_DUET_HEIGHT,fps=60,setsar=1[l];"
        "[1:v]setpts=PTS-STARTPTS,scale=$videoWidth:$videoHeight,pad=$VERTICAL_DUET_WIDTH:$VERTICAL_DUET_HEIGHT:$paddingHoz:$paddingVer,fps=60,setsar=1[r];"
        "[l][r]hstack=inputs=2:shortest=1,format=yuv420p;[0][1]amerge ";
    await FlutterFFmpeg().execute(" -y -i " +
        leftVideoPath +
        " -i " +
        rightVideoPath +
        " -filter_complex" +
        filter! +
        "-c:v libx264 -crf 20 -preset ultrafast -c:a aac -strict -2 " +
        //"-c:v mpeg2video -q:v 3 " +
        outputPath);
  }
}

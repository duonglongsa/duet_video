import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_video_duet/duet_screen/duet_screen.dart';
import 'package:flutter_video_duet/video/video_screen.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
       
        primarySwatch: Colors.blue,
      ),
      home: const VideoApp(),
    );
  }
}


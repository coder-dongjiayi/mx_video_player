import 'package:example/convenient_video_page.dart';
import 'package:mx_video_player/mx_video_player.dart';

import 'package:flutter/material.dart';

import 'basic_video_page.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);


  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  MXVideoPlayerController? _videoPlayerController;
  @override
  void initState() {
    super.initState();
    _videoPlayerController = MXVideoPlayerController();
    String dataSource =  "assets://assets/video/video.mp4";

    /// 初始化网络视频 必须以http 或者 https开头 https://www.xxxx.mp4
    /// 初始化本地视频 必须以file:// 开头,比如 file://var/xxxx/video.mp4
    /// 初始化assets视频  必须以 assets:// 开头，比如 assets://assets/video/video.mp4
    _videoPlayerController?.setDataSource(dataSource);
    _videoPlayerController?.setAssetsSource("assets://assets/video/video.mp4");
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  Center(
        child: MXVideoPlayer(
         controller: _videoPlayerController,
        )
      ),
     // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

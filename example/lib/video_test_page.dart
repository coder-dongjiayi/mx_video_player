import 'dart:io';

import 'package:auto_orientation/auto_orientation.dart';
import 'package:example/videoplayer/video_player_panel_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'videoplayer/blmedia_controller.dart';


class VideoTestPage extends StatefulWidget {
  const VideoTestPage({Key? key}) : super(key: key);

  @override
  State<VideoTestPage> createState() => _VideoTestPageState();
}

class _VideoTestPageState extends State<VideoTestPage> {
  late BLMediaController _blVideoController;


  String videoUrl =
      "https://1254467417.vod2.myqcloud.com/ea86f20bvodtransbj1254467417/baa2218a387702302020859391/v.f32849.m3u8";
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _blVideoController.release();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _blVideoController = BLMediaController(
        videoUrl: videoUrl,
        completionCallback: () {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [_videoPlayer()],
      ),
    );
  }

  Widget _videoPlayer() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: VideoPlayerPanelWidget(
          videoController: _blVideoController,
          small: true,
          fullScreenCallback: () async {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return VideoFullScreenPage(videoController: _blVideoController);
            }));
          }),
    );
  }
}

class VideoFullScreenPage extends StatefulWidget {
  const VideoFullScreenPage({Key? key, required this.videoController})
      : super(key: key);
  final BLMediaController videoController;
  @override
  State<VideoFullScreenPage> createState() => _VideoFullScreenPageState();
}

class _VideoFullScreenPageState extends State<VideoFullScreenPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.videoController.videoPlayerController.aspectRatio > 1) {
      setLandscapeRightMode();
    }
  }
  void setLandscapeRightMode(){
    if (Platform.isIOS) {
      // ios 需要设置这个，安卓不需要
       SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight]);
    }else{
      AutoOrientation.landscapeRightMode();
    }

  }
  void setPortraitUpMode(){
    if (Platform.isIOS) {
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }else{
       AutoOrientation.portraitUpMode();
    }
  }

  @override
  void dispose() {
    ///页面退出时，切换为竖屏

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: VideoPlayerPanelWidget(
      backCallback: (Duration current) {
        setPortraitUpMode();
        Navigator.of(context).pop();
      },
      videoController: widget.videoController,
    ));
  }
}

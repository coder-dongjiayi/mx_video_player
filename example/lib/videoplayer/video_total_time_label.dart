import 'package:flutter/material.dart';

import 'blmedia_controller.dart';
class VideoTotalTimeLabel extends StatelessWidget {
  const VideoTotalTimeLabel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _totalTime();
  }
  ///视频总时间
  Widget _totalTime() {
    return Builder(builder: (context) {
      String _time = context.select<BLMediaController, String>((value) {
        return value.duration;
      });

      return Text("$_time",
          style: TextStyle(color: Colors.white));
    });
  }
}

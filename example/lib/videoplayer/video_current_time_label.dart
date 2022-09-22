import 'package:flutter/material.dart';
import 'blmedia_controller.dart';
class VideoCurrentTimeLabel extends StatelessWidget {
  const VideoCurrentTimeLabel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _currentTime();
  }
  ///视频当前时间
  Widget _currentTime() {
    return Builder(builder: (context) {
      String _time = context.select<BLMediaController, String>((value) {
        return value.position;
      });
      return Padding(
          padding: EdgeInsets.only(left: 10), child: Text("$_time",
          style: TextStyle(color: Colors.white)));
    });
  }
}

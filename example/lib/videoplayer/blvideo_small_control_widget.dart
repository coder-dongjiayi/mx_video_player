
import 'package:example/videoplayer/video_current_time_label.dart';
import 'package:example/videoplayer/video_play_button.dart';
import 'package:example/videoplayer/video_total_time_label.dart';
import 'package:flutter/material.dart';

import 'blvideo_progress_slider.dart';

class BlVideoSmallControlWidget extends StatefulWidget {
  const BlVideoSmallControlWidget({Key? key,this.fullScreenCallback}) : super(key: key);

 final VoidCallback? fullScreenCallback;
  @override
  State<BlVideoSmallControlWidget> createState() =>
      _BlVideoSmallControlWidgetState();
}

class _BlVideoSmallControlWidgetState extends State<BlVideoSmallControlWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.only(left: 15, right: 0),
      decoration: BoxDecoration(
          color: Color.fromRGBO(0, 0, 0, 0.7),
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromRGBO(0, 0, 0, 0),
                Color.fromRGBO(0, 0, 0, 1),
              ])),
      child: Row(
        children: [
          VideoPlayButton(small: true),
          VideoCurrentTimeLabel(),
          SizedBox(width: 10),
          Expanded(child: BlVideoProgressSlider()),
          SizedBox(width: 10),
          VideoTotalTimeLabel(),
          _fullScreen(),
        ],
      ),
    );
  }

  Widget _fullScreen() {
    return GestureDetector(
      onTap: () {
     widget.fullScreenCallback?.call();
      },
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.only(right: 15,bottom: 25,top: 25,left: 20),
        child: Image.asset(
          "assets/images/icon_quanping.png",
          width: 14,
          height: 14,
        ),
      ),
    );
  }
}


import 'package:example/videoplayer/video_current_time_label.dart';
import 'package:example/videoplayer/video_play_button.dart';
import 'package:example/videoplayer/video_total_time_label.dart';
import 'package:flutter/material.dart';

import 'blvideo_progress_slider.dart';



class BLVideoControlWidget extends StatefulWidget {
  const BLVideoControlWidget({Key? key}) : super(key: key);

  @override
  _BLVideoControlWidgetState createState() => _BLVideoControlWidgetState();
}

class _BLVideoControlWidgetState extends State<BLVideoControlWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(left: 30, top: 12, right: 40, bottom: 10),
        decoration: BoxDecoration(
            color: Color.fromRGBO(0, 0, 0, 0.7),
            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [
              Color.fromRGBO(0, 0, 0, 0),
              Color.fromRGBO(0, 0, 0, 1),
            ])),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _sliderProgress(),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      VideoPlayButton(small: false),
                      SizedBox(width: 40),
                      VideoCurrentTimeLabel(),
                      _timeLabel("/"),
                      VideoTotalTimeLabel()
                    ],
                  ),

                ],
              )
            ],
          ),
        ));
  }



  Widget _sliderProgress() {
    return BlVideoProgressSlider();
  }

  Widget _timeLabel(String time) {
    return Text("$time", style: TextStyle(color: Colors.white));
  }

}

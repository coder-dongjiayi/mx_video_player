import 'package:flutter/material.dart';

import 'audio_video_progress_bar.dart';
import 'blmedia_controller.dart';


class BlVideoProgressSlider extends StatefulWidget {
  const BlVideoProgressSlider({Key? key}) : super(key: key);

  @override
  _BlVideoProgressSliderState createState() => _BlVideoProgressSliderState();
}

class _BlVideoProgressSliderState extends State<BlVideoProgressSlider> {
  Duration _position = Duration.zero;
  bool _seek = false;

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      Duration position =
          context.select<BLMediaController, Duration>((value) =>value.videoPosition);
      if (_seek == false) {
        _position = position;
      }
      Duration buffer = context.select<BLMediaController, Duration>((value) {
        return value.buffer ?? Duration.zero;
      });

      List<Duration>? segmentedDurationList = context.read<BLMediaController>().segmentedDurationList;
      bool interaction =  context.select<BLMediaController,bool>((value) => value.interaction);

      return Container(

        child: ProgressBar(
          segmentedDurationList: interaction == false ? [] : segmentedDurationList,
          onSeek: (Duration duration) async {
            context.read<BLMediaController>().setVideoControllerDealEvent(true);
            await context.read<BLMediaController>().seek(duration);
            _seek = false;
            context.read<BLMediaController>().setVideoControllerDealEvent(false);

          },
          onDragStart: (ThumbDragDetails details) {
            context.read<BLMediaController>().setVideoControllerDealEvent(true);
            _seek = true;
          },
          onDragUpdate: (ThumbDragDetails details) {
            setState(() {
              _position = details.timeStamp;
            });
          },
          onDragEnd: () {
            context.read<BLMediaController>().setVideoControllerDealEvent(false);
          },
          baseBarColor: Color.fromRGBO(255, 255, 255, 0.5),
          thumbColor: Colors.red,
          barHeight: 5,
          timeLabelLocation: TimeLabelLocation.none,
          progress: _position,
          progressBarColor: Colors.red,
          bufferedBarColor: Colors.yellow,
          buffered: buffer,
          total: context.read<BLMediaController>().videoPlayerController.duration ?? Duration.zero,
        ),
      );
    });
  }
}

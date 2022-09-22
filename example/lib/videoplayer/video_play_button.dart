import 'package:flutter/material.dart';

import 'blmedia_controller.dart';



class VideoPlayButton extends StatelessWidget {
  const VideoPlayButton({Key? key, required this.small}) : super(key: key);
  final bool small;
  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return GestureDetector(onTap: () async {
        context.read<BLMediaController>().setVideoControllerDealEvent(true);
        await context.read<BLMediaController>().playOrPause();
        context.read<BLMediaController>().setVideoControllerDealEvent(false);
      }, child: Builder(builder: (context) {
        bool isPlaying = context.select<BLMediaController, bool>((value) {
          return value.videoPlayerController.isPlaying;
        });

        String playImage = isPlaying == false
            ? "assets/images/play.png"
            : "assets/images/pause.png";
        return Image.asset(playImage,

            fit: BoxFit.cover,
            width: small == true ? 25 : 40,
            height: small == true ? 25 : 40);

      }));
    });
  }
}

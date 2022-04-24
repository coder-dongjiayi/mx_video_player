import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mx_video_player/mx_video_player.dart';
import 'package:provider/provider.dart';

class VideoPlayPaneState extends ChangeNotifier {
  MXVideoPlayerController playerController;

  Duration? position;
  double progress = 0.0;
  Duration? buffered;
  late StreamSubscription<double> _progressSubscription;

  late StreamSubscription<Duration?> _bufferedSubscription;
  VideoPlayPaneState(this.playerController) {
    _progressSubscription = playerController.onProgressStream.listen((p) {
      position = playerController.position;
      progress = p;
      notifyListeners();
    });

    _bufferedSubscription = playerController.onBufferedStream.listen((b) {
      buffered = b;
      notifyListeners();
    });
  }
  @override
  void dispose() {
    // TODO: implement dispose

    _progressSubscription.cancel();
    _bufferedSubscription.cancel();
    super.dispose();
  }
}

class VideoPlayPanel extends StatelessWidget {
  VideoPlayPanel({Key? key, required this.playerController}) : super(key: key);
  MXVideoPlayerController playerController;

  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider<VideoPlayPaneState>(
      create: (_) {
        return VideoPlayPaneState(playerController);
      },
      child: Container(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _buildProgress(),
            Row(
              children: [
                _buildCurrentTime(),
                _buildSliderProgress(),
                _buildTotalTime()
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildProgress() {
    return Builder(builder: (context) {
      Duration? _buffered = context
          .select<VideoPlayPaneState, Duration?>((value) => value.buffered);
      Duration? _total =
          context.read<VideoPlayPaneState>().playerController.duration;
      double percent = 0.0;

      if (_total != null && _buffered != null) {
        percent = _buffered.inMilliseconds / (_total.inMilliseconds);
      }

      return Padding(
        padding: const EdgeInsets.only(left: 60, right: 60),
        child: Column(
          children: [
            const Text(
              "当前视频缓冲进度",
              style: TextStyle(color: Colors.white),
            ),
            LinearProgressIndicator(
              value: percent,
              color: Colors.yellow,
              valueColor: const AlwaysStoppedAnimation(Colors.red),
            )
          ],
        ),
      );
    });
  }

  Widget _buildSliderProgress() {
    return Builder(builder: (context) {
      return Expanded(
          child: Stack(
        children: [
          SliderTheme(
              data: const SliderThemeData(
                  trackHeight: 5,
                  thumbColor: Colors.yellow,
                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 5),
                  activeTrackColor: Colors.red,
                  inactiveTrackColor: Colors.white),
              child: Builder(builder: (context) {
                double progress = context.select<VideoPlayPaneState, double>(
                    (value) => value.progress);

                return Slider(
                  value: progress,
                  max: 1.0,
                  onChanged: (double value) {},
                );
              }))
        ],
      ));
    });
  }

  Widget _buildTotalTime() {
    return Builder(builder: (context) {
      Duration? _duration = context.select<VideoPlayPaneState, Duration?>(
          (value) => value.playerController.duration);

      return Text(MXPlayerUtil.durationToString(_duration),
          style: const TextStyle(color: Colors.white));
    });
  }

  Widget _buildCurrentTime() {
    return Builder(builder: (context) {
      Duration? _duration =
          context.select<VideoPlayPaneState, Duration?>((value) {
        return value.position;
      });

      return Text(MXPlayerUtil.durationToString(_duration),
          style: const TextStyle(color: Colors.white));
    });
  }
}

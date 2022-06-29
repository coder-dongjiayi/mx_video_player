import 'package:example/video_player_panel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mx_video_player/mx_video_player.dart';
import 'package:provider/provider.dart';

class BasicVideoState extends ChangeNotifier {
  late MXVideoPlayerController playerController;
  double _progress = 0.0;

  double get progress => _progress;

  set progress(double value) {
    _progress = value;
    notifyListeners();
  }

  bool isDrag = false;

  BasicVideoState(this.playerController) {
    playerController.onPositionStream.listen((event) {
      if (isDrag == false) {
        progress = playerController.progress;
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}

class BasicVideoPage extends StatefulWidget {
  const BasicVideoPage({Key? key}) : super(key: key);

  @override
  _BasicVideoPageState createState() => _BasicVideoPageState();
}

class _BasicVideoPageState extends State<BasicVideoPage> {
  late MXVideoPlayerController _videoPlayerController;

  double _volume = 0.3;

  String url = "https://1254467417.vod2.myqcloud.com/139d0463vodbj1254467417/963069588602268010636208027/f0.mp4";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _videoPlayerController = MXVideoPlayerController();
    _videoPlayerController.onIsBufferingStream.listen((event) {});
    MXLogger.changeLogLevel(MXLogLevel.info);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _videoPlayerController.release();
    super.dispose();
  }

  Widget _placeholder() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: Colors.red,

        alignment: Alignment.bottomCenter,
        child: ElevatedButton(
            onPressed: () {
              _videoPlayerController.setDataSource(url, isLooping: true);
            },
            child: const Text("默认占位的widget 点击播放视频")),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("基本功能演示")),
      body: Column(
        children: [
          MXVideoPlayer(
            controller: _videoPlayerController,
            /// 视频加载指示器
            indicatorBuilder: (context, controller) {
              return const CupertinoActivityIndicator();
            },
            /// 播放网络视频如果视频正在缓冲，可以使用这个builder 定制缓冲样式
            bufferBuilder: (context, controller) {
              return Container(
                width: 100,
                height: 100,
                alignment: Alignment.center,
                color: Colors.yellow,
                child: const Text("正在缓冲中"),
              );
            },
            /// 视频还没有初始化之前用于占位的builder
            placeholderBuilder: (context, controller) {
              return _placeholder();
            },
            /// 视频加载失败或者播放过程中出现了error
            errorWidgetBuilder: (context, error, controller) {
              return Text("视频播放失败了 ${error.toString()}");
            },

          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                  onPressed: () {
                    _videoPlayerController.play();
                  },
                  child: const Text("play")),
              ElevatedButton(
                  onPressed: () {
                    _videoPlayerController.pause();
                  },
                  child: const Text("pause")),
              ElevatedButton(
                  onPressed: () {
                    _videoPlayerController.stop();
                  },
                  child: const Text("stop")),
              ElevatedButton(
                  onPressed: () {
                    _videoPlayerController.reset();
                  },
                  child: const Text("reset")),
            ],
          ),
          Row(
            children: [
              ElevatedButton(
                  onPressed: () {
                    _volume = _volume + 0.2;

                    _videoPlayerController.setVolume(_volume);
                  },
                  child: const Text("声音增大")),
              SizedBox(width: 20),
              ElevatedButton(
                  onPressed: () {
                    _volume = _volume - 0.2;

                    _videoPlayerController.setVolume(_volume);
                  },
                  child: const Text("声音减小")),
            ],
          ),
          Row(
            children: [
              ElevatedButton(
                  onPressed: () {
                    _videoPlayerController.setSpeed(1.0);
                  },
                  child: const Text("正常速度播放")),
              SizedBox(width: 20),
              ElevatedButton(
                  onPressed: () {
                    _videoPlayerController.setSpeed(1.5);
                  },
                  child: const Text("1.5倍速播放")),
              SizedBox(width: 20),
              ElevatedButton(
                  onPressed: () {
                    _volume = _volume - 0.2;

                    _videoPlayerController.setSpeed(2.0);
                  },
                  child: const Text("2倍速播放")),
            ],
          ),
          _sliderProgress()
        ],
      ),
    );
  }

  Widget _sliderProgress() {
    return ChangeNotifierProvider<BasicVideoState>(
      create: (context) {
        return BasicVideoState(_videoPlayerController);
      },
      child: SliderTheme(
          data: const SliderThemeData(
              trackHeight: 15,
              thumbColor: Colors.blue,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 15),
              activeTrackColor: Colors.red,
              inactiveTrackColor: Colors.grey),
          child: Builder(builder: (context) {
            BasicVideoState playerState = context.read<BasicVideoState>();
            context.select<BasicVideoState, double>((value) {
              return value.progress;
            });

            return Slider(
              value: playerState.progress,
              max: 1.0,
              onChangeStart: (double value) {
                playerState.isDrag = true;
              },
              onChangeEnd: (double value) async {
                playerState.progress = value;

                await playerState.playerController.setProgress(value);

                playerState.isDrag = false;
              },
              onChanged: (double value) {
                playerState.progress = value;
              },
            );
          })),
    );
  }
}

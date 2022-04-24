import 'package:example/video_player_panel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mx_video_player/mx_video_player.dart';
/// 原理就是 使用视频的第一帧占位 然后播放视频的时候就可以平稳过度
class SwitchVideoPlayerPage extends StatefulWidget {
  const SwitchVideoPlayerPage({Key? key}) : super(key: key);

  @override
  _SwitchVideoPlayerPageState createState() => _SwitchVideoPlayerPageState();
}

class _SwitchVideoPlayerPageState extends State<SwitchVideoPlayerPage> {
  late MXVideoPlayerController _videoPlayerController;

  final List<String> _list = [
    "assets://assets/video/video1.mp4",
    "assets://assets/video/video2.mp4",
    "assets://assets/video/video3.mp4"
  ];
final  List<String> _placeholderCover = [
    "assets/images/video_cover1.jpg",
    "assets/images/video_cover2.jpg",
    "assets/images/video_cover3.jpg"
  ];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _videoPlayerController = MXVideoPlayerController();
    MXLogger.changeLogLevel(MXLogLevel.detail);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _videoPlayerController.release();
  }



  Widget _customPlaceholder(String path) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Image.asset(path, width: double.infinity),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("多视频无缝切换")),
      body: Stack(
        children: [
          /// 提前渲染占位图 否则首次切换视频会有白屏
          /// BlingVideo 把提前渲染的图片盖住 这样看不出来

          _customPlaceholder(_placeholderCover[1]),
          _customPlaceholder(_placeholderCover[2]),
          _customPlaceholder(_placeholderCover[0]),

          Column(
            children: [
              MXVideoPlayer(
                controller: _videoPlayerController,
                placeholderBuilder: (context,controller){
                  return _customPlaceholder(_placeholderCover[0]);
                },
                errorWidgetBuilder: (BuildContext context, Object? error,MXVideoPlayerController? controller) {
                  return Container(
                    width: 200,
                    height: 200,
                    color: Colors.red,
                    alignment: Alignment.center,
                    child: Text(error.toString()),
                  );
                },
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List<Widget>.generate(_list.length, (index) {
                    return ElevatedButton(
                        onPressed: () {
                          _videoPlayerController.setDataSource(_list[index],
                              isLooping:true,

                              prepare:
                                  _customPlaceholder(_placeholderCover[index]));
                        },
                        child: Text("video${index + 1}"));
                  }).toList()),

            ],
          )
        ],
      ),
    );
  }
}

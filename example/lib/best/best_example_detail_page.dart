import 'package:flutter/material.dart';
import 'package:mx_video_player/mx_video_player.dart';
class BestExampleDetailPage extends StatefulWidget {
  const BestExampleDetailPage({Key? key,required this.controller}) : super(key: key);
 final MXVideoPlayerController controller;
  @override
  _BestExampleDetailPageState createState() => _BestExampleDetailPageState();
}

class _BestExampleDetailPageState extends State<BestExampleDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:Text("视频详情页面")),
          body: Column(
            children: [
              MXVideoPlayer(
                controller: widget.controller,
              )
            ],
          ),
    );
  }
}

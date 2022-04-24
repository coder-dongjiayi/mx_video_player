import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mx_video_player/mx_video_player.dart';
import 'package:path_provider/path_provider.dart';

class ConvenientVideoPage extends StatefulWidget {
  const ConvenientVideoPage({Key? key}) : super(key: key);

  @override
  _ConvenientVideoPageState createState() => _ConvenientVideoPageState();
}

class _ConvenientVideoPageState extends State<ConvenientVideoPage> {
  String url =
      "http://vfx.mtime.cn/Video/2019/02/04/mp4/190204084208765161.mp4";

  String? filePath;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    MXLogger.changeLogLevel(MXLogLevel.info);
     _copyResource();
  }

  void _copyResource() async {
    String dir = (await getApplicationDocumentsDirectory()).path;
    String path = '$dir/video2.mp4';
    if (File(path).existsSync()) {
      setState(() {
        filePath = path;
      });
    } else {
      var bytes = await rootBundle.load("assets/video/video2.mp4");

      await writeToFile(bytes, path);

      setState(() {
        filePath = path;
      });
    }
  }

  Future<void> writeToFile(ByteData data, String path) {
    final buffer = data.buffer;

    return File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("便捷初始化"),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 20,bottom: 20),
            child: Column(
              children: [
                const Text("network", style: TextStyle(fontSize: 20)),
                _buildNetwork(),
                const Text("assets",
                    style: TextStyle(fontSize: 20)),
                _buildAssets(),
                const Text("file", style: TextStyle(fontSize: 20)),
                _buildFile(),
              ],
            ),
          )
        ));
  }

  Widget _buildAssets() {
    return MXVideoPlayer.assets("assets/video/video1.mp4",

        isLooping: true, placeholderBuilder: (context, controller) {
      return _placeholder();
    });
  }

  Widget _buildFile() {
    if (filePath == null) return const SizedBox();

    return MXVideoPlayer.file(filePath!,
        isLooping: true,
   placeholderBuilder: (context, controller) {
      return _placeholder();
    });
  }

  Widget _buildNetwork() {

    return MXVideoPlayer.network(
      url,
      isLooping: true,
      indicatorBuilder:
          (BuildContext context, MXVideoPlayerController? player) {
        return const CupertinoActivityIndicator();
      },
      placeholderBuilder: (context, controller) {
        return _placeholder();
      },
    );
  }

  Widget _placeholder() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: Colors.red,
        alignment: Alignment.center,
        child: const Text("placeholder"),
      ),
    );
  }
}

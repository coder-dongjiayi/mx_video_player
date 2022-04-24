import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:mx_video_player/mx_video_player.dart';
class BestExampleState extends ChangeNotifier{

  List<Map<String,dynamic>> videoList = [];

  late MXVideoPlayerController videoPlayerController;
  int? currentIndex;
  double? currentY;
  MXVideoPlayerState playerState = MXVideoPlayerState.idle;


  BestExampleState(){
    videoPlayerController = MXVideoPlayerController();
    videoPlayerController.onPlayerStateChanged.listen((event) {
      if(event == MXVideoPlayerState.initialized){

      }
    });
  }
  @override
  void dispose() {
    // TODO: implement dispose
    videoPlayerController.release();
    super.dispose();

  }

  void play(int index) {
    currentIndex = index;
    String videoUrl =  videoList[index]["videoUrl"];
    notifyListeners();
    videoPlayerController.setDataSource(videoUrl);

  }
  void reset(){
    videoPlayerController.reset();
    currentIndex = null;
    currentY = null;
    notifyListeners();

  }
  void requestVideoList() async{
    var dio = Dio();
    final response = await dio.get('https://api.apiopen.top/todayVideo');
   List<dynamic> _list = response.data["result"];
    for (var element in _list) {
     Map<String,dynamic> _videoMap = {};

      Map<String,dynamic> _data = element["data"] ?? {};
      if(_data["content"] != null){
        if(_data["content"]["type"] == "video"){
          if(_data["content"]["data"] != null){
            if(_data["content"]["data"]["playUrl"] != null){
              _videoMap["videoUrl"] = _data["content"]["data"]["playUrl"];
            }
            if(_data["content"]["data"]["playInfo"] != null){
             List _playInfo =  _data["content"]["data"]["playInfo"];
             _videoMap["width"] = _playInfo.first["width"];
             _videoMap["height"] = _playInfo.first["height"];

             if(_data["content"]["data"]["cover"]["feed"] != null){
               _videoMap["cover"] = _data["content"]["data"]["cover"]["feed"];
             }
             _videoMap["name"] = _data["content"]["data"]["author"]["name"] ?? "name";

             _videoMap["header"] = _data["content"]["data"]["author"]["icon"];
             videoList.add(_videoMap);
            }
            if(_data["content"]["data"]["description"] != null){
              _videoMap["description"] = _data["content"]["data"]["description"];
            }



          }

        }


      }
    }
    notifyListeners();

  }
}
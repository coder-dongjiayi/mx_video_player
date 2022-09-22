import 'dart:io';


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:mx_video_player/mx_video_player.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'blmedia_controller.dart';
import 'blvideo_control_widget.dart';
import 'blvideo_small_control_widget.dart';
import 'buffer_loading.dart';

typedef DisposeCallback = void Function(Duration current);
class VideoPlayerPanelWidget extends StatefulWidget {
  const VideoPlayerPanelWidget(
      {Key? key,
      this.backCallback,
      required this.videoController,
      this.width,
      this.height,
      this.small,
      this.fullScreenCallback})
      : super(key: key);
  final DisposeCallback? backCallback;
  final BLMediaController videoController;
  final double? width;
  final double? height;
  final bool? small;
  final VoidCallback? fullScreenCallback;

  @override
  State<VideoPlayerPanelWidget> createState() => _VideoPlayerPanelWidgetState();
}

class _VideoPlayerPanelWidgetState extends State<VideoPlayerPanelWidget> with WidgetsBindingObserver {
  double _startHorizontalDragX = 0.0;


  bool _showRouter = false;

  ///灵敏度
  double _percentLength = 0.0;
  late BLMediaController _videoController;

  @override
  void initState() {
    super.initState();
    _videoController = widget.videoController;
    _videoController.videoPlayerController.onPlayerStateChanged.listen((event) {
      if ((event == MXVideoPlayerState.completed) && _showRouter == true) {
        Navigator.of(context).pop();
        _showRouter = false;
      }
    });
    WidgetsBinding.instance.addObserver(this);
  }

  /// app进入后台监听
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (Platform.isIOS) return;
    if (state == AppLifecycleState.paused) {
      _videoController.pause();
    } else if (state == AppLifecycleState.resumed) {
      /// 正在投屏中 或者是互动视频正在进行互动 从后台回来也是暂停状态
      if (_videoController.isDLNAPlaying || _videoController.interacting == true) {
        _videoController.pause();
      } else {
        _videoController.play();
      }
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {

    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: widget.videoController,
        child: Container(
          child: Stack(
            children: [
              _playerBuilder(),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _appBar(),
                  _bottomNavigationBar(),
                ],
              ),
            ],
          ),
        ));
  }

  Widget _appBar() {
    return SafeArea(
        top: false,
        child: Builder(builder: (context) {
          bool hidden = context.select<BLMediaController, bool>((value) => value.appBarHidden);
          return Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.only(top: 10),
            child: _leading(hidden),
          );
        }));
  }

  Widget _bottomNavigationBar() {
    return Builder(builder: (context) {
      bool isField = context
          .select<BLMediaController, bool>((value) => value.videoPlayerController.state == MXVideoPlayerState.error);

      bool visible = isField == false ;

      bool bottom = context.select<BLMediaController, bool>((value) => value.bottomNaviHidden);

      Widget _widget = widget.small == true
          ? BlVideoSmallControlWidget(
        fullScreenCallback: widget.fullScreenCallback,
      )
          : BLVideoControlWidget();


      return Visibility(visible: visible, child: _animationBuilder(_widget, bottom));
    });
  }

  /// 视频播放器主体
  Widget _playerBuilder() {
    _percentLength = 90 / MediaQuery.of(context).size.width;

    return Builder(builder: (context) {
      return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            /// 隐藏相关操作页面
            context.read<BLMediaController>().controlHidden();
          },
          onHorizontalDragStart: (DragStartDetails details) {
            context.read<BLMediaController>().setVideoControllerDealEvent(true);
            _onHorizontalDragStart(context, details);
          },
          onHorizontalDragUpdate: (DragUpdateDetails details) {
            _onHorizontalDragUpdate(context, details);
          },
          onHorizontalDragEnd: (DragEndDetails details) {
            context.read<BLMediaController>().setVideoControllerDealEvent(false);
            _onHorizontalDragEnd(context, details);
          },
          onVerticalDragStart: (DragStartDetails details) {
            context.read<BLMediaController>().setVideoControllerDealEvent(true);
            _onVerticalDragStart(context, details);
          },
          onVerticalDragUpdate: (DragUpdateDetails details) {
            _onVerticalDragUpdate(context, details);
          },
          onVerticalDragEnd: (DragEndDetails details) {
            context.read<BLMediaController>().setVideoControllerDealEvent(false);

            ///延迟1.5s后再关闭进度条
            Future.delayed(Duration(milliseconds: 1500), () {
              if (mounted) {
                context.read<BLMediaController>().setVerticalDrag(false);
              }
            });
          },
          child: Stack(
            children: [
              Center(
                child: Builder(builder: (context) {
                  bool lastTime = context.select<BLMediaController, bool>((value) => value.lastTime);
                  if (lastTime == true) {
                    Fluttertoast.showToast(msg: "已定位到上次浏览位置", toastLength: Toast.LENGTH_LONG);
                    context.read<BLMediaController>().lastTime = false;
                  }
                  return OrientationBuilder(builder: (context, orientation) {
                    return MXVideoPlayer(
                      color: Colors.black,
                      width: widget.width,
                      height: widget.height,
                      fit: BoxFit.contain,
                      controller: context.read<BLMediaController>().videoPlayerController,
                      errorWidgetBuilder: (context, error, controller) {

                        return _errorBuild("$error");
                      },
                      indicatorBuilder: (BuildContext context, MXVideoPlayerController? controller) {
                        return BufferLoading();
                      },
                      bufferBuilder: (BuildContext context, MXVideoPlayerController? controller) {
                        return BufferLoading();
                      },
                    );
                  });
                }),
              ),
            ],
          ));
    });
  }

  /// 视频播放失败
  Widget _errorBuild(String error) {
    return Builder(builder: (context) {

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("网络不畅通哦", style:TextStyle(color: Colors.white)),
          SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              context.read<BLMediaController>().retry();
            },
            child: Text("点击重试",style: TextStyle(color: Colors.white),),
          )
        ],
      );
    });
  }


  /// 左边返回按钮
  Widget _leading(bool hidden) {
    return _animationBuilder(_back(), hidden);
  }

  /// 返回按钮
  Widget _back() {

    return Builder(builder: (context) {
    Size size =   context.select<BLMediaController,Size>((value) => value.videoPlayerController.size);
    double top = MediaQuery.of(context).padding.top;
    bool isVertical = size.width / size.height < 1 ? true : false;
    double marginTop= 0 ;
    if(Platform.isIOS == true && top>= 48 && isVertical == true){
      marginTop = 20;
    }
      return GestureDetector(
          onTap: () {
            context.read<BLMediaController>().setVideoControllerDealEvent(true);

            /// 保存视频进度
            context.read<BLMediaController>().saveCurrentPosition();

            if (widget.backCallback == null) {
              Navigator.of(context).pop();
            } else {
              widget.backCallback!
                  .call(context.read<BLMediaController>().videoPlayerController.position ?? Duration(seconds: 0));
            }
          },
          child: Container(
            margin: EdgeInsets.only(top: marginTop),
            width: 64,
            height: 64,
            color: Colors.transparent,
            padding: EdgeInsets.all(10),
            child: Icon(Icons.arrow_back,color: Colors.black,size: 40,),
          ));
    });
  }






  Widget _animationBuilder(Widget widget, bool isHidden) {
    return Builder(builder: (context) {
      return AnimatedOpacity(
        opacity: isHidden == true ? 0 : 1,
        duration: Duration(milliseconds: 300),
        child: IgnorePointer(
          ignoring: isHidden,
          child: widget,
        ),
      );
    });
  }



  ///设置屏幕横向滑动调整视频进度
  void _onHorizontalDragStart(BuildContext context, DragStartDetails details) {


    context.read<BLMediaController>().setHorizontalDrag(true);
    _startHorizontalDragX = details.globalPosition.dx;
  }

  void _onHorizontalDragUpdate(BuildContext context, DragUpdateDetails details) async {

    double dx = details.globalPosition.dx;

    double distance = dx - _startHorizontalDragX;
    int second = (distance * _percentLength).toInt();

    context.read<BLMediaController>().dragSecond = second;
  }

  ///垂直滑动左边改变屏幕亮度 右边控制声音大小
  void _onVerticalDragStart(BuildContext context, DragStartDetails details) {

    context.read<BLMediaController>().setVerticalDrag(true);

  }

  void _onVerticalDragUpdate(BuildContext context, DragUpdateDetails details) async {

  }

  void _onHorizontalDragEnd(BuildContext context, DragEndDetails details) {

    context.read<BLMediaController>().setHorizontalDrag(false);
    context.read<BLMediaController>().dragSeek();
  }
}

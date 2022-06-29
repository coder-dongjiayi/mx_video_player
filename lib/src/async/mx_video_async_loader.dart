import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter/cupertino.dart';
import 'package:mx_video_player/src/video_player/mx_inner_widget.dart';

import '../../mx_video_player.dart';

enum MXVideoUIState {
  none,

  loading,

  startBuffering,
  endBuffering,
  succeed,

  error,
}

typedef ResultWidgetBuilder = Widget? Function(BuildContext context);


typedef AsyncLoaderWidgetBuilder = Widget? Function(BuildContext context);

class MXVideoAsyncFutureLoader extends StatefulWidget {
  const MXVideoAsyncFutureLoader(
      {Key? key,
      this.onStream,
      this.onIsBufferingStream,
      required this.successWidgetBuilder,
      this.bufferedBuilder,
      this.placeholderBuilder,
      this.errorWidgetBuilder,
      this.indicatorBuilder})
      : super(key: key);

  final Stream<MXVideoPlayerState>? onStream;
  final Stream<bool>? onIsBufferingStream;

  final AsyncLoaderWidgetBuilder? placeholderBuilder;
  final AsyncLoaderWidgetBuilder? bufferedBuilder;

  final ResultWidgetBuilder successWidgetBuilder;

  final ResultWidgetBuilder? errorWidgetBuilder;
  final AsyncLoaderWidgetBuilder? indicatorBuilder;
  @override
  _MXVideoAsyncFutureLoaderState createState() =>
      _MXVideoAsyncFutureLoaderState();
}

class _MXVideoAsyncFutureLoaderState
    extends State<MXVideoAsyncFutureLoader> {
  Widget? _cachePlaceholder;

  final StreamController<MXVideoUIState> _streamController =
      StreamController.broadcast();
  StreamSubscription<MXVideoPlayerState>? _subscription;

  StreamSubscription<bool>? _isBufferingSubscription;

  List<Widget> _stack = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _initSubscription();
  }

  void _initSubscription() {
    if (widget.onStream == null) {
      _addState(MXVideoUIState.none);

      return;
    }
    _isBufferingSubscription = widget.onIsBufferingStream?.listen((event) {
      
      if(event == true){
        _addState(MXVideoUIState.startBuffering);

      }else{
        _addState(MXVideoUIState.endBuffering);

      }

    });

    _subscription = widget.onStream?.listen((event) {
      switch (event) {
        case MXVideoPlayerState.prepareInitialized:
          _addState(MXVideoUIState.loading);

          break;
        case MXVideoPlayerState.initialized:

          _addState(MXVideoUIState.succeed);
          break;
        case   MXVideoPlayerState.completed:
          _addState(MXVideoUIState.succeed);
          break;
        case MXVideoPlayerState.error:
          _addState(MXVideoUIState.error);

          break;
        default:
          break;
      }
    });
  }

  void _addState(MXVideoUIState state){

    Future.delayed(Duration.zero,(){
      _streamController.sink.add(state);
    });
  }
  @override
  void dispose() {
    // TODO: implement dispose
    _subscription?.cancel();
    _isBufferingSubscription?.cancel();

    _streamController.close();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MXVideoAsyncFutureLoader oldWidget) {
    // TODO: implement didUpdateWidget
    _subscription?.cancel();

    _subscription = null;

    _isBufferingSubscription?.cancel();
    _isBufferingSubscription = null;

    _initSubscription();


    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MXVideoUIState?>(
        stream: _streamController.stream,
        builder:
            (BuildContext context, AsyncSnapshot<MXVideoUIState?> snapshot) {

          if (snapshot.data == MXVideoUIState.error) {
            return _buildError();
          }
          if (snapshot.data == MXVideoUIState.none || snapshot.data == null) {
            _stack = [_buildPlaceholder(context, snapshot)];
          }
          if (snapshot.data == MXVideoUIState.loading) {
            _stack.clear();
            _stack.add(_buildPlaceholder(context, snapshot));
            _stack.add(_buildActivityIndicator());
          }
          if (snapshot.data == MXVideoUIState.succeed) {
            _stack.clear();
            if (_cachePlaceholder != null) {
              _stack.add(_cachePlaceholder!);
            }
            _stack.add(_buildDone(snapshot));
          }
          if(snapshot.data == MXVideoUIState.startBuffering){

             Widget? buffering = widget.bufferedBuilder?.call(context);

            if(buffering != null &&  _contain(runtimeType: MXInnerBuffer) == false){

              _stack.add(buffering);

            }
          }
          if(snapshot.data == MXVideoUIState.endBuffering){

            _stack.removeWhere((element) => element.runtimeType == MXInnerBuffer);
            /// 此时如果视频播放器不存在 stack中 就需要添加视频播放的widget
            if(!_contain(runtimeType: MXInnerSuccess)){
              _stack.add(_buildDone(snapshot));
            }
          }


          MXLogger.info("MXVideoUIState:${snapshot.data}, stack:${_stack.toString()}");
          return Stack(
            alignment: Alignment.center,
            children: _stack,
          );
        });
  }

  bool _contain({required Type runtimeType}){
    for (var element in _stack) {
      if(element.runtimeType == runtimeType) return true;
    }
    return false;
  }
  Widget _buildPlaceholder(
      BuildContext context, AsyncSnapshot<MXVideoUIState?> snapshot) {
    Widget? _placeholderWidget = widget.placeholderBuilder?.call(context);
    _cachePlaceholder = _placeholderWidget;
    return _placeholderWidget ?? const SizedBox();
  }

  Widget _buildDone(AsyncSnapshot<MXVideoUIState?> snapshot) {
    return widget.successWidgetBuilder.call(context)!;
  }

  Widget _buildError() {
    if (widget.errorWidgetBuilder?.call(context) != null) {
      return widget.errorWidgetBuilder!.call(context)!;
    }

    return const Center(
      child: Text("use BLLogger.changeLogLevel(BLLogLevel.error)"),
    );
  }

  Widget _buildActivityIndicator() {
    if (widget.indicatorBuilder?.call(context) != null) {
      return widget.indicatorBuilder!.call(context)!;
    }
    return const Center(
      child: SizedBox(),
    );
  }
}

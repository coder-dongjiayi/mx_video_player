import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter/cupertino.dart';

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
  Widget? _cacheBuffering;
  List<Widget> _stack = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _initSubscription();
  }

  void _initSubscription() {
    if (widget.onStream == null) {
      Future.delayed(Duration.zero, () {
        _streamController.sink.add(MXVideoUIState.none);
      });
      return;
    }
    _isBufferingSubscription = widget.onIsBufferingStream?.listen((event) {
      if(event == true){
         _streamController.sink.add(MXVideoUIState.startBuffering);
      }else{
        _streamController.sink.add(MXVideoUIState.endBuffering);

      }

    });

    _subscription = widget.onStream?.listen((event) {
      switch (event) {
        case MXVideoPlayerState.prepareInitialized:
          _streamController.sink.add(MXVideoUIState.loading);
          break;
        case MXVideoPlayerState.initialized:
          _streamController.sink.add(MXVideoUIState.succeed);
          break;
        case MXVideoPlayerState.error:
          _streamController.sink.add(MXVideoUIState.error);
          break;
        default:
          break;
      }
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
    _streamController.sink.add(MXVideoUIState.loading);

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
             _cacheBuffering = buffering;
            if(buffering != null){

              _stack.add(buffering);
            }
          }
          if(snapshot.data == MXVideoUIState.endBuffering){
            _stack.remove(_cacheBuffering);
          }
          MXLogger.info("MXVideoUIState:${snapshot.data}, stack:${_stack.toString()}");
          return Stack(
            alignment: Alignment.center,
            children: _stack,
          );
        });
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

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mx_video_player/src/video_player/mx_inner_widget.dart';
import 'package:super_player/super_player.dart';
import 'package:mx_video_player/src/async/mx_video_async_loader.dart';
import 'package:mx_video_player/src/video_player/basic_mx_video_player.dart';

class MXVideoPlayer extends BasicMXVideoPlayer {
  /// Creates a widget that displays an videoPlayer.
  /// If you're just playing a video and not doing too much,you might want to use a convenience constructor
  /// [MXVideoPlayer.assets]、
  /// [MXVideoPlayer.file] or [ MXVideoPlayer.network]
  const MXVideoPlayer(
      {Key? key,
      MXVideoPlayerController? controller,
      double? width,
      double? height,
      Alignment? alignment,
      BoxFit? fit,
      BlingVideoBuilder? indicatorBuilder,
      BlingVideoBuilder? placeholderBuilder,
      BlingVideoBuilder? bufferBuilder,
      Color? color,
      AsyncErrorWidgetBuilder? errorWidgetBuilder,
      InitializedBuilder? initializedBuilder,
      bool? delayInit})
      : _dataSource = null,
        _mixWithOthers = null,
        _package = null,
        _isLooping = null,
        super(controller,
            key: key,
            width: width,
            height: height,
            alignment: alignment,
            fit: fit,
            indicatorBuilder: indicatorBuilder,
            placeholderBuilder: placeholderBuilder,
            bufferBuilder: bufferBuilder,
            color: color,
            errorWidgetBuilder: errorWidgetBuilder,
            initializedBuilder: initializedBuilder);

  /// 腾讯的视频播放器暂不支持本地视频播放
  const MXVideoPlayer.assets(String dataSource,
      {Key? key,
      bool? mixWithOthers,
      String? package,
      bool? isLooping,
      double? width,
      double? height,
      Alignment? alignment,
      BoxFit? fit,
      BlingVideoBuilder? indicatorBuilder,
      BlingVideoBuilder? placeholderBuilder,
      Color? color,
      AsyncErrorWidgetBuilder? errorWidgetBuilder,
      InitializedBuilder? initializedBuilder,
      bool? delayInit})
      : _dataSource = "assets://" + dataSource,
        _mixWithOthers = mixWithOthers,
        _package = package,
        _isLooping = isLooping,
        super(
          null,
          key: key,
          width: width,
          height: height,
          alignment: alignment,
          fit: fit,
          indicatorBuilder: indicatorBuilder,
          placeholderBuilder: placeholderBuilder,
          color: color,
          errorWidgetBuilder: errorWidgetBuilder,
          initializedBuilder: initializedBuilder,
        );
  /// 腾讯的视频播放器暂不支持本地视频播放
  const MXVideoPlayer.file(String dataSource,
      {Key? key,
      bool? mixWithOthers,
      String? package,
      bool? isLooping,
      double? width,
      double? height,
      Alignment? alignment,
      BoxFit? fit,
      BlingVideoBuilder? indicatorBuilder,
      BlingVideoBuilder? placeholderBuilder,
      Color? color,
      AsyncErrorWidgetBuilder? errorWidgetBuilder,
      InitializedBuilder? initializedBuilder,
      bool? delayInit})
      : _dataSource = "file://" + dataSource,
        _mixWithOthers = mixWithOthers,
        _package = package,
        _isLooping = isLooping,
        super(
          null,
          key: key,
          width: width,
          height: height,
          alignment: alignment,
          fit: fit,
          indicatorBuilder: indicatorBuilder,
          placeholderBuilder: placeholderBuilder,
          color: color,
          errorWidgetBuilder: errorWidgetBuilder,
          initializedBuilder: initializedBuilder,
        );

  const MXVideoPlayer.network(String dataSource,
      {Key? key,
      bool? mixWithOthers,
      String? package,
      bool? isLooping,
      double? width,
      double? height,
      Alignment? alignment,
      BoxFit? fit,
      BlingVideoBuilder? indicatorBuilder,
      BlingVideoBuilder? placeholderBuilder,
      BlingVideoBuilder? bufferBuilder,
      Color? color,
      AsyncErrorWidgetBuilder? errorWidgetBuilder,
      InitializedBuilder? initializedBuilder,
      bool? delayInit})
      : _dataSource = dataSource,
        _mixWithOthers = mixWithOthers,
        _package = package,
        _isLooping = isLooping,
        super(
          null,
          key: key,
          width: width,
          height: height,
          alignment: alignment,
          fit: fit,
          indicatorBuilder: indicatorBuilder,
          placeholderBuilder: placeholderBuilder,
          bufferBuilder: bufferBuilder,
          color: color,
          errorWidgetBuilder: errorWidgetBuilder,
          initializedBuilder: initializedBuilder,
        );

  final String? _dataSource;
  final bool? _mixWithOthers;
  final String? _package;

  final bool? _isLooping;

  @override
  _BlingVideoPlayerState createState() => _BlingVideoPlayerState();
}

class _BlingVideoPlayerState extends State<MXVideoPlayer> {
  MXVideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    SuperPlayerPlugin.setLogLevel(6);
    if (widget._dataSource != null) {
      _controller = MXVideoPlayerController(
          dataSource: widget._dataSource,
          package: widget._package,
          isLooping: widget._isLooping ?? false,
          autoPlay: true,
          mixWithOthers: widget._mixWithOthers,
          alignment: widget.alignment,
          fit: widget.fit);
    } else {
      _controller = widget.controller;
    }
  }

  @override
  void dispose() {
    if (widget._dataSource != null) {
      _controller!.release();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MXVideoPlayer oldWidget) {
    // TODO: implement didUpdateWidget

    if (widget._dataSource == null) {
      _controller = widget.controller;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return MXVideoAsyncFutureLoader(
          playerStack: _controller?.playerStack,
          stackCacheCallback: (List<Widget> stack) {
            _controller?.updatePlayerStack(stack);
          },
          onStream: _controller?.onPlayerStateChanged,
          onIsBufferingStream: _controller?.onIsBufferingStream,
          indicatorBuilder: (BuildContext context) {
            Widget? _indicator =
            widget.indicatorBuilder?.call(context, _controller);

            return _indicator == null
                ? null
                : MXInnerBuffer(child: _indicator);
          },
          errorWidgetBuilder: (BuildContext context) {
            Widget? errorWidget = widget.errorWidgetBuilder
                ?.call(context, "视频播放失败", _controller);

            return errorWidget;
          },
          placeholderBuilder: (BuildContext context) {
            return _controller?.prepare ??
                (widget.placeholderBuilder?.call(context, _controller));
          },
          bufferedBuilder: (BuildContext context) {
            Widget? _buffer =
            widget.bufferBuilder?.call(context, _controller);

            return _buffer == null ? null : MXInnerBuffer(child: _buffer);
          },
          successWidgetBuilder: (BuildContext context) {
            if (_controller == null) {
              return const SizedBox();
            }
            Size _applySize = _applyContent(constraints);


            Widget successWidget = OrientationBuilder(builder: (context,orientation){
              double width = orientation == Orientation.landscape
                  ? max(_applySize.width, _applySize.height)
                  : min(_applySize.width, _applySize.height);
              double height = orientation == Orientation.landscape
                  ? min(_applySize.width, _applySize.height)
                  : max(_applySize.width, _applySize.height);
              return Container(
                  color: widget.color,
                  width: width,
                  height: height,
                  child: _buildPlayer(Size(width,height)));
            });
            widget.initializedBuilder?.call(context, _controller!);
            return MXInnerSuccess(child: successWidget);
          });
    });
  }

  Widget _buildPlayer(Size size) {
    if (_controller?.videoPlayerController == null || size.width == 0) return const SizedBox();


    return ClipRect(
      child: LimitedBox(
        maxWidth: size.width,
        maxHeight: size.height,
        child: FittedBox(
          fit: _controller?.fit ?? (widget.fit ?? BoxFit.contain),
          alignment: widget.alignment ?? Alignment.center,
          child: SizedBox(
            width: _controller?.size.width,
            height: _controller?.size.height,
            child:
                TXPlayerVideo(controller: _controller!.videoPlayerController!),
          ),
        ),
      ),
    );
  }

  Size _applyContent(BoxConstraints constraints) {
    double _applyWidth = widget.width ?? 0.0;
    double _applyHeight = widget.height ?? 0.0;

    if (widget.width == null && widget.height == null) {
      _applyWidth = constraints.maxWidth;
      _applyHeight = _applyWidth / _controller!.aspectRatio;
    }

    if (widget.width != null && widget.height == null) {
      _applyHeight = _applyWidth / _controller!.aspectRatio;
    }

    if (widget.width == null && widget.height != null) {
      _applyWidth = _applyHeight * _controller!.aspectRatio;
    }

    return Size(_applyWidth, _applyHeight);
  }
}

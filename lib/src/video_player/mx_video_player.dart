import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
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
      PanelBuilder? panelBuilder,
      AsyncErrorWidgetBuilder? errorWidgetBuilder,
      InitializedBuilder? initializedBuilder,
      bool? delayInit})
      : _dataSource = null,
        _mixWithOthers = null,
        _package = null,
        _closedCaptionFile = null,
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
            panelBuilder: panelBuilder,
            errorWidgetBuilder: errorWidgetBuilder,
            initializedBuilder: initializedBuilder);

  const MXVideoPlayer.assets(String dataSource,
      {Key? key,
      bool? mixWithOthers,
      String? package,
      Future<ClosedCaptionFile>? closedCaptionFile,
      bool? isLooping,
      double? width,
      double? height,
      Alignment? alignment,
      BoxFit? fit,
      BlingVideoBuilder? indicatorBuilder,
      BlingVideoBuilder? placeholderBuilder,
        Color? color,
      PanelBuilder? panelBuilder,
      AsyncErrorWidgetBuilder? errorWidgetBuilder,
      InitializedBuilder? initializedBuilder,
      bool? delayInit})
      : _dataSource = "assets://" + dataSource,
        _mixWithOthers = mixWithOthers,
        _package = package,
        _closedCaptionFile = closedCaptionFile,
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
          panelBuilder: panelBuilder,
          errorWidgetBuilder: errorWidgetBuilder,
          initializedBuilder: initializedBuilder,
        );

  const MXVideoPlayer.file(String dataSource,
      {Key? key,
      bool? mixWithOthers,
      String? package,
      Future<ClosedCaptionFile>? closedCaptionFile,
      bool? isLooping,
      double? width,
      double? height,
      Alignment? alignment,
      BoxFit? fit,
      BlingVideoBuilder? indicatorBuilder,
      BlingVideoBuilder? placeholderBuilder,
      Color? color,
      PanelBuilder? panelBuilder,
      AsyncErrorWidgetBuilder? errorWidgetBuilder,
      InitializedBuilder? initializedBuilder,
      bool? delayInit})
      : _dataSource = "file://" + dataSource,
        _mixWithOthers = mixWithOthers,
        _package = package,
        _closedCaptionFile = closedCaptionFile,
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
          panelBuilder: panelBuilder,
          errorWidgetBuilder: errorWidgetBuilder,
          initializedBuilder: initializedBuilder,
        );

  const MXVideoPlayer.network(String dataSource,
      {Key? key,
      bool? mixWithOthers,
      String? package,
      Future<ClosedCaptionFile>? closedCaptionFile,
      bool? isLooping,
      double? width,
      double? height,
      Alignment? alignment,
      BoxFit? fit,
      BlingVideoBuilder? indicatorBuilder,
      BlingVideoBuilder? placeholderBuilder,
        BlingVideoBuilder? bufferBuilder,
        Color? color,
      PanelBuilder? panelBuilder,
      AsyncErrorWidgetBuilder? errorWidgetBuilder,
      InitializedBuilder? initializedBuilder,
      bool? delayInit})
      : _dataSource = dataSource,
        _mixWithOthers = mixWithOthers,
        _package = package,
        _closedCaptionFile = closedCaptionFile,
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
          panelBuilder: panelBuilder,
          errorWidgetBuilder: errorWidgetBuilder,
          initializedBuilder: initializedBuilder,
        );

  final String? _dataSource;
  final bool? _mixWithOthers;
  final String? _package;
  final Future<ClosedCaptionFile>? _closedCaptionFile;
  final bool? _isLooping;

  @override
  _BlingVideoPlayerState createState() => _BlingVideoPlayerState();
}

class _BlingVideoPlayerState extends State<MXVideoPlayer> {
  MXVideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget._dataSource != null) {
      _controller = MXVideoPlayerController(
          dataSource: widget._dataSource,
          package: widget._package,
          isLooping: widget._isLooping ?? false,
          autoPlay: true,
          mixWithOthers: widget._mixWithOthers,
          closedCaptionFile: widget._closedCaptionFile,
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
          onStream: _controller?.onPlayerStateChanged,
          onIsBufferingStream: _controller?.onIsBufferingStream,
          indicatorBuilder: (BuildContext context) {
            return widget.indicatorBuilder?.call(context, _controller);
          },
          errorWidgetBuilder: (BuildContext context) {
            Widget? errorWidget = widget.errorWidgetBuilder?.call(
                context,
                _controller?.videoPlayerController?.value.errorDescription,
                _controller);

            return errorWidget;
          },
          placeholderBuilder: (BuildContext context) {
            return _controller?.prepare ??
                (widget.placeholderBuilder?.call(context, _controller));
          },
          bufferedBuilder: (BuildContext context) {
            return widget.bufferBuilder?.call(context,_controller);
          },
          successWidgetBuilder: (BuildContext context) {
            if (_controller == null) {
              return const SizedBox();
            }
            Size _applySize = _applyContent(constraints);

            Widget successWidget = Container(
              color: widget.color,
              width: _applySize.width,
              height: _applySize.height,
              child: Stack(
                children: [
                  _buildPlayer(_applySize),
                  _buildPanel(context, _applySize)
                ],
              ),
            );
            widget.initializedBuilder?.call(context, _controller!);
            return  successWidget;
          });
    });
  }

  Widget _buildPanel(BuildContext context, Size applySize) {
    Widget? _panel = widget.panelBuilder?.call(context, _controller, applySize);
    return _panel ?? const SizedBox();
  }

  Widget _buildPlayer(Size size) {
    return ClipRect(
      child: OverflowBox(
        maxWidth: size.width,
        maxHeight: size.height,
        alignment: _controller?.alignment ?? Alignment.center,
        child: FittedBox(
          fit: _controller?.fit ?? (widget.fit ?? BoxFit.contain),
          alignment: widget.alignment ?? Alignment.center,
          child: SizedBox(
            width: _controller?.size.width,
            height: _controller?.size.height,
            child: VideoPlayer(_controller!.videoPlayerController!),
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

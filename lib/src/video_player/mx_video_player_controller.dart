
/*
author: 董家祎
* */
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mx_video_player/mx_video_player.dart';
import 'package:mx_video_player/src/video_player/mx_logger.dart';
import 'package:video_player/video_player.dart';
import 'package:mx_video_player/src/api/video_player_state.dart';

class MXVideoPlayerController {
  /// Stream of change on video buffered,
  Stream<Duration> get onBufferedStream => _bufferedController.stream;

  /// The video is buffering
  /// The value is true when buffer duration < position duration
  Stream<bool> get onIsBufferingStream => _isBufferingController.stream;

  /// Stream of change on video current duration
  Stream<Duration> get onPositionStream => _positionController.stream;

  /// Stream of change on  video_player
  Stream<VideoPlayerValue> get onValueStream => _valueController.stream;

  /// Stream of change on video progress
  Stream<double> get onProgressStream => _progressController.stream;

  ///Stream of change  on video player state
  Stream<MXVideoPlayerState> get onPlayerStateChanged =>
      _playerStateController.stream;

  /// The current playing position of the video。The video hasn't been initialized yet if it's null
  Duration? get position => _position;

  /// The total duration of the video。The video hasn't been initialized yet if it's null
  Duration? get duration => _duration;

  /// The current playing progress of the video
  double get progress => _progress;


  /// The current playing state op the video
  MXVideoPlayerState get state => _state;

  /// The value is true when buffer duration < position duration
  bool get isBuffering => _isBuffering;

  /// The video aspect
  double get aspectRatio => _videoPlayerController == null
      ? 1.0
      : _videoPlayerController!.value.aspectRatio;

  ///The video size, default value is Size.zero。
  Size get size => _videoPlayerController == null
      ? Size.zero
      : _videoPlayerController!.value.size;

  /// Android: exoplayer, ios:AVFoundation
  VideoPlayerController? get videoPlayerController => _videoPlayerController;

  /// Get media Volume
  double  get volume => _videoPlayerController?.value.volume ?? 0;

  /// Sets whether or not the video should loop after playing once.
  bool isLooping = false;

  /// Set whether to automatically play the video after initialization
  bool autoPlay = true;

  /// You can use [prepare] to placeholder the video before initialization is successful
  Widget? prepare;

  /// Set the screen mode of the video. This parameter overrides [MXVideoPlayer] fit
  BoxFit? fit;

  /// This parameter overrides [MXVideoPlayer] alignment
  Alignment? alignment;

  /// This parameter overrides [MXVideoPlayer] alignment
  ///  Only set for [BlingVideoPlayer.assets] videos. The package that the asset was loaded from.
  String? package;

  final StreamController<VideoPlayerValue> _valueController =
      StreamController.broadcast();

  final StreamController<double> _progressController =
      StreamController.broadcast();

  final StreamController<MXVideoPlayerState> _playerStateController =
      StreamController.broadcast();

  final StreamController<Duration> _positionController =
      StreamController.broadcast();

  final StreamController<Duration> _bufferedController =
      StreamController.broadcast();

  final StreamController<bool> _isBufferingController =
      StreamController.broadcast();

  bool _isRelease = false;

  VoidCallback? _listener;

  Duration? _duration;

  Duration? _position;

  Duration? _buffered;

  bool _isBuffering = false;

  double _progress = 0.0;

  MXVideoPlayerState _state = MXVideoPlayerState.idle;

  VideoPlayerController? _videoPlayerController;

  /// assets://xxxxx
  /// file://xxxxxx
  /// http、https ://xxxx
  MXVideoPlayerController(
      {String? dataSource,
      this.package,
      bool isLooping = false,
      bool autoPlay = true,
      bool? mixWithOthers,
      Future<ClosedCaptionFile>? closedCaptionFile,
      Widget? prepare,
      Alignment? alignment,
      BoxFit? fit}) {
    if (dataSource != null) {
      setDataSource(
        dataSource,
        package: package,
        isLooping: isLooping,
        autoPlay: autoPlay,
        mixWithOthers: mixWithOthers,
        closedCaptionFile: closedCaptionFile,
        prepare: prepare,
        alignment: alignment,
        fit: fit,
      );
    }
  }

  Future<void> setFileSource(String filePath,
      {bool isLooping = false,
      bool autoPlay = true,
      bool? mixWithOthers,
      Future<ClosedCaptionFile>? closedCaptionFile,
      Widget? prepare,
      Alignment? alignment,
      BoxFit? fit}) {
    return setDataSource("file://" + filePath,
        isLooping: isLooping,
        autoPlay: autoPlay,
        mixWithOthers: mixWithOthers,
        closedCaptionFile: closedCaptionFile,
        prepare: prepare,
        alignment: alignment,
        fit: fit);
  }

  Future<void> setAssetsSource(String assetsPath,
      {String? package,
      bool isLooping = false,
      bool autoPlay = true,
      bool? mixWithOthers,
      Future<ClosedCaptionFile>? closedCaptionFile,
      Widget? prepare,
      Alignment? alignment,
      BoxFit? fit}) {
    return setDataSource("assets://" + assetsPath,
        package: package,
        isLooping: isLooping,
        autoPlay: autoPlay,
        mixWithOthers: mixWithOthers,
        closedCaptionFile: closedCaptionFile,
        prepare: prepare,
        alignment: alignment,
        fit: fit);
  }

  Future<void> setDataSource(String dataSource,
      {String? package,
      bool isLooping = false,
      bool autoPlay = true,
      bool? mixWithOthers,
      Future<ClosedCaptionFile>? closedCaptionFile,
      Widget? prepare,
      Alignment? alignment,
      BoxFit? fit}) async {
    if (_isRelease == true) {
      MXLogger.error("videoPlayer has been release");
      throw FlutterError(
          " release() has been performed ，please initialize again ");
    }

    this.isLooping = isLooping;
    this.autoPlay = autoPlay;
    this.package = package;
    this.alignment = alignment;
    this.fit = fit;
    this.prepare = prepare;

    await _innerReset();

    _updatePlayerState(MXVideoPlayerState.prepareInitialized);

    _videoPlayerController = _initVideoController(
        dataSource, mixWithOthers, package, closedCaptionFile);

   await _initialize();

    MXLogger.info("parameters:\n"
        "[package = $package] \n"
        "[isLooping = $isLooping] \n"
        "[autoPlay = $autoPlay] \n"
        "[alignment = $alignment] \n"
        "[fit = $fit]");
  }

  void _addListener() {
    ///Get the total video duration when the video is successfully played
    _duration = _videoPlayerController!.value.duration ;

    _listener = () async {
      if (_videoPlayerController == null || _isRelease == true) return;

      _valueController.add(_videoPlayerController!.value);

      if (_videoPlayerController!.value.hasError == true) {
        String? errorDescription =
            _videoPlayerController!.value.errorDescription;

        MXLogger.error("_videoPlayerController error:$errorDescription");

        _updatePlayerState(MXVideoPlayerState.error);

        throw FlutterError(errorDescription ?? "error is null");
      }
      if (_videoPlayerController!.value.isInitialized == false) {
        return;
      }


      _position = _videoPlayerController!.value.position;


      if (_videoPlayerController!.dataSourceType == DataSourceType.network) {
        int maxBuffering = 0;
        for (var element in _videoPlayerController!.value.buffered) {
          final int end = element.end.inMilliseconds;
          if (end > maxBuffering) {
            maxBuffering = end;
          }
        }
        _buffered = Duration(milliseconds: maxBuffering);

        _bufferedController.sink.add(_buffered ?? Duration.zero);
        bool isBuffering =  (_buffered ?? Duration.zero) < _position! ? true : false;

        if(Platform.isAndroid){
           isBuffering = _videoPlayerController!.value.isBuffering;
         }

        if (isBuffering != _isBuffering && _state != MXVideoPlayerState.completed) {
          _isBuffering = isBuffering;
       
          _isBufferingController.sink.add(isBuffering);
        }

        MXLogger.detail(
            "isBuffering:$_isBuffering ,buffered:$_buffered,_position:$_position");
      }



      double progress = _position!.inMilliseconds / _duration!.inMilliseconds;
      progress = progress >= 1.0 ? 1.0 : progress;

      bool isCompleted = _isCompleted(progress);


      _progress = progress;
     if(_state != MXVideoPlayerState.paused){
       _positionController.sink.add(_position!);
       _progressController.sink.add(progress);
     }


      MXLogger.detail("progress:"
          "$_progress position:${_position!},"
          "duration:${_duration!}");

      if (isCompleted) {
        _updatePlayerState(MXVideoPlayerState.completed);
      }
    };
    _videoPlayerController!.addListener(_listener!);
  }

  bool _isCompleted(double progress) {
    /// 循环播放的情况下 没有播放完成的状态
    if (_state == MXVideoPlayerState.completed || isLooping == true) {
      return false;
    }


    return _position!.inMicroseconds == _duration!.inMicroseconds;
  }

  Future<bool> _initialize() async {
    if (_videoPlayerController == null) {
      return false;
    }
    bool _result = await _innerInitialize();

    if (autoPlay == true && _result == true) {
      MXLogger.info("autoPlay = true Start auto play");
      play();
    }
    _videoPlayerController?.setLooping(isLooping);
    return _result;
  }

  Future<bool> _innerInitialize() async {
    try {
      await _videoPlayerController?.initialize();
      _updatePlayerState(MXVideoPlayerState.initialized);
      MXLogger.info(
          "The player is successfully initialized. videoSize = $size");
      return true;
    } catch (error) {
      MXLogger.error("Failed to initialize the player:${error.toString()}");
      _updatePlayerState(MXVideoPlayerState.error);
      return false;
    }
  }

  /// ios platform : See https://developer.apple.com/library/archive/qa/qa1772/_index.html
  /// for an explanation of

  /// For releases of OS X prior to 10.9 and releases of iOS prior to 7.0,
  /// indicates whether the item can be played at rates greater than 1.0.
  /// Starting with OS X 10.9 and iOS 7.0,
  /// all AVPlayerItems with status AVPlayerItemReadyToPlay can be played at rates between 1.0 and 2.0,
  /// inclusive, even if canPlayFastForward is NO;
  /// for those releases canPlayFastForward indicates whether the item can be played at rates greater than 2.0.

  Future<void> setSpeed(double speed) async {
    MXLogger.info("player setting speed is  $speed");

    await _videoPlayerController?.setPlaybackSpeed(speed);
  }

  Future<void> setVolume(double volume) async {
    if (_verify(null) == false) {
      MXLogger.info("setVolume() invalid,the player is not initialized yet");
      return Future.value();
    }
    if (volume < 0 || volume > 1.0) {
      MXLogger.info("$volume invalid，the value ranges from 0.0  to 1.0");
      return Future.value();
    }
    MXLogger.info("setting volume is $volume");
    return _videoPlayerController?.setVolume(volume);
  }

  Future<void> play() async {
    if (_verify(MXVideoPlayerState.playing) == false) {
      MXLogger.info("play()invalid,BlVideoPlayerState is$_state");
      return Future.value();
    }
    return _innerPlay();
  }

  Future<void> pause() async {
    if (_verify(MXVideoPlayerState.paused) == false) {
      MXLogger.info("pause() invalid,current BlVideoPlayerState is$_state");
      return Future.value();
    }
    return _innerPause();
  }

  Future<void> reset() async {
    if (_verify(MXVideoPlayerState.idle) == false) {
      MXLogger.info("reset() invalid ,current BlVideoPlayerState is: $_state");
      return Future.value();
    }
    await _innerReset();
  }

  Future<void> stop() async {
    if (_verify(MXVideoPlayerState.stop) == false) {
      MXLogger.info("stop() invalid ,current BlVideoPlayerState is:$_state");
      return Future.value();
    }
    return _innerStop();
  }

  Future<void> seekTo(Duration position) async {
    if (_verify(null) == false) {
      MXLogger.info(
          "seekTo(Duration position) invalid ,current BlVideoPlayerState is:$_state");
      return Future.value();
    }
    if(_state != MXVideoPlayerState.paused){
      await _videoPlayerController?.pause();
    }
    await _videoPlayerController?.seekTo(position);

    if(_state != MXVideoPlayerState.paused){
      await _videoPlayerController?.play();
    }
  }

  Future<void> setProgress(double progress) async {
    if (_verify(null) == false) {
      MXLogger.info(
          "setProgress(double progress) invalid ,current BlVideoPlayerState is:$_state");
      return Future.value();
    }

    progress = progress > 1.0 ? 1.0 : progress;
    int durationMicroseconds = (_duration ?? Duration.zero).inMicroseconds;
    int positionMicroseconds = (durationMicroseconds * progress).toInt();

    Duration position = Duration(microseconds: positionMicroseconds);

    return seekTo(position);
  }

  Future<void> _innerStop() async {
    if (_state == MXVideoPlayerState.playing) {
      _videoPlayerController?.pause();
    }
    _updatePlayerState(MXVideoPlayerState.stop);
  }

  Future<void> _innerPlay() async {
    if (_listener == null) {
      _addListener();
    }
    await _videoPlayerController?.play();
    _updatePlayerState(MXVideoPlayerState.playing);
  }

  Future<void> _innerPause() async {
    await _videoPlayerController?.pause();
    _updatePlayerState(MXVideoPlayerState.paused);
  }

  void _updatePlayerState(MXVideoPlayerState state) {
    if (_videoPlayerController != null ||
        state == MXVideoPlayerState.prepareInitialized) {
      _state = state;
      if (_playerStateController.isClosed == false) {
        _playerStateController.sink.add(state);
      }
      MXLogger.info("play state:${state.toString()}");
    }
  }

  VideoPlayerController? _initVideoController(
      String dataSource,
      bool? mixWithOthers,
      String? package,
      Future<ClosedCaptionFile>? closedCaptionFile) {
    VideoPlayerController? _controller;

    VideoPlayerOptions? _options =
        VideoPlayerOptions(mixWithOthers: mixWithOthers ?? true);

    String prefix = dataSource.split("://").first;

    if (prefix == "http" || prefix == "https") {
      _controller = VideoPlayerController.network(dataSource,
          videoPlayerOptions: _options, closedCaptionFile: closedCaptionFile);

      MXLogger.info("remote path :$dataSource");
    } else if (prefix == "assets") {
      String assets = dataSource.replaceRange(0, 9, "");
      _controller = VideoPlayerController.asset(assets,
          videoPlayerOptions: _options,
          package: package,
          closedCaptionFile: closedCaptionFile);
      MXLogger.info("assets path:$dataSource");
    } else if (prefix == "file") {
      String path = dataSource.replaceRange(0, 6, "");

      _controller = VideoPlayerController.file(File(path),
          videoPlayerOptions: _options, closedCaptionFile: closedCaptionFile);
      MXLogger.info("location path:$dataSource");
    }

    return _controller;
  }

  bool _verify(MXVideoPlayerState? state) {
    if (_videoPlayerController?.value.isInitialized == false) {
      MXLogger.info("videoPlayer is not initialized yet ");
      return false;
    }

    if (_state == MXVideoPlayerState.stop && state != MXVideoPlayerState.idle) {
      return false;
    }

    if (state != null && state == _state) {
      return false;
    }
    if (_videoPlayerController == null) {
      return false;
    }
    return true;
  }

  Future<void> _innerReset() async {
    _updatePlayerState(MXVideoPlayerState.idle);

    await _videoPlayerController?.dispose();
    if (_listener != null) {
      _videoPlayerController?.removeListener(_listener!);
    }
    _videoPlayerController = null;
    _listener = null;
  }


  void release() {
    if (_isRelease == true) return;
    MXLogger.info("reset()");
    _innerReset();
    _isRelease = true;
    if (_playerStateController.isClosed == false) {
      _playerStateController.close();
    }
    if (_valueController.isClosed == false) {
      _valueController.close();
    }
    if (_progressController.isClosed == false) {
      _progressController.close();
    }
    if (_positionController.isClosed == false) {
      _positionController.close();
    }

    if (_bufferedController.isClosed == false) {
      _bufferedController.close();
    }
    if (_isBufferingController.isClosed == false) {
      _isBufferingController.close();
    }
    MXLogger.info("release()");
  }
}

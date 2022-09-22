
/*
author: 董家祎
* */
import 'dart:async';

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mx_video_player/mx_video_player.dart';
import 'package:mx_video_player/src/video_player/mx_logger.dart';
import 'package:super_player/super_player.dart';
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
  // Stream<VideoPlayerValue> get onValueStream => _valueController.stream;

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
  bool get isBuffering => _isBuffering ?? false;

  /// The video aspect
  double get aspectRatio => _size.width / _size.height;

  Size _size = Size.zero;
  ///The video size, default value is Size.zero。
  Size get size => _size;
  /// Android: exoplayer, ios:AVFoundation
  TXVodPlayerController? get videoPlayerController => _videoPlayerController;

  bool _isPlaying = false;
  bool  get  isPlaying =>  _isPlaying;
  /// Get media Volume
  double  get volume => 1.0;

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

  // final StreamController<VideoPlayerValue> _valueController =
  //     StreamController.broadcast();

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


  List<Widget> _playerStack = [];

  List<Widget> get playerStack => _playerStack;

  Completer<void>? _completer;

  bool _isRelease = false;
  /// 播放器是否已经初始化完成了
  bool _initialized = false;

  VoidCallback? _listener;

  Duration? _duration;

  Duration? _position;


  bool? _isBuffering;

  double _progress = 0.0;

  MXVideoPlayerState _state = MXVideoPlayerState.idle;

  TXVodPlayerController? _videoPlayerController;

  /// assets://xxxxx
  /// file://xxxxxx
  /// http、https ://xxxx
  MXVideoPlayerController(
      {String? dataSource,
       bool? onlyAudio, /// 是否为纯音频模式 默认NO
      this.package,
      bool isLooping = false,
      this.autoPlay = true,
      bool? mixWithOthers,
      Widget? prepare,
      Alignment? alignment,
      BoxFit? fit}) {
    LogUtils.logOpen = false;
    SuperPlayerPlugin.setConsoleEnabled(false);
    _videoPlayerController = TXVodPlayerController();
     _initialize(onlyAudio: onlyAudio);
    _videoPlayerController!.setConfig(FTXVodPlayConfig());
    _addListener();
    if (dataSource != null) {
      setDataSource(
        dataSource,
        package: package,
        isLooping: isLooping,
        autoPlay: autoPlay,
        mixWithOthers: mixWithOthers,

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

      Widget? prepare,
      Alignment? alignment,
      BoxFit? fit}) {
    return setDataSource("file://" + filePath,
        isLooping: isLooping,
        autoPlay: autoPlay,
        mixWithOthers: mixWithOthers,

        prepare: prepare,
        alignment: alignment,
        fit: fit);
  }

  Future<void> setAssetsSource(String assetsPath,
      {String? package,
      bool isLooping = false,
      bool autoPlay = true,
      bool? mixWithOthers,

      Widget? prepare,
      Alignment? alignment,
      BoxFit? fit}) {
    return setDataSource("assets://" + assetsPath,
        package: package,
        isLooping: isLooping,
        autoPlay: autoPlay,
        mixWithOthers: mixWithOthers,

        prepare: prepare,
        alignment: alignment,
        fit: fit);
  }

  Future<void> setDataSource(String dataSource,
      {String? package,
      bool isLooping = false,
      bool autoPlay = true,
      bool? mixWithOthers,

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
    _completer = Completer();

   if(_initialized == false){
   await  Future.delayed(Duration.zero,(){
       _updatePlayerState(MXVideoPlayerState.prepareInitialized);
     });
     
   }


   await _videoPlayerController!.startPlay(dataSource);

    MXLogger.info("parameters:\n"
        "[package = $package] \n"
        "[isLooping = $isLooping] \n"
        "[autoPlay = $autoPlay] \n"
        "[alignment = $alignment] \n"
        "[fit = $fit]");
    return _completer?.future;
  }

  void _addListener() {
    _videoPlayerController?.onPlayerState.listen((event) {
      switch(event){
        case TXPlayerState.playing:
          _isPlaying = true;
          _updatePlayerState(MXVideoPlayerState.playing);
          break;
        case TXPlayerState.paused:
          _isPlaying = false;
          _updatePlayerState(MXVideoPlayerState.paused);
          break;
        case TXPlayerState.stopped:
          _updatePlayerState(MXVideoPlayerState.stop);
          break;
        case   TXPlayerState.buffering:
          _updatePlayerState(MXVideoPlayerState.buffering);
          break;
        case TXPlayerState.failed:
          _updatePlayerState(MXVideoPlayerState.error);
          break;
        case TXPlayerState.disposed:
          _updatePlayerState(MXVideoPlayerState.idle);
          break;
      }
    });

    _videoPlayerController?.onPlayerEventBroadcast.listen((event) async{
      int eventCode = event['event'];
      if(eventCode < 0){
            MXLogger.error("_videoPlayerController error:$eventCode");

            _updatePlayerState(MXVideoPlayerState.error);

            return;
      }


      switch (eventCode){
        case  TXVodPlayEvent.PLAY_EVT_PLAY_PROGRESS:
          {

            dynamic progress = Platform.isIOS ?  (event[TXVodPlayEvent.EVT_PLAY_PROGRESS]) * 1000 : event[TXVodPlayEvent.EVT_PLAY_PROGRESS_MS];
            dynamic duration = Platform.isIOS ?  (event[TXVodPlayEvent.EVT_PLAY_DURATION]) * 1000 : event[TXVodPlayEvent.EVT_PLAY_DURATION_MS];


            if (null != progress && duration != null && _state != MXVideoPlayerState.completed && _state!=MXVideoPlayerState.idle) {
              _duration =   Duration(microseconds: (duration*1000).toInt());
               var position = progress > duration ? duration : progress;
              _position = Duration(milliseconds: (position).toInt());

              var _progress = _position!.inMilliseconds/_duration!.inMilliseconds;

              this._progress  = _progress;

              _positionController.sink.add(_position!);
               _progressController.sink.add(_progress);
              double bufferDuration =  await _videoPlayerController?.getPlayableDuration() ?? 0;
              Duration buffer =  Duration(milliseconds: (bufferDuration*1000).toInt());

              _bufferedController.sink.add(buffer);
            }

          }
          break;
        case  TXVodPlayEvent.PLAY_EVT_PLAY_BEGIN:
          {

           int width =  await _videoPlayerController?.getWidth() ?? 0;
           int height =  await _videoPlayerController?.getHeight() ?? 0;

           _size = Size(width.toDouble(), height.toDouble());
           Future.delayed(Duration.zero,(){
             MXLogger.info("videoWidth:$width videoHeight = $height");
             _updatePlayerState(MXVideoPlayerState.initialized);
           });

           _initialized = true;
           _completer?.complete();
           _completer = null;
          }
          break;
        case TXVodPlayEvent.PLAY_EVT_PLAY_LOADING:
          {
            _isBufferingController.add(true);

          }
          break;
        case  TXVodPlayEvent.PLAY_EVT_VOD_LOADING_END:
          {
            _isBufferingController.add(false);

          }
          break;
        case TXVodPlayEvent.PLAY_EVT_PLAY_END:
          {
            _isPlaying = false;
            /// 修复播放器返回时间不准确的问题
            if(_duration != _position){
              _position = _duration;
              _positionController.sink.add(_position!);
              _progressController.sink.add(1.0);

            }
            _updatePlayerState(MXVideoPlayerState.completed);
          }
          break;
      }
    });

  }


  Future<bool> _initialize({bool? onlyAudio}) async {
    if (_videoPlayerController == null) {
      return false;
    }
    bool _result = await _innerInitialize(onlyAudio: onlyAudio);

    if ( _result == true) {
      await _videoPlayerController?.setAutoPlay(isAutoPlay: autoPlay);
      MXLogger.info("autoPlay = true Start auto play");
    }

    return _result;
  }

  Future<bool> _innerInitialize({bool? onlyAudio}) async {
    try {
      await _videoPlayerController?.initialize(onlyAudio: onlyAudio);


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
    await _videoPlayerController?.setRate(speed);

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
    return _videoPlayerController?.setAudioPlayoutVolume((volume*100).toInt());
  }

  Future<void> play() async {
    if (_verify(MXVideoPlayerState.playing) == false) {
      MXLogger.info("play()invalid,MXVideoPlayerState is$_state");
      return Future.value();
    }
    return _innerPlay();
  }

  Future<void> pause() async {
    if (_verify(MXVideoPlayerState.paused) == false) {
      MXLogger.info("pause() invalid,current MXVideoPlayerState is$_state");
      return Future.value();
    }
    return _innerPause();
  }

  Future<void> reset() async {
    if (_verify(MXVideoPlayerState.idle) == false) {
      MXLogger.info("reset() invalid ,current MXVideoPlayerState is: $_state");
      return Future.value();
    }
    await _innerReset();
  }

  Future<void> stop() async {
    if (_verify(MXVideoPlayerState.stop) == false) {
      MXLogger.info("stop() invalid ,current MXVideoPlayerState is:$_state");
      return Future.value();
    }
    return _innerStop();
  }

  Future<void> seekTo(Duration position) async {
    if (_verify(null) == false) {
      MXLogger.info(
          "seekTo(Duration position) invalid ,current MXVideoPlayerState is:$_state");
      return Future.value();
    }

    await _videoPlayerController?.seek(position.inSeconds.toDouble());


  }

  Future<void> setProgress(double progress) async {
    if (_verify(null) == false) {
      MXLogger.info(
          "setProgress(double progress) invalid ,current MXVideoPlayerState is:$_state");
      return Future.value();
    }

    progress = progress > 1.0 ? 1.0 : progress;
    int durationMicroseconds = (_duration ?? Duration.zero).inMicroseconds;
    int positionMicroseconds = (durationMicroseconds * progress).toInt();

    Duration position = Duration(microseconds: positionMicroseconds);

    return seekTo(position);
  }

  Future<void> _innerStop() async {
    _videoPlayerController?.stop();
    _updatePlayerState(MXVideoPlayerState.stop);
  }

  Future<void> _innerPlay() async {
   _isPlaying = true;
    await _videoPlayerController?.resume();
    _updatePlayerState(MXVideoPlayerState.playing);
  }

  Future<void> _innerPause() async {
    await _videoPlayerController?.pause();
    _updatePlayerState(MXVideoPlayerState.paused);
  }

  void updatePlayerStack(List<Widget> stack){
    _playerStack = stack;
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



  bool _verify(MXVideoPlayerState? state) {
    // if (_videoPlayerController?.value.isInitialized == false) {
    //   MXLogger.info("videoPlayer is not initialized yet ");
    //   return false;
    // }

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

    _videoPlayerController?.dispose();
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

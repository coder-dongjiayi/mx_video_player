import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mx_video_player/mx_video_player.dart';

export 'package:provider/provider.dart';

import 'package:net_speed_plugin/net_speed_plugin.dart';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

int videoResolution = 1;

typedef SegmentedDurationCallback = Future<void> Function(int index, Duration position);

typedef InitializedVideoCallback = void Function(Size videoSize);

class BLMediaController extends ChangeNotifier {
  SharedPreferences? _sharedPreferences;

  int _segmentPosition = 0;

  bool lastTime = false;

  /// 流畅
  String? smallVideoUrl;

  ///标清
  String? middleVideoUrl;

  /// 高清
  String? videoUrl;

  /// 标记在进度条上的时间点
  final List<Duration>? segmentedDurationList;

  late String _md5Key;

  List<String?> _dataSource = [];

  List<String?> get dataSource => _dataSource;

  /// 本地存储的播放视频等级 0 流畅 1 标清 2 高清
  int _currentLevel = 0;

  int get currentLevel => _currentLevel;

  /// 获取当前正在播放的url
  String? _currentVideoUrl;

  String get currentVideoUrl => _currentVideoUrl ?? "";

  ValueNotifier<bool> completedNotifier = ValueNotifier(false);

  bool isSpeed = false;


  bool isDelay = false;

  ///是否循环播放
  bool isLooping = false;
  VoidCallback? completionCallback;

  /// 标记视频是否播放完成
  VoidCallback? markVideoFinishCallback;

  final InitializedVideoCallback? initVideoSuccessCallback;

  /// 时间点触发的回调
  final SegmentedDurationCallback? segmentedDurationCallback;

  MXVideoPlayerController _videoPlayerController = MXVideoPlayerController();

  Duration _videoPosition = Duration.zero;

  Duration get videoPosition => _videoPosition;

  ///是否开始水平滑动
  bool _horizontalDrag = false;

  bool get horizontalDrag => _horizontalDrag;

  ///是否开始竖直滑动
  bool _verticalDrag = false;

  bool get verticalDrag => _verticalDrag;

  int _dragSecond = 0;

  int get dragSecond => _dragSecond;

  double _netSpeed = 0.0;

  String get currentSpeed {
    if (_netSpeed <= 1024) {
      return _netSpeed.toStringAsFixed(1) + "KB/s";
    }
    double mb = _netSpeed / 1024;
    return mb.toStringAsFixed(1) + "MB/s";
  }

  Timer? _timer;

  bool _videoControllerDeal = false;

  bool _isDLNAPlaying = false;

  bool get isDLNAPlaying => _isDLNAPlaying;

  void setDLNAPlayingStatus(bool isDLNAPlaying) {
    _isDLNAPlaying = isDLNAPlaying;
  }

  set dragSecond(int value) {
    _dragSecond = value;
    notifyListeners();
  }

  /// 是否正在播放
  bool get isPlaying => _videoPlayerController.isPlaying;

  /// 播放进度
  double get progress {
    if (_videoPlayerController.duration == null) {
      return 0.0;
    }

    double progress =
        (_videoPlayerController.position!.inSeconds + dragSecond) / _videoPlayerController.duration!.inSeconds;
    return progress > 1.0 ? 1.0 : (progress < 0 ? 0.0 : progress);
  }

  /// 总时间
  String get duration => MXPlayerUtil.durationToString(_videoPlayerController.duration);

  ///总时间的时间戳
  int get totalDurationMilliSeconds => _videoPlayerController.duration?.inMilliseconds ?? 0;

  /// 当前时间
  String get position {
    if (_videoPlayerController.duration == null) {
      return "";
    }
    return MXPlayerUtil.durationToString(Duration(seconds: _videoPlayerController.position!.inSeconds + dragSecond));
  }

  /// 视频控制器
  MXVideoPlayerController get videoPlayerController => _videoPlayerController;


  /// 当前视频否正在互动中
  bool _interacting = false;


  bool get interacting => _interacting;


  /// 是否开启了视频互动
  bool _interaction = true;


  bool get interaction => _interaction;

  double _speed = 1.0;

  double get speed => _speed;

  bool _bottomNaviHidden = true;

  bool _appBarHidden = true;

  /// 设置是appbar否隐藏控制器
  bool get appBarHidden => _appBarHidden;

  bool get bottomNaviHidden => _bottomNaviHidden;

  int _currentTime = 0;

  Duration? buffer;

  /// 播放器是否初始化完成
  bool _initialized = false;

  bool get initialized => _initialized;

  /// 标记视频完成状态临界值
  int? _criticalValue;

  /// 选择清晰度
  bool _chooseDefinition = false;

  bool get chooseDefinition => _chooseDefinition;



  var mSensitivity = 0.3; //灵敏度


  BLMediaController(
      {this.smallVideoUrl,
      this.middleVideoUrl,
      this.videoUrl,
      this.isSpeed = false,

      this.isDelay = false,
      this.isLooping = false,
      this.initVideoSuccessCallback,
      this.segmentedDurationList,
      this.segmentedDurationCallback,
      VoidCallback? markVideoFinishCallback,
      VoidCallback? completionCallback}) {

    getMaxVolume();
    MXLogger.changeLogLevel(MXLogLevel.none);

    setDataSource(
        smallVideoUrl: smallVideoUrl,
        middleVideoUrl: middleVideoUrl,
        videoUrl: videoUrl,
        markVideoFinishCallback: markVideoFinishCallback,
        completionCallback: completionCallback);

    /// 点击屏幕自动隐藏进度条监听 每秒执行一次
    _networkMonitor(callback: () {
      if (DateTime.now().millisecondsSinceEpoch - _currentTime >= 3000 &&
          _appBarHidden == false &&
          !_videoControllerDeal &&
          isPlaying) {
        _appBarHidden = true;
        _bottomNaviHidden = true;
        notifyListeners();
      }
    });

    ///监听 播放状态
    _mediaStateMonitor(mediaPlayerCallback: (state) {
      if (state == MXVideoPlayerState.completed) {
        completedNotifier.value = true;
      }
      if (state == MXVideoPlayerState.initialized) {
        /// 获取临界值
        _criticalValue = _getCriticalValue();

        /// 初始化完成进行屏幕旋转
        Future.delayed(Duration.zero, () async {
          initVideoSuccessCallback?.call(_videoPlayerController.size);
          _appBarHidden = false;
          _bottomNaviHidden = false;
          notifyListeners();
        });
      }
    });
    _videoPlayerController.onPositionStream.listen((Duration position) {

      _videoPosition = position;
      _markVideoFinish();
      _markSegmentPoint(position);

      notifyListeners();
    });

    ///监听 缓冲进度
    _videoPlayerController.onBufferedStream.listen((event) {
      buffer = event;
      notifyListeners();
    });
  }

  void setVideoControllerDealEvent(bool isDeal) {
    _videoControllerDeal = isDeal;
    if (_videoControllerDeal == false) {
      _currentTime = DateTime.now().millisecondsSinceEpoch;
    } else {
      Future.delayed(Duration.zero, () {
        _bottomNaviHidden = false;
        _appBarHidden = _bottomNaviHidden;
        notifyListeners();
      });
    }
  }

  void setDataSource(
      {String? smallVideoUrl,
      String? middleVideoUrl,
      String? videoUrl,
      VoidCallback? completionCallback,
      VoidCallback? markVideoFinishCallback}) async {
    this.completionCallback = completionCallback;
    this.markVideoFinishCallback = markVideoFinishCallback;
    _initMediaState(
        meidaUrl1: smallVideoUrl, meidaUrl2: middleVideoUrl, meidaUrl3: videoUrl, initIndex: videoResolution);

    _currentTime = DateTime.now().millisecondsSinceEpoch;
  }

  /// 初始化多媒体播放状态

  Future<void> _initMediaState(
      {bool? onlyAudio, String? meidaUrl1, String? meidaUrl2, String? meidaUrl3, required int initIndex}) async {
    _dataSource = [meidaUrl1, meidaUrl2, meidaUrl3];

    _generateMd5();

    await initCurrentVideoUrl(level: initIndex);
  }

  /// 监听视频回调
  void _mediaStateMonitor({void Function(MXVideoPlayerState state)? mediaPlayerCallback}) {
    _videoPlayerController.onPlayerStateChanged.listen((event) {
      if (event == MXVideoPlayerState.completed) {
        _playCompleted();
      } else if (event == MXVideoPlayerState.initialized) {
        _initialized = true;
      }
      mediaPlayerCallback?.call(event);
    });
  }

  /// 网速监听
  void _networkMonitor({VoidCallback? callback}) {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      /// 网速监听
      NetSpeedPlugin.getNetSpeedWithKB().then((value) {
        _netSpeed = value;
        notifyListeners();
      });
      callback?.call();
    });
  }

  void getMaxVolume() async {

  }

  void _generateMd5() {
    String urlJoin = _dataSource.join("_");
    _md5Key = md5.convert(utf8.encode(urlJoin)).toString();
  }

  /// 标记是否观看完成
  void _markVideoFinish() {
    if (_criticalValue != null) {
      if (_videoPlayerController.position!.inSeconds >= _criticalValue!) {
        markVideoFinishCallback?.call();
        _criticalValue = null;
      }
    }
  }

  /// 是否存在标记点
  void _markSegmentPoint(Duration position) async {
   if(_interaction == false) return;
    /// 误差 微妙
    int differenceValue = 500000;

    int value = position.inMicroseconds -_segmentPosition;
    if(value < 0){
      _segmentPosition = position.inMicroseconds;
    }
    /// 500毫秒内 不再执行第二次
    if (segmentedDurationList == null || segmentedDurationList?.isEmpty == true || value <= differenceValue) {

      return;
    }

    for (int i = 0; i < segmentedDurationList!.length; i++) {
      Duration element = segmentedDurationList![i];
      int start = element.inMicroseconds;
      int end = start + differenceValue;

      int _position = position.inMicroseconds;

      if (_position >= start && _position < end) {
        _segmentPosition = _position;

        await _videoPlayerController.pause();
        _interacting = true;
        await segmentedDurationCallback?.call(i, element);

        await _videoPlayerController.play();
        _interacting = false;
        break;
      }
    }
  }

  int _getCriticalValue() {
    int second = _videoPlayerController.duration!.inSeconds;

    int criticalValue = second * 0.1 < 5 ? 5 : (second * 0.1).toInt();

    return second - criticalValue;
  }

  void _playCompleted() async {
    await _sharedPreferences?.remove(_md5Key);
    completionCallback?.call();
  }

  void play() {
    _videoPlayerController.play();
    notifyListeners();
  }

  void pause() {
    _videoPlayerController.pause();
    notifyListeners();
  }

  Future<void> playOrPause() async {
    if (_videoPlayerController.isPlaying == false) {
      await _videoPlayerController.play();
    } else {
      await _videoPlayerController.pause();
    }
    notifyListeners();
  }

  Future<void> initCurrentVideoUrl({required int level}) async {
    await _setCurrentVideoUrl(level: level);
    _sharedPreferences ??= await SharedPreferences.getInstance();
    _interaction = _sharedPreferences?.getBool("com.bling.interaction") ?? true;
    int microseconds = _sharedPreferences!.getInt(_md5Key) ?? 0;
    if (microseconds <= 0) return;
    await _videoPlayerController.seekTo(Duration(microseconds: microseconds));
    lastTime = true;
    notifyListeners();
  }

  /// 保存当前进度
  void saveCurrentPosition() {
    Duration _position = _videoPlayerController.position ?? Duration.zero;
    Duration _total = _videoPlayerController.duration ?? Duration.zero;

    if (_position.inSeconds >= _total.inSeconds) {
      _sharedPreferences?.remove(_md5Key);
    } else {
      _sharedPreferences?.setInt(_md5Key, _position.inMicroseconds);
    }
  }

  Future<void> _setCurrentVideoUrl({required int level}) async {
    _currentVideoUrl = _dataSource[level];

    if (_currentVideoUrl != null) {
      await _saveVideoLevel(level);
      return;
    }

    for (int index = _dataSource.length - 1; index >= 0; index--) {
      if (_dataSource[index] != null) {
        _currentVideoUrl = _dataSource[index];
        await _saveVideoLevel(index);

        break;
      }
    }
  }

  Future<void> _saveVideoLevel(int level) async {
    _currentLevel = level;
    videoResolution = level;
    await _switchVideo();
  }

  String currentDefinition() {
    return getDefinition(_currentLevel);
  }

  /// 切换清晰度
  Future<void> switchDefinition(int level) async {
    if (level == currentLevel) return;
    Duration position = _videoPlayerController.position ?? Duration.zero;
    await _setCurrentVideoUrl(level: level);

    await _videoPlayerController.seekTo(position);
  }

  Future<void> seek(Duration position) async {
    _videoPosition  = position;
    await _videoPlayerController.seekTo(position);
  }

  String getDefinition(int level) {
    String _current = "流畅";
    if (level == 1) {
      _current = "标清";
    } else if (level == 2) {
      _current = "高清";
    }
    return _current;
  }

  ///点击屏幕控制显示隐藏
  void controlHidden() {
    Future.delayed(Duration.zero, () {
      _currentTime = DateTime.now().millisecondsSinceEpoch;
      if (_initialized == false) {
        _appBarHidden = !_appBarHidden;
        _bottomNaviHidden = true;
      } else {
        _bottomNaviHidden = !_bottomNaviHidden;
        _appBarHidden = _bottomNaviHidden;
      }
      notifyListeners();
    });
  }

  void controlWidgetHide() {
    Future.delayed(Duration.zero, () {
      _bottomNaviHidden = true;
      _appBarHidden = _bottomNaviHidden;
      notifyListeners();
    });
  }

  ///用户控制是否显示滑动遮罩
  Future<void> setHorizontalDrag(bool isDrag) {
    if (_initialized == false) return Future.value();
    return Future.delayed(Duration.zero, () {
      _horizontalDrag = isDrag;
      notifyListeners();
    });
  }

  ///用户控制是否显示音量/亮度进度
  void setVerticalDrag(bool isDrag) {
    if (_verticalDrag == isDrag || _initialized == false) {
      return;
    }
    _verticalDrag = isDrag;
    notifyListeners();
  }

  Future<void> _switchVideo() async {
    await switchMediaUrl(url: currentVideoUrl);
  }

  Future<void> switchMediaUrl({required String url}) async {
    await _videoPlayerController.setDataSource(url, autoPlay: true, isLooping: false, mixWithOthers: true);
    notifyListeners();
  }

  Future<void> retry() async {
    await _switchVideo();
  }



  /// 设置倍速
  Future<void> setSpeed(double speed) async {
    _speed = speed;
    await _videoPlayerController.setSpeed(speed);
    notifyListeners();
  }

  /// 滑动屏幕设置拖动时间
  Future<void> dragSeek() async {
    if (_initialized == false) return;
    int _second = _dragSecond + videoPlayerController.position!.inSeconds;
     Duration seek =  Duration(seconds: _second < 0 ? 0 : _second);
    _videoPosition =  seek;
    notifyListeners();
    await videoPlayerController.seekTo(seek);
    _dragSecond = 0;

  }

  Future<void> stop() async {
    if (_initialized == false) return;
    await videoPlayerController.stop();
  }

  /// 开始视频互动
  void startInteraction(){
    _interaction = true;
    _sharedPreferences?.setBool("com.bling.interaction", true);
    notifyListeners();
  }
  /// 关闭视频互动
  void closeInteraction(){
    _interaction = false;
    _sharedPreferences?.setBool("com.bling.interaction", false);
    notifyListeners();
  }
  void release() {

    _timer?.cancel();
    _timer = null;
    _videoPlayerController.release();
    _segmentPosition = 0;
  }

  @override
  void dispose() {
    if (_timer == null) return;
    release();
    super.dispose();
  }
}

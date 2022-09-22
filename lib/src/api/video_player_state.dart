enum MXVideoPlayerState {
  ///视频初始状态 或者是调用了 reset()
  idle,

  /// 准备初始化播放器
  prepareInitialized,

  ///播放器初始化完成
  initialized,

  /// 正在播放中
  playing,

  /// 缓冲中
  buffering,
  /// 暂停
  paused,

  /// 停止播放 播放器会停留在当前画面 play() pause()无效 必须调用setDataSource() 重新初始化播放器才可以
  stop,

  /// 播放完成 可以使用 play()方法重新播放当前视频,
  /// 如果isLooping == true 这个状态也会被回调，然后继续为playing状态继续播放
  completed,

  /// 播放出现错误
  error,
}


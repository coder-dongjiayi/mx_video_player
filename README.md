#  mx_video_player

基于Flutter官方的 [video_player](https://pub.flutter-io.cn/packages/video_player) 的二次封装

## 基本功能如下图

<img src="https://github.com/coder-dongjiayi/mx_video_player/blob/main/images/base.gif" alt="avatar"/>



## 为什么要二次封装 video_player

* 实际开发中如果你的业务仅仅是播放一个视频，那么最好的选择就是使用官方提供的播放器，iOS端使用``` AVFoundation``` Android端使用google官方的``` Exoplayer``` 
* 官方提供``` video_player``` 插件功能过于单一，在时间开发中还需要写很多代码，二次封装是为了提高实际业务的开发效率

## Installation 安装

```yaml
dependencies:
  mx_video_player:
    git:
      ref: 0.0.1
      url: https://github.com/coder-dongjiayi/mx_video_player
```

## 如何使用

### 1. 基本使用

* 播放网络视频

```dart
  body: const Center(
        child: MXVideoPlayer.network("https://xxxxx.mp4")
      ),
```

* 本地文件视频播放

```dart
  body: const Center(
        child: MXVideoPlayer.file("/var/xxxx/xxx.mp4")
      ),
```

* 工程路径视频播放

```dart
  body: const Center(
        child: MXVideoPlayer.assets("assets/video/video1.mp4")
      ),
```

以上方式初始化视频播放器，会自动根据视频尺寸比例显示播放器的大小，如下图所示

<img src="https://github.com/coder-dongjiayi/mx_video_player/blob/main/images/IMG_0890.PNG" alt="avatar" style="zoom:20%;" />

### 2. 使用控制器初始化视频播放器

```dart

  MXVideoPlayerController? _videoPlayerController;
  @override
  void initState() {
    super.initState();
    _videoPlayerController = MXVideoPlayerController();
    String dataSource =  "assets://assets/video/video.mp4";
    /// 初始化网络视频 必须以http 或者 https开头 https://www.xxxx.mp4
    /// 初始化本地视频 必须以file:// 开头,比如 file://var/xxxx/video.mp4
    /// 初始化assets视频  必须以 assets:// 开头，比如 assets://assets/video/video.mp4
    _videoPlayerController?.setDataSource(dataSource);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  Center(
        child: MXVideoPlayer(
         controller: _videoPlayerController,
        )
      ),
     // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
```

对于视频文件的初始化也可以使用 ``` MXVideoPlayerController```提供好的方法

* 网络视频

  ```dart
  _videoPlayerController?.setDataSource("https://www.xxxx.mp4");
  ```

* 本地视频

  ```dart
  _videoPlayerController?.setFileSource("/var/xxxx/video.mp4");
  ```

* 工程目录视频

  ```dart
  _videoPlayerController?.setAssetsSource("/assets/video/video.mp4");
  ```

* 也可使用``` setDataSource``` 加前缀的方式来播放不同类型的视频

  ```dart
  _videoPlayerController?.setDataSource("https://www.xxxx.mp4"); /// 网路视频
  _videoPlayerController?.setDataSource("fiel://var/xxxx/video.mp4"); /// 本地视频
  _videoPlayerController?.setDataSource("assets://assets/video/video.mp4"); ///工程目录视频
  
  ```

  



### 3. 定制播放器

```dart
         MXVideoPlayer(
                controller: _videoPlayerController,
                /// 视频初始化的操作是耗时的，可以使用这个builder 给用户一个加载中的提示
                indicatorBuilder: (context, controller) {
                  return const CupertinoActivityIndicator();
                },
                ///播放网络视频如果视频正在缓冲，可以使用这个builder 定制缓冲样式
                bufferBuilder: (context, controller) {
                  return Container(
                    width: 100,
                    height: 100,
                    alignment: Alignment.center,
                    color: Colors.yellow,
                    child: const Text("正在缓冲中"),
                  );
                },
                /// 视频还没有初始化之前一般会有一张封面图进行占位，可以用这个builder定制占位的widget
                placeholderBuilder: (context, controller) {
                  return _placeholder();
                },
                /// 如果视频加载失败或者播放过程中出现了error 可以在这里显示播放错误的widget
                errorWidgetBuilder: (context, error, controller) {
                  return Text("视频播放失败了 ${error.toString()}");
                },
                /// 用于定制显示视频播放器的样式，比如播放按钮，进度条等等
                panelBuilder: (context, player, size) {
                  return player == null
                      ? const SizedBox()
                      : VideoPlayPanel(playerController: player);
                },
              )
```



### issues

在使用中遇到的任何问题都可以在 [github](https://github.com/coder-dongjiayi/flutter_bling_video_player/issues)上的 issues 提出，严重的问题24小时内解决，不严重的问题，一周内解决。

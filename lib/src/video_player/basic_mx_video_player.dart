import 'package:flutter/material.dart';

import 'package:mx_video_player/src/video_player/mx_video_player_controller.dart';
export 'package:mx_video_player/src/video_player/mx_video_player_controller.dart';


typedef BlingVideoBuilder = Widget? Function(
    BuildContext context, MXVideoPlayerController? controller);

typedef InitializedBuilder = Widget? Function(
    BuildContext context, MXVideoPlayerController controller);

typedef AsyncErrorWidgetBuilder = Widget? Function(BuildContext context,
    Object? error, MXVideoPlayerController? controller);

abstract class BasicMXVideoPlayer extends StatefulWidget {
  /// Creates a widget that displays an videoPlayer.
  const BasicMXVideoPlayer(this.controller,
      {Key? key,
      this.placeholderBuilder,
      this.indicatorBuilder,
      this.initializedBuilder,
      this.bufferBuilder,
      this.width,
      this.height,
      this.color,
      this.alignment,
      this.fit,
      this.errorWidgetBuilder})
      : super(key: key);

  /// The [placeholderBuilder] is displayed if controller == null
  final MXVideoPlayerController? controller;

  /// You can use a placeholderBuilder  when the video has not yet initialize
  final BlingVideoBuilder? placeholderBuilder;

  /// you can use indicatorBuilder when the video is initializing or buffering
  final BlingVideoBuilder? indicatorBuilder;

  /// you can use bufferBuilder when video is buffering
  final BlingVideoBuilder? bufferBuilder;

  /// The initializedBuilder  is executed when the video is successfully initialized
  final InitializedBuilder? initializedBuilder;

  /// Just like the properties of the [Image.width]
  final double? width;

  /// Just like the properties of the [Image.height]
  final double? height;

  /// video background color
  final Color? color;

  /// Just like the properties of the [Image.alignment], default value is  Alignment.center
  final Alignment? alignment;

  /// Just like the properties of the [Image.fit], default value is  BoxFit.contain
  final BoxFit? fit;


  /// When playing an exception, you can customize the exception style using errorWidgetBuilder
  final AsyncErrorWidgetBuilder? errorWidgetBuilder;
}

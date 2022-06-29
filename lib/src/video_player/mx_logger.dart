import 'package:mx_video_player/src/api/log_level.dart';
import 'dart:developer' as developer;
class MXLogger {
  static MXLogLevel _logLevel = MXLogLevel.error;

  static MXLogLevel get logLevel => _logLevel;


  MXLogger._() {
    throw UnimplementedError();
  }
  static void changeLogLevel(MXLogLevel value) {
    _logLevel = value;
  }

  static void log(MXLogLevel level, String message) {
    if (level.getLevel() <= logLevel.getLevel()){
      if(level == MXLogLevel.detail){
        developer.log(message, name: 'mx_video_player:detail');
      }
      if(level == MXLogLevel.error){
        developer.log(message, name: 'mx_video_player:error');

      }
      if(level == MXLogLevel.info){
        developer.log(message, name: 'mx_video_player:info');
      }
    }



  }

  static void detail(String message) => log(MXLogLevel.detail, message);
  static void info(String message) => log(MXLogLevel.info, message);
  static void error(String message) => log(MXLogLevel.error, message);
}

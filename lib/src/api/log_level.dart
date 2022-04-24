enum MXLogLevel {detail, info, error, none }

extension MXLogLevelExtension on MXLogLevel {
  int getLevel() {
    switch (this) {
      case MXLogLevel.detail:
        return 3;
      case MXLogLevel.info:
        return 2;
      case MXLogLevel.error:
        return 1;
      case MXLogLevel.none:
        return 0;
    }
  }
}

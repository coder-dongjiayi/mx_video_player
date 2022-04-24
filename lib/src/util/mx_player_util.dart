class MXPlayerUtil{

  static String durationToString(Duration? duration) {
    if(duration == null) return "00:00";

    if (duration.inMilliseconds < 0) return "00:00";

    String digits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String digitMinutes = digits(duration.inMinutes.remainder(60));
    String digitSeconds = digits(duration.inSeconds.remainder(60));
    int inHours = duration.inHours;
    return inHours > 0
        ? "$inHours:$digitMinutes:$digitSeconds"
        : "$digitMinutes:$digitSeconds";
  }
}
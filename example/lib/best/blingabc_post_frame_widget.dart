import 'package:flutter/material.dart';
typedef PostFrameCallback = void Function(BuildContext context, Duration timeStamp);

class BlingabcPostFrameWidget extends StatefulWidget {

  BlingabcPostFrameWidget({Key? key, required this.child, required this.callback}) : super(key: key);

  final PostFrameCallback callback;
  final Widget child;
  @override
  _BlingabcPostFrameWidgetState createState() => _BlingabcPostFrameWidgetState();
}

class _BlingabcPostFrameWidgetState extends State<BlingabcPostFrameWidget> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback(_endFrame);
  }

  void _endFrame(Duration timeStamp){
    widget.callback.call(context, timeStamp);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

extension BlingabcFrameWidgetExtension on Widget{
  BlingabcPostFrameWidget blingPostFrame({Key? key,required PostFrameCallback callback}){
    return BlingabcPostFrameWidget(key: key,child: this, callback: callback);
  }
}

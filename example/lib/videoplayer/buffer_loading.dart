

import 'package:flutter/material.dart';

import 'blmedia_controller.dart';
class BufferLoading extends StatefulWidget {
  const BufferLoading({Key? key}) : super(key: key);

  @override
  _BufferLoadingState createState() => _BufferLoadingState();
}

class _BufferLoadingState extends State<BufferLoading> {


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }
  @override
  void dispose() {

    super.dispose();

  }

  @override
  Widget build(BuildContext context) {
    return  Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(75),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text("加载中...",style: TextStyle(color: Colors.white),),
              Builder(builder: (context){
              String speed =   context.select<BLMediaController,String>((value) => value.currentSpeed);

                return Text(
                  speed,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                );
              })
            ],
          ),
        ),
      ),
    );
  }
}

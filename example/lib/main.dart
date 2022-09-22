
import 'package:example/video_test_page.dart';
import 'package:flutter/material.dart';


import 'package:super_player/super_player.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
 await SuperPlayerPlugin.setGlobalLicense("腾讯的授权XXXXX.license", "xxxxxxxx");
  SuperPlayerPlugin.setLogLevel(6);
 runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);


  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        title: Text(widget.title),
      ),
      body: Center(

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(onPressed: (){
              Navigator.of(context).push(MaterialPageRoute(builder: (context){
                return VideoTestPage();
              }));
            }, child: const Text("最佳实战")),

          ],
        ),
      ),

    );
  }
}

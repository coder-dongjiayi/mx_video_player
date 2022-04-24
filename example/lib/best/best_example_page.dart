import 'package:example/best/best_example_detail_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mx_video_player/mx_video_player.dart';
import 'best_example_state.dart';

class BestExamplePage extends StatefulWidget {
  const BestExamplePage({Key? key}) : super(key: key);

  @override
  _BestExamplePageState createState() => _BestExamplePageState();
}

class _BestExamplePageState extends State<BestExamplePage> {
  late BestExampleState exampleState;
  late ScrollController scrollController;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    MXLogger.changeLogLevel(MXLogLevel.none);
    exampleState = BestExampleState();
    exampleState.requestVideoList();

    scrollController = ScrollController();



  }

  @override
  void dispose() {
    exampleState.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("")),
        body: ChangeNotifierProvider.value(
          value: exampleState,
          child: Builder(builder: (context) {


            List<Map<String, dynamic>> _list =
                context.watch<BestExampleState>().videoList;

            return ListView.builder(
              controller: scrollController,
                itemBuilder: (BuildContext context, int index) {
                  return _buildItem(_list[index], index);
                },
                itemCount: _list.length);
          }),
        ));
  }

  Widget _buildItem(Map<String, dynamic> map, int index) {
    return Builder(builder: (context){
      BestExampleState state = context.read<BestExampleState>();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          _buildHeader(map),
          const SizedBox(height: 10),
          _buildVideoPlayer(map, index,(){

          }),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: (){

              Navigator.of(context).push(MaterialPageRoute(builder: (context){
                return BestExampleDetailPage(controller: state.videoPlayerController);
              }));
            },
            child: _buildBottom(),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            height: 10,
            color: Colors.white,
          )
        ],
      );
    });
  }

  Widget _placeholder(Map<String, dynamic> map, int index,bool isShowPlayButton) {
    int width = map["width"] as int;
    int height = map["height"] as int;

    double aspectRatio = width / height;
    return Stack(
      alignment: Alignment.center,
      children: [
        AspectRatio(
          aspectRatio: aspectRatio,
          child: Container(
            color: Colors.white60,
            width: double.infinity,
            height: MediaQuery.of(context).size.width / aspectRatio,
            child: Builder(builder: (context) {
              return Image.network(map["cover"] ?? "", fit: BoxFit.fill);
            }),
          ),
        ),
        isShowPlayButton == false ? SizedBox() :  Builder(builder: (context) {
          BestExampleState state = context.read<BestExampleState>();

          return GestureDetector(
            onTap: () {
              print("currentIndex = $index");
              state.play(index);
            },
            child: const Icon(Icons.play_arrow_rounded,
                size: 90, color: Colors.white),
          );
        })
      ],
    );
  }


  Widget _buildVideoPlayer(Map<String, dynamic> map, int index,Function initSuccessFunc) {
    return Builder(builder: (context) {

      BestExampleState state = context.read<BestExampleState>();
      bool flag = state.currentIndex == index;
      return MXVideoPlayer(
        controller: flag ? state.videoPlayerController : null,
        delayInit: false,
        indicatorBuilder: (context, controller) {
          return const CircularProgressIndicator();
        },
        initializedBuilder: (context,controller){
          initSuccessFunc.call();

        },
        placeholderBuilder: (context,controller){

          return _placeholder(map, index,!flag);
        },
      );
    });
  }

  Widget _buildHeader(Map<String, dynamic> map) {
    String desc = "这是描述";
    String image =
        "http://img.kaiyanapp.com/509b73e7f6254c78ccef2a644a6ceb05.jpeg?imageMogr2/quality/60/format/jpg";
    return Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40.0,
              height: 40.0,
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              child: Image.network(image),
            ),
            const SizedBox(width: 10),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("name",
                    style: TextStyle(color: Colors.grey, fontSize: 14)),
                Text(desc, maxLines: 2, style: TextStyle(fontSize: 17))
              ],
            ))
          ],
        ));
  }

  Widget _buildBottom() {

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildBottomItem(Icons.star_border, "13k"),
        _buildBottomItem(Icons.message, "12k"),
        _buildBottomItem(Icons.share, "1.3w"),
      ],
    );
  }

  Widget _buildBottomItem(IconData iconData, String number) {
    return Row(
      children: [Icon(iconData, color: Colors.grey), Text(number)],
    );
  }
}

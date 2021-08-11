import 'dart:math';
import 'package:alexpark_videoeditor/aieditor.dart';
import 'package:alexpark_videoeditor/backendsettings.dart';
import 'package:alexpark_videoeditor/operationresult.dart';
import 'package:alexpark_videoeditor/privatelib.dart';
import 'package:alexpark_videoeditor/publiclib.dart';
import 'package:alexpark_videoeditor/regulareditor.dart';
import 'package:alexpark_videoeditor/videolayerstruct.dart';
import 'package:flutter/material.dart';
import 'package:better_player/better_player.dart';
import 'package:extended_tabs/extended_tabs.dart';
import 'package:resizable_widget/resizable_widget.dart';
import 'globals.dart' as globals;

class VideoOperatorApp extends StatelessWidget 
{
  @override
  Widget build(BuildContext context) 
  {
    return MaterialApp(
      title: globals.packData.apptitle,
      theme: ThemeData(
        primarySwatch: globals.packData.colorFromARGB(255,136,14,79),
        buttonTheme: const ButtonThemeData
        (
          textTheme: ButtonTextTheme.primary,
        ),
      ),
      home: VideoOperator(),
    );
  }
}

class VideoOperator extends StatefulWidget 
{
  @override
  _VideoOperatorState createState() => _VideoOperatorState();
}

class _VideoOperatorState extends State<VideoOperator> 
with TickerProviderStateMixin
{
  late BetterPlayerController betterPlayerController;
  late TabController tabController;

  @override
  void initState() 
  {
    super.initState();
    
    tabController = TabController(length: 6, vsync: this);

    BetterPlayerDataSource betterPlayerDataSource = 
    BetterPlayerDataSource
    (
        BetterPlayerDataSourceType.network,
        globals.configFile.serveraddr+globals.configFile.publickey+"/placeholder.mp3",
    );
    betterPlayerController = 
    BetterPlayerController
    (
        BetterPlayerConfiguration
        (
          aspectRatio: globals.packData.videoaspect,
        ),
        betterPlayerDataSource: betterPlayerDataSource
    );
    betterPlayerController.setControlsEnabled(false);
    //betterPlayerController.disablePictureInPicture();
    globals.packData.bpcontroller = betterPlayerController;

/*
    globals.packData.vlcplayer = Player(
    id: 0,
    videoWidth: globals.packData.videowidth.toInt(),
    videoHeight: (globals.packData.videoheight-globals.packData.titleheight).toInt(),
    );
*/
  }

  @override
  void dispose() 
  {
    tabController.dispose();
    betterPlayerController.dispose();

    super.dispose();
  }

  void rebuildAllChildren(BuildContext context) 
  {
    void rebuild(Element el) 
    {
      el.markNeedsBuild();
      el.visitChildren(rebuild);
    }
    (context as Element).visitChildren(rebuild);
  }

  @override
  Widget build(BuildContext context) 
  {
    //rebuildAllChildren(context);

    return 
    Stack
    (
      children: 
      [
    Row
    (
      children: 
      [
        Container
        (
            height: globals.packData.videoheight,
            width: globals.packData.scrwidth-globals.packData.videowidth,      
        ),
        Container
        (
            height: globals.packData.videoheight,
            width: globals.packData.videowidth, 
            child: 
            Column
            (
              children: 
              [
                BetterPlayer
                  (
                    controller: betterPlayerController,
                  ), 
                Container
                  (
                    alignment: Alignment.center,
                    height: globals.packData.titleheight,
                    color: globals.packData.color2(colorcase: 6),
                    padding: EdgeInsets.fromLTRB(0, 3, 0, 0),
                    child: 
                    Row
                    (
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: 
                      [
                        ElevatedButton
                        (
                          onPressed: 
                          ()
                          async
                          {
                            if(vlu.vls.scalefactor<100)
                            {
                              globals.packData.tapvideolayerscrpos = 0;
                              vlu.vls.scalefactor=exp(log(vlu.vls.scalefactor)+0.4);
                              globals.packData.mainsetstate.call();
                            }
                          },
                          child: Icon(Icons.zoom_in_rounded)
                        ),
                        ElevatedButton
                        (
                          onPressed: 
                          ()
                          async
                          {
                            await globals.packData.videoPauseToCurrentBlockStart();
                            globals.packData.marklayerneedscroll = true;
                            globals.packData.mainsetstate.call();
                          },
                          child: Icon(Icons.skip_previous_rounded)
                        ),
                        ElevatedButton
                        (
                          onPressed: 
                          ()
                          async
                          {
                            if(globals.packData.isVideoPlaying())
                            {
                              await globals.packData.videoSetNormalSpeed();
                              await globals.packData.videoPauseCurrent();
                            }
                            else
                            {
                              if(vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].respeedenable)
                              {

                              }
                              else
                              {
                                await globals.packData.videoSetNormalSpeed();
                                await globals.packData.videoPlayCurrent();
                              }
                            }
                            globals.packData.mainsetstate.call();
                          },
                          child: globals.packData.isVideoPlaying()?Icon(Icons.pause_rounded):Icon(Icons.play_arrow_rounded)
                        ),
                        ElevatedButton
                        (
                          onLongPress: 
                          ()
                          async
                          {
                              if(vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].respeedenable)
                              {

                              }
                              else
                              {
                            await globals.packData.videoSetFastForward();
                            globals.packData.mainsetstate.call();
                              }

                          },
                          onPressed: 
                          ()
                          async
                          {
                              if(vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].respeedenable)
                              {

                              }
                              else
                              {
                            await globals.packData.videoSetNormalSpeed();
                            await globals.packData.videoForward();
                            globals.packData.marklayerneedscroll = true;
                            globals.packData.mainsetstate.call();
                              }
                          },
                          child: Icon(Icons.fast_forward_rounded)
                        ),
                        ElevatedButton
                        (
                          onPressed: 
                          ()
                          async
                          {
                            await globals.packData.videoPauseToCurrentBlockEnd();
                            globals.packData.marklayerneedscroll = true;
                            globals.packData.mainsetstate.call();
                          },
                          child: Icon(Icons.skip_next_rounded)
                        ),
                        ElevatedButton
                        (
                          onPressed: 
                          ()
                          async
                          {
                            if(vlu.vls.scalefactor>3)
                            {
                              globals.packData.tapvideolayerscrpos = 0;
                              vlu.vls.scalefactor=exp(log(vlu.vls.scalefactor)-0.4);
                              globals.packData.mainsetstate.call();
                            }
                          },
                          child: Icon(Icons.zoom_out_rounded)
                        ),
                      ],
                    ),
                  ),
              ],
            ),
        ),
      ],
    ),
    ResizableWidget
    (
      isHorizontalSeparator: false,
      /*      */
      percentages: 
      [
        1-(globals.packData.videowidth/globals.packData.scrwidth),
        globals.packData.videowidth/globals.packData.scrwidth
      ],
      onResized: (infoList)
      {
          //print(infoList.map((x) => '(${x.size}, ${x.percentage}%)').join(", "));
          globals.packData.optpanelwidth = infoList[0].size-55.0;
      },
      separatorSize: 4,
      separatorColor: globals.packData.color1(colorcase:2),
      children: [
        SizedBox
        (
          height: globals.packData.videoheight,
          //width: globals.packData.scrwidth-globals.packData.videowidth,
          child: 
              Row(
              children: <Widget>
              [
                ExtendedTabBar
                (
                  indicator: ColorTabIndicator(globals.packData.color1(colorcase:2)),
                  labelColor: globals.packData.colorFromARGB(255,0,0,10),
                  scrollDirection: Axis.vertical,
                  tabs: <ExtendedTab>
                  [
                    ExtendedTab(
                      size: globals.packData.tabsize,
                      icon: Image(image: AssetImage('images/48/Favourites.png')),
                      scrollDirection: Axis.vertical,
                    ),
                    ExtendedTab(
                      size: globals.packData.tabsize,
                      icon: Image(image: AssetImage('images/48/Calculator.png')),
                      scrollDirection: Axis.vertical,
                    ),
                    ExtendedTab(
                      size: globals.packData.tabsize,
                      icon: Image(image: AssetImage('images/48/Pictures.png')),
                      scrollDirection: Axis.vertical,
                    ),
                    ExtendedTab(
                      size: globals.packData.tabsize,
                      icon: Image(image: AssetImage('images/48/SchoolStudy.png')),
                      scrollDirection: Axis.vertical,
                    ),
                    ExtendedTab(
                      size: globals.packData.tabsize,
                      icon: Image(image: AssetImage('images/48/ControlPanel.png')),
                      scrollDirection: Axis.vertical,
                    ),
                    ExtendedTab(
                      size: globals.packData.tabsize,
                      icon: Image(image: AssetImage('images/48/Explorer.png')),
                      scrollDirection: Axis.vertical,
                    ),
                  ],
                  controller: tabController,
                ),
                Expanded
                (
                  child: 
                  ExtendedTabBarView
                  (
                    children: <Widget>
                    [
                      PrivateLib(),
                      RegularEditor(),
                      OperationResult(),
                      AIEditor(),
                      BackendSettings(),
                      PublicLib(),
                    ],
                    controller: tabController,
                    scrollDirection: Axis.vertical,
                  ),
                ),
              ],
          ),
        ),
        Container
        (
            //height: globals.packData.videoheight,
            //width: globals.packData.videowidth,      
        ),
      ],

    ),
      ],
    );
    
  }
}

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
import 'package:dart_vlc/dart_vlc.dart';
import 'globals.dart' as globals;

class VideoOperatorPCApp extends StatelessWidget 
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
      home: VideoOperatorPC(),
    );
  }
}

class VideoOperatorPC extends StatefulWidget 
{
  @override
  _VideoOperatorPCState createState() => _VideoOperatorPCState();
}

class _VideoOperatorPCState extends State<VideoOperatorPC> 
with TickerProviderStateMixin
{
  late BetterPlayerController betterPlayerController;
  late TabController tabController;
  late Player vlcplayer;
  //late Timer timerloop;

  @override
  void initState() 
  {
    super.initState();
    
    tabController = TabController(length: 6, vsync: this);

/*
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
*/

    globals.packData.bpcontroller = BetterPlayerController(BetterPlayerConfiguration
        (
          aspectRatio: globals.packData.videoaspect,
        ),);

    vlcplayer = Player(
    id: 2,
    videoWidth: globals.packData.videowidth.toInt(),
    videoHeight: (globals.packData.videoheight-globals.packData.titleheight).toInt(),
    );
    globals.packData.vlcplayer = vlcplayer;
    vlcplayer.playbackStream.listen((PlaybackState state) 
    {
      globals.packData.vlcisplaying = state.isPlaying;
      globals.packData.vlcseekable = state.isSeekable;
      //state.isCompleted;
    });
    vlcplayer.positionStream.listen((PositionState state)
    {
      globals.packData.vlcposition = state.position!;
      //state.duration;
    });

/*
    timerloop = Timer.periodic(Duration(milliseconds: 200), (timer) 
    async
    {
      if(globals.packData.vlccommands.length>0)
      {
        try
        {
        List<String> tstr = globals.packData.vlccommands[0].split("|");
        switch (tstr[0]) 
        {
          case "pause":
            await globals.packData.videoPauseCurrent();
            break;
          case "play":
            await globals.packData.videoPlayCurrent();
            break;
          case "seek":
            await globals.packData.videoSeekTo(int.parse(tstr[1]));
            break;   
          default:
        }
        }
        catch(e)
        {}
        globals.packData.vlccommands.removeAt(0);
        
      }
    });
*/

  }

  @override
  void dispose() 
  {
    tabController.dispose();
    betterPlayerController.dispose();
    vlcplayer.dispose();

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
                Video(
                    playerId: 2,
                    width: globals.packData.videowidth,
                    height: globals.packData.videoheight-globals.packData.titleheight,
                    volumeThumbColor: globals.packData.color2(colorcase: 13),
                    volumeActiveColor: globals.packData.color2(colorcase: 13),
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
          //print(globals.packData.optpanelwidth);
      },
      separatorSize: 4,
      separatorColor: globals.packData.color1(colorcase:2),
      children: [
        SizedBox
        (
          height: globals.packData.videoheight,
          //width: globals.packData.optpanelwidth+35.0,
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
                Expanded(child: 
                ExtendedTabBarView
                (
                  key: UniqueKey(),
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
                  physics: NeverScrollableScrollPhysics(),
                ),
                ),
              ],
          ),
        ),
        Container
        (
            //height: globals.packData.videoheight,
            //width: globals.packData.scrwidth-globals.packData.optpanelwidth-35.0,      
        ),
      ],
    ),

      ],
    );
    
  }
}
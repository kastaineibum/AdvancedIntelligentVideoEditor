import 'dart:async';
import 'package:flutter/material.dart';
//import 'package:transparent_image/transparent_image.dart';
//import 'package:flutter_image/flutter_image.dart';
import 'package:extended_image/extended_image.dart';
import 'globals.dart' as globals;
import 'videolayerstruct.dart';
import 'videoruler.dart';

class VideoLayerApp extends StatelessWidget 
{
  @override
  Widget build(BuildContext context) 
  {
    return MaterialApp(
      title: globals.packData.apptitle,
      theme: ThemeData(
        primarySwatch: globals.packData.color1(colorcase:1),
        buttonTheme: const ButtonThemeData
        (
          textTheme: ButtonTextTheme.primary,
        ),
      ),
      home: VideoLayer(),
    );
  }
}

class VideoLayer extends StatefulWidget 
{
  @override
  _VideoLayerState createState() => _VideoLayerState();
}

class _VideoLayerState extends State<VideoLayer> 
{
  List<ScrollController> scs = 
  List<ScrollController>.filled(1, ScrollController(), growable: true);
  double scrollPosition = 0;
  //Offset _tapPosition = Offset(0, 0);
  late Timer timerloop;

  void _handleTapDown(TapDownDetails details) 
  {
    final RenderBox referenceBox = context.findRenderObject() as RenderBox;
    //setState(() 
    //{
      //_tapPosition = referenceBox.globalToLocal(details.globalPosition);
      //print(_tapPosition);
    //});
    globals.packData.tapvideolayerscrpos=referenceBox.globalToLocal(details.globalPosition).dx;
    globals.packData.mainsetstate.call();
  }

  Future<void> blocktapped(BuildContext context,int layeridx,int blockidx)
  async
  {
    if(globals.packData.currentpickid!=0)
    {
      globals.packData.blockpickresult[globals.packData.currentpickid] = layeridx.toString()+"^"+blockidx.toString();
      globals.packData.blockpicktcc[globals.packData.currentpickid].text = "layer:"+layeridx.toString()+" "+"block:"+blockidx.toString()+" "+globals.packData.timestrFromMillisec(vlu.vls.videolayers[layeridx].videoblocks[blockidx].blocklength.inMilliseconds);
      globals.packData.currentpickid=0;
    }

    //print(scrollPosition.toString()+" "+layeridx.toString()+" "+blockidx.toString());
    globals.packData.tapvideolayerpos = scrollPosition + globals.packData.tapvideolayerscrpos;
    globals.packData.taplayeridx = layeridx;
    globals.packData.tapblockidx = blockidx;
    globals.packData.currentposinmilli = (globals.packData.tapvideolayerpos/vlu.vls.scalefactor*1000).toInt();
    globals.packData.currentpos = globals.packData.timestrFromMillisec(globals.packData.currentposinmilli);
    //globals.packData.initflag=2;
    
    globals.packData.currentposctl.text = globals.packData.currentpos;
    //globals.packData.rebuildAllChildren(globals.packData.mobilemaincontext);

    //if(vlu.vls.videolayers[layeridx].videoblocks[blockidx].fileclass!="placeholder")
    //{
      int fpos = globals.packData.getCurrentMillinBlockFile(layeridx,blockidx);
      //globals.packData.forceisplayingfalse = true;
      await globals.packData.openVideoFile(vlu.vls.videolayers[layeridx].videoblocks[blockidx].ispubliclib, 
      vlu.vls.videolayers[layeridx].videoblocks[blockidx].filename);
      await globals.packData.videoPauseAt(fpos);
      //globals.packData.forceisplayingfalse = false;
    //}
    globals.packData.mainsetstate.call();
  }

  @override
  void initState() 
  {
    super.initState();

    globals.packData.scs0 = scs[0];
    
    timerloop = Timer.periodic(Duration(milliseconds: globals.packData.videowatcherinterval), (timer) 
    async
    {
      if(globals.packData.isVideoPlaying()||globals.packData.marklayerneedscroll)
      {
        globals.packData.marklayerneedscroll = false;
        VideoLayerBlock vbt =
          vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx];
        double blockmaxtouch = (vbt.fromstamp+vbt.blocklength).inMilliseconds/1000*vlu.vls.scalefactor;
        double vmarkpos = await globals.packData.getScreenMarkPos();
        if(vmarkpos<0||vmarkpos>globals.packData.scrwidth)
        {
            scrollPosition = vmarkpos+globals.packData.rulerscrollpos;
            globals.packData.rulerscrollpos = scrollPosition;
            if(globals.packData.rulerscrollpos+globals.packData.listwidth
            >blockmaxtouch)
            {
              scrollPosition = blockmaxtouch-globals.packData.listwidth;
              globals.packData.rulerscrollpos = scrollPosition;
            }
            for(int i=0;i<=vlu.vls.videolayers.length;i++)
            {
              scs[i].jumpTo(globals.packData.rulerscrollpos);
            }

        }
        if(globals.packData.ifblockchanged)
        {
          globals.packData.blockchanged(globals.packData.tapblockidx);
        }
        setState(() 
            {
              globals.packData.tapvideolayerscrpos = vmarkpos;
              globals.packData.currentposctl.text = globals.packData.currentpos;
            });
        
      }
    });
    
  }

  @override
  Widget build(BuildContext context) 
  {
    return
Stack
(
  
  children: 
  <Widget>[

      Column(
      children: 
      [
        SizedBox
        (
          height: globals.packData.rulerheight,
          child: 
            NotificationListener<ScrollEndNotification>
            (
              child: ListView.builder
              (
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(0.0),
                scrollDirection: Axis.horizontal,
                controller: scs[0],
                itemCount: 1,
                itemBuilder:  
                (context, blockidx) 
                {
                  return buildRuler(context);
                }
              ),
              onNotification: (notification) 
              {
                scrollPosition = scs[0].position.pixels;
                //print(scrollPosition.toString());
                for(int i=1;i<=vlu.vls.videolayers.length;i++)
                {
                  scs[i].jumpTo(scrollPosition);
                }
                globals.packData.rulerscrollpos = scrollPosition;
                globals.packData.tapvideolayerscrpos=-1;
                return true;
              },
            ),
        ),
        SizedBox
        (
          height: globals.packData.listheight-globals.packData.rulerheight,
          child: 
          ListView.builder
          (
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(0.0),
            itemCount: vlu.vls.videolayers.length,
            itemBuilder:  
            (context, layeridx) 
            {
              return buildLayerItem(context,layeridx);
            }
          ),
        ),
      ],
    ),
    Positioned
    (
      left: globals.packData.tapvideolayerscrpos,
      right: globals.packData.listwidth-globals.packData.tapvideolayerscrpos-1,
      top: 0,
      bottom: 0,
      child: 
      Container
      (
        color: globals.packData.color2(colorcase:5),
        width: 1,
        height: globals.packData.listheight,
      )
    ),

    
  ],

);

      
  }

  Widget buildRuler(BuildContext context)
  {
    return 
    SizedBox
            (
              width: vlu.getListWidthLength(),
              height: globals.packData.rulerheight,
              child:
              CustomPaint
              (
                painter:VideoRulerPainter(),
              )
            );
  }

  Widget buildLayerItem(BuildContext context,int layeridx)
  {
    return 
      SizedBox
      (
          height: globals.packData.layeritemheight,
          child: 
          buildLayerBlocks(context, layeridx),
      );
  }

  Widget buildLayerBlocks(BuildContext context,int layeridx)
  {
    scs.add(ScrollController());

      return ListView.builder
          (
            padding: EdgeInsets.all(0.0),
            scrollDirection: Axis.horizontal,
            physics: NeverScrollableScrollPhysics(),
            controller: scs[layeridx+1],
            itemCount: vlu.vls.videolayers[layeridx].videoblocks.length,
            itemBuilder:  
            (context, blockidx) 
            {
              return 
              GestureDetector
              (
                child: buildBlock(context,layeridx,blockidx),
                onTap: ()async{await blocktapped(context,layeridx,blockidx);},
                onTapDown: _handleTapDown,
              );
            }
          );
  }

  Widget buildBlock(BuildContext context,int layeridx,int blockidx)
  {
    double blockwidth = vlu.vls.videolayers[layeridx].videoblocks[blockidx].blocklength.inMilliseconds/1000*vlu.vls.scalefactor;
    String volumetext="";
    String resizetext="";
    String speedtext="";
    String pictext="";
    if(vlu.vls.videolayers[layeridx].videoblocks[blockidx].respeedenable)
    {
      blockwidth = blockwidth/vlu.vls.videolayers[layeridx].videoblocks[blockidx].respeed;
      speedtext="speed:"+((vlu.vls.videolayers[layeridx].videoblocks[blockidx].respeed*100).toInt()/100).toString()+"x";
    }
    if(vlu.vls.videolayers[layeridx].videoblocks[blockidx].revolumeenable)
    {
      volumetext = "volume:"+((vlu.vls.videolayers[layeridx].videoblocks[blockidx].revolume*100).toInt()/100).toString()+"x";
    }
    if(vlu.vls.videolayers[layeridx].videoblocks[blockidx].filename.contains('-silent'))
    {
      volumetext = "volume:silent";
    }
    if(vlu.vls.videolayers[layeridx].videoblocks[blockidx].resizeenable)
    {
      resizetext = vlu.vls.videolayers[layeridx].videoblocks[blockidx].resizeleft.toString()+" "+vlu.vls.videolayers[layeridx].videoblocks[blockidx].resizetop.toString()+
      " "+vlu.vls.videolayers[layeridx].videoblocks[blockidx].resizewidth.toString()+"x"+vlu.vls.videolayers[layeridx].videoblocks[blockidx].resizeheight.toString();
    }
    Color selectedcolor = 
    (globals.packData.taplayeridx==layeridx
    &&globals.packData.tapblockidx==blockidx)
    ?globals.packData.color2(colorcase: 9):
    vlu.vls.videolayers[layeridx].videoblocks[blockidx].blockcolor;

    if(vlu.vls.videolayers[layeridx].videoblocks[blockidx].fileclass=="mp4")
    {
      return 
    //Row
    //(
    //children:
    //[
    SizedBox
    (
      width: blockwidth,
      child: 
        Container
        (
          padding: EdgeInsets.fromLTRB(0, 4, 0, 4),
          child: 
        Container
        (
          padding: EdgeInsets.fromLTRB(1, 0, 1, 0),
          color: blockidx.isEven?vlu.vls.videolayers[layeridx].videoblocks[blockidx].blockcolor:vlu.vls.videolayers[layeridx].videoblocks[blockidx].blockcolor.withAlpha((vlu.vls.videolayers[layeridx].videoblocks[blockidx].blockcolor.alpha/2).floor()),
          child: 
          Container
          (
          padding: EdgeInsets.fromLTRB(0, 1, 0, 1),
          color: selectedcolor,
          child:
          ListView.builder
          (
            padding: EdgeInsets.all(0.0),
            scrollDirection: Axis.horizontal,
            physics: NeverScrollableScrollPhysics(),
            itemCount: ((blockwidth-2)/((globals.packData.layeritemheight-10)*globals.packData.videoaspect)).ceil(),
            itemBuilder:  
            (context, picidx)
            {
              String imagepath = "";
              if(vlu.vls.videolayers[layeridx].videoblocks[blockidx].ispubliclib)
              {
                imagepath = globals.configFile.serveraddr+'alexgetpospic.php?key='+globals.packData.encodeDES3CBC(globals.configFile.publickey)
                            +'&file='+vlu.vls.videolayers[layeridx].videoblocks[blockidx].filename.replaceAll("-silent", "")+'&milli='+getposMilli(layeridx,blockidx,picidx).toString();
              }
              else
              {
                imagepath = globals.configFile.serveraddr+'alexgetpospic.php?key='+globals.packData.encodeDES3CBC(globals.configFile.apikey)
                            +'&file='+vlu.vls.videolayers[layeridx].videoblocks[blockidx].filename.replaceAll("-silent", "")+'&milli='+getposMilli(layeridx,blockidx,picidx).toString();
              }

              return 
              Stack
              (
                children: 
                [
                  ExtendedImage.network
                  (
      imagepath,
      width: (globals.packData.layeritemheight-10)*globals.packData.videoaspect,
      height: (globals.packData.layeritemheight-10),
      fit: BoxFit.fill,
      cache: true,
      //border: Border.all(color: globals.packData.color2(colorcase:5), width: 1.0),
      shape: BoxShape.rectangle,
      borderRadius: BorderRadius.all(Radius.circular(5.0)),
      //cancelToken: cancellationToken,
                  ),
                  Column
                  (
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: 
                    [
                      Text(volumetext,style: TextStyle(fontSize: 8,color: globals.packData.color2(colorcase: 12)),),
                      Text(speedtext,style: TextStyle(fontSize: 8,color: globals.packData.color2(colorcase: 12)),),
                      Text(resizetext,style: TextStyle(fontSize: 8,color: globals.packData.color2(colorcase: 12)),),
                    ],
                  ),
                ],
              );

            }
          ),
          ),
          ),
        )
    //),
    //Container(width: 1,padding: EdgeInsets.all(0.0),color: globals.packData.color2(colorcase: 10),),
    //]
    );
    }
    else if(vlu.vls.videolayers[layeridx].videoblocks[blockidx].fileclass=="mp3")
    {
      return 
    //Row
    //(
    //children:
    //[
    SizedBox
    (
      width: blockwidth,
      child: 
        Container
        (
          padding: EdgeInsets.fromLTRB(0, 4, 0, 4),
          child: 
        Container
        (
          padding: EdgeInsets.fromLTRB(1, 0, 1, 0),
          color: blockidx.isEven?vlu.vls.videolayers[layeridx].videoblocks[blockidx].blockcolor:vlu.vls.videolayers[layeridx].videoblocks[blockidx].blockcolor.withAlpha((vlu.vls.videolayers[layeridx].videoblocks[blockidx].blockcolor.alpha/2).floor()),
          child: 
          Container
          (
          padding: EdgeInsets.fromLTRB(0, 1, 0, 1),
          color: selectedcolor,
          child:
          ListView.builder
          (
            padding: EdgeInsets.all(0.0),
            scrollDirection: Axis.horizontal,
            physics: NeverScrollableScrollPhysics(),
            itemCount: 1,
            itemBuilder:  
            (context, picidx)
            {
              String imagepath = "";
              if(vlu.vls.videolayers[layeridx].videoblocks[blockidx].ispubliclib)
              {
                imagepath = globals.configFile.serveraddr+'alexgetposwave.php?key='+globals.packData.encodeDES3CBC(globals.configFile.publickey)
                            +'&file='+vlu.vls.videolayers[layeridx].videoblocks[blockidx].filename
                            +'&start='+getwavestartMilli(layeridx,blockidx).toString()+'&len='+getwavelengthMilli(layeridx,blockidx).toString();
              }
              else
              {
                imagepath = globals.configFile.serveraddr+'alexgetposwave.php?key='+globals.packData.encodeDES3CBC(globals.configFile.apikey)
                            +'&file='+vlu.vls.videolayers[layeridx].videoblocks[blockidx].filename
                            +'&start='+getwavestartMilli(layeridx,blockidx).toString()+'&len='+getwavelengthMilli(layeridx,blockidx).toString();
              }

              return 
              Stack
              (
                children: 
                [
ExtendedImage.network
              (
  imagepath,
  width: blockwidth-2,
  height: (globals.packData.layeritemheight-10),
  fit: BoxFit.fill,
  cache: true,
  //border: Border.all(color: globals.packData.color2(colorcase:5), width: 1.0),
  shape: BoxShape.rectangle,
  borderRadius: BorderRadius.all(Radius.circular(5.0)),
  //cancelToken: cancellationToken,
              ),
                  Column
                  (
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: 
                    [
                      Text(volumetext,style: TextStyle(fontSize: 8,color: globals.packData.color2(colorcase: 12)),),
                      Text(speedtext,style: TextStyle(fontSize: 8,color: globals.packData.color2(colorcase: 12)),),
                    ],
                  ),
                ],
              );
              
            }
          ),
          ),
          ),
        )
    //),
    //Container(width: 1,padding: EdgeInsets.all(0.0),color: globals.packData.color2(colorcase: 10),),
    //],
    );
    }
    else if(vlu.vls.videolayers[layeridx].videoblocks[blockidx].fileclass=="placeholder")
    {
      return 
    //Row
    //(
    //children:
    //[
    SizedBox
    (
      width: blockwidth,
      child: 
        Container
        (
          padding: EdgeInsets.fromLTRB(0, 4, 0, 4),
          child: 
        Container
        (
          padding: EdgeInsets.fromLTRB(1, 0, 1, 0),
          color: blockidx.isEven?vlu.vls.videolayers[layeridx].videoblocks[blockidx].blockcolor:vlu.vls.videolayers[layeridx].videoblocks[blockidx].blockcolor.withAlpha((vlu.vls.videolayers[layeridx].videoblocks[blockidx].blockcolor.alpha/2).floor()),
          child: 
          Container
          (
          padding: EdgeInsets.fromLTRB(0, 1, 0, 1),
          color: selectedcolor,
          child:
            SizedBox(),
          ),
          ),
        )
    //),
    //Container(width: 1,padding: EdgeInsets.all(0.0),color: globals.packData.color2(colorcase: 10),),
    //],
    );
    }
    else if(vlu.vls.videolayers[layeridx].videoblocks[blockidx].fileclass=="png")
    {
      return 
    //Row
    //(
    //children:
    //[
    SizedBox
    (
      width: blockwidth,
      child: 
        Container
        (
          padding: EdgeInsets.fromLTRB(0, 4, 0, 4),
          child: 
        Container
        (
          padding: EdgeInsets.fromLTRB(1, 0, 1, 0),
          color: blockidx.isEven?vlu.vls.videolayers[layeridx].videoblocks[blockidx].blockcolor:vlu.vls.videolayers[layeridx].videoblocks[blockidx].blockcolor.withAlpha((vlu.vls.videolayers[layeridx].videoblocks[blockidx].blockcolor.alpha/2).floor()),
          child: 
          Container
          (
          padding: EdgeInsets.fromLTRB(0, 1, 0, 1),
          color: selectedcolor,
          child:
          ListView.builder
          (
            padding: EdgeInsets.all(0.0),
            scrollDirection: Axis.horizontal,
            physics: NeverScrollableScrollPhysics(),
            itemCount: ((blockwidth-2)/((globals.packData.layeritemheight-10)*globals.packData.videoaspect)).ceil(),
            itemBuilder:  
            (context, picidx)
            {
              String imagepath="";
              if(vlu.vls.videolayers[layeridx].videoblocks[blockidx].ispubliclib)
              {
                imagepath = globals.configFile.serveraddr+'alexgetpospng.php?key='+globals.packData.encodeDES3CBC(globals.configFile.publickey)
                            +'&file='+vlu.vls.videolayers[layeridx].videoblocks[blockidx].filename;
              }
              else
              {
                imagepath = globals.configFile.serveraddr+'alexgetpospng.php?key='+globals.packData.encodeDES3CBC(globals.configFile.apikey)
                            +'&file='+vlu.vls.videolayers[layeridx].videoblocks[blockidx].filename;
              }
              
              return 
              Stack
              (
                children: 
                [
                  ExtendedImage.network
              (
  imagepath,
  width: (globals.packData.layeritemheight-10)*globals.packData.videoaspect,
  height: (globals.packData.layeritemheight-10),
  fit: BoxFit.fill,
  cache: true,
  //border: Border.all(color: globals.packData.color2(colorcase:5), width: 1.0),
  shape: BoxShape.rectangle,
  borderRadius: BorderRadius.all(Radius.circular(5.0)),
  //cancelToken: cancellationToken,
              ),
                  Column
                  (
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: 
                    [
                      Text(resizetext,style: TextStyle(fontSize: 8,color: globals.packData.color2(colorcase: 12)),),
                      Text(pictext,style: TextStyle(fontSize: 8,color: globals.packData.color2(colorcase: 12)),),
                    ],
                  ),
                ],
              );
              
            }
          ),
          ),
          ),
        )
    //),
    //Container(width: 1,padding: EdgeInsets.all(0.0),color: globals.packData.color2(colorcase: 10),),
    //],
    );
    }
    
    return SizedBox();
  }

  int getposMilli(int layeridx,int blockidx,int picidx)
  {
    int startmilli = vlu.vls.videolayers[layeridx].videoblocks[blockidx].filestartpos.inMilliseconds;
    double picwidth = (globals.packData.layeritemheight-10)*globals.packData.videoaspect;
    double halfpicwidth = (globals.packData.layeritemheight-10)*globals.packData.videoaspect/2;
    double poslenth = halfpicwidth+(picwidth*picidx)+1;
    int posmilli = startmilli + (poslenth/vlu.vls.scalefactor*1000).toInt();
    if(vlu.vls.videolayers[layeridx].videoblocks[blockidx].respeedenable)
    {
      posmilli = startmilli + (poslenth/vlu.vls.scalefactor*1000*vlu.vls.videolayers[layeridx].videoblocks[blockidx].respeed).toInt();
    }
    return posmilli;
  }

  int getwavestartMilli(int layeridx,int blockidx)
  {
    int startmilli = vlu.vls.videolayers[layeridx].videoblocks[blockidx].filestartpos.inMilliseconds;
    return startmilli;
  }
  
  int getwavelengthMilli(int layeridx,int blockidx)
  {
    int lengthmilli = vlu.vls.videolayers[layeridx].videoblocks[blockidx].blocklength.inMilliseconds;
    return lengthmilli;
  }

}
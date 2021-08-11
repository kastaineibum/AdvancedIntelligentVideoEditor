library alexpark_videoeditor.globals;
import 'dart:async';
import 'dart:convert';
import 'package:alexpark_videoeditor/videolayerstruct.dart';
import 'package:dart_des/dart_des.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:better_player/better_player.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:dart_vlc/dart_vlc.dart';
import 'dart:io';
import 'package:sprintf/sprintf.dart';
import 'package:http/http.dart' as http;
import 'dart:math';

PackData packData = new PackData();
ConfigFile configFile = new ConfigFile();

////////////////////////////////////////////////////////////////////////////////
/// global data and function class
/// ////////////////////////////////////////////////////////////////////////////
class PackData
{
  int randomseed = 0;   //random seed for random int creator
  int randomi = 0;      //random integer buffer
  String homepagetitle = 'Video Editor'; //homepage title
  String apptitle = 'Video Editor'; //app title
  String testrandom1 = ''; //random string buffer
  String osname = '';  //current os name
  String osversion = '';//current os version
  String status1 = ''; //app status discription

  double videowidth = 0;   //ui display video width
  double videoheight = 0;  //ui display video height
  double listwidth = 0;    //ui display list width
  double listheight = 0;   //ui display list height
  double optpanelwidth = 0;//ui dispaly video operation panel width
  int initflag = 1;        //if ui in init progress

  double rulerheight = 0;  //video layers ruler height
  double layeritemheight = 0;//video layer item height

  double scrheight = 0;     //device screen height
  double scrwidth = 0;      //device screen width
  double scrpixelratio = 0; //device screen pixel ratio

  double tabsize = 0;       //tabcontrol tab size
  double titleheight = 0;   //tab window title height
  double videolinepercent = 0;//video operator row height percent
  double buttonheight = 20.0;   //ui display button height
  double buttongap = 5.0;       //ui display gap between buttons vertical
  double buttonminwidth = 50.0;//ui display button min width
  double buttongaphrz = 10.0;   //ui display gap betwwen buttons horizontal

  String configfilename = 'aivideoeditor.cfg';          //app config file name

  String currentpos = '00:00:00.000';                   //current video position on video layer ruler
  int currentposinmilli = 0;                            //current video position in milliseconds
  String softwarever = '0.0.1';                         //this software version
  double videoaspect = 16/9;                            //video aspect ratio
  double videoaspectforbp = 16/9;                       //video aspect ratio for better player
  double bpnormalspeed = 1.0;                           //better player's normal speed

  double tapvideolayerpos = 0.0;                        //tapped postion on videoruler in length
  double tapvideolayerscrpos = -1.0;                    //tapped postion on screen in length
  int taplayeridx = 0;                                  //tapped layer index
  int tapblockidx = 0;                                  //tapped block index in his layer

  Duration currentrawpos = Duration();                  //current video playing file raw position
  double rulerscrollpos = 0.0;                          //current video ruler scroll postion
  bool marklayerneedscroll = false;                     //when set true mark the video layers display need scroll
  Duration currentrulerpos = Duration();                //current video playing postion on ruler
  bool forceisplayingfalse = false;                     //if force playing status to false. used for critical pauseat function.
  bool ifblockchanged = false;                          //if block is changed while playing

  int fastforwardstepmilli = 5000;                      //how long is a step when fast forward pressed

  int videowatcherinterval = 200;                       //video playing watchdog timer interval in millisecond

  late BuildContext mobilemaincontext;                  //mobile app main page context
  TextEditingController currentposctl = TextEditingController();//controller of the time box on title bar
  late BetterPlayerController bpcontroller;             //controller of mobile bpvideoplayer
  late ScrollController scs0;                           //video layers ruler scroll controller
  late Function mainsetstate;                           //mobile app main page setstate function
  late ItemScrollController aiscc;                      //ai video editor panel scroll controller
  List<TextEditingController> blockpicktcc=List.filled(0, TextEditingController(),growable: true); //block picker text controller
  List<TextEditingController> colorpicktcc=List.filled(0, TextEditingController(),growable: true); //block picker text controller
  int currentpickid = 0;                                //block picker current picking's pickid
  List<String> blockpickresult = List.filled(100, "0^0",growable: true); //block picker pick result strings "layeridx^blockidx"
  List<Map<int,String>> blockpicker = 
  [
    {0:'gap'},
    {1:'backgroundmattingv2video'},
    {2:'backgroundmattingv2bgpng'},
    {3:'freeformvideoinpaintingvideo'},
    {4:'freeformvideoinpaintingmask'},
    {5:'panopticdeeplabvideo'},    
    {6:'skyaroriginalvideo'}, 
    {7:'skyarskyvideo'}, 
    {8:'wav2liporiginalvideo'}, 
    {9:'wav2lipmp3'}, 
  ];

  late Player vlcplayer;//=Player(id: 1,videoWidth: 1,videoHeight: 1);
  bool vlcisplaying = false;
  Duration vlcposition = Duration();
  bool vlcseekable = false;
  //List<String> vlccommands = List.filled(0, "",growable: true);

  PackData();

////////////////////////////////////////////////////////////////////////////////
/// video functions
/// ////////////////////////////////////////////////////////////////////////////

  Future<double> getScreenMarkPos()
  async
  {
    if(osname=="android"||osname=="ios")
    {
      currentrawpos = 
            await bpcontroller.videoPlayerController!.position as Duration;
      Duration currentrawoffset = currentrawpos-vlu.vls.videolayers[taplayeridx].videoblocks[tapblockidx].filestartpos;
      if(currentrawoffset.inMilliseconds-vlu.vls.videolayers[taplayeridx].videoblocks[tapblockidx].blocklength.inMilliseconds>-videowatcherinterval)
      {
        ifblockchanged = true;
      }
      currentrulerpos = (currentrawoffset
      +vlu.vls.videolayers[taplayeridx].videoblocks[tapblockidx].fromstamp);
      currentposinmilli = currentrulerpos.inMilliseconds.toInt();
      currentpos = timestrFromMillisec(currentposinmilli);
      return (currentrulerpos.inMilliseconds/1000
      *vlu.vls.scalefactor)-rulerscrollpos;
    }
    else
    {
      if(vlcposition.inMilliseconds!=0)
      {
      currentrawpos = 
            vlcposition;
      Duration currentrawoffset = currentrawpos-vlu.vls.videolayers[taplayeridx].videoblocks[tapblockidx].filestartpos;
      if(currentrawoffset.inMilliseconds-vlu.vls.videolayers[taplayeridx].videoblocks[tapblockidx].blocklength.inMilliseconds>-videowatcherinterval)
      {
        ifblockchanged = true;
      }
      currentrulerpos = (currentrawoffset
      +vlu.vls.videolayers[taplayeridx].videoblocks[tapblockidx].fromstamp);
      currentposinmilli = currentrulerpos.inMilliseconds.toInt();
      currentpos = timestrFromMillisec(currentposinmilli);
      return (currentrulerpos.inMilliseconds/1000
      *vlu.vls.scalefactor)-rulerscrollpos;
      }
      else
      {
        return tapvideolayerscrpos;
      }
    }
  }

  Future<void> blockchanged(int blockidx)
  async
  {
    if(osname=="android"||osname=="ios")
    {
      ifblockchanged = false;
      bool isplaying = isVideoPlaying();
      if(vlu.vls.videolayers[taplayeridx].videoblocks.length-1>blockidx)
      {
        tapblockidx = blockidx+1;
      }
      else
      {
        await bpcontroller.pause();
        return;
      }
      int fpos = getCurrentMillinBlockFile(taplayeridx,tapblockidx);
      await openVideoFile(vlu.vls.videolayers[taplayeridx].videoblocks[tapblockidx].ispubliclib, 
        vlu.vls.videolayers[taplayeridx].videoblocks[tapblockidx].filename);
      if(isplaying)
      {
        await videoPauseAt(fpos);
        await videoPlayCurrent();
      }
      else
      {
        await videoPauseAt(fpos);
      } 
    }
    else
    {
      ifblockchanged = false;
      bool isplaying = isVideoPlaying();
      if(vlu.vls.videolayers[taplayeridx].videoblocks.length-1>blockidx)
      {
        tapblockidx = blockidx+1;
      }
      else
      {
        vlcplayer.pause();
        return;
      }
      int fpos = getCurrentMillinBlockFile(taplayeridx,tapblockidx);
      await openVideoFile(vlu.vls.videolayers[taplayeridx].videoblocks[tapblockidx].ispubliclib, 
        vlu.vls.videolayers[taplayeridx].videoblocks[tapblockidx].filename);
      if(isplaying)
      {
        await videoPauseAt(fpos);
        await videoPlayCurrent();
      }
      else
      {
        await videoPauseAt(fpos);
      } 
    }
  }

  Future<void> openVideoFile(bool ispubliclib,String vfilename)
  async
  {
    if(osname=="android"||osname=="ios")
    {
      String fileaddr = 
        configFile.serveraddr+configFile.apikey+"/"+vfilename;
      if(ispubliclib)
      {
        fileaddr = 
          configFile.serveraddr+configFile.publickey+"/"+vfilename;
      }
      else
      {
        fileaddr = 
          configFile.serveraddr+configFile.apikey+"/"+vfilename;
      }
      BetterPlayerDataSource bpDataSourceHolder = 
      BetterPlayerDataSource
      (
          BetterPlayerDataSourceType.network,
          configFile.serveraddr+configFile.publickey+"/placeholder.mp3",
      );
      BetterPlayerDataSource bpDataSource = 
      BetterPlayerDataSource
      (
          BetterPlayerDataSourceType.network,
          fileaddr,
      );
      try
      {
        await bpcontroller.setupDataSource(bpDataSourceHolder);
        //bpcontroller.toggleFullScreen();
        await bpcontroller.clearCache();
        await bpcontroller.setupDataSource(bpDataSource);
        //bpcontroller.setResolution(fileaddr);
        //await bpcontroller.disablePictureInPicture();
      }
      catch(e)
      {
        bpDataSource = 
        BetterPlayerDataSource
        (
          BetterPlayerDataSourceType.network,
          configFile.serveraddr+configFile.publickey+"/placeholder.mp3",
        );
        await bpcontroller.setupDataSource(bpDataSource);
      }
      bpnormalspeed = bpcontroller.videoPlayerController!.value.speed;
    }
    else
    {
      String fileaddr = 
        configFile.serveraddr+configFile.apikey+"/"+vfilename;
      if(ispubliclib)
      {
        fileaddr = 
          configFile.serveraddr+configFile.publickey+"/"+vfilename;
      }
      else
      {
        fileaddr = 
          configFile.serveraddr+configFile.apikey+"/"+vfilename;
      }

/*
      Directory? dir;
      try
      {
        dir = await getDownloadsDirectory();
      } 
      catch(e)
      {
        dir = null;
      }
      Directory d = Directory('/storage/emulated/0/');
      if(osname=='linux')
      {
        d = dir==null?Directory('~/Downloads/'):dir;
      }
      else if(osname=='windows')
      {
        d = dir==null?Directory('C:\\'):dir;
      }
      else if(osname=='macos')
      {
        d = dir==null?Directory('~/Downloads/'):dir;
      }
      Directory(d.path+"/temp").createSync();
      if(!await File(d.path+"/temp/"+vfilename).exists())
      {
        await Flowder.download(
        fileaddr,
        DownloaderUtils(
        progressCallback: 
        (current, total) 
        {
          //double progress = (current / total) * 100;
          //print('Downloading: $progress %');
        },
        file: File(d.path+"/temp/"+vfilename),
        progress: ProgressImplementation(),
        onDone: ()
        async
        {        
        },
        deleteOnCancel: true,
      )
      );
      }
*/

      vlcplayer.open
      (
        Media.network(fileaddr,timeout: Duration(seconds: 60)),
        //Media.file(File(d.path+"/temp/"+vfilename),),
        autoStart: true,
      );
      //vlccommands.add("pause|");
      sleep(Duration(milliseconds: 100));
    }
  }

  Future<void> videoPauseAt(int millisecinblock)
  async
  {
    if(osname=="android"||osname=="ios")
    {
      forceisplayingfalse = true;
      await bpcontroller.play();
      await bpcontroller.seekTo(Duration(milliseconds:millisecinblock));
      await bpcontroller.pause();
      forceisplayingfalse = false;
    }
    else
    {
      //vlccommands.add("seek|"+millisecinblock.toString());
      //vlccommands.add("pause|");
      vlcplayer.seek(Duration(milliseconds:millisecinblock-100));
      vlcplayer.play();
      sleep(Duration(milliseconds: 100));
      vlcplayer.pause();
    }
  }

  Future<void> videoSeekTo(int milli)
  async
  {
    if(osname=="android"||osname=="ios")
    {
      await bpcontroller.seekTo(Duration(milliseconds:milli));
    }
    else
    {
      vlcplayer.seek(Duration(seconds: milli));
      //vlcplayer.pause();
    }
  }

  Future<void> videoForward()
  async
  {
    if(osname=="android"||osname=="ios")
    {
      if(isVideoPlaying())
      {
        await bpcontroller.seekTo(currentrawpos+Duration(milliseconds:fastforwardstepmilli));
      }
      else
      {
        forceisplayingfalse = true;
        await bpcontroller.play();
        await bpcontroller.seekTo(currentrawpos+Duration(milliseconds:fastforwardstepmilli));
        await bpcontroller.pause();
        forceisplayingfalse = false;
      }
    }
    else
    {
      if(isVideoPlaying())
      {
        //vlccommands.add("seek|"+(currentrawpos+Duration(milliseconds:fastforwardstepmilli)).inMilliseconds.toString());
        vlcplayer.seek(currentrawpos+Duration(milliseconds:fastforwardstepmilli));
      }
      else
      {
        //forceisplayingfalse = true;
        //vlccommands.add("play|");

        //vlccommands.add("seek|"+(currentrawpos+Duration(milliseconds:fastforwardstepmilli)).inMilliseconds.toString());
        //vlccommands.add("pause|");

        //forceisplayingfalse = false;

        vlcplayer.seek(currentrawpos+Duration(milliseconds:fastforwardstepmilli));
      }
    }
  }

  Future<void> videoSetFastForward()
  async
  {
    if(osname=="android"||osname=="ios")
    {
      await bpcontroller.setSpeed(bpnormalspeed+0.5);
    }
    else
    {
      vlcplayer.setRate(bpnormalspeed+0.5);
    }
  }

  Future<void> videoSetNormalSpeed()
  async
  {
    if(osname=="android"||osname=="ios")
    {
      await bpcontroller.setSpeed(bpnormalspeed);
    }
    else
    {
      vlcplayer.setRate(bpnormalspeed);
    }
  }

  Future<void> videoPlayCurrent()
  async
  {
    if(osname=="android"||osname=="ios")
    {
      await bpcontroller.play();
    }
    else
    {
      vlcplayer.play();
    }
  }

  Future<void> videoPauseCurrent()
  async
  {
    if(osname=="android"||osname=="ios")
    {
      await bpcontroller.pause();
    }
    else
    {
      vlcplayer.pause();
    }
  }

  Future<void> videoPauseToCurrentBlockStart()
  async
  {
    if(osname=="android"||osname=="ios")
    {
      await bpcontroller.play();
      await bpcontroller.seekTo(vlu.vls.videolayers[taplayeridx].videoblocks[tapblockidx].filestartpos);
      await bpcontroller.pause();
    }
    else
    {
      //vlccommands.add("seek|"+(vlu.vls.videolayers[taplayeridx].videoblocks[tapblockidx].filestartpos).inMilliseconds.toString());
      //vlccommands.add("pause|");
      vlcplayer.seek(vlu.vls.videolayers[taplayeridx].videoblocks[tapblockidx].filestartpos);
    }
  }

  Future<void> videoPauseToCurrentBlockEnd()
  async
  {
    if(osname=="android"||osname=="ios")
    {
      //await bpcontroller.play();
      await bpcontroller.seekTo(vlu.vls.videolayers[taplayeridx].videoblocks[tapblockidx].filestartpos+vlu.vls.videolayers[taplayeridx].videoblocks[tapblockidx].blocklength);
      await bpcontroller.pause();
    }
    else
    {
      //vlccommands.add("seek|"+(vlu.vls.videolayers[taplayeridx].videoblocks[tapblockidx].filestartpos+vlu.vls.videolayers[taplayeridx].videoblocks[tapblockidx].blocklength).inMilliseconds.toString());
      //vlccommands.add("pause|");
      vlcplayer.seek(Duration(milliseconds: (vlu.vls.videolayers[taplayeridx].videoblocks[tapblockidx].filestartpos+vlu.vls.videolayers[taplayeridx].videoblocks[tapblockidx].blocklength).inMilliseconds-100));
    }
  }

  bool isVideoPlaying()
  {
    if(osname=="android"||osname=="ios")
    {
      if(forceisplayingfalse)
      {
        return false;
      }
      String brst = bpcontroller.isPlaying().toString();
      if(brst=="true")
      {
        return true;
      }
      else
      {
        return false;
      }
    }
    else
    {
      if(forceisplayingfalse)
      {
        return false;
      }
      String brst = vlcisplaying.toString();
      if(brst=="true")
      {
        return true;
      }
      else
      {
        return false;
      }


    }
  }

  int getCurrentMillinBlockFile(int layeridx,int blockidx)
  {
    int fromstamp = vlu.vls.videolayers[layeridx].videoblocks[blockidx].fromstamp.inMilliseconds;
    int blockposmilli = currentposinmilli.toInt()-fromstamp;
    int filestartpos = vlu.vls.videolayers[layeridx].videoblocks[blockidx].filestartpos.inMilliseconds;
    int filepos = filestartpos + blockposmilli;
    return filepos;
  }

////////////////////////////////////////////////////////////////////////////////
/// config functions
/// ////////////////////////////////////////////////////////////////////////////

  Future<String> get _localPath
  async
  {
    final directory = await getApplicationDocumentsDirectory();
    print(directory.path);
    return directory.path;
  }

  Future<File> get _localConfig
  async 
  {
    final path = await _localPath;
    return File('$path/$configfilename');
  }

  Future<String> writeCfg()
  async
  {
    final file = await _localConfig;
    String encodedstr = jsonEncode(configFile); 
    file.writeAsString(encodedstr);
    return file.path;
  }

  Future<String> readCfg()
  async
  {
    try 
    {
      final file = await _localConfig;
      final contents = await file.readAsString();
      Map mapcf = jsonDecode(contents);
      configFile = ConfigFile.fromJson(mapcf);
      return jsonEncode(configFile);
    } 
    catch (e)
    {
      return '';
      //return e.toString();
    }
  }

  MaterialColor color1({int colorcase = 0})
  {
    switch (colorcase) 
    {
      case 1: //main color
        return colorFromARGB(255,44,43,66);
        //break;
      case 2: //seperator color
        return colorFromARGB(64,54,93,206);
        //break;
      case 3:
        return colorFromARGB(255,79,14,136);
        //break;        
      default:
        return colorFromARGB(255,54,123,236);
        //break;
    }
    
  }

  Color color2({int colorcase = 0})
  {
    switch (colorcase) 
    {
      case 1: //folder color
        return Color.fromARGB(255,54,123,236);
        //break;
      case 2: //ruler short index color
        return Color.fromARGB(255,118,165,248);
        //break;
      case 3: //ruler long index color
        return Color.fromARGB(255,78,105,148);
        //break;
      case 4: //ruler text color
        return Color.fromARGB(255,178,175,198);
        //break;
      case 5: //video position color
        return Color.fromARGB(200,245,10,120);
        //break;
      case 6: //tab class title color
        return Color.fromARGB(64,54,93,206);
        //break;
      case 7: //music layer color
        return Color.fromARGB(180,215,103,100);
        //break;
      case 8: //default chromakey color
        return Color.fromARGB(255,117,254,153);
        //break;
      case 9: //selected video block color
        return Color.fromARGB(180,54,93,236);
        //break;
      case 10://placeholder block color
        return Color.fromARGB(80,14,14,34);
        //break;
      case 11://png block color
        return Color.fromARGB(180,84,54,90);
        //break;
      case 12://video block tip text color
        return Color.fromARGB(214,240,240,164);
        //break;
      case 13://vlc color
        return Color.fromARGB(255,44,43,66);
        //break;
      default:
        return Color.fromARGB(255,54,123,236);
        //break;
    }
    
  }
  MaterialColor colorFromARGB(int a,int r,int g,int b)
  {
    Map<int, Color> colormaker = 
    {50:Color.fromRGBO(r,g,b, .1),
    100:Color.fromRGBO(r,g,b, .2),
    200:Color.fromRGBO(r,g,b, .3),
    300:Color.fromRGBO(r,g,b, .4),
    400:Color.fromRGBO(r,g,b, .5),
    500:Color.fromRGBO(r,g,b, .6),
    600:Color.fromRGBO(r,g,b, .7),
    700:Color.fromRGBO(r,g,b, .8),
    800:Color.fromRGBO(r,g,b, .9),
    900:Color.fromRGBO(r,g,b, 1),};
    int hexargb = a<<24 | r<<16 | g<<8 | b;
    return MaterialColor(hexargb, colormaker);
  }

  MaterialColor colorFromString(String cstr)
  {
    Color cc = rgbstr2color(cstr);
    return colorFromARGB(255,cc.red,cc.green,cc.blue);
  }

  Color rgbstr2color(String rgbstr)
  {
    String rgb = rgbstr.replaceAll("[", "").replaceAll("]", "").replaceAll(" ", "").replaceAll("(", "").replaceAll(")", "");
    try
    {
      List<String> cc = rgb.split(",");
      int red = int.parse(cc[0]);
      int green = int.parse(cc[1]);
      int blue = int.parse(cc[2]);
      Color rst = Color.fromARGB(255, red, green, blue);
      return rst;
    }
    catch(e)
    {
      return Color(0x00000000);
    }
  }

////////////////////////////////////////////////////////////////////////////////
/// tools functions
/// ////////////////////////////////////////////////////////////////////////////

  String timestrFromDuration(Duration dr)
  {
    String rst='';
    rst = timestrFromMillisec(dr.inMilliseconds);
    return rst;
  }

  String timestrFromMillisec(int milli)
  {
    String finalstr = "00:00:00.000";
    try 
    {
        int millisec=milli.toInt();
        int hour = (millisec/3600000).floor();
        int minute = ((millisec/60000).floor())%60;
        int sec = ((millisec/1000).floor())%60;
        millisec = millisec%1000;
        finalstr = sprintf('%02d:%02d:%02d.%03d', [hour,minute,sec,millisec]);
    } 
    catch (e) 
    {
      return "00:00:00.000";
    }
    return finalstr;
  }

  int millisecFromTimestr(String timestr)
  {
    int totalmillisec = 0;
    try 
    {
        List<String> strparts = timestr.split(":");
        int hour = int.parse(strparts[0]);
        int minute = int.parse(strparts[1]);
        String secand = strparts[2];
        List<String> strparts2 = secand.split(".");
        int sec = int.parse(strparts2[0]);
        int millisec = 0;
        if(strparts2[1].length==3)
        {
          millisec = int.parse(strparts2[1]);
        }
        else if(strparts2[1].length==2)
        {
          millisec = int.parse(strparts2[1])*10;
        }
        else if(strparts2[1].length==1)
        {
          millisec = int.parse(strparts2[1])*100;
        }
        else if(strparts2[1].length==6)
        {
          millisec = (int.parse(strparts2[1])/1000).floor();
        }
        else
        {
          millisec = 0;
        }
        totalmillisec = millisec+sec*1000+minute*60000+hour*3600000;
    } 
    catch (e) 
    {
      return 0;
    }
    return totalmillisec;
  }

  int intFromRandom(int maxv)
  {
    randomseed = DateTime.now().microsecond + DateTime.now().millisecond;
    randomi = Random(randomseed).nextInt(maxv);
    return randomi;
  }

  String stringFromRandom()
  {
    testrandom1 = '';
    for(int i=0;i<16;i++)
    {
      testrandom1 += intFromRandom(10).toString();
    }
    return testrandom1;
  }

  Future<String> jsonRawPostback(String urlstring,String poststring)
  async
  {
    String rst='';
    var url = Uri.parse(urlstring);
    var response = await http.post(
    url, 
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      
      },
    body: jsonEncode(<String, String>{
      'apikey': encodeDES3CBC(configFile.apikey),
      'content':poststring,
    }),);
    if(response.statusCode!=200)
    {
      rst = 'error';
    }
    else
    {
      rst = response.body;
    }
    return rst;
  }

  Future<String> jsonPostback(String urlstring,String poststring)
  async
  {
    String rst='';
    if(configFile.serveraddr.length<2)
    {
      await readCfg();
    }
    var url = Uri.parse(configFile.serveraddr+urlstring+'?key='+encodeDES3CBC(configFile.apikey));
    var response = await http.post(
    url, 
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      
      },
    body: jsonEncode(<String, String>{
      'apikey': encodeDES3CBC(configFile.apikey),
      'content':poststring,
    }),);
    //print('Response status: ${response.statusCode}');
    //print('Response body: ${response.body}');
    if(response.statusCode!=200)
    {
      rst = 'error';
    }
    else
    {
      rst = response.body;
    }
    return rst;
  }

  Future<String> uploadmp4file(String urlstring,File datafile,String targetname,String targetdesc)
  async 
  {
    String rst='';
    if(configFile.serveraddr.length<2)
    {
      await readCfg();
    }
    if(osname=='android'||osname=='ios')
    {
      var status = await Permission.storage.status;
      if(!status.isGranted)
      {
        await Permission.storage.request();
      }
    }
    var stream  = new http.ByteStream(datafile.openRead()); 
    stream.cast();
    var length = await datafile.length();
    var uri = Uri.parse(configFile.serveraddr+urlstring+'?key='+encodeDES3CBC(configFile.apikey)
    +'&desc='+Uri.encodeComponent(targetdesc));
    var request = new http.MultipartRequest("POST", uri);
    var multipartFile = new http.MultipartFile('file', stream, length,
          filename: targetname+'.mp4');
          //contentType: new MediaType('image', 'png'));
    request.files.add(multipartFile);
    var response = await request.send();
    //print(response.statusCode);
    String respStr = await response.stream.bytesToString();
    /*
    response.stream.transform(utf8.decoder).listen
    (
      (value) 
      {
        print(value);
        rst += value.trim();
      }
    );
    if(response.statusCode!=200)
    {
      rst += 'failed';
      print(response.statusCode);
    }
    else
    {
      //rst += 'done';
    }
    */
    //print(rst);
    rst+=respStr;
    return rst;
  }

  Future<String> uploadmp3file(String urlstring,File datafile,String targetname,String targetdesc)
  async 
  {
    String rst='';
    if(configFile.serveraddr.length<2)
    {
      await readCfg();
    }
    if(osname=='android'||osname=='ios')
    {
      var status = await Permission.storage.status;
      if(!status.isGranted)
      {
        await Permission.storage.request();
      }
    }
    var stream  = new http.ByteStream(datafile.openRead()); 
    stream.cast();
    var length = await datafile.length();
    var uri = Uri.parse(configFile.serveraddr+urlstring+'?key='+encodeDES3CBC(configFile.apikey)
    +'&desc='+Uri.encodeComponent(targetdesc));
    var request = new http.MultipartRequest("POST", uri);
    var multipartFile = new http.MultipartFile('file', stream, length,
          filename: targetname+'.mp3');
          //contentType: new MediaType('image', 'png'));
    request.files.add(multipartFile);
    var response = await request.send();
    //print(response.statusCode);
    String respStr = await response.stream.bytesToString();
    rst+=respStr;
    return rst;
  }

  Future<String> uploadpngfile(String urlstring,File datafile,String targetname,String targetdesc)
  async 
  {
    String rst='';
    if(configFile.serveraddr.length<2)
    {
      await readCfg();
    }
    if(osname=='android'||osname=='ios')
    {
      var status = await Permission.storage.status;
      if(!status.isGranted)
      {
        await Permission.storage.request();
      }
    }
    var stream  = new http.ByteStream(datafile.openRead()); 
    stream.cast();
    var length = await datafile.length();
    var uri = Uri.parse(configFile.serveraddr+urlstring+'?key='+encodeDES3CBC(configFile.apikey)
    +'&desc='+Uri.encodeComponent(targetdesc));
    var request = new http.MultipartRequest("POST", uri);
    var multipartFile = new http.MultipartFile('file', stream, length,
          filename: targetname+'.png');
          //contentType: new MediaType('image', 'png'));
    request.files.add(multipartFile);
    var response = await request.send();
    //print(response.statusCode);
    String respStr = await response.stream.bytesToString();
    rst+=respStr;
    return rst;
  }

  String encodeDES3CBC(String message)
  {
      String result='';
      List<int> encrypted;
      //List<int> decrypted;
      List<int> iv = [7, 8, 1, 4, 5, 2, 3, 6];
      String key = datetimetokey(); // 24-byte
      DES3 des3CBC = DES3(key: key.codeUnits, mode: DESMode.CBC, iv: iv);
      encrypted = des3CBC.encrypt(message.codeUnits);
      //decrypted = des3CBC.decrypt(encrypted);
      /*
      print('Triple DES mode: CBC');
      print('encrypted: $encrypted');
      print('encrypted (hex): ${hex.encode(encrypted)}');
      print('encrypted (base64): ${base64.encode(encrypted)}');
      print('decrypted: $decrypted');
      print('decrypted (hex): ${hex.encode(decrypted)}');
      print('decrypted (utf8): ${utf8.decode(decrypted)}');
      */
      for(int i=0;i<encrypted.length;i++)
      {
        result += (encrypted[i].toString() + "-");
      }
      return result;
  }

  String decodeDES3CBC(String message)
  {
      String result='';
      List<int> encrypted = List.filled(0, 0, growable: true);
      List<int> decrypted;
      List<int> iv = [7, 8, 1, 4, 5, 2, 3, 6];
      String key = datetimetokey();
      DES3 des3CBC = DES3(key: key.codeUnits, mode: DESMode.CBC, iv: iv);

      List<String> mls = message.split("-");
      for(int i=0;i<mls.length;i++)
      {
        if(mls[i].length>0)
        {
          encrypted.add(int.parse(mls[i]));
        }
        
      }

      //encrypted = des3CBC.encrypt(message.codeUnits);
      decrypted = des3CBC.decrypt(encrypted);
      /*
      print('Triple DES mode: CBC');
      print('encrypted: $encrypted');
      print('encrypted (hex): ${hex.encode(encrypted)}');
      print('encrypted (base64): ${base64.encode(encrypted)}');
      print('decrypted: $decrypted');
      print('decrypted (hex): ${hex.encode(decrypted)}');
      print('decrypted (utf8): ${utf8.decode(decrypted)}');
      */
      result = utf8.decode(decrypted,allowMalformed: true);
      return result;
  }

  String decodeDES3CBC1minago(String message)
  {
      String result='';
      List<int> encrypted = List.filled(0, 0, growable: true);
      List<int> decrypted;
      List<int> iv = [7, 8, 1, 4, 5, 2, 3, 6];
      String key = formerdatetimetokey();
      DES3 des3CBC = DES3(key: key.codeUnits, mode: DESMode.CBC, iv: iv);

      List<String> mls = message.split("-");
      for(int i=0;i<mls.length;i++)
      {
        if(mls[i].length>0)
        {
          encrypted.add(int.parse(mls[i]));
        }
        
      }

      //encrypted = des3CBC.encrypt(message.codeUnits);
      decrypted = des3CBC.decrypt(encrypted);
      /*
      print('Triple DES mode: CBC');
      print('encrypted: $encrypted');
      print('encrypted (hex): ${hex.encode(encrypted)}');
      print('encrypted (base64): ${base64.encode(encrypted)}');
      print('decrypted: $decrypted');
      print('decrypted (hex): ${hex.encode(decrypted)}');
      print('decrypted (utf8): ${utf8.decode(decrypted)}');
      */
      result = utf8.decode(decrypted,allowMalformed: true);
      return result;
  }

  String datetimetokey()
  {
    String result='';
    int lkey = 24;
    List<int> key=List.filled(lkey, 32);
    int t = DateTime.now().millisecondsSinceEpoch~/60000;
    //print(t);
    String ts = t.toString();
    List<int> tls = ts.codeUnits;
    int keyidx = lkey-1;
    for(int j=0;j<3;j++)
    {
      for(int i=0;i<tls.length;i++)
      {
        key[keyidx]=tls[i];
        keyidx--;
        if(keyidx<0)keyidx=lkey-1;
      }
    }
    result = utf8.decode(key,allowMalformed: true);
    return result;
  }

  String formerdatetimetokey()
  {
    String result='';
    int lkey = 24;
    List<int> key=List.filled(lkey, 32);
    int t = (DateTime.now().millisecondsSinceEpoch~/60000)-1;
    String ts = t.toString();
    List<int> tls = ts.codeUnits;
    int keyidx = lkey-1;
    for(int j=0;j<3;j++)
    {
      for(int i=0;i<tls.length;i++)
      {
        key[keyidx]=tls[i];
        keyidx--;
        if(keyidx<0)keyidx=lkey-1;
      }
    }
    result = utf8.decode(key,allowMalformed: true);
    return result;
  }

  Duration parseDuration(String s) 
  {
    /*
    int hours = 0;
    int minutes = 0;
    int micros;
    List<String> parts = s.split(':');
    if (parts.length > 2) 
    {
      hours = int.parse(parts[parts.length - 3]);
    }
    if (parts.length > 1) 
    {
      minutes = int.parse(parts[parts.length - 2]);
    }
    micros = (double.parse(parts[parts.length - 1]) * 1000000).round();
    return Duration(hours: hours, minutes: minutes, microseconds: micros);
    */
    return Duration(milliseconds: millisecFromTimestr(s));
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

  Icon gettaskstatusicon(String statusstr)
  {
    switch (statusstr) 
    {
      case "processing":
        return Icon(Icons.hourglass_bottom);
      case "done":
        return Icon(Icons.domain_verification);
      case "stopped":
        return Icon(Icons.stop);
       
      default:
        return Icon(Icons.settings_backup_restore);
        
    }
  }

  Icon gettaskclassicon(String classstr)
  {
    switch (classstr) 
    {
      case "regular":
        return Icon(Icons.ondemand_video);
      case "backgroundmattingv2":
        return Icon(Icons.person_pin );
      case "freeformvideoinpainting":
        return Icon(Icons.video_camera_back );
      case "panopticdeeplab":
        return Icon(Icons.streetview );
      case "skyar":
        return Icon(Icons.cloud_circle );
      case "wav2lip":
        return Icon(Icons.record_voice_over );
        
      default:
        return Icon(Icons.settings_backup_restore);
        
    }
  }

  int blockpickergetidx(String picklabel)
  {
    for(int i=0;i<blockpicker.length;i++)
    {
      if(blockpicker[i].values.first==picklabel)
      {
        return i;
      }
    }
    return 0;
  }

}

////////////////////////////////////////////////////////////////////////////////
/// config file class
/// ////////////////////////////////////////////////////////////////////////////
class ConfigFile
{
  String apikey = '';
  String serveraddr = '';
  String publickey = '3mn.net-public-common';
  String videoaspect = '16:9';
  String finalwidth = '1920';
  String finalheight = '1080';

  ConfigFile();

  Map toJson() => 
  {
    'apikey': apikey,
    'serveraddr': serveraddr,
    'videoaspect': videoaspect,
    'finalwidth': finalwidth,
    'finalheight': finalheight,
  };

  ConfigFile.fromJson(Map json)
  {
    apikey=json['apikey'];
    serveraddr=json['serveraddr'];
    videoaspect=json['videoaspect'];
    finalwidth=json['finalwidth'];
    finalheight=json['finalheight'];
  }
}

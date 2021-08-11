// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'dart:io';
import 'package:sprintf/sprintf.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:dart_des/dart_des.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

PackData packData = PackData();
ConfigFile configFile = ConfigFile();

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
  int currentposinmilli = 0;                         //current video position in milliseconds
  String softwarever = '0.0.0.0';                       //this software version
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
  late ScrollController scs0;                           //video layers ruler scroll controller
  late Function mainsetstate;

  PackData();

////////////////////////////////////////////////////////////////////////////////
/// config functions
/// ////////////////////////////////////////////////////////////////////////////

  Future<String> get _localPath
  async
  {
    final directory = await getApplicationDocumentsDirectory();
    //print(directory.path);
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
        return Color.fromARGB(255,70,210,100);
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

  Future<String> jsonPostback(String urlstring,String poststring,String keystr)
  async
  {
    String rst='';
    if(configFile.serveraddr.length<2)
    {
      await readCfg();
    }
    var url = Uri.parse(configFile.serveraddr+urlstring+'?key='+encodeDES3CBC(keystr));
    var response = await http.post(
    url, 
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      
      },
    body: jsonEncode(<String, String>{
      'apikey': encodeDES3CBC(keystr),
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

  Future<String> jsonPostbackWithTaskid(String urlstring,String poststring,String keystr,String taskid,String taskdesc)
  async
  {
    String rst='';
    if(configFile.serveraddr.length<2)
    {
      await readCfg();
    }

    var url = Uri.parse(configFile.serveraddr+urlstring+'?key='+encodeDES3CBC(keystr)
    +'&desc='+Uri.encodeComponent(taskdesc)+'&taskid='+Uri.encodeComponent(taskid));
    
    var response = await http.post(
    url, 
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      
      },
    body: jsonEncode(<String, String>{
      'apikey': encodeDES3CBC(keystr),
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
        if(mls[i].isNotEmpty)
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
        if(mls[i].isNotEmpty)
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
      case "BackgroundMattingV2":
        return Icon(Icons.person_pin );
      case "Free-Form-Video-Inpainting":
        return Icon(Icons.video_camera_back );
      case "panoptic-deeplab":
        return Icon(Icons.streetview );
      case "SkyAR":
        return Icon(Icons.cloud_circle );
      case "Wav2Lip":
        return Icon(Icons.record_voice_over );
        
      default:
        return Icon(Icons.settings_backup_restore);
        
    }
  }

}

////////////////////////////////////////////////////////////////////////////////
/// config file class
/// ////////////////////////////////////////////////////////////////////////////
class ConfigFile
{
  String apikey = '';
  String serveraddr = 'http://127.0.0.1/';
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

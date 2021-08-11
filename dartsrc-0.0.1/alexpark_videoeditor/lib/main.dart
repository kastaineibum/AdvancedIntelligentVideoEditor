//import 'dart:async';
//import 'dart:math';
import 'package:flutter/material.dart';
import 'globals.dart' as globals;
import "package:os_detect/os_detect.dart" as Platform;
import 'package:flutter/services.dart';
import 'package:dart_vlc/dart_vlc.dart';
//import 'package:desktop_window/desktop_window.dart';
import 'mobilemain.dart';
import 'pcmain.dart';

void main() 
async
{
  //globals.packData.status1 = 'starting';
  globals.packData.osname = Platform.operatingSystem;
  globals.packData.osversion = Platform.operatingSystemVersion;

  if(Platform.isAndroid||Platform.isIOS)
  {
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations(
      [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight])
    .then(
      (_) 
      async
      {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom]);
        if(globals.configFile.serveraddr.length<2)
        {
          await globals.packData.readCfg();

        }
        globals.packData.videolinepercent = 0.5;
        globals.packData.titleheight = 20.0;
        globals.packData.rulerheight = 20.0;
        globals.packData.layeritemheight = 50.0;
        globals.packData.tabsize = 20.0;

        runApp(MobileMainApp());
      }
      );
    
  }
  else if(Platform.isWindows||Platform.isLinux||Platform.isMacOS)
  {
        if(globals.configFile.serveraddr.length<2)
        {
          await globals.packData.readCfg();

        }
        globals.packData.videolinepercent = 0.65;
        globals.packData.titleheight = 20.0;
        globals.packData.rulerheight = 20.0;
        globals.packData.layeritemheight = 50.0;
        globals.packData.tabsize = 20.0;

        DartVLC.initialize();

        runApp(PCMainApp());
        //sleep(Duration(seconds: 1));

  } 
  else if(Platform.isBrowser)
  {
    
  }
}

class ThisApp extends StatelessWidget 
{
  @override
  Widget build(BuildContext context) 
  {
    return MaterialApp(
      title: globals.packData.apptitle,
      theme: ThemeData(
        primarySwatch: globals.packData.colorFromARGB(255,79,14,136),
        buttonTheme: const ButtonThemeData
        (
          textTheme: ButtonTextTheme.primary,
        ),
      ),
      home: Homepage1(),
    );
  }
}

class Homepage1 extends StatefulWidget 
{
  @override
  _Homepage1State createState() => _Homepage1State();
}

class _Homepage1State extends State<Homepage1> 
{
  @override
  Widget build(BuildContext context) 
  {
    final size = MediaQuery.of(context).size;
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final width = size.width;
    final height = size.height;
    print('width is $width; height is $height; pixelRatio is $pixelRatio');

    return 
    Scaffold
    (

    );
  }
}
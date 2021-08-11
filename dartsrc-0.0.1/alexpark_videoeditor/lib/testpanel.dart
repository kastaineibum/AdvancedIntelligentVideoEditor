import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'videolayerstruct.dart';
import 'globals.dart' as globals;

class TestPanelApp extends StatelessWidget 
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
      home: TestPanel(),
    );
  }
}

class TestPanel extends StatefulWidget 
{
  @override
  _TestPanelState createState() => _TestPanelState();
}

class _TestPanelState extends State<TestPanel> 
{
  @override
  void initState() {
    super.initState();
    
  }

  @override
  Widget build(BuildContext context) 
  {
    return 
    SizedBox
    (
      width: globals.packData.optpanelwidth,
      height: globals.packData.videoheight,
      child:
      ListView
      (
        padding: EdgeInsets.all(0.0),
        children:
        [
          SizedBox(height: globals.packData.buttonheight+globals.packData.buttongap,child:
          Row
          (
          children:
          [
            ElevatedButton
            (
              onPressed: 
              ()
              async
              {
                String rst = 
                await globals.packData.jsonPostback('testpostjson.php','test content');
                print(rst);
              },
              child: 
              Text(AppLocalizations.of(context)!.testpostjson),
            ),
            SizedBox
                (
                  width: globals.packData.buttongaphrz,
                ),
            ElevatedButton
            (
              onPressed: 
              ()
              async
              {
                String rst = 
                await globals.packData.uploadmp4file
                (
                  'testuploadmp4.php',
                  File('/storage/emulated/0/Download/butterfly.mp4'),
                  'temp',
                  '-'
                );
                print(rst);
              },
              child: 
              Text(AppLocalizations.of(context)!.testpostfile),
            ),
            SizedBox
                (
                  width: globals.packData.buttongaphrz,
                ),
            ElevatedButton
            (
              onPressed: 
              ()
              async
              {
                globals.configFile.apikey='3mn.net-'
                +DateTime.now().millisecondsSinceEpoch.toString();
                String rst = 
                await globals.packData.writeCfg();
                print(rst);
              },
              child: 
              Text(AppLocalizations.of(context)!.testwriteconf),
            ),
            SizedBox
                (
                  width: globals.packData.buttongaphrz,
                ),
            ElevatedButton
            (
              onPressed: 
              ()
              async
              {
                String rst = 
                await globals.packData.readCfg();
                print(rst);
              },
              child: 
              Text(AppLocalizations.of(context)!.testreadconf),
            ),
          ]
          ),
          ),
          SizedBox(height: globals.packData.buttonheight+globals.packData.buttongap,child:
          Row
          (
          children:
          [
            ElevatedButton
            (
              onPressed: 
              ()
              async
              {
                String p = globals.configFile.serveraddr+'alexgetpic.php?key='+globals.packData.encodeDES3CBC(globals.configFile.apikey)
                            +'&file=1623675616407.mp4';
                Image.network(p);
                
              },
              child: 
              Text(AppLocalizations.of(context)!.testimagenetwork),
            ),
            SizedBox
                (
                  width: globals.packData.buttongaphrz,
                ),
            ElevatedButton
            (
              onPressed: 
              ()
              async
              {
                  await vlu.createFirstStruct();
                  await vlu.preparePosPics();
                  vlu.sortLayersZ();
                  //vlu.createDemoStruct();
                
              },
              child: 
              Text(AppLocalizations.of(context)!.loadtestvideo),
            ),
            SizedBox
                (
                  width: globals.packData.buttongaphrz,
                ),
          ]
          ),
          ),
        ]
      ),
    );
  }
}
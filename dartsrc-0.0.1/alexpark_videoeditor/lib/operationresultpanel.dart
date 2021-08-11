import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:path_provider/path_provider.dart';
//import 'package:transparent_image/transparent_image.dart';
import 'package:quiver/async.dart';
import 'package:permission_handler/permission_handler.dart';
//import 'package:flutter_image/flutter_image.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flowder/flowder.dart';
import 'globals.dart' as globals;
import 'videolayerstruct.dart';

class OperationResultPanelApp extends StatelessWidget 
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
      home: OperationResultPanel(),
    );
  }
}

class OperationResultPanel extends StatefulWidget 
{
  @override
  _OperationResultPanelState createState() => _OperationResultPanelState();
}

class _OperationResultPanelState extends State<OperationResultPanel> 
{
  final _formKey = GlobalKey<FormState>();
  final List<String> taskids = List.filled(0, "",growable: true);
  final List<String> finallength = List.filled(0, "",growable: true);
  final List<String> taskdesc = List.filled(0, "",growable: true);
  final List<String> taskclass = List.filled(0, "",growable: true);
  final List<String> taskstatus = List.filled(0, "",growable: true);
  final List<String> resultfile = List.filled(0, "",growable: true);
  int updateflg = 0;
  String fltstr = "";

  int _start = 100;
  //int _current = 100;
  void startTimer(BuildContext context) 
  {
    CountdownTimer countDownTimer = new CountdownTimer
    (
      new Duration(milliseconds: _start),
      new Duration(milliseconds: 50),
    );

    var sub = countDownTimer.listen(null);
    sub.onData((duration) 
    {
      setState
      (
        () 
        { 
          //_current = _start - duration.elapsed.inMilliseconds; 
          //print('$_current');
        }
      );
    });
    sub.onDone(() 
    {
      //print('$_current');
      rebuildAllChildren(context);
      sub.cancel();
    });
  }

  Future updateLists(BuildContext context)
  async
  {
    try
    {
      taskids.clear();
      finallength.clear();
      taskdesc.clear();
      taskclass.clear();
      taskstatus.clear();
      resultfile.clear();
      String vfs = (await globals.packData.jsonPostback("alexgettasks.php", "")).trim();
      List<String> libitems = vfs.split("|");
      for(int i=0;i<libitems.length;i++)
      {
        if(libitems[i].length>2)
        {
          List<String> its = libitems[i].trim().split("^");
          taskids.add(its[0].trim());
          finallength.add(its[5].trim());
          taskdesc.add(its[2].trim());
          taskclass.add(its[1].trim());
          taskstatus.add(its[3].trim());
          resultfile.add(its[4].trim());
        }
      }
    }
    catch(e)
    {
      print(e.toString());
    }
    startTimer(context);
  }

  Future updateLists2(BuildContext context,String filterstr)
  async
  {
    try
    {
      taskids.clear();
      finallength.clear();
      taskdesc.clear();
      taskclass.clear();
      taskstatus.clear();
      resultfile.clear();
      String vfs = (await globals.packData.jsonPostback("alexgettasks.php", "")).trim();
      List<String> libitems = vfs.split("|");
      for(int i=0;i<libitems.length;i++)
      {
        if(libitems[i].length>2)
        {
          List<String> its = libitems[i].trim().split("^");
          if(its[2].trim().contains(filterstr))
          {
          taskids.add(its[0].trim());
          finallength.add(its[5].trim());
          taskdesc.add(its[2].trim());
          taskclass.add(its[1].trim());
          taskstatus.add(its[3].trim());
          resultfile.add(its[4].trim());
          }
        }
      }
    }
    catch(e)
    {
      print(e.toString());
    }
    startTimer(context);
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

  void removetaskpressed(BuildContext context,String taskid)
  {
  showDialog
  (
    context: context,
    builder: (BuildContext context)
    {
      return AlertDialog
      (
        title: Text(AppLocalizations.of(context)!.choosedialog),
        content: Text(AppLocalizations.of(context)!.suretoremove),
        actions: <Widget>
        [
          ElevatedButton
          (
            child: Text(AppLocalizations.of(context)!.yes),
            onPressed: () 
            async
            {
              await globals.packData.jsonPostback("alexremovetask.php", taskid);
              await updateLists(context);
              Navigator.of(context).pop();
            },
          ),
 
          ElevatedButton
          (
            child: Text(AppLocalizations.of(context)!.no),
            onPressed: () 
            {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
  }


  Future<void> downloadstruct(BuildContext context,String taskid)
  async
  {
    showDialog
    (
      context: context,
      barrierDismissible: false,
      builder: 
      (BuildContext context) 
      {
        return Center(child: CircularProgressIndicator(),);
      }
    );
    String layercnt = (await globals.packData.jsonPostback("alexgetstructlayercnt.php", taskid)).trim();
    String rst = (await globals.packData.jsonPostback("alexgettaskstruct.php", taskid)).trim();
    int lcnt = int.parse(layercnt);
    vlu.vls.videolayers.clear();
    for(int i=0;i<lcnt;i++)
    {
      vlu.vli = VideoLayerItem(vlu.getNewLayerid());
      vlu.vls.videolayers.add(vlu.vli);
    }
    List<String> structrows=rst.split('|');
    List<String> structits = List.filled(0, "",growable: true);
    for(int i=0;i<structrows.length;i++)
    {
      if(structrows[i].length>29)
      {
      structits = structrows[i].split('^');
      VideoLayerBlock vlbb = new VideoLayerBlock(int.parse(structits[1]));
      vlbb.blend = double.parse(structits[11]);
      vlbb.blockcolor = Color(int.parse(structits[8]));
      vlbb.blockid = int.parse(structits[1]);
      vlbb.blocklength = Duration(milliseconds: int.parse(structits[6]));
      vlbb.createstamp = DateTime.parse(structits[3]);
      vlbb.fileclass = structits[7];
      vlbb.filename = structits[2];
      vlbb.filestartpos = Duration(milliseconds: int.parse(structits[12]));
      vlbb.fromstamp = Duration(milliseconds: int.parse(structits[4]));
      if(structits[9].length>2)
      {
        vlbb.ispubliclib = structits[9].toLowerCase() == 'true';
      }
      else
      {
        vlbb.ispubliclib = int.parse(structits[9])!=0?true:false;
      }
      if(structits[17].length>2)
      {
        vlbb.resizeenable = structits[17].toLowerCase() == 'true';
      }
      else
      {
        vlbb.resizeenable = int.parse(structits[17])!=0?true:false;
      }
      vlbb.resizeheight = int.parse(structits[16]);
      vlbb.resizeleft = int.parse(structits[13]);
      vlbb.resizetop = int.parse(structits[14]);
      vlbb.resizewidth = int.parse(structits[15]);
      vlbb.respeed = double.parse(structits[18]);
      if(structits[19].length>2)
      {
        vlbb.respeedenable = structits[19].toLowerCase() == 'true';
      }
      else
      {
        vlbb.respeedenable = int.parse(structits[19])!=0?true:false;
      }
      vlbb.revolume = double.parse(structits[20]);
      if(structits[21].length>2)
      {
        vlbb.revolumeenable = structits[21].toLowerCase() == 'true';
      }
      else
      {
        vlbb.revolumeenable = int.parse(structits[21])!=0?true:false;
      }
      vlbb.similarity = double.parse(structits[10]);
      vlbb.tostamp = Duration(milliseconds: int.parse(structits[5]));
      vlu.vls.videolayers[int.parse(structits[25])].videoblocks.add(vlbb);
      vlu.vls.videolayers[int.parse(structits[25])].layerid = int.parse(structits[26]);
      vlu.vls.videolayers[int.parse(structits[25])].createstamp = DateTime.parse(structits[22]);
      vlu.vls.videolayers[int.parse(structits[25])].zindex = int.parse(structits[23]);
      vlu.vls.videolayers[int.parse(structits[25])].layerlength = Duration(milliseconds: int.parse(structits[24]));
      vlu.vls.createstamp = DateTime.parse(structits[27]);
      vlu.vls.scalefactor = double.parse(structits[28]);
      }
    }

    Navigator.pop(context);
    globals.packData.mainsetstate.call();
  }

  Future<void> downloadfile(BuildContext context,String taskid,int index)
  async
  {
    if(globals.packData.osname=="android"||globals.packData.osname=="ios")
    {
                   var status = await Permission.storage.status;
                    if(!status.isGranted)
                    {
                      await Permission.storage.request();
                    }
    }
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
                    if(globals.packData.osname=='android')
                    {
                      d = dir==null?Directory('/storage/emulated/0/'):dir;
                    }
                    else if(globals.packData.osname=='ios')
                    {
                      d = dir==null?Directory('/private/var/mobile/Media/'):dir;
                    }
                    else if(globals.packData.osname=='linux')
                    {
                      d = dir==null?Directory('~/Downloads/'):dir;
                    }
                    else if(globals.packData.osname=='windows')
                    {
                      d = dir==null?Directory('C:\\'):dir;
                    }
                    else if(globals.packData.osname=='macos')
                    {
                      d = dir==null?Directory('~/Downloads/'):dir;
                    }

                    String? path = await FilesystemPicker.open
                    (
                      title: AppLocalizations.of(context)!.selectfolder,
                      context: context,
                      rootDirectory: d,
                      fsType: FilesystemType.folder,
                      pickText: AppLocalizations.of(context)!.savefiletofolder,
                      folderIconColor: globals.packData.color2(colorcase:1),
                    );

    if(path!=null)
    {
    showDialog
    (
      context: context,
      barrierDismissible: false,
      builder: 
      (BuildContext context) 
      {
        return Center(child: CircularProgressIndicator(),);
      }
    );

    await Flowder.download(
      globals.configFile.serveraddr+'alexgetmp4.php?key='+globals.packData.encodeDES3CBC(globals.configFile.apikey)
      +'&file='+resultfile[index],
      DownloaderUtils(
      progressCallback: 
      (current, total) 
      {
        //double progress = (current / total) * 100;
        //print('Downloading: $progress %');
      },
      file: File(path+"/"+resultfile[index]),
      progress: ProgressImplementation(),
      onDone: ()
      async
      {
        //print('Download done');
        Navigator.pop(context);
        await showDialog
        (
        context: context,
        builder: (_) => new 
        AlertDialog
        (
          title: new Text(AppLocalizations.of(context)!.tip),
          content: new Text(AppLocalizations.of(context)!.downloadover),
          actions: <Widget>
          [
            ElevatedButton
            (
              child: Text(AppLocalizations.of(context)!.ok),
              onPressed: 
              () 
              {
                Navigator.of(context).pop();
              },
            )
          ],
        )
        );
      },
      deleteOnCancel: true,
    )
    );

    
    }
  }

  Future<void> stoptask(BuildContext context,String taskid)
  async
  {
  showDialog
  (
    context: context,
    builder: (BuildContext context)
    {
      return AlertDialog
      (
        title: Text(AppLocalizations.of(context)!.choosedialog),
        content: Text(AppLocalizations.of(context)!.suretostop),
        actions: <Widget>
        [
          ElevatedButton
          (
            child: Text(AppLocalizations.of(context)!.yes),
            onPressed: () 
            async
            {
              await globals.packData.jsonPostback("alexmarkstoptask.php", taskid);
              await updateLists(context);
              Navigator.of(context).pop();
            },
          ),
 
          ElevatedButton
          (
            child: Text(AppLocalizations.of(context)!.no),
            onPressed: () 
            {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
  }

  Future<void> starttask(BuildContext context,String taskid)
  async
  {
  showDialog
  (
    context: context,
    builder: (BuildContext context)
    {
      return AlertDialog
      (
        title: Text(AppLocalizations.of(context)!.choosedialog),
        content: Text(AppLocalizations.of(context)!.suretostart),
        actions: <Widget>
        [
          ElevatedButton
          (
            child: Text(AppLocalizations.of(context)!.yes),
            onPressed: () 
            async
            {
              await globals.packData.jsonPostback("alexmarkstarttask.php", taskid);
              await updateLists(context);
              Navigator.of(context).pop();
            },
          ),
 
          ElevatedButton
          (
            child: Text(AppLocalizations.of(context)!.no),
            onPressed: () 
            {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
  }

  @override
  void initState()
  {
    super.initState();
    updateflg = 1;
  }

  @override
  Widget build(BuildContext context) 
  {
    if(updateflg==1)
    {
      updateflg = 0;
      updateLists(context);
    }
    return 
    SizedBox
    (
      width: globals.packData.optpanelwidth,
      height: globals.packData.videoheight-globals.packData.titleheight,
      child:
      Align
      (
        alignment: Alignment.bottomCenter, 
        child: 
        Form
        (
        key: _formKey,
        child: 
        Column
        (
          children:
          [
            SizedBox
            (
              width: globals.packData.optpanelwidth,
              height: globals.packData.videoheight-globals.packData.titleheight-globals.packData.buttonheight*2-globals.packData.buttongap,
              child:
                ListView.builder
                (
                  reverse: true,
                  padding: const EdgeInsets.all(0.0),
                  itemCount: taskids.length,
                  itemBuilder: (BuildContext context, int index) 
                  {
                    Icon statusicon = globals.packData.gettaskstatusicon(taskstatus[index]);
                    Icon classicon = globals.packData.gettaskclassicon(taskclass[index]);
                    return Container
                    (
                      padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                      height: 50,
                      child: 
                      Row
                      (
                        children: 
                        [
                          Container(
                          padding: const EdgeInsets.all(0.0),
                          width: 40.0, // you can adjust the width as you need
                          child: IconButton
                          (
                            tooltip: AppLocalizations.of(context)!.delete,
                            splashRadius: 20.0,
                            icon: Icon(Icons.delete_forever),
                            onPressed: () => removetaskpressed(context,taskids[index]),
                          ),
                          ),
                          classicon,
                          SizedBox(width: 10,),
                          SizedBox
                          (
                            height: 40,
                            width: globals.packData.optpanelwidth-200,
                            child: 
                              Column
                              (
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: 
                                [
                                  SizedBox(height: 2,),
                                  Text
                                  (
                                    AppLocalizations.of(context)!.videotimelength+globals.packData.timestrFromMillisec(int.parse(finallength[index])),
                                    style: TextStyle(fontSize: 10),
                                  ),
                                  SizedBox(height: 5,),
                                  Text
                                  (
                                    AppLocalizations.of(context)!.videodescription+((taskdesc[index].length>15)?taskdesc[index].substring(0,15):taskdesc[index]),
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ],
                              ),
                          ),
                          statusicon,
                          SizedBox(width: 5,),
                          /* 
                          Container
                          (
                          padding: const EdgeInsets.all(0.0),
                          width: 20.0, // you can adjust the width as you need
                          child: 
                            //stopbutton(taskstatus,index),
                          ),
                          */
                          Container
                          (
                          padding: const EdgeInsets.all(0.0),
                          width: 40.0, // you can adjust the width as you need
                          child: 
                            downloadbutton(taskstatus,index),
                          ),
                          Container(
                          padding: const EdgeInsets.all(0.0),
                          width: 40.0, // you can adjust the width as you need
                          child: IconButton
                          (
                            tooltip: AppLocalizations.of(context)!.import2layer,
                            padding: EdgeInsets.all(0),
                            splashRadius: 20.0,
                            icon: Icon(Icons.archive),
                            onPressed: ()async => await downloadstruct(context,taskids[index]),
                          ),
                          ),
                        ],
                      ),
                    );
                  }
                ),
            ),
            SizedBox(height: globals.packData.buttonheight*2+globals.packData.buttongap,child:
            Row
            (
              children:
              [
                SizedBox
                (
                  width: globals.packData.optpanelwidth-60.0,
                  child: 
                  TextFormField
            (
              //initialValue:'',
              onChanged:
              (text)
              {
                fltstr = text;
                if(text.isEmpty)updateLists(context);
              },
              decoration: 
              InputDecoration
              (
                contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                labelText: AppLocalizations.of(context)!.taskdescription,
                border: OutlineInputBorder
                (
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(),
                ),
              ),
              validator:
              (String? val) 
              {
                if(val==null||val.isEmpty) 
                {
                  return AppLocalizations.of(context)!.cannotempty;
                }
                else
                {
                  return null;
                }
              },
              keyboardType: TextInputType.text,
              style: TextStyle
              (
                fontSize: 12,
                //fontFamily: "Poppins",
              ),
            ),
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
                    final form = _formKey.currentState;
                    if(form!.validate())
                    {
                    }
                    else
                    {
                      return;
                    }
                    updateLists2(context, fltstr);
                  },
                  child: 
                  Text(AppLocalizations.of(context)!.search),
                ),
                
              ],
            ),
            ),
            
            
          ]
        ),
        ),
      ),

    );
  }

  Widget stopbutton(List<String> taskstatus,int index)
  {
    if(taskstatus[index]=="processing")
    {
      return IconButton
      (
        tooltip: AppLocalizations.of(context)!.stopprocessing,
        padding: EdgeInsets.all(0),
        splashRadius: 20.0,
        icon: Icon(Icons.stop),
        onPressed: () => stoptask(context,taskids[index]),
      );
    }
    else if(taskstatus[index]=="stopped")
    {
      return IconButton
      (
        tooltip: AppLocalizations.of(context)!.startprocessing,
        padding: EdgeInsets.all(0),
        splashRadius: 20.0,
        icon: Icon(Icons.play_circle),
        onPressed: () => starttask(context,taskids[index]),
      );
    }
    else
    {
      return SizedBox(width:20,);
    }
  }

  Widget downloadbutton(List<String> taskstatus,int index)
  {
    if(taskstatus[index]=="done")
    {
      return IconButton
      (
        tooltip: AppLocalizations.of(context)!.downloadfile,
        padding: EdgeInsets.all(0),
        splashRadius: 20.0,
        icon: Icon(Icons.move_to_inbox),
        onPressed: ()async => await downloadfile(context,taskids[index],index),
      );
    }
    else
    {
      return SizedBox(width:20,);
    }
  }
}
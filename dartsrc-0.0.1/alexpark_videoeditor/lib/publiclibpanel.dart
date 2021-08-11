import 'dart:async';
import 'dart:io';
import 'package:flowder/flowder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:path_provider/path_provider.dart';
//import 'package:transparent_image/transparent_image.dart';
import 'package:quiver/async.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:input_slider/input_slider.dart';
//import 'package:flutter_image/flutter_image.dart';
import 'package:extended_image/extended_image.dart';
import 'globals.dart' as globals;
import 'videolayerstruct.dart';

class PublicLibPanelApp extends StatelessWidget 
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
      home: PublicLibPanel(),
    );
  }
}

class PublicLibPanel extends StatefulWidget 
{
  @override
  _PublicLibPanelState createState() => _PublicLibPanelState();
}

class _PublicLibPanelState extends State<PublicLibPanel> 
{
  final _formKey = GlobalKey<FormState>();
  final List<String> libfiles = List.filled(0, "",growable: true);
  final List<String> filestimelength = List.filled(0, "",growable: true);
  final List<String> filesdesc = List.filled(0, "",growable: true);
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
      libfiles.clear();
      filestimelength.clear();
      filesdesc.clear();
      String vfs = (await globals.packData.jsonPostback("alexgetvideofilespublic.php", "")).trim();
      List<String> libitems = vfs.split("|");
      for(int i=0;i<libitems.length;i++)
      {
        if(libitems[i].length>2)
        {
          List<String> its = libitems[i].trim().split("^");
          libfiles.add(its[0].trim());
          filestimelength.add(its[1].trim());
          filesdesc.add(its[2].trim());
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
      libfiles.clear();
      filestimelength.clear();
      filesdesc.clear();
      String vfs = (await globals.packData.jsonPostback("alexgetvideofilespublic.php", "")).trim();
      List<String> libitems = vfs.split("|");
      for(int i=0;i<libitems.length;i++)
      {
        if(libitems[i].length>2)
        {
          List<String> its = libitems[i].trim().split("^");
          if(its[2].trim().contains(filterstr))
          {
            libfiles.add(its[0].trim());
            filestimelength.add(its[1].trim());
            filesdesc.add(its[2].trim());
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

  void removefilepressed(BuildContext context,String removefilename)
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
              await globals.packData.jsonPostback("alexremovevideofilepublic.php", removefilename);
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

  Future<void> downloadfile(BuildContext context,String resfilename)
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
                      d = dir==null?Directory('/Public/var/mobile/Media/'):dir;
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
      globals.configFile.serveraddr+'alexgetmp4public.php?key='+globals.packData.encodeDES3CBC(globals.configFile.apikey)
      +'&file='+resfilename,
      DownloaderUtils(
      progressCallback: 
      (current, total) 
      {
        //double progress = (current / total) * 100;
        //print('Downloading: $progress %');
      },
      file: File(path+"/"+resfilename),
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

  Future<void> addtolayerpressed(BuildContext context,String addingfilename)
  async
  {
    Color currentblockchromakey = globals.packData.color2(colorcase:8);
    double currentblocksimularity = 0.1; 
    double currentblockblend = 0.2;
    int dlgrst = 0;

    if(addingfilename.endsWith("mp4"))
    {
    await showDialog
    (
      context: context,
      builder: (BuildContext context)
      {
        return AlertDialog
        (
          //title: Text(AppLocalizations.of(context)!.newlayersettings),
          content: Text(AppLocalizations.of(context)!.setlayercoloretc,style: TextStyle(fontSize: 10),),
          actions: <Widget>
          [
            Column
            (
              children: 
              [
                SizedBox
                (
                  height: 130,
                  width: 440,
                  child: 
                    ColorPicker
                    (
                      //colorPickerWidth: 100,
                      enableAlpha: false,
                      pickerColor: globals.packData.color2(colorcase:8),
                      onColorChanged: 
                      (changeColor)
                      {
                        currentblockchromakey = changeColor;
                      },
                      showLabel: true,
                    ),
                ),
                InputSlider
                (
                  onChange: (value)
                  {
                    //print("change: $value");
                    String str = (value/100).toString();
                    if(str.length>4)str=str.substring(0,4);
                    currentblocksimularity = double.parse(str);
                  },
                  min: 1.0,
                  max: 100.0,
                  decimalPlaces: 0,
                  defaultValue: 10,
                  leading: Text(AppLocalizations.of(context)!.chromasimilarity),
                ),
                InputSlider
                (
                  onChange: (value)
                  {
                    //print("change: $value");
                    String str = (value/100).toString();
                    if(str.length>4)str=str.substring(0,4);
                    currentblockblend = double.parse(str);
                  },
                  min: 1.0,
                  max: 100.0,
                  decimalPlaces: 0,
                  defaultValue: 20,
                  leading: Text(AppLocalizations.of(context)!.chromablend),
                ),
                Row
                (
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: 
                  [
                ElevatedButton
                (
                  child: Text(AppLocalizations.of(context)!.ok),
                  onPressed: () 
                  async
                  {
                    dlgrst = 1;
                    Navigator.of(context).pop();
                    
                  },
                ),
                SizedBox(width: 100,),
                ElevatedButton
                (
                  child: Text(AppLocalizations.of(context)!.cancel),
                  onPressed: () 
                  {
                    dlgrst = 0;
                    Navigator.of(context).pop();
                  },
                ),
                  ],
                ),

              ],
            ),
            
          ],
        );
      },
    );
    if(dlgrst==1)
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
      await vlu.insertLayerWithFile(true,globals.packData.taplayeridx,addingfilename,
      currentblockchromakey,
      currentblocksimularity,
      currentblockblend);
      await vlu.preparePosPics();
      Navigator.pop(context);
    }
    }
    else if(addingfilename.endsWith("mp3"))
    {
      currentblockchromakey = globals.packData.color2(colorcase:7);
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
      await vlu.insertLayerWithFile(true,globals.packData.taplayeridx,addingfilename,
      currentblockchromakey,
      currentblocksimularity,
      currentblockblend);
      await vlu.preparePosPics();
      Navigator.pop(context);
    }
    else if(addingfilename.endsWith("png"))
    {
      currentblockchromakey = globals.packData.color2(colorcase:11);
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
      await vlu.insertLayerWithPng(true,globals.packData.taplayeridx,addingfilename,
      currentblockchromakey,
      currentblocksimularity,
      currentblockblend);
      await vlu.preparePosPics();
      Navigator.pop(context);

    }
    globals.packData.mainsetstate.call();
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
              Scrollbar
              (
                //isAlwaysShown: true,
                child: 
                ListView.builder
                (
                  reverse: true,
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(0.0),
                  itemCount: libfiles.length,
                  itemBuilder: (BuildContext context, int index) 
                  {
                    String imagepath = globals.configFile.serveraddr+'alexgetpicpublic.php?key='+globals.packData.encodeDES3CBC(globals.configFile.apikey)
                            +'&file='+libfiles[index];
                    return Container
                    (
                      padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                      height: 50,
                      child: 
                      Row
                      (
                        children: 
                        [
                          SizedBox(width: 40,child:
                          IconButton
                          (
                            tooltip: AppLocalizations.of(context)!.delete,
                            splashRadius: 20.0,
                            icon: Icon(Icons.delete_forever),
                            onPressed: () => removefilepressed(context,libfiles[index]),
                          ),),
                          /*
                          FadeInImage.memoryNetwork
                          (
                            placeholder: kTransparentImage,
                            image: imagepath,
                            height: 40,
                            width: 71,
                          ),
                          */
                          /*
                          Image
                          (
                            height: 40,
                            width: 71,
                            image: NetworkImageWithRetry(imagepath),
                          ),
                          */
                          ExtendedImage.network
                          (
                            imagepath,
                            width: 71,
                            height: 40,
                            fit: BoxFit.fill,
                            cache: true,
                            //border: Border.all(color: globals.packData.color2(colorcase:5), width: 1.0),
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.all(Radius.circular(5.0)),
                            //cancelToken: cancellationToken,
                          ),
                          SizedBox(width: 5,),
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
                                    AppLocalizations.of(context)!.videotimelength+filestimelength[index],
                                    style: TextStyle(fontSize: 8),
                                  ),
                                  SizedBox(height: 5,),
                                  Text
                                  (
                                    AppLocalizations.of(context)!.videodescription+((filesdesc[index].length>15)?filesdesc[index].substring(0,15):filesdesc[index]),
                                    style: TextStyle(fontSize: 8),
                                  ),
                                ],
                              ),
                          ),
                          SizedBox(width: 40,child:
                          IconButton
                          (
                            tooltip: AppLocalizations.of(context)!.downloadfile,
                            splashRadius: 20.0,
                            icon: Icon(Icons.move_to_inbox),
                            onPressed: ()async => await downloadfile(context,libfiles[index]),
                          ),),
                          SizedBox(width: 40,child:
                          IconButton
                          (
                            tooltip: AppLocalizations.of(context)!.import2layer,
                            splashRadius: 20.0,
                            icon: Icon(Icons.archive),
                            onPressed: ()async => await addtolayerpressed(context,libfiles[index]),
                          ),),
                        ],
                      ),
                    );
                  }
                ),
              ),
            ),
            SizedBox(height: globals.packData.buttonheight*2+globals.packData.buttongap,child:
            Row
            (
              children:
              [
                SizedBox
                (
                  width: globals.packData.optpanelwidth-110.0,
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
                labelText: AppLocalizations.of(context)!.resdescription,
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
                ElevatedButton
                (
                  onPressed: 
                  ()
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
                      d = dir==null?Directory('/Public/var/mobile/Media/'):dir;
                    }
                    
                    String? path = await FilesystemPicker.open
                    (
                      title: AppLocalizations.of(context)!.selectfile,
                      context: context,
                      rootDirectory: d,
                      fsType: FilesystemType.file,
                      folderIconColor: globals.packData.color2(colorcase:1),
                      allowedExtensions: ['.mp3','.mp4','.png'],
                      fileTileSelectMode: FileTileSelectMode.wholeTile,
                    );
                    String targetname=DateTime.now().millisecondsSinceEpoch.toString();
                    String targetdesc='-';
                    if(path!=null&&path.length>3)
                    {
                      await showDialog
                      (
                        context: context,
                        builder: (context)
                        {
                          return AlertDialog(
                            title: Text(AppLocalizations.of(context)!.typeinfo),
                            content: TextField(
                              onChanged: (value) 
                              {
                                  targetdesc = value.replaceAll("^", "").replaceAll("|", "").trim();
                                  if(targetdesc.length<1)
                                  {
                                    targetdesc='-';
                                  }
                              },
                              decoration: InputDecoration(hintText: AppLocalizations.of(context)!.targetfiledesc),
                            ),
                            actions: <Widget>[
                              ElevatedButton(
                                child: Text(AppLocalizations.of(context)!.ok),
                                onPressed: () 
                                {
                                    Navigator.pop(context);
                                },
                              ),
                            ],
                          );
                        }
                      );
                    }
                    if(path!=null&&path.length>3&&path.substring(path.length-3)=="mp4")
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
                      String rst = 
                      await globals.packData.uploadmp4file
                      (
                        'alexuploadpublicmp4.php',
                        File(path),
                        targetname,
                        targetdesc
                      );
                      String result = AppLocalizations.of(context)!.gap;
                      if(rst.contains("done"))
                      {
                        result = AppLocalizations.of(context)!.uploadsuccess;
                        await updateLists(context);
                      }
                      else
                      {
                        print(rst);
                        result = AppLocalizations.of(context)!.uploadfailed;
                      }
                      Navigator.pop(context);
                      showDialog
                      (
                        context: context,
                        builder: (_) => new 
                        AlertDialog
                        (
                            title: new Text(AppLocalizations.of(context)!.resultdialog),
                            content: new Text(result),
                            actions: <Widget>
                            [
                              ElevatedButton(
                                child: Text(AppLocalizations.of(context)!.ok),
                                onPressed: () 
                                {
                                  Navigator.of(context).pop();
                                },
                              )
                            ],
                        )
                      );
                      
                    }
                    else if(path!=null&&path.length>3&&path.substring(path.length-3)=="mp3")
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
                      String rst = 
                      await globals.packData.uploadmp3file
                      (
                        'alexuploadpublicmp3.php',
                        File(path),
                        targetname,
                        targetdesc
                      );
                      String result = AppLocalizations.of(context)!.gap;
                      if(rst.contains("done"))
                      {
                        result = AppLocalizations.of(context)!.uploadsuccess;
                        await updateLists(context);
                      }
                      else
                      {
                        print(rst);
                        result = AppLocalizations.of(context)!.uploadfailed;
                      }
                      Navigator.pop(context);
                      showDialog
                      (
                        context: context,
                        builder: (_) => new 
                        AlertDialog
                        (
                            title: new Text(AppLocalizations.of(context)!.resultdialog),
                            content: new Text(result),
                            actions: <Widget>
                            [
                              ElevatedButton(
                                child: Text(AppLocalizations.of(context)!.ok),
                                onPressed: () 
                                {
                                  Navigator.of(context).pop();
                                },
                              )
                            ],
                        )
                      );
                    }
                    else if(path!=null&&path.length>3&&path.substring(path.length-3)=="png")
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
                      String rst = 
                      await globals.packData.uploadpngfile
                      (
                        'alexuploadpublicpng.php',
                        File(path),
                        targetname,
                        targetdesc
                      );
                      String result = AppLocalizations.of(context)!.gap;
                      if(rst.contains("done"))
                      {
                        result = AppLocalizations.of(context)!.uploadsuccess;
                        await updateLists(context);
                      }
                      else
                      {
                        print(rst);
                        result = AppLocalizations.of(context)!.uploadfailed;
                      }
                      Navigator.pop(context);
                      showDialog
                      (
                        context: context,
                        builder: (_) => new 
                        AlertDialog
                        (
                            title: new Text(AppLocalizations.of(context)!.resultdialog),
                            content: new Text(result),
                            actions: <Widget>
                            [
                              ElevatedButton(
                                child: Text(AppLocalizations.of(context)!.ok),
                                onPressed: () 
                                {
                                  Navigator.of(context).pop();
                                },
                              )
                            ],
                        )
                      );
                    }                
                    
                  },
                  child: 
                  Text(AppLocalizations.of(context)!.upload),
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
}
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'globals.dart' as globals;
import 'videolayerstruct.dart';

class PanopticDeeplabApp extends StatelessWidget 
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
      home: PanopticDeeplab(),
    );
  }
}

class PanopticDeeplab extends StatefulWidget 
{
  @override
  _PanopticDeeplabState createState() => _PanopticDeeplabState();
}

class _PanopticDeeplabState extends State<PanopticDeeplab> 
{
  List<String> labelcolor = List.filled(0, "",growable: true);
  List<String> labeltext = List.filled(0, "",growable: true);
  int initflag = 1;

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
  void initState() 
  {
    super.initState();

  }

  Future<void> submittask()
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
    int rst=0;
    String allcolor = "";
    for(int i=0;i<19;i++)
    {
      allcolor+=(labelcolor[i]+"^");
    }
    String poststr = 
    globals.configFile.finalwidth+"|"+globals.configFile.finalheight
    +"|"+"panopticdeeplab"+"|"+AppLocalizations.of(context)!.panopticdeeplabtask+""+DateTime.now().toString().substring(5,19).replaceAll(" ", "").replaceAll(":","").replaceAll("-", "")+"|"
    +globals.packData.blockpickresult[globals.packData.blockpickergetidx("panopticdeeplabvideo")]
    +"*"+allcolor
    +"|"+vlu.getMaxLayerlength().inMilliseconds.toString();
    String rstaskid = (await globals.packData.jsonPostback("alexsubmittask.php", poststr)).trim();
    if(rstaskid.length<2||rstaskid.length>14)
    {
      rst=-1;
    }
    String rsstructupload="";
    String rsstructprocess="";
    for(int i=0;i<vlu.vls.videolayers.length;i++)
    {
      for(int j=0;j<vlu.vls.videolayers[i].videoblocks.length;j++)
      {
        poststr = j.toString()
        +"|"+vlu.vls.videolayers[i].videoblocks[j].blockid.toString()
        +"|"+vlu.vls.videolayers[i].videoblocks[j].filename
        +"|"+vlu.vls.videolayers[i].videoblocks[j].createstamp.toString()
        +"|"+vlu.vls.videolayers[i].videoblocks[j].fromstamp.inMilliseconds.toString()
        +"|"+vlu.vls.videolayers[i].videoblocks[j].tostamp.inMilliseconds.toString()
        +"|"+vlu.vls.videolayers[i].videoblocks[j].blocklength.inMilliseconds.toString()
        +"|"+vlu.vls.videolayers[i].videoblocks[j].fileclass
        +"|"+vlu.vls.videolayers[i].videoblocks[j].blockcolor.value.toString()
        +"|"+vlu.vls.videolayers[i].videoblocks[j].ispubliclib.toString().toUpperCase()
        +"|"+vlu.vls.videolayers[i].videoblocks[j].similarity.toString()
        +"|"+vlu.vls.videolayers[i].videoblocks[j].blend.toString()
        +"|"+vlu.vls.videolayers[i].videoblocks[j].filestartpos.inMilliseconds.toString()
        +"|"+vlu.vls.videolayers[i].videoblocks[j].resizeleft.toString()
        +"|"+vlu.vls.videolayers[i].videoblocks[j].resizetop.toString()
        +"|"+vlu.vls.videolayers[i].videoblocks[j].resizewidth.toString()
        +"|"+vlu.vls.videolayers[i].videoblocks[j].resizeheight.toString()
        +"|"+vlu.vls.videolayers[i].videoblocks[j].resizeenable.toString().toUpperCase()
        +"|"+vlu.vls.videolayers[i].videoblocks[j].respeed.toString()
        +"|"+vlu.vls.videolayers[i].videoblocks[j].respeedenable.toString().toUpperCase()
        +"|"+vlu.vls.videolayers[i].videoblocks[j].revolume.toString()
        +"|"+vlu.vls.videolayers[i].videoblocks[j].revolumeenable.toString().toUpperCase()
        +"|"+vlu.vls.videolayers[i].createstamp.toString()
        +"|"+vlu.vls.videolayers[i].zindex.toString()
        +"|"+vlu.vls.videolayers[i].layerlength.inMilliseconds.toString()
        +"|"+i.toString()
        +"|"+vlu.vls.videolayers[i].layerid.toString()
        +"|"+vlu.vls.createstamp.toString()
        +"|"+vlu.vls.scalefactor.toString()
        +"|"+rstaskid;
        rsstructupload = (await globals.packData.jsonPostback("alexstructupload.php", poststr)).trim();
        if(!rsstructupload.contains("done"))
        {
          rst=-2;
        }
      }
    }
    rsstructprocess=(await globals.packData.jsonPostback("alexstructprocess.php", rstaskid)).trim();
    if(!rsstructprocess.contains("done"))
    {
      rst=-3;
    }
    Navigator.pop(context);
    String resultstr="";
    switch (rst) 
    {
      case 0:
        resultstr=AppLocalizations.of(context)!.operationfinished;
        break;
      case -1:
        resultstr=AppLocalizations.of(context)!.errortasksubmit;
        break;
      case -2:
        resultstr=AppLocalizations.of(context)!.errorstructupload;
        break;
      case -3:
        resultstr=AppLocalizations.of(context)!.errorstatusprocess;
        break;  
      default:
    }
      await showDialog
      (
        context: context,
        builder: (_) => new 
        AlertDialog
        (
          title: new Text(AppLocalizations.of(context)!.resultdialog),
          content: new Text(resultstr),
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
    //globals.packData.mainsetstate.call();
  }

  @override
  Widget build(BuildContext context) 
  {
    String licstr = """
@inproceedings{cheng2020panoptic,
  title={Panoptic-DeepLab: A Simple, Strong, and Fast Baseline for Bottom-Up Panoptic Segmentation},
  author={Cheng, Bowen and Collins, Maxwell D and Zhu, Yukun and Liu, Ting and Huang, Thomas S and Adam, Hartwig and Chen, Liang-Chieh},
  booktitle={CVPR},
  year={2020}
}

@inproceedings{cheng2019panoptic,
  title={Panoptic-DeepLab},
  author={Cheng, Bowen and Collins, Maxwell D and Zhu, Yukun and Liu, Ting and Huang, Thomas S and Adam, Hartwig and Chen, Liang-Chieh},
  booktitle={ICCV COCO + Mapillary Joint Recognition Challenge Workshop},
  year={2019}
}
    """;

    if(initflag==1)
    {
      if(labelcolor.length>1)
      {
        labelcolor.clear();
        labeltext.clear();
      }
      labelcolor.add("[128, 64, 128]");
      labelcolor.add("[244, 35, 232]");
      labelcolor.add("[70, 70, 70]");
      labelcolor.add("[102, 102, 156]");
      labelcolor.add("[190, 153, 153]");
      labelcolor.add("[153, 153, 153]");
      labelcolor.add("[250, 170, 30]");
      labelcolor.add("[220, 220, 0]");
      labelcolor.add("[107, 142, 35]");
      labelcolor.add("[152, 251, 152]");
      labelcolor.add("[70, 130, 180]");
      labelcolor.add("[220, 20, 60]");
      labelcolor.add("[255, 0, 0]");
      labelcolor.add("[0, 0, 142]");
      labelcolor.add("[0, 0, 70]");
      labelcolor.add("[0, 60, 100]");
      labelcolor.add("[0, 80, 100]");
      labelcolor.add("[0, 0, 230]");
      labelcolor.add("[119, 11, 32]");
      
      labeltext.add(AppLocalizations.of(context)!.road);
      labeltext.add(AppLocalizations.of(context)!.sidewalk);
      labeltext.add(AppLocalizations.of(context)!.building);
      labeltext.add(AppLocalizations.of(context)!.wall);
      labeltext.add(AppLocalizations.of(context)!.fence);
      labeltext.add(AppLocalizations.of(context)!.pole);
      labeltext.add(AppLocalizations.of(context)!.trafficlight);
      labeltext.add(AppLocalizations.of(context)!.trafficsign);
      labeltext.add(AppLocalizations.of(context)!.vegetation);
      labeltext.add(AppLocalizations.of(context)!.terrain);
      labeltext.add(AppLocalizations.of(context)!.sky);
      labeltext.add(AppLocalizations.of(context)!.person);
      labeltext.add(AppLocalizations.of(context)!.rider);
      labeltext.add(AppLocalizations.of(context)!.car);
      labeltext.add(AppLocalizations.of(context)!.truck);
      labeltext.add(AppLocalizations.of(context)!.bus);
      labeltext.add(AppLocalizations.of(context)!.train);
      labeltext.add(AppLocalizations.of(context)!.motorcycle);
      labeltext.add(AppLocalizations.of(context)!.bicycle);

      for(int i=0;i<19;i++)
      {
        globals.packData.colorpicktcc[i].text=labelcolor[i];
      }
      
      initflag=0;
    }
    return SizedBox
    (
      width: globals.packData.optpanelwidth,
      height: globals.packData.videoheight-globals.packData.titleheight,
      child:
      Align
      (
        alignment: Alignment.bottomCenter, 
        child:
        ListView
        (
          reverse: true,
          children: 
          [
            SizedBox(height: globals.packData.buttonheight+globals.packData.buttongap,child:
            Row
            (
              children:
              [
                SizedBox
                (
                  width: 10.0, 
                ),
                Text(AppLocalizations.of(context)!.panopticdeeplabdesc,style: TextStyle(fontSize: 10),),
                SizedBox
                (
                  width: (globals.packData.optpanelwidth-300.0>0)?globals.packData.optpanelwidth-300.0:20, 
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
                    globals.packData.aiscc.jumpTo(index: 0);
                  },
                  child: 
                  Text(AppLocalizations.of(context)!.backtoaipanel),
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
                    await submittask();
                  },
                  child: 
                  Text(AppLocalizations.of(context)!.startoperation),
                ),
              ],
            ),
            ),
            SizedBox(height: globals.packData.buttongap,),
            pickblockbutton(AppLocalizations.of(context)!.videowanttosegment,globals.packData.blockpickergetidx("panopticdeeplabvideo")),
            SizedBox(height: globals.packData.buttongap,),
            pickcolorbutton(0),
            pickcolorbutton(1),
            pickcolorbutton(2),
            pickcolorbutton(3),
            pickcolorbutton(4),
            pickcolorbutton(5),
            pickcolorbutton(6),
            pickcolorbutton(7),
            pickcolorbutton(8),
            pickcolorbutton(9),
            pickcolorbutton(10),
            pickcolorbutton(11),
            pickcolorbutton(12),
            pickcolorbutton(13),
            pickcolorbutton(14),
            pickcolorbutton(15),
            pickcolorbutton(16),
            pickcolorbutton(17),
            pickcolorbutton(18),
            SizedBox(height: globals.packData.buttongap,),
            Text(licstr,style: TextStyle(fontSize: 10),),

          ],

        ),
      ),
    );
  }

  Widget pickblockbutton(String buttontext,int pickid)
  {
    return SizedBox
    (
      width: globals.packData.optpanelwidth,
      //height: globals.packData.titleheight,
      child:
      Row
      (
        children:
        [
          SizedBox(width: 5,),
          Icon(Icons.video_camera_back),
          SizedBox(width: 5,),
          SizedBox(width: globals.packData.optpanelwidth-188, child:
            TextFormField
            (
              //key: UniqueKey(),
              decoration: 
              InputDecoration
              (
                contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                labelText: buttontext,
                hintText: AppLocalizations.of(context)!.tapmetoselectblock,
                border: OutlineInputBorder
                (
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(),
                ),
              ),
              controller: globals.packData.blockpicktcc[pickid],
              textAlign: TextAlign.start,
              readOnly: true,
              style: TextStyle
              (
                fontSize: 12,
              ),
              onTap: ()
              {
                globals.packData.currentpickid = pickid;
                print(globals.packData.currentpickid);
              },
            ),
          ),
          SizedBox(width: 5,),
          Text(buttontext,style: TextStyle(fontSize: 10),),
        ],
      )
    );
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

  Widget pickcolorbutton(int pickid)
  {
    return SizedBox
    (
      width: globals.packData.optpanelwidth,
      //height: globals.packData.titleheight,
      child:
      Row
      (
        children:
        [
          SizedBox(width: 5,),
          Icon(Icons.color_lens,),
          SizedBox(width: 5,),
          SizedBox(width: globals.packData.optpanelwidth-188, child:
            TextFormField
            (
              //key: UniqueKey(),
              decoration: 
              InputDecoration
              (
                fillColor: rgbstr2color(labelcolor[pickid]),
                hoverColor: rgbstr2color(labelcolor[pickid]),
                focusColor: rgbstr2color(labelcolor[pickid]),
                contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                labelText: "",
                hintText: "",
                border: OutlineInputBorder
                (
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(),
                ),
              ),
              controller: globals.packData.colorpicktcc[pickid],
              textAlign: TextAlign.start,
              style: TextStyle
              (
                //color: rgbstr2color(labelcolor[pickid]),
                fontSize: 12,
              ),
              onTap: ()
              {
                print(globals.packData.currentpickid);
              },
              onChanged: (value)
              {
                labelcolor[pickid] = value;
              },
            ),
          ),
          SizedBox(width: 5,),
                ElevatedButton
                (
                  style: 
                  ButtonStyle(backgroundColor: 
                  MaterialStateProperty.all<Color>
                  (
                    rgbstr2color(labelcolor[pickid]),
                  ),),
                  onPressed: 
                  ()
                  async
                  {
                    labelcolor[pickid] = "[0, 0, 0]";
                    globals.packData.colorpicktcc[pickid].text = labelcolor[pickid];
                    globals.packData.mainsetstate.call();
                  },
                  child: 
                  Text(AppLocalizations.of(context)!.blacktosave,style: TextStyle(fontSize: 10),),
                ),
          SizedBox(width: 5,),
          Text(labeltext[pickid],style: 
          TextStyle(backgroundColor: rgbstr2color(labelcolor[pickid]),fontSize: 10),),
        ],
      )
    );
  }
}
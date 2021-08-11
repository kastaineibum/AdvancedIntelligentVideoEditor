import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'globals.dart' as globals;
import 'videolayerstruct.dart';

class BackgroundMattingV2App extends StatelessWidget 
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
      home: BackgroundMattingV2(),
    );
  }
}

class BackgroundMattingV2 extends StatefulWidget 
{
  @override
  _BackgroundMattingV2State createState() => _BackgroundMattingV2State();
}

class _BackgroundMattingV2State extends State<BackgroundMattingV2> 
{

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
    String poststr = 
    globals.configFile.finalwidth+"|"+globals.configFile.finalheight
    +"|"+"backgroundmattingv2"+"|"+AppLocalizations.of(context)!.backgroundmattingv2task+""+DateTime.now().toString().substring(5,19).replaceAll(" ", "").replaceAll(":","").replaceAll("-", "")+"|"
    +globals.packData.blockpickresult[globals.packData.blockpickergetidx("backgroundmattingv2video")]
    +"*"+globals.packData.blockpickresult[globals.packData.blockpickergetidx("backgroundmattingv2bgpng")]
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
@article{BGMv2,
  title={Real-Time High-Resolution Background Matting},
  author={Lin, Shanchuan and Ryabtsev, Andrey and Sengupta, Soumyadip and Curless, Brian and Seitz, Steve and Kemelmacher-Shlizerman, Ira},
  journal={arXiv},
  pages={arXiv--2012},
  year={2020}
}
    """;
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
                Text(AppLocalizations.of(context)!.backgroundmattingv2desc,style: TextStyle(fontSize: 10),),
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
            pickblockbutton(AppLocalizations.of(context)!.videowanttoremovebg,globals.packData.blockpickergetidx("backgroundmattingv2video")),
            pickblockbutton(AppLocalizations.of(context)!.videobg,globals.packData.blockpickergetidx("backgroundmattingv2bgpng")),
            SizedBox(height: globals.packData.buttongap,),
            Text(AppLocalizations.of(context)!.mattinglayercaution,style: TextStyle(fontSize: 10),),
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
}
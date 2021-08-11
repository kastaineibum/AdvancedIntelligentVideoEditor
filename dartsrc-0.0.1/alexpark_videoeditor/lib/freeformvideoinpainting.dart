import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'globals.dart' as globals;
import 'videolayerstruct.dart';

class FreeFormVideoInpaintingApp extends StatelessWidget 
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
      home: FreeFormVideoInpainting(),
    );
  }
}

class FreeFormVideoInpainting extends StatefulWidget 
{
  @override
  _FreeFormVideoInpaintingState createState() => _FreeFormVideoInpaintingState();
}

class _FreeFormVideoInpaintingState extends State<FreeFormVideoInpainting> 
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
    +"|"+"freeformvideoinpainting"+"|"+AppLocalizations.of(context)!.freeformvideoinpaintingtask+""+DateTime.now().toString().substring(5,19).replaceAll(" ", "").replaceAll(":","").replaceAll("-", "")+"|"
    +globals.packData.blockpickresult[globals.packData.blockpickergetidx("freeformvideoinpaintingvideo")]
    +"*"+globals.packData.blockpickresult[globals.packData.blockpickergetidx("freeformvideoinpaintingmask")]
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
    String licstr="""
@article{chang2019free,
  title={Free-form Video Inpainting with 3D Gated Convolution and Temporal PatchGAN},
  author={Chang, Ya-Liang and Liu, Zhe Yu and Lee, Kuan-Ying and Hsu, Winston},
  journal={In Proceedings of the International Conference on Computer Vision (ICCV)},
  year={2019}
}
@article{chang2019learnable,
  title={Learnable Gated Temporal Shift Module for Deep Video Inpainting"},
  author={Chang, Ya-Liang and Liu, Zhe Yu and Lee, Kuan-Ying and Hsu, Winston},
  journal={BMVC},
  year={2019}
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
                Text(AppLocalizations.of(context)!.freeformvideoinpaintingdesc,style: TextStyle(fontSize: 10),),
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
            pickblockbutton(AppLocalizations.of(context)!.videowanttoinpaint,globals.packData.blockpickergetidx("freeformvideoinpaintingvideo")),
            pickblockbutton(AppLocalizations.of(context)!.videosegmask,globals.packData.blockpickergetidx("freeformvideoinpaintingmask")),
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
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'globals.dart' as globals;
import 'videolayerstruct.dart';

class AIEditorPanelApp extends StatelessWidget 
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
      home: AIEditorPanel(),
    );
  }
}

class AIEditorPanel extends StatefulWidget 
{
  @override
  _AIEditorPanelState createState() => _AIEditorPanelState();
}

class _AIEditorPanelState extends State<AIEditorPanel> 
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
    +"|"+"regular"+"|"+AppLocalizations.of(context)!.regulartask+" "+DateTime.now().toString()+"|"+"-"
    +"|"+vlu.getMaxLayerlength().inMilliseconds.toString();
    String rstaskid = (await globals.packData.jsonPostback("alexsubmittask.php", poststr)).trim();
    if(rstaskid.length<2)
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

  Future<void> icontapped(int index)
  async
  {
    try
    {
      //globals.packData.aiscc.scrollTo(index: (index+1)*2,duration: Duration(milliseconds: 200),curve: Curves.easeInOutCubic);
      globals.packData.aiscc.jumpTo(index: (index+1)*2);
    switch (index) 
    {
      case 0:

        break;
      case 1:

        break;
      case 2:

        break;
      case 3:

        break;
      case 4:

        break;
      case 5:

        break;
      case 6:

        break;
      case 7:

        break;
      case 8:

        break;
      case 9:

        break;
      case 10:

        break;
      case 11:

        break;
      case 12:

        break;
      case 13:

        break;
      case 14:

        break;
      case 15:
        
        break;

      default:
    }
    }
    catch(e)
    {

    }

  }

  Icon buildicon(int index)
  {
    switch (index) 
    {
      case 0:
        return Icon(Icons.person_pin);
      case 1:
        return Icon(Icons.video_camera_back);
      case 2:
        return Icon(Icons.streetview);        
      case 3:
        return Icon(Icons.cloud_circle);
      case 4:
        return Icon(Icons.record_voice_over);
      case 5:
        return Icon(Icons.access_alarm);
      case 6:
        return Icon(Icons.access_alarm);
      case 7:
        return Icon(Icons.access_alarm);
      case 8:
        return Icon(Icons.access_alarm);
      case 9:
        return Icon(Icons.access_alarm);
      case 10:
        return Icon(Icons.access_alarm);
      case 11:
        return Icon(Icons.access_alarm);
      case 12:
        return Icon(Icons.access_alarm);
      case 13:
        return Icon(Icons.access_alarm);
      case 14:
        return Icon(Icons.access_alarm);
      case 15:
        return Icon(Icons.access_alarm);
        
      default:
        return Icon(Icons.access_alarm);
    }
  }

  Text buildtext(int index)
  {
    switch (index) 
    {
      case 0:
        return Text(AppLocalizations.of(context)!.backgroundmattingv2,style: TextStyle(fontSize: 10),);
      case 1:
        return Text(AppLocalizations.of(context)!.freeformvideoinpainting,style: TextStyle(fontSize: 10),);
      case 2:
        return Text(AppLocalizations.of(context)!.panopticdeeplab,style: TextStyle(fontSize: 10),);
      case 3:
        return Text(AppLocalizations.of(context)!.skyar,style: TextStyle(fontSize: 10),);
      case 4:
        return Text(AppLocalizations.of(context)!.wav2lip,style: TextStyle(fontSize: 10),);
      case 5:
        
      case 6:
        
      case 7:
        
      case 8:
        
      case 9:
        
      case 10:
        
      case 11:
        
      case 12:
        
      case 13:
        
      case 14:
        
      case 15:
        
        
      default:
        return Text('test');
    }
  }

  @override
  Widget build(BuildContext context) 
  {
    return SizedBox
    (
      width: globals.packData.optpanelwidth,
      height: globals.packData.videoheight-globals.packData.titleheight,
      child:
      Align
      (
        alignment: Alignment.bottomCenter, 
        child:
StaggeredGridView.countBuilder
(
  reverse: true,
  crossAxisCount: 5,
  //((globals.packData.scrwidth-globals.packData.videowidth-globals.packData.tabsize)~/70),
  itemCount: 5,
  itemBuilder: (BuildContext context, int index)
  {
    return 
    Container
    (
      padding: EdgeInsets.all(0.0),
      child: 
        InkWell
        (
          onTap: ()
          async
          {
            await icontapped(index);
          },
          child:
        Column
        (
          children: 
          [
            SizedBox(height: 2,),
            buildicon(index),
            buildtext(index),
          ],
        ),
        ),
    );
  },
  staggeredTileBuilder: (int index)
  {
    return StaggeredTile.count(1, 0.7);
  },  
  mainAxisSpacing: 4.0,
  crossAxisSpacing: 4.0,
),
      ),
    );
  }
}
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:input_slider/input_slider.dart';
import 'globals.dart' as globals;
import 'videolayerstruct.dart';

class RegularEditorApp extends StatelessWidget 
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
      home: RegularEditor(),
    );
  }
}

class RegularEditor extends StatefulWidget 
{
  @override
  _RegularEditorState createState() => _RegularEditorState();
}

class _RegularEditorState extends State<RegularEditor> 
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
    +"|"+"regular"+"|"+AppLocalizations.of(context)!.regulartask+""+DateTime.now().toString().substring(5,19).replaceAll(" ", "").replaceAll(":","").replaceAll("-", "")+"|"+"-"
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

  Future<void> filmcut()
  async
  {
    if(globals.packData.tapvideolayerscrpos==0||globals.packData.tapvideolayerscrpos==-1)
    {
      await showDialog
      (
        context: context,
        builder: (_) => new 
        AlertDialog
        (
          title: new Text(AppLocalizations.of(context)!.tip),
          content: new Text(AppLocalizations.of(context)!.tapvideoblockfirst),
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
      return;
    }
    if(vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].respeedenable)
    {
      await showDialog
      (
        context: context,
        builder: (_) => new 
        AlertDialog
        (
          title: new Text(AppLocalizations.of(context)!.tip),
          content: new Text(AppLocalizations.of(context)!.cannoteditrespeed),
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
      return;
    }
    vlu.vlb = VideoLayerBlock(vlu.getNewBlockid());
    VideoLayerBlock vlbb = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx];
    vlu.vlb.fromstamp = Duration(milliseconds: vlbb.fromstamp.inMilliseconds);
    vlu.vlb.tostamp = Duration(milliseconds: globals.packData.currentposinmilli.toInt());
    vlu.vlb.blocklength=vlu.vlb.tostamp-vlu.vlb.fromstamp;
    vlu.vlb.createstamp = DateTime.now();
    vlu.vlb.blend = vlbb.blend;
    vlu.vlb.blockcolor = vlbb.blockcolor;
    vlu.vlb.fileclass = vlbb.fileclass;
    vlu.vlb.filename = vlbb.filename;
    vlu.vlb.filestartpos = Duration(milliseconds: vlbb.filestartpos.inMilliseconds);
    vlu.vlb.ispubliclib = vlbb.ispubliclib;
    vlu.vlb.similarity = vlbb.similarity;
    vlu.vlb.resizeenable = vlbb.resizeenable;
    vlu.vlb.resizeleft = vlbb.resizeleft;
    vlu.vlb.resizetop = vlbb.resizetop;
    vlu.vlb.resizewidth = vlbb.resizewidth;
    vlu.vlb.resizeheight = vlbb.resizeheight;
    vlu.vlb.revolumeenable = vlbb.revolumeenable;
    vlu.vlb.revolume = vlbb.revolume;
    if(
      vlu.vlb.blocklength.inMilliseconds<200
    ||(vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].tostamp.inMilliseconds-Duration(milliseconds: globals.packData.currentposinmilli.toInt()).inMilliseconds<200)
      )
    {
      /*
      await showDialog
      (
        context: context,
        builder: (_) => new 
        AlertDialog
        (
          title: new Text(AppLocalizations.of(context)!.tip),
          content: new Text(AppLocalizations.of(context)!.blocktooshort),
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
      */
      return;
    }
    vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks.add(vlu.vlb);
    vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].fromstamp = Duration(milliseconds: globals.packData.currentposinmilli.toInt());
    vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].blocklength = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].tostamp-vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].fromstamp;
    vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].filestartpos += vlu.vlb.blocklength;
    vlu.sortBlocksD();
    globals.packData.mainsetstate.call();
  }

  Future<void> filmblockcut()
  async
  {
    if(globals.packData.tapvideolayerscrpos==0||globals.packData.tapvideolayerscrpos==-1)
    {
      await showDialog
      (
        context: context,
        builder: (_) => new 
        AlertDialog
        (
          title: new Text(AppLocalizations.of(context)!.tip),
          content: new Text(AppLocalizations.of(context)!.tapvideoblockfirst),
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
      return;
    }
    VideoLayerBlock vlbb = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx];
    if(vlbb.fileclass=="placeholder")
    {
      if(vlbb.respeedenable)
      {
        moveblocksbackward(globals.packData.taplayeridx, globals.packData.tapblockidx+1, vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].blocklength.inMilliseconds~/vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].respeed);
      }
      else
      {
        moveblocksbackward(globals.packData.taplayeridx, globals.packData.tapblockidx+1, vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].blocklength.inMilliseconds);
      }
      

      vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks.removeAt(globals.packData.tapblockidx);
      vlu.sortBlocksD();
      vlu.calLayerslength();
      vlu.refreshLayerlengthPlaceholder();
    }
    else
    {
      vlu.vlbcopied = VideoLayerBlock(vlu.getNewBlockid());
      vlu.vlbcopied.fromstamp = Duration(milliseconds: vlbb.fromstamp.inMilliseconds);
      vlu.vlbcopied.tostamp = Duration(milliseconds: vlbb.tostamp.inMilliseconds);
      vlu.vlbcopied.blocklength = Duration(milliseconds: vlbb.blocklength.inMilliseconds);
      vlu.vlbcopied.createstamp = vlbb.createstamp;
      vlu.vlbcopied.blend = vlbb.blend;
      vlu.vlbcopied.blockcolor = vlbb.blockcolor;
      vlu.vlbcopied.fileclass = vlbb.fileclass;
      vlu.vlbcopied.filename = vlbb.filename;
      vlu.vlbcopied.filestartpos = Duration(milliseconds: vlbb.filestartpos.inMilliseconds);
      vlu.vlbcopied.ispubliclib = vlbb.ispubliclib;
      vlu.vlbcopied.similarity = vlbb.similarity;
      vlu.vlbcopied.resizeenable = vlbb.resizeenable;
      vlu.vlbcopied.resizeleft = vlbb.resizeleft;
      vlu.vlbcopied.resizetop = vlbb.resizetop;
      vlu.vlbcopied.resizewidth = vlbb.resizewidth;
      vlu.vlbcopied.resizeheight = vlbb.resizeheight;
      vlu.vlbcopied.revolumeenable = vlbb.revolumeenable;
      vlu.vlbcopied.revolume = vlbb.revolume;
      vlu.vlbcopied.respeedenable = vlbb.respeedenable;
      vlu.vlbcopied.respeed = vlbb.respeed;
      vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].fileclass="placeholder";
      vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].filename="placeholder.mp3";
      vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].ispubliclib=true;
      vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].blockcolor=globals.packData.color2(colorcase:10);
      vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].blend = 0.2;
      vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].similarity = 0.1;
    }
    await globals.packData.openVideoFile(true,"placeholder.mp3");
    globals.packData.tapvideolayerscrpos = 0;
    globals.packData.mainsetstate.call();
  }

  Future<void> filmblockcopy()
  async
  {
    VideoLayerBlock vlbb = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx];
      vlu.vlbcopied = VideoLayerBlock(vlu.getNewBlockid());
      vlu.vlbcopied.fromstamp = Duration(milliseconds: vlbb.fromstamp.inMilliseconds);
      vlu.vlbcopied.tostamp = Duration(milliseconds: vlbb.tostamp.inMilliseconds);
      vlu.vlbcopied.blocklength = Duration(milliseconds: vlbb.blocklength.inMilliseconds);
      vlu.vlbcopied.createstamp = vlbb.createstamp;
      vlu.vlbcopied.blend = vlbb.blend;
      vlu.vlbcopied.blockcolor = vlbb.blockcolor;
      vlu.vlbcopied.fileclass = vlbb.fileclass;
      vlu.vlbcopied.filename = vlbb.filename;
      vlu.vlbcopied.filestartpos = Duration(milliseconds: vlbb.filestartpos.inMilliseconds);
      vlu.vlbcopied.ispubliclib = vlbb.ispubliclib;
      vlu.vlbcopied.similarity = vlbb.similarity;
      vlu.vlbcopied.resizeenable = vlbb.resizeenable;
      vlu.vlbcopied.resizeleft = vlbb.resizeleft;
      vlu.vlbcopied.resizetop = vlbb.resizetop;
      vlu.vlbcopied.resizewidth = vlbb.resizewidth;
      vlu.vlbcopied.resizeheight = vlbb.resizeheight;
      vlu.vlbcopied.revolumeenable = vlbb.revolumeenable;
      vlu.vlbcopied.revolume = vlbb.revolume;
      vlu.vlbcopied.respeedenable = vlbb.respeedenable;
      vlu.vlbcopied.respeed = vlbb.respeed;
  }

  void moveblocksforward(int layeridx,int startblockidx,int millisec)
  {
    if(startblockidx>=vlu.vls.videolayers[layeridx].videoblocks.length)return;
    for(int i=startblockidx;i<vlu.vls.videolayers[layeridx].videoblocks.length;i++)
    {
      vlu.vls.videolayers[layeridx].videoblocks[i].fromstamp+=Duration(milliseconds: millisec);
      vlu.vls.videolayers[layeridx].videoblocks[i].tostamp+=Duration(milliseconds: millisec);
    }
  }

  void moveblocksbackward(int layeridx,int startblockidx,int millisec)
  {
    if(startblockidx>=vlu.vls.videolayers[layeridx].videoblocks.length)return;
    for(int i=startblockidx;i<vlu.vls.videolayers[layeridx].videoblocks.length;i++)
    {
      vlu.vls.videolayers[layeridx].videoblocks[i].fromstamp-=Duration(milliseconds: millisec);
      vlu.vls.videolayers[layeridx].videoblocks[i].tostamp-=Duration(milliseconds: millisec);
    }
  }

  Future<void> filmblockpasteahead()
  async
  {
    if(globals.packData.tapvideolayerscrpos==0||globals.packData.tapvideolayerscrpos==-1)
    {
      await showDialog
      (
        context: context,
        builder: (_) => new 
        AlertDialog
        (
          title: new Text(AppLocalizations.of(context)!.tip),
          content: new Text(AppLocalizations.of(context)!.tapvideoblockfirst),
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
      return;
    }

    vlu.vlb=VideoLayerBlock(vlu.getNewBlockid());

    vlu.vlb.blend = vlu.vlbcopied.blend;
    vlu.vlb.blockcolor = vlu.vlbcopied.blockcolor;
    vlu.vlb.blocklength = Duration(milliseconds: vlu.vlbcopied.blocklength.inMilliseconds);
    vlu.vlb.createstamp = vlu.vlbcopied.createstamp;
    vlu.vlb.fileclass = vlu.vlbcopied.fileclass;
    vlu.vlb.filename = vlu.vlbcopied.filename;
    vlu.vlb.filestartpos = Duration(milliseconds: vlu.vlbcopied.filestartpos.inMilliseconds);
    vlu.vlb.fromstamp = Duration(milliseconds: vlu.vlbcopied.fromstamp.inMilliseconds);
    vlu.vlb.ispubliclib = vlu.vlbcopied.ispubliclib;
    vlu.vlb.similarity = vlu.vlbcopied.similarity;
    vlu.vlb.tostamp = Duration(milliseconds: vlu.vlbcopied.tostamp.inMilliseconds);
    vlu.vlb.resizeenable = vlu.vlbcopied.resizeenable;
    vlu.vlb.resizeleft = vlu.vlbcopied.resizeleft;
    vlu.vlb.resizetop = vlu.vlbcopied.resizetop;
    vlu.vlb.resizewidth = vlu.vlbcopied.resizewidth;
    vlu.vlb.resizeheight = vlu.vlbcopied.resizeheight;
    vlu.vlb.revolumeenable = vlu.vlbcopied.revolumeenable;
    vlu.vlb.revolume = vlu.vlbcopied.revolume;
    vlu.vlb.respeedenable = vlu.vlbcopied.respeedenable;
    vlu.vlb.respeed = vlu.vlbcopied.respeed;

    vlu.vlb.fromstamp = Duration(milliseconds: vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].fromstamp.inMilliseconds);
    vlu.vlb.tostamp = vlu.vlb.fromstamp + vlu.vlb.blocklength;

    if(vlu.vlb.respeedenable)
    {
      moveblocksforward(globals.packData.taplayeridx,globals.packData.tapblockidx,vlu.vlb.blocklength.inMilliseconds~/vlu.vlb.respeed);
    }
    else
    {
      moveblocksforward(globals.packData.taplayeridx,globals.packData.tapblockidx,vlu.vlb.blocklength.inMilliseconds);
    }

    vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks.add(vlu.vlb);
    vlu.sortBlocksD();
    vlu.calLayerslength();
    vlu.refreshLayerlengthPlaceholder();
    await globals.packData.openVideoFile(true,"placeholder.mp3");
    globals.packData.tapvideolayerscrpos = 0;
    globals.packData.mainsetstate.call();
  }

  Future<void> filmblockpasteafter()
  async
  {
    if(globals.packData.tapvideolayerscrpos==0||globals.packData.tapvideolayerscrpos==-1)
    {
      await showDialog
      (
        context: context,
        builder: (_) => new 
        AlertDialog
        (
          title: new Text(AppLocalizations.of(context)!.tip),
          content: new Text(AppLocalizations.of(context)!.tapvideoblockfirst),
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
      return;
    }

    vlu.vlb=VideoLayerBlock(vlu.getNewBlockid());

    vlu.vlb.blend = vlu.vlbcopied.blend;
    vlu.vlb.blockcolor = vlu.vlbcopied.blockcolor;
    vlu.vlb.blocklength = Duration(milliseconds: vlu.vlbcopied.blocklength.inMilliseconds);
    vlu.vlb.createstamp = vlu.vlbcopied.createstamp;
    vlu.vlb.fileclass = vlu.vlbcopied.fileclass;
    vlu.vlb.filename = vlu.vlbcopied.filename;
    vlu.vlb.filestartpos = Duration(milliseconds: vlu.vlbcopied.filestartpos.inMilliseconds);
    vlu.vlb.fromstamp = Duration(milliseconds: vlu.vlbcopied.fromstamp.inMilliseconds);
    vlu.vlb.ispubliclib = vlu.vlbcopied.ispubliclib;
    vlu.vlb.similarity = vlu.vlbcopied.similarity;
    vlu.vlb.tostamp = Duration(milliseconds: vlu.vlbcopied.tostamp.inMilliseconds);
    vlu.vlb.resizeenable = vlu.vlbcopied.resizeenable;
    vlu.vlb.resizeleft = vlu.vlbcopied.resizeleft;
    vlu.vlb.resizetop = vlu.vlbcopied.resizetop;
    vlu.vlb.resizewidth = vlu.vlbcopied.resizewidth;
    vlu.vlb.resizeheight = vlu.vlbcopied.resizeheight;
    vlu.vlb.revolumeenable = vlu.vlbcopied.revolumeenable;
    vlu.vlb.revolume = vlu.vlbcopied.revolume;
    vlu.vlb.respeedenable = vlu.vlbcopied.respeedenable;
    vlu.vlb.respeed = vlu.vlbcopied.respeed;

    vlu.vlb.fromstamp = Duration(milliseconds: vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].tostamp.inMilliseconds);
    vlu.vlb.tostamp = vlu.vlb.fromstamp + vlu.vlb.blocklength;

    if(vlu.vlb.respeedenable)
    {
      moveblocksforward(globals.packData.taplayeridx,globals.packData.tapblockidx+1,vlu.vlb.blocklength.inMilliseconds~/vlu.vlb.respeed);
    }
    else
    {
      moveblocksforward(globals.packData.taplayeridx,globals.packData.tapblockidx+1,vlu.vlb.blocklength.inMilliseconds);
    }
    
    vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks.add(vlu.vlb);
    vlu.sortBlocksD();
    vlu.calLayerslength();
    vlu.refreshLayerlengthPlaceholder();
    globals.packData.mainsetstate.call();
  }

  Future<void> filmblockpastecover()
  async
  {
    if(globals.packData.tapvideolayerscrpos==0||globals.packData.tapvideolayerscrpos==-1)
    {
      await showDialog
      (
        context: context,
        builder: (_) => new 
        AlertDialog
        (
          title: new Text(AppLocalizations.of(context)!.tip),
          content: new Text(AppLocalizations.of(context)!.tapvideoblockfirst),
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
      return;
    }
    if(vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].respeedenable)
    {
      await showDialog
      (
        context: context,
        builder: (_) => new 
        AlertDialog
        (
          title: new Text(AppLocalizations.of(context)!.tip),
          content: new Text(AppLocalizations.of(context)!.cannoteditrespeed),
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
      return;
    }

    vlu.vlb=VideoLayerBlock(vlu.getNewBlockid());

    vlu.vlb.blend = vlu.vlbcopied.blend;
    vlu.vlb.blockcolor = vlu.vlbcopied.blockcolor;
    vlu.vlb.blocklength = Duration(milliseconds: vlu.vlbcopied.blocklength.inMilliseconds);
    vlu.vlb.createstamp = vlu.vlbcopied.createstamp;
    vlu.vlb.fileclass = vlu.vlbcopied.fileclass;
    vlu.vlb.filename = vlu.vlbcopied.filename;
    vlu.vlb.filestartpos = Duration(milliseconds: vlu.vlbcopied.filestartpos.inMilliseconds);
    vlu.vlb.fromstamp = Duration(milliseconds: vlu.vlbcopied.fromstamp.inMilliseconds);
    vlu.vlb.ispubliclib = vlu.vlbcopied.ispubliclib;
    vlu.vlb.similarity = vlu.vlbcopied.similarity;
    vlu.vlb.tostamp = Duration(milliseconds: vlu.vlbcopied.tostamp.inMilliseconds);
    vlu.vlb.resizeenable = vlu.vlbcopied.resizeenable;
    vlu.vlb.resizeleft = vlu.vlbcopied.resizeleft;
    vlu.vlb.resizetop = vlu.vlbcopied.resizetop;
    vlu.vlb.resizewidth = vlu.vlbcopied.resizewidth;
    vlu.vlb.resizeheight = vlu.vlbcopied.resizeheight;
    vlu.vlb.revolumeenable = vlu.vlbcopied.revolumeenable;
    vlu.vlb.revolume = vlu.vlbcopied.revolume;
    vlu.vlb.respeedenable = vlu.vlbcopied.respeedenable;
    vlu.vlb.respeed = vlu.vlbcopied.respeed;

    vlu.vlb.fromstamp = Duration(milliseconds: vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].fromstamp.inMilliseconds);
    if(vlu.vlb.respeedenable)
    {  
    if(Duration(milliseconds:vlu.vlb.blocklength.inMilliseconds~/vlu.vlb.respeed)>=vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].blocklength)
    {
      vlu.vlb.blocklength = Duration(milliseconds: (vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].blocklength.inMilliseconds*vlu.vlb.respeed).toInt());
      vlu.vlb.tostamp = vlu.vlb.fromstamp + vlu.vlb.blocklength;
      vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks.add(vlu.vlb);
      vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks.removeAt(globals.packData.tapblockidx);
      vlu.sortBlocksD();
    }
    else
    {
      vlu.vlb.tostamp = vlu.vlb.fromstamp + vlu.vlb.blocklength;
      vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks.add(vlu.vlb);
      vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].fromstamp = Duration(milliseconds: vlu.vlb.fromstamp.inMilliseconds+(vlu.vlb.blocklength.inMilliseconds~/vlu.vlb.respeed));
      vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].blocklength = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].tostamp-vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].fromstamp;
      vlu.sortBlocksD();
    }
    }
    else
    {
    if(vlu.vlb.blocklength>=vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].blocklength)
    {
      vlu.vlb.blocklength = Duration(milliseconds: vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].blocklength.inMilliseconds);
      vlu.vlb.tostamp = vlu.vlb.fromstamp + vlu.vlb.blocklength;
      vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks.add(vlu.vlb);
      vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks.removeAt(globals.packData.tapblockidx);
      vlu.sortBlocksD();
    }
    else
    {
      vlu.vlb.tostamp = vlu.vlb.fromstamp + vlu.vlb.blocklength;
      vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks.add(vlu.vlb);
      vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].fromstamp = Duration(milliseconds: vlu.vlb.tostamp.inMilliseconds);
      vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].blocklength = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].tostamp-vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].fromstamp;
      vlu.sortBlocksD();
    }
    }

    await globals.packData.openVideoFile(true,"placeholder.mp3");
    globals.packData.tapvideolayerscrpos = 0;
    globals.packData.mainsetstate.call();
  }

  Future<void> filmblockmove()
  async
  {
    if(globals.packData.tapvideolayerscrpos==0||globals.packData.tapvideolayerscrpos==-1)
    {
      await showDialog
      (
        context: context,
        builder: (_) => new 
        AlertDialog
        (
          title: new Text(AppLocalizations.of(context)!.tip),
          content: new Text(AppLocalizations.of(context)!.tapvideoblockfirst),
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
      return;
    }
    if(vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].respeedenable)
    {
      await showDialog
      (
        context: context,
        builder: (_) => new 
        AlertDialog
        (
          title: new Text(AppLocalizations.of(context)!.tip),
          content: new Text(AppLocalizations.of(context)!.cannoteditrespeed),
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
      return;
    }
    int dlgrst = 0;
    TextEditingController tec = TextEditingController(text:globals.packData.timestrFromMillisec(vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].fromstamp.inMilliseconds));
    int millipos = 0;
    
    await showDialog
    (
      context: context,
      builder: (BuildContext context)
      {
        return AlertDialog
        (
          content: Text(AppLocalizations.of(context)!.blockmove),
          actions: <Widget>
          [
            Column
            (
              children: 
              [
                TextFormField
                (
                  controller: tec,
                  readOnly: true,
                  //style: TextStyle(fontSize: 12),
                ),
                InputSlider
                (
                  onChange: (value)
                  {
                    //print("change: $value");
                    tec.text = globals.packData.timestrFromMillisec(value.toInt());
                    millipos = value.toInt();
                  },
                  min: 0.0,
                  max: vlu.getMaxLayerlength().inMilliseconds.toDouble(),
                  decimalPlaces: 0,
                  defaultValue: vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].fromstamp.inMilliseconds.toDouble(),
                  leading: Text(AppLocalizations.of(context)!.blockmovepos),
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
      if(millipos>=vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].fromstamp.inMilliseconds)
      {
        moveblocksforward(globals.packData.taplayeridx, globals.packData.tapblockidx,millipos-vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].fromstamp.inMilliseconds);
        if(globals.packData.tapblockidx>0)
        {
          vlu.vlb=VideoLayerBlock(vlu.getNewBlockid());

          vlu.vlb.blockcolor = globals.packData.color2(colorcase:10);
          
          vlu.vlb.fileclass = "placeholder";
          vlu.vlb.filename = "placeholder.mp3";
          vlu.vlb.fromstamp = Duration(milliseconds: vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx-1].tostamp.inMilliseconds);
          vlu.vlb.ispubliclib = true;
          vlu.vlb.tostamp = Duration(milliseconds: vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].fromstamp.inMilliseconds);
          vlu.vlb.blocklength = vlu.vlb.tostamp-vlu.vlb.fromstamp;
          vlu.vlb.blend = 0.2;
          vlu.vlb.similarity = 0.1;

          vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks.add(vlu.vlb);

        }
        else
        {
          vlu.vlb=VideoLayerBlock(vlu.getNewBlockid());

          vlu.vlb.blockcolor = globals.packData.color2(colorcase:10);
          
          vlu.vlb.fileclass = "placeholder";
          vlu.vlb.filename = "placeholder.mp3";
          vlu.vlb.fromstamp = Duration(milliseconds: 0);
          vlu.vlb.ispubliclib = true;
          vlu.vlb.tostamp = Duration(milliseconds: vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].fromstamp.inMilliseconds);
          vlu.vlb.blocklength = vlu.vlb.tostamp-vlu.vlb.fromstamp;
          vlu.vlb.blend = 0.2;
          vlu.vlb.similarity = 0.1;

          vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks.add(vlu.vlb);
        }
        vlu.sortBlocksD();
        vlu.calLayerslength();
        vlu.refreshLayerlengthPlaceholder();
      }
      else
      {
        moveblocksbackward(globals.packData.taplayeridx, globals.packData.tapblockidx, vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].fromstamp.inMilliseconds-millipos);
        List<int> removeidx = List.filled(0, 0,growable: true);
        for(int i=globals.packData.tapblockidx-1;i>=0;i--)
        {
          if(vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[i].fromstamp>=vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].fromstamp)
          {
            removeidx.add(i);
          }
          else if
          (
            vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[i].fromstamp<vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].fromstamp
          &&vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[i].tostamp>vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].fromstamp
          )
          {
            vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[i].tostamp = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].fromstamp;
            vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[i].blocklength = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[i].tostamp - vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[i].fromstamp;
          }
        }
        for(int i=0;i<removeidx.length;i++)
        {
          vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks.removeAt(removeidx[i]);
        }
        vlu.sortBlocksD();
        vlu.calLayerslength();
        vlu.refreshLayerlengthPlaceholder();
      }
      await globals.packData.openVideoFile(true,"placeholder.mp3");
      globals.packData.tapvideolayerscrpos = 0;
      globals.packData.mainsetstate.call();
    }
  }

  Future<void> filmlayerdelete()
  async
  {
    if(globals.packData.tapvideolayerscrpos==0||globals.packData.tapvideolayerscrpos==-1)
    {
      await showDialog
      (
        context: context,
        builder: (_) => new 
        AlertDialog
        (
          title: new Text(AppLocalizations.of(context)!.tip),
          content: new Text(AppLocalizations.of(context)!.tapvideoblockfirst),
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
      return;
    }
    await showDialog
    (
      context: context, 
      builder: (_) => new
      AlertDialog
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
              vlu.vls.videolayers.removeAt(globals.packData.taplayeridx);
              vlu.sortLayersZ();
              vlu.calLayerslength();
              vlu.refreshLayerlengthPlaceholder();
              await globals.packData.openVideoFile(true,"placeholder.mp3");
              globals.packData.tapvideolayerscrpos = 0;
              globals.packData.mainsetstate.call();
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
      )
    );
  }

  Future<void> filmblockcombinenext()
  async
  {
    if(globals.packData.tapvideolayerscrpos==0||globals.packData.tapvideolayerscrpos==-1)
    {
      await showDialog
      (
        context: context,
        builder: (_) => new 
        AlertDialog
        (
          title: new Text(AppLocalizations.of(context)!.tip),
          content: new Text(AppLocalizations.of(context)!.tapvideoblockfirst),
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
      return;
    }
    if(vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks.length-1<=globals.packData.tapblockidx)
    {
      await showDialog
      (
        context: context,
        builder: (_) => new 
        AlertDialog
        (
          title: new Text(AppLocalizations.of(context)!.tip),
          content: new Text(AppLocalizations.of(context)!.nonextblock),
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
      return;
    }
    if(vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].respeedenable)
    {
      await showDialog
      (
        context: context,
        builder: (_) => new 
        AlertDialog
        (
          title: new Text(AppLocalizations.of(context)!.tip),
          content: new Text(AppLocalizations.of(context)!.cannoteditrespeed),
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
      return;
    }
    if
    (
      vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].filename!=vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx+1].filename
    ||vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].filestartpos+vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].blocklength!=vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx+1].filestartpos
    ||vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].ispubliclib!=vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx+1].ispubliclib
    )
    {
      await showDialog
      (
        context: context,
        builder: (_) => new 
        AlertDialog
        (
          title: new Text(AppLocalizations.of(context)!.tip),
          content: new Text(AppLocalizations.of(context)!.cannotblockcombine),
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
      return;
    }
    vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].tostamp = Duration(milliseconds: vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx+1].tostamp.inMilliseconds);
    vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].blocklength = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].tostamp-vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].fromstamp;
    vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks.removeAt(globals.packData.tapblockidx+1);
    globals.packData.mainsetstate.call();
  }

  Future<void> separateaudio()
  async
  {
    if(globals.packData.tapvideolayerscrpos==0||globals.packData.tapvideolayerscrpos==-1)
    {
      await showDialog
      (
        context: context,
        builder: (_) => new 
        AlertDialog
        (
          title: new Text(AppLocalizations.of(context)!.tip),
          content: new Text(AppLocalizations.of(context)!.tapvideoblockfirst),
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
      return;
    }
    if(vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].respeedenable)
    {
      await showDialog
      (
        context: context,
        builder: (_) => new 
        AlertDialog
        (
          title: new Text(AppLocalizations.of(context)!.tip),
          content: new Text(AppLocalizations.of(context)!.cannoteditrespeed),
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
      return;
    }
    if(vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].fileclass!="mp4")
    {
      await showDialog
      (
        context: context,
        builder: (_) => new 
        AlertDialog
        (
          title: new Text(AppLocalizations.of(context)!.tip),
          content: new Text(AppLocalizations.of(context)!.taponlyvideoblock),
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
      return;
    }
    if(vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].filename.contains("-silent"))
    {
      await showDialog
      (
        context: context,
        builder: (_) => new 
        AlertDialog
        (
          title: new Text(AppLocalizations.of(context)!.tip),
          content: new Text(AppLocalizations.of(context)!.silentblockhasnoaudio),
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
      return;
    } 
    String poststr='';
    for(int i=0;i<vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks.length;i++)
    {
      poststr+=
      (vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[i].ispubliclib?"1":"0"
      +"^"+vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[i].filename.replaceAll("-silent", "")
      +"^"+globals.packData.timestrFromDuration(vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[i].filestartpos)
      +"^"+globals.packData.timestrFromDuration(vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[i].blocklength)
      +"^"+vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[i].fromstamp.inMilliseconds.toString()
      +"|"
      );
      vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[i].filename =
      vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[i].filename.replaceAll(".mp4", "-silent.mp4");
    }
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
    String rst = (await globals.packData.jsonPostback("alexseparateaudio.php", poststr)).trim();

    vlu.vli = VideoLayerItem(vlu.getNewLayerid());
    vlu.vli.zindex = vlu.vls.videolayers[globals.packData.taplayeridx].zindex+10;
    List<String> rsts=rst.split("|");
    for(int i=0;i<rsts.length;i++)
    {
      if(rsts[i].length<3)continue;
      List<String> rsti = rsts[i].split("^");
      vlu.vlb=VideoLayerBlock(vlu.getNewBlockid());
      vlu.vlb.fileclass="mp3";
      vlu.vlb.blockcolor = globals.packData.color2(colorcase: 7);
      vlu.vlb.ispubliclib = rsti[0]=="0"?false:true;
      vlu.vlb.filename = rsti[1];
      vlu.vlb.filestartpos = Duration(milliseconds: globals.packData.millisecFromTimestr(rsti[2]));
      vlu.vlb.blocklength = Duration(milliseconds: globals.packData.millisecFromTimestr(rsti[3]));
      vlu.vlb.fromstamp = Duration(milliseconds: int.parse(rsti[4]));
      vlu.vlb.tostamp = vlu.vlb.fromstamp + vlu.vlb.blocklength;
      vlu.vli.videoblocks.add(vlu.vlb);
    }
    vlu.vls.videolayers.add(vlu.vli);
    vlu.sortBlocksD();
    vlu.sortLayersZ();
    vlu.calLayerslength();
    vlu.refreshLayerlengthPlaceholder();
    Navigator.pop(context);
    globals.packData.mainsetstate.call();
  }

  Future<void> resizelayer()
  async
  {
    if(globals.packData.tapvideolayerscrpos==0||globals.packData.tapvideolayerscrpos==-1)
    {
      await showDialog
      (
        context: context,
        builder: (_) => new 
        AlertDialog
        (
          title: new Text(AppLocalizations.of(context)!.tip),
          content: new Text(AppLocalizations.of(context)!.tapvideoblockfirst),
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
      return;
    }
    if(vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].fileclass!="mp4"
    &&vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].fileclass!="png")
    {
      await showDialog
      (
        context: context,
        builder: (_) => new 
        AlertDialog
        (
          title: new Text(AppLocalizations.of(context)!.tip),
          content: new Text(AppLocalizations.of(context)!.taponlyvideoblock),
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
      return;
    }
    int dlgrst = 0;
        //vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizeleft=(int.parse(globals.configFile.finalwidth)/2).floor();
        //vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizetop=(int.parse(globals.configFile.finalheight)/2).floor();
        //vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizewidth=(int.parse(globals.configFile.finalwidth)/2).floor();
        //vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizeheight=(int.parse(globals.configFile.finalheight)/2).floor();
    await showDialog
    (
      context: context,
      builder: (context) {
    double dispscale = ((globals.packData.scrwidth/2)-20)/(int.parse(globals.configFile.finalwidth));
    double dispwidth = (globals.packData.scrwidth/2)-20;
    double dispheight = ((globals.packData.scrwidth/2)-20)/globals.packData.videoaspect;
    double dispwidthinner = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizewidth*dispscale;
    double dispheightinner = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizeheight*dispscale;
    double disppaddingleft = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizeleft*dispscale;
    double disppaddingtop = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizetop*dispscale;
    double disppaddingright = dispwidth - disppaddingleft - dispwidthinner;
    double disppaddingbottom = dispheight - disppaddingtop - dispheightinner; 
    String imagep = "";
    if(vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].fileclass=="mp4")
    {
      imagep=globals.configFile.serveraddr+'alexgetpospic.php?key='+globals.packData.encodeDES3CBC(globals.configFile.apikey)
                            +'&file='+vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].filename.replaceAll("-silent", "")+'&milli='+globals.packData.currentrawpos.inMilliseconds.toString();
    }
    else if(vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].fileclass=="png")
    {
      imagep=globals.configFile.serveraddr+'alexgetpospng.php?key='+globals.packData.encodeDES3CBC(globals.configFile.apikey)
                            +'&file='+vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].filename;
    }
    
    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog
        (
          //title: Text(AppLocalizations.of(context)!.),
          //content: Text(AppLocalizations.of(context)!.),
          actions: <Widget>
          [
            Column
            (
              children: 
              [
            Row
            (
              children: 
              [
                SizedBox
                (
                  width: globals.packData.scrwidth/2-100,
                  child: 
                  Column
            (
              children: 
              [
                
                InputSlider
                (
                  onChange: (value)
                  {
                    //print("change: $value");
                    vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizeleft=value.toInt();
    setState(() 
    {
    dispscale = ((globals.packData.scrwidth/2)-20)/(int.parse(globals.configFile.finalwidth));
    dispwidth = (globals.packData.scrwidth/2)-20;
    dispheight = ((globals.packData.scrwidth/2)-20)/globals.packData.videoaspect;
    dispwidthinner = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizewidth*dispscale;
    dispheightinner = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizeheight*dispscale;
    disppaddingleft = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizeleft*dispscale;
    disppaddingtop = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizetop*dispscale;
    disppaddingright = dispwidth - disppaddingleft - dispwidthinner;
    disppaddingbottom = dispheight - disppaddingtop - dispheightinner;
    });
                  },
                  min: 0.0,
                  max: int.parse(globals.configFile.finalwidth)-1,
                  decimalPlaces: 0,
                  defaultValue: vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizeleft.toDouble(),
                  leading: Text(AppLocalizations.of(context)!.resizeleft),
                ),
                InputSlider
                (
                  onChange: (value)
                  {
                    //print("change: $value");
                    vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizetop=value.toInt();
    setState(() 
    {
    dispscale = ((globals.packData.scrwidth/2)-20)/(int.parse(globals.configFile.finalwidth));
    dispwidth = (globals.packData.scrwidth/2)-20;
    dispheight = ((globals.packData.scrwidth/2)-20)/globals.packData.videoaspect;
    dispwidthinner = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizewidth*dispscale;
    dispheightinner = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizeheight*dispscale;
    disppaddingleft = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizeleft*dispscale;
    disppaddingtop = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizetop*dispscale;
    disppaddingright = dispwidth - disppaddingleft - dispwidthinner;
    disppaddingbottom = dispheight - disppaddingtop - dispheightinner;
    });
                  },
                  min: 0.0,
                  max: int.parse(globals.configFile.finalheight)-1,
                  decimalPlaces: 0,
                  defaultValue: vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizetop.toDouble(),
                  leading: Text(AppLocalizations.of(context)!.resizetop),
                ),
                InputSlider
                (
                  onChange: (value)
                  {
                    //print("change: $value");
                    vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizewidth=value.toInt();
                    if(vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizewidth%2!=0)
                    {
                      vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizewidth+=1;
                    }
    setState(() 
    {
    dispscale = ((globals.packData.scrwidth/2)-20)/(int.parse(globals.configFile.finalwidth));
    dispwidth = (globals.packData.scrwidth/2)-20;
    dispheight = ((globals.packData.scrwidth/2)-20)/globals.packData.videoaspect;
    dispwidthinner = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizewidth*dispscale;
    dispheightinner = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizeheight*dispscale;
    disppaddingleft = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizeleft*dispscale;
    disppaddingtop = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizetop*dispscale;
    disppaddingright = dispwidth - disppaddingleft - dispwidthinner;
    disppaddingbottom = dispheight - disppaddingtop - dispheightinner;
    });
                  },
                  min: 16.0,
                  max: int.parse(globals.configFile.finalwidth).toDouble(),
                  decimalPlaces: 0,
                  defaultValue: vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizewidth.toDouble(),
                  leading: Text(AppLocalizations.of(context)!.resizewidth),
                ),
                InputSlider
                (
                  onChange: (value)
                  {
                    //print("change: $value");
                    vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizeheight=value.toInt();
                    if(vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizeheight%2!=0)
                    {
                      vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizeheight+=1;
                    }
    setState(() 
    {
    dispscale = ((globals.packData.scrwidth/2)-20)/(int.parse(globals.configFile.finalwidth));
    dispwidth = (globals.packData.scrwidth/2)-20;
    dispheight = ((globals.packData.scrwidth/2)-20)/globals.packData.videoaspect;
    dispwidthinner = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizewidth*dispscale;
    dispheightinner = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizeheight*dispscale;
    disppaddingleft = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizeleft*dispscale;
    disppaddingtop = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizetop*dispscale;
    disppaddingright = dispwidth - disppaddingleft - dispwidthinner;
    disppaddingbottom = dispheight - disppaddingtop - dispheightinner;
    });
                  },
                  min: 8.0,
                  max: int.parse(globals.configFile.finalheight).toDouble(),
                  decimalPlaces: 0,
                  defaultValue: vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizeheight.toDouble(),
                  leading: Text(AppLocalizations.of(context)!.resizeheight),
                ),
              ],
            ),
                ),
                SizedBox
                (
                  width: globals.packData.scrwidth/2-20,
                  child: 
                  Container
                  (
                    padding: EdgeInsets.fromLTRB
                      (
                        disppaddingleft, 
                        disppaddingtop,
                        disppaddingright>0?disppaddingright:0,
                        disppaddingbottom>0?disppaddingbottom:0,
                      ),
                    width: dispwidth,
                    height: dispheight,
                    color: globals.packData.color2(colorcase: 10),
                    child: 
                    Container
                    (
                      color: globals.packData.color2(colorcase: 9),
                      child: 
ExtendedImage.network
              (
  imagep,
  width: dispwidthinner,
  height: dispheightinner,
  fit: BoxFit.fill,
  cache: true,
  //border: Border.all(color: globals.packData.color2(colorcase:5), width: 1.0),
  shape: BoxShape.rectangle,
  //borderRadius: BorderRadius.all(Radius.circular(5.0)),
  //cancelToken: cancellationToken,
              ),
                    ),
                  )
                ),

              ],
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
        }
        );
      },
    );
    if(dlgrst==1)
    {
      //crop inner width and height
      if(int.parse(globals.configFile.finalwidth)-vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizeleft<vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizewidth)
      {
        vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizewidth
        =int.parse(globals.configFile.finalwidth)-vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizeleft;
      }
      if(int.parse(globals.configFile.finalheight)-vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizetop<vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizeheight)
      {
        vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizeheight
        =int.parse(globals.configFile.finalheight)-vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizetop;
      }
      vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizeenable = true;
      
      //copy block resize info to other blocks in this layer
      for(int i=0;i<vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks.length;i++)
      {
        vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[i].resizeleft = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizeleft;
        vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[i].resizetop = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizetop;
        vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[i].resizewidth = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizewidth;
        vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[i].resizeheight = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizeheight;
        vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[i].resizeenable = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizeenable;
      }
      
      showDialog
      (
        context: context,
        builder: (_) => new 
        AlertDialog
        (
          title: new Text(AppLocalizations.of(context)!.resultdialog),
          content: new Text(AppLocalizations.of(context)!.operationfinished),
          actions: <Widget>
          [
            ElevatedButton
            (
              child: Text(AppLocalizations.of(context)!.ok),
              onPressed: () 
              {
                globals.packData.mainsetstate.call();
                Navigator.of(context).pop();
              },
            )
          ],
        )
      );
    }
  }

  Future<void> setvolume()
  async
  {
    if(globals.packData.tapvideolayerscrpos==0||globals.packData.tapvideolayerscrpos==-1)
    {
      await showDialog
      (
        context: context,
        builder: (_) => new 
        AlertDialog
        (
          title: new Text(AppLocalizations.of(context)!.tip),
          content: new Text(AppLocalizations.of(context)!.tapvideoblockfirst),
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
      return;
    }
    if(vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].fileclass!="mp4"
    &&vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].fileclass!="mp3")
    {
      await showDialog
      (
        context: context,
        builder: (_) => new 
        AlertDialog
        (
          title: new Text(AppLocalizations.of(context)!.tip),
          content: new Text(AppLocalizations.of(context)!.taponlyvideoblock),
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
      return;
    }
    int dlgrst = 0;
    await showDialog
    (
      context: context,
      builder: (BuildContext context)
      {
        return AlertDialog
        (
          //title: Text(AppLocalizations.of(context)!.),
          //content: Text(AppLocalizations.of(context)!.),
          actions: <Widget>
          [
            Column
            (
              children: 
              [
                InputSlider
                (
                  onChange: (value)
                  {
                    vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].revolume=value;
                  },
                  min: 0.1,
                  max: 3.0,
                  decimalPlaces: 2,
                  defaultValue: vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].revolume,
                  leading: Text(AppLocalizations.of(context)!.multipleofvolume),
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

      vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].revolumeenable=true;
      showDialog
      (
        context: context,
        builder: (_) => new 
        AlertDialog
        (
          title: new Text(AppLocalizations.of(context)!.resultdialog),
          content: new Text(AppLocalizations.of(context)!.operationfinished),
          actions: <Widget>
          [
            ElevatedButton
            (
              child: Text(AppLocalizations.of(context)!.ok),
              onPressed: () 
              {
                globals.packData.mainsetstate.call();
                Navigator.of(context).pop();
              },
            )
          ],
        )
      );
    }
  }

  Future<void> setspeed()
  async
  {
    if(globals.packData.tapvideolayerscrpos==0||globals.packData.tapvideolayerscrpos==-1)
    {
      await showDialog
      (
        context: context,
        builder: (_) => new 
        AlertDialog
        (
          title: new Text(AppLocalizations.of(context)!.tip),
          content: new Text(AppLocalizations.of(context)!.tapvideoblockfirst),
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
      return;
    }
    if(vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].fileclass!="mp4"
    &&vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].fileclass!="mp3")
    {
      await showDialog
      (
        context: context,
        builder: (_) => new 
        AlertDialog
        (
          title: new Text(AppLocalizations.of(context)!.tip),
          content: new Text(AppLocalizations.of(context)!.taponlyvideoblock),
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
      return;
    }
    int dlgrst = 0;
    await showDialog
    (
      context: context,
      builder: (BuildContext context)
      {
        return AlertDialog
        (
          //title: Text(AppLocalizations.of(context)!.),
          //content: Text(AppLocalizations.of(context)!.),
          actions: <Widget>
          [
            Column
            (
              children: 
              [
                InputSlider
                (
                  onChange: (value)
                  {
                    vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].respeed=value;
                  },
                  min: 0.5,
                  max: 2.0,
                  decimalPlaces: 2,
                  defaultValue: vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].respeed,
                  leading: Text(AppLocalizations.of(context)!.multipleofspeed),
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
      //fromstamp and tostamp is not changing
      vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].respeedenable=true;
      int millithisblock = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].blocklength.inMilliseconds;
      int forwardlen = (millithisblock/vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].respeed-millithisblock).toInt();
      moveblocksforward(globals.packData.taplayeridx, globals.packData.tapblockidx+1, forwardlen);
      vlu.sortBlocksD();
      vlu.calLayerslength();
      vlu.refreshLayerlengthPlaceholder();
      showDialog
      (
        context: context,
        builder: (_) => new 
        AlertDialog
        (
          title: new Text(AppLocalizations.of(context)!.resultdialog),
          content: new Text(AppLocalizations.of(context)!.operationfinished),
          actions: <Widget>
          [
            ElevatedButton
            (
              child: Text(AppLocalizations.of(context)!.ok),
              onPressed: () 
              {
                globals.packData.mainsetstate.call();
                Navigator.of(context).pop();
              },
            )
          ],
        )
      );
    }
  }

  Future<void> createimage()
  async
  {
    if(globals.packData.tapvideolayerscrpos==0||globals.packData.tapvideolayerscrpos==-1)
    {
      await showDialog
      (
        context: context,
        builder: (_) => new 
        AlertDialog
        (
          title: new Text(AppLocalizations.of(context)!.tip),
          content: new Text(AppLocalizations.of(context)!.tapvideoblockfirst),
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
      return;
    }

      String addingfilename = "temp/"+DateTime.now().millisecondsSinceEpoch.toString()+".png";
      Color currentblockchromakey = globals.packData.color2(colorcase:11);
      double currentblocksimularity = 0.1; 
      double currentblockblend = 0.2;
      await vlu.insertLayerWithPng(false,globals.packData.taplayeridx,addingfilename,
        currentblockchromakey,
        currentblocksimularity,
        currentblockblend);
      globals.packData.tapblockidx = 0;

    int dlgrst = 0;
    String puttext="";
        //vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizeleft=(int.parse(globals.configFile.finalwidth)/2).floor();
        //vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizetop=(int.parse(globals.configFile.finalheight)/2).floor();
        //vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizewidth=(int.parse(globals.configFile.finalwidth)/2).floor();
        //vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizeheight=(int.parse(globals.configFile.finalheight)/2).floor();
    await showDialog
    (
      context: context,
      builder: (context) {
    double dispscale = ((globals.packData.scrwidth/2)-20)/(int.parse(globals.configFile.finalwidth));
    double dispwidth = (globals.packData.scrwidth/2)-20;
    double dispheight = ((globals.packData.scrwidth/2)-20)/globals.packData.videoaspect;
    double dispwidthinner = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizewidth*dispscale;
    double dispheightinner = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizeheight*dispscale;
    double disppaddingleft = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizeleft*dispscale;
    double disppaddingtop = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizetop*dispscale;
    double disppaddingright = dispwidth - disppaddingleft - dispwidthinner;
    double disppaddingbottom = dispheight - disppaddingtop - dispheightinner; 
    String imagep = "";

    imagep=globals.configFile.serveraddr+'alexgetpospng.php?key='+globals.packData.encodeDES3CBC(globals.configFile.publickey)
                            +'&file=abcdef.png';
    
    
    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog
        (
          //title: Text(AppLocalizations.of(context)!.),
          //content: Text(AppLocalizations.of(context)!.),
          actions: <Widget>
          [
            Column
            (
              children: 
              [
                
            Row
            (
              children: 
              [
            SizedBox(width: 200,child:
            TextFormField
            (
              onChanged:
              (text)
              {
                puttext=text;
              },
              decoration: 
              InputDecoration
              (
                contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                labelText: AppLocalizations.of(context)!.puttext,
                border: OutlineInputBorder
                (
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(),
                ),
              ),
              keyboardType: TextInputType.text,
              style: TextStyle
              (
                fontSize: 12,
                //fontFamily: "Poppins",
              ),
            ),),
            SizedBox(width: 10,),
            Text(AppLocalizations.of(context)!.puttextcaution,),
              ]
            ),      
            Row
            (
              children: 
              [
                SizedBox
                (
                  width: globals.packData.scrwidth/2-100,
                  child: 
                  Column
            (
              children: 
              [
                
                InputSlider
                (
                  onChange: (value)
                  {
                    //print("change: $value");
                    vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizeleft=value.toInt();
    setState(() 
    {
    dispscale = ((globals.packData.scrwidth/2)-20)/(int.parse(globals.configFile.finalwidth));
    dispwidth = (globals.packData.scrwidth/2)-20;
    dispheight = ((globals.packData.scrwidth/2)-20)/globals.packData.videoaspect;
    dispwidthinner = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizewidth*dispscale;
    dispheightinner = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizeheight*dispscale;
    disppaddingleft = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizeleft*dispscale;
    disppaddingtop = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizetop*dispscale;
    disppaddingright = dispwidth - disppaddingleft - dispwidthinner;
    disppaddingbottom = dispheight - disppaddingtop - dispheightinner;
    });
                  },
                  min: 0.0,
                  max: int.parse(globals.configFile.finalwidth)-1,
                  decimalPlaces: 0,
                  defaultValue: vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizeleft.toDouble(),
                  leading: Text(AppLocalizations.of(context)!.resizeleft),
                ),
                InputSlider
                (
                  onChange: (value)
                  {
                    //print("change: $value");
                    vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizetop=value.toInt();
    setState(() 
    {
    dispscale = ((globals.packData.scrwidth/2)-20)/(int.parse(globals.configFile.finalwidth));
    dispwidth = (globals.packData.scrwidth/2)-20;
    dispheight = ((globals.packData.scrwidth/2)-20)/globals.packData.videoaspect;
    dispwidthinner = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizewidth*dispscale;
    dispheightinner = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizeheight*dispscale;
    disppaddingleft = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizeleft*dispscale;
    disppaddingtop = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizetop*dispscale;
    disppaddingright = dispwidth - disppaddingleft - dispwidthinner;
    disppaddingbottom = dispheight - disppaddingtop - dispheightinner;
    });
                  },
                  min: 0.0,
                  max: int.parse(globals.configFile.finalheight)-1,
                  decimalPlaces: 0,
                  defaultValue: vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizetop.toDouble(),
                  leading: Text(AppLocalizations.of(context)!.resizetop),
                ),
                InputSlider
                (
                  onChange: (value)
                  {
                    //print("change: $value");
                    vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizewidth=value.toInt();
                    if(vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizewidth%2!=0)
                    {
                      vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizewidth+=1;
                    }
    setState(() 
    {
    dispscale = ((globals.packData.scrwidth/2)-20)/(int.parse(globals.configFile.finalwidth));
    dispwidth = (globals.packData.scrwidth/2)-20;
    dispheight = ((globals.packData.scrwidth/2)-20)/globals.packData.videoaspect;
    dispwidthinner = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizewidth*dispscale;
    dispheightinner = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizeheight*dispscale;
    disppaddingleft = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizeleft*dispscale;
    disppaddingtop = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizetop*dispscale;
    disppaddingright = dispwidth - disppaddingleft - dispwidthinner;
    disppaddingbottom = dispheight - disppaddingtop - dispheightinner;
    });
                  },
                  min: 16.0,
                  max: int.parse(globals.configFile.finalwidth).toDouble(),
                  decimalPlaces: 0,
                  defaultValue: vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizewidth.toDouble(),
                  leading: Text(AppLocalizations.of(context)!.resizewidth),
                ),
                InputSlider
                (
                  onChange: (value)
                  {
                    //print("change: $value");
                    vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizeheight=value.toInt();
                    if(vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizeheight%2!=0)
                    {
                      vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizeheight+=1;
                    }
    setState(() 
    {
    dispscale = ((globals.packData.scrwidth/2)-20)/(int.parse(globals.configFile.finalwidth));
    dispwidth = (globals.packData.scrwidth/2)-20;
    dispheight = ((globals.packData.scrwidth/2)-20)/globals.packData.videoaspect;
    dispwidthinner = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizewidth*dispscale;
    dispheightinner = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizeheight*dispscale;
    disppaddingleft = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizeleft*dispscale;
    disppaddingtop = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizetop*dispscale;
    disppaddingright = dispwidth - disppaddingleft - dispwidthinner;
    disppaddingbottom = dispheight - disppaddingtop - dispheightinner;
    });
                  },
                  min: 8.0,
                  max: int.parse(globals.configFile.finalheight).toDouble(),
                  decimalPlaces: 0,
                  defaultValue: vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizeheight.toDouble(),
                  leading: Text(AppLocalizations.of(context)!.resizeheight),
                ),
              ],
            ),
                ),
                SizedBox
                (
                  width: globals.packData.scrwidth/2-20,
                  child: 
                  Container
                  (
                    padding: EdgeInsets.fromLTRB
                      (
                        disppaddingleft, 
                        disppaddingtop,
                        disppaddingright>0?disppaddingright:0,
                        disppaddingbottom>0?disppaddingbottom:0,
                      ),
                    width: dispwidth,
                    height: dispheight,
                    color: globals.packData.color2(colorcase: 10),
                    child: 
                    Container
                    (
                      color: globals.packData.color2(colorcase: 9),
                      child: 
ExtendedImage.network
              (
  imagep,
  width: dispwidthinner,
  height: dispheightinner,
  fit: BoxFit.fill,
  cache: true,
  //border: Border.all(color: globals.packData.color2(colorcase:5), width: 1.0),
  shape: BoxShape.rectangle,
  //borderRadius: BorderRadius.all(Radius.circular(5.0)),
  //cancelToken: cancellationToken,
              ),
                    ),
                  )
                ),

              ],
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
        }
        );
      },
    );
    if(dlgrst==1)
    {
      String poststr = 
      addingfilename+"|"+puttext;
      await globals.packData.jsonPostback("alexputtext.php", poststr);

      //crop inner width and height
      if(int.parse(globals.configFile.finalwidth)-vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizeleft<vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizewidth)
      {
        vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizewidth
        =int.parse(globals.configFile.finalwidth)-vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizeleft;
      }
      if(int.parse(globals.configFile.finalheight)-vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizetop<vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizeheight)
      {
        vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizeheight
        =int.parse(globals.configFile.finalheight)-vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizetop;
      }
      vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizeenable = true;
      
      //copy block resize info to other blocks in this layer
      for(int i=0;i<vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks.length;i++)
      {
        vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[i].resizeleft = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizeleft;
        vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[i].resizetop = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizetop;
        vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[i].resizewidth = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizewidth;
        vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[i].resizeheight = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizeheight;
        vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[i].resizeenable = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizeenable;
      }
      
      showDialog
      (
        context: context,
        builder: (_) => new 
        AlertDialog
        (
          title: new Text(AppLocalizations.of(context)!.resultdialog),
          content: new Text(AppLocalizations.of(context)!.operationfinished),
          actions: <Widget>
          [
            ElevatedButton
            (
              child: Text(AppLocalizations.of(context)!.ok),
              onPressed: () 
              {
                globals.packData.mainsetstate.call();
                Navigator.of(context).pop();
              },
            )
          ],
        )
      );
    }
    else
    {
      vlu.vls.videolayers.removeAt(globals.packData.taplayeridx);
    }
  }

  Future<void> advancedargs()
  async
  {
    if(globals.packData.tapvideolayerscrpos==0||globals.packData.tapvideolayerscrpos==-1)
    {
      await showDialog
      (
        context: context,
        builder: (_) => new 
        AlertDialog
        (
          title: new Text(AppLocalizations.of(context)!.tip),
          content: new Text(AppLocalizations.of(context)!.tapvideoblockfirst),
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
      return;
    }

    int dlgrst = 0;
    String blockcreatestamp = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].createstamp.toString();
    String blockfilename = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].filename;
    String blockfromstamp = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].fromstamp.toString();
    String blocktostamp = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].tostamp.toString();
    String blocklength = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].blocklength.toString();
    String blockfileclass = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].fileclass;
    String blockcolor = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].blockcolor.value.toRadixString(16);
    String blocksimilarity = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].similarity.toString();
    String blockblend = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].blend.toString();
    String blockfilestartpos = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].filestartpos.toString();
    String blockresizeleft = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizeleft.toString();
    String blockresizetop = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizetop.toString();
    String blockresizewidth = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizewidth.toString();
    String blockresizeheight = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizeheight.toString();
    String blockresizeenable = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizeenable.toString();
    String blockrespeed = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].respeed.toString();
    String blockrespeedenable = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].respeedenable.toString();
    String blockrevolume = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].revolume.toString();
    String blockrevolumeenable = vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].revolumeenable.toString();
    await showDialog
    (
      context: context,
      builder: (BuildContext context)
      {
        return AlertDialog
        (
          //title: Text(AppLocalizations.of(context)!.),
          //content: Text(AppLocalizations.of(context)!.),
          actions: <Widget>
          [
            Column
            (
            children:
            [
            SizedBox(width:globals.packData.scrwidth-300,
            height:globals.packData.scrheight-200,
            child:
            ListView
            (
              children: 
              [
                Row
                (
                  children: 
                  [
                    SizedBox(width: 200,child:
                    TextFormField
                    (
                      initialValue: vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].createstamp.toString(),
                      onChanged:
                      (text)
                      {
                        blockcreatestamp = text;
                      },
                      decoration: 
                      InputDecoration
                      (
                        contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        labelText: AppLocalizations.of(context)!.blockcreatestamp,
                        border: OutlineInputBorder
                        (
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(),
                        ),
                      ),
                      keyboardType: TextInputType.text,
                      style: TextStyle
                      (
                        fontSize: 12,
                        //fontFamily: "Poppins",
                      ),
                    ),),
                    SizedBox(width: 10,),
                    Text(AppLocalizations.of(context)!.blockcreatestamp,),
                  ]
                ),
                Row
                (
                  children: 
                  [
                    SizedBox(width: 200,child:
                    TextFormField
                    (
                      initialValue: vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].filename,
                      onChanged:
                      (text)
                      {
                        blockfilename = text;
                      },
                      decoration: 
                      InputDecoration
                      (
                        contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        labelText: AppLocalizations.of(context)!.blockfilename,
                        border: OutlineInputBorder
                        (
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(),
                        ),
                      ),
                      keyboardType: TextInputType.text,
                      style: TextStyle
                      (
                        fontSize: 12,
                        //fontFamily: "Poppins",
                      ),
                    ),),
                    SizedBox(width: 10,),
                    Text(AppLocalizations.of(context)!.blockfilename,),
                  ]
                ),
                Row
                (
                  children: 
                  [
                    SizedBox(width: 200,child:
                    TextFormField
                    (
                      initialValue: vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].fromstamp.toString(),
                      onChanged:
                      (text)
                      {
                        blockfromstamp = text;
                      },
                      decoration: 
                      InputDecoration
                      (
                        contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        labelText: AppLocalizations.of(context)!.blockfromstamp,
                        border: OutlineInputBorder
                        (
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(),
                        ),
                      ),
                      keyboardType: TextInputType.text,
                      style: TextStyle
                      (
                        fontSize: 12,
                        //fontFamily: "Poppins",
                      ),
                    ),),
                    SizedBox(width: 10,),
                    Text(AppLocalizations.of(context)!.blockfromstamp,),
                  ]
                ),
                Row
                (
                  children: 
                  [
                    SizedBox(width: 200,child:
                    TextFormField
                    (
                      initialValue: vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].tostamp.toString(),
                      onChanged:
                      (text)
                      {
                        blocktostamp = text;
                      },
                      decoration: 
                      InputDecoration
                      (
                        contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        labelText: AppLocalizations.of(context)!.blocktostamp,
                        border: OutlineInputBorder
                        (
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(),
                        ),
                      ),
                      keyboardType: TextInputType.text,
                      style: TextStyle
                      (
                        fontSize: 12,
                        //fontFamily: "Poppins",
                      ),
                    ),),
                    SizedBox(width: 10,),
                    Text(AppLocalizations.of(context)!.blocktostamp,),
                  ]
                ),
                Row
                (
                  children: 
                  [
                    SizedBox(width: 200,child:
                    TextFormField
                    (
                      initialValue: vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].blocklength.toString(),
                      onChanged:
                      (text)
                      {
                        blocklength = text;
                      },
                      decoration: 
                      InputDecoration
                      (
                        contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        labelText: AppLocalizations.of(context)!.blocklength,
                        border: OutlineInputBorder
                        (
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(),
                        ),
                      ),
                      keyboardType: TextInputType.text,
                      style: TextStyle
                      (
                        fontSize: 12,
                        //fontFamily: "Poppins",
                      ),
                    ),),
                    SizedBox(width: 10,),
                    Text(AppLocalizations.of(context)!.blocklength,),
                  ]
                ),
                Row
                (
                  children: 
                  [
                    SizedBox(width: 200,child:
                    TextFormField
                    (
                      initialValue: vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].fileclass,
                      onChanged:
                      (text)
                      {
                        blockfileclass = text;
                      },
                      decoration: 
                      InputDecoration
                      (
                        contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        labelText: AppLocalizations.of(context)!.blockfileclass,
                        border: OutlineInputBorder
                        (
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(),
                        ),
                      ),
                      keyboardType: TextInputType.text,
                      style: TextStyle
                      (
                        fontSize: 12,
                        //fontFamily: "Poppins",
                      ),
                    ),),
                    SizedBox(width: 10,),
                    Text(AppLocalizations.of(context)!.blockfileclass,),
                  ]
                ),
                Row
                (
                  children: 
                  [
                    SizedBox(width: 200,child:
                    TextFormField
                    (
                      initialValue: vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].blockcolor.value.toRadixString(16),
                      onChanged:
                      (text)
                      {
                        blockcolor = text;
                      },
                      decoration: 
                      InputDecoration
                      (
                        contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        labelText: AppLocalizations.of(context)!.blockcolor,
                        border: OutlineInputBorder
                        (
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(),
                        ),
                      ),
                      keyboardType: TextInputType.text,
                      style: TextStyle
                      (
                        fontSize: 12,
                        //fontFamily: "Poppins",
                      ),
                    ),),
                    SizedBox(width: 10,),
                    Text(AppLocalizations.of(context)!.blockcolor,),
                  ]
                ),
                Row
                (
                  children: 
                  [
                    SizedBox(width: 200,child:
                    TextFormField
                    (
                      initialValue: vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].similarity.toString(),
                      onChanged:
                      (text)
                      {
                        blocksimilarity = text;
                      },
                      decoration: 
                      InputDecoration
                      (
                        contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        labelText: AppLocalizations.of(context)!.blocksimilarity,
                        border: OutlineInputBorder
                        (
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(),
                        ),
                      ),
                      keyboardType: TextInputType.text,
                      style: TextStyle
                      (
                        fontSize: 12,
                        //fontFamily: "Poppins",
                      ),
                    ),),
                    SizedBox(width: 10,),
                    Text(AppLocalizations.of(context)!.blocksimilarity,),
                  ]
                ),
                Row
                (
                  children: 
                  [
                    SizedBox(width: 200,child:
                    TextFormField
                    (
                      initialValue: vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].blend.toString(),
                      onChanged:
                      (text)
                      {
                        blockblend = text;
                      },
                      decoration: 
                      InputDecoration
                      (
                        contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        labelText: AppLocalizations.of(context)!.blockblend,
                        border: OutlineInputBorder
                        (
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(),
                        ),
                      ),
                      keyboardType: TextInputType.text,
                      style: TextStyle
                      (
                        fontSize: 12,
                        //fontFamily: "Poppins",
                      ),
                    ),),
                    SizedBox(width: 10,),
                    Text(AppLocalizations.of(context)!.blockblend,),
                  ]
                ),
                Row
                (
                  children: 
                  [
                    SizedBox(width: 200,child:
                    TextFormField
                    (
                      initialValue: vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].filestartpos.toString(),
                      onChanged:
                      (text)
                      {
                        blockfilestartpos = text;
                      },
                      decoration: 
                      InputDecoration
                      (
                        contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        labelText: AppLocalizations.of(context)!.blockfilestartpos,
                        border: OutlineInputBorder
                        (
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(),
                        ),
                      ),
                      keyboardType: TextInputType.text,
                      style: TextStyle
                      (
                        fontSize: 12,
                        //fontFamily: "Poppins",
                      ),
                    ),),
                    SizedBox(width: 10,),
                    Text(AppLocalizations.of(context)!.blockfilestartpos,),
                  ]
                ),
                Row
                (
                  children: 
                  [
                    SizedBox(width: 200,child:
                    TextFormField
                    (
                      initialValue: vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizeleft.toString(),
                      onChanged:
                      (text)
                      {
                        blockresizeleft = text;
                      },
                      decoration: 
                      InputDecoration
                      (
                        contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        labelText: AppLocalizations.of(context)!.blockresizeleft,
                        border: OutlineInputBorder
                        (
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(),
                        ),
                      ),
                      keyboardType: TextInputType.text,
                      style: TextStyle
                      (
                        fontSize: 12,
                        //fontFamily: "Poppins",
                      ),
                    ),),
                    SizedBox(width: 10,),
                    Text(AppLocalizations.of(context)!.blockresizeleft,),
                  ]
                ),
                Row
                (
                  children: 
                  [
                    SizedBox(width: 200,child:
                    TextFormField
                    (
                      initialValue: vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizetop.toString(),
                      onChanged:
                      (text)
                      {
                        blockresizetop = text;
                      },
                      decoration: 
                      InputDecoration
                      (
                        contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        labelText: AppLocalizations.of(context)!.blockresizetop,
                        border: OutlineInputBorder
                        (
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(),
                        ),
                      ),
                      keyboardType: TextInputType.text,
                      style: TextStyle
                      (
                        fontSize: 12,
                        //fontFamily: "Poppins",
                      ),
                    ),),
                    SizedBox(width: 10,),
                    Text(AppLocalizations.of(context)!.blockresizetop,),
                  ]
                ),
                Row
                (
                  children: 
                  [
                    SizedBox(width: 200,child:
                    TextFormField
                    (
                      initialValue: vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizewidth.toString(),
                      onChanged:
                      (text)
                      {
                        blockresizewidth = text;
                      },
                      decoration: 
                      InputDecoration
                      (
                        contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        labelText: AppLocalizations.of(context)!.blockresizewidth,
                        border: OutlineInputBorder
                        (
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(),
                        ),
                      ),
                      keyboardType: TextInputType.text,
                      style: TextStyle
                      (
                        fontSize: 12,
                        //fontFamily: "Poppins",
                      ),
                    ),),
                    SizedBox(width: 10,),
                    Text(AppLocalizations.of(context)!.blockresizewidth,),
                  ]
                ),
                Row
                (
                  children: 
                  [
                    SizedBox(width: 200,child:
                    TextFormField
                    (
                      initialValue: vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizeheight.toString(),
                      onChanged:
                      (text)
                      {
                        blockresizeheight = text;
                      },
                      decoration: 
                      InputDecoration
                      (
                        contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        labelText: AppLocalizations.of(context)!.blockresizeheight,
                        border: OutlineInputBorder
                        (
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(),
                        ),
                      ),
                      keyboardType: TextInputType.text,
                      style: TextStyle
                      (
                        fontSize: 12,
                        //fontFamily: "Poppins",
                      ),
                    ),),
                    SizedBox(width: 10,),
                    Text(AppLocalizations.of(context)!.blockresizeheight,),
                  ]
                ),
                Row
                (
                  children: 
                  [
                    SizedBox(width: 200,child:
                    TextFormField
                    (
                      initialValue: vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizeenable.toString(),
                      onChanged:
                      (text)
                      {
                        blockresizeenable = text;
                      },
                      decoration: 
                      InputDecoration
                      (
                        contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        labelText: AppLocalizations.of(context)!.blockresizeenable,
                        border: OutlineInputBorder
                        (
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(),
                        ),
                      ),
                      keyboardType: TextInputType.text,
                      style: TextStyle
                      (
                        fontSize: 12,
                        //fontFamily: "Poppins",
                      ),
                    ),),
                    SizedBox(width: 10,),
                    Text(AppLocalizations.of(context)!.blockresizeenable,),
                  ]
                ),
                Row
                (
                  children: 
                  [
                    SizedBox(width: 200,child:
                    TextFormField
                    (
                      initialValue: vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].respeed.toString(),
                      onChanged:
                      (text)
                      {
                        blockrespeed = text;
                      },
                      decoration: 
                      InputDecoration
                      (
                        contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        labelText: AppLocalizations.of(context)!.blockrespeed,
                        border: OutlineInputBorder
                        (
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(),
                        ),
                      ),
                      keyboardType: TextInputType.text,
                      style: TextStyle
                      (
                        fontSize: 12,
                        //fontFamily: "Poppins",
                      ),
                    ),),
                    SizedBox(width: 10,),
                    Text(AppLocalizations.of(context)!.blockrespeed,),
                  ]
                ),
                Row
                (
                  children: 
                  [
                    SizedBox(width: 200,child:
                    TextFormField
                    (
                      initialValue: vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].respeedenable.toString(),
                      onChanged:
                      (text)
                      {
                        blockrespeedenable = text;
                      },
                      decoration: 
                      InputDecoration
                      (
                        contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        labelText: AppLocalizations.of(context)!.blockrespeedenable,
                        border: OutlineInputBorder
                        (
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(),
                        ),
                      ),
                      keyboardType: TextInputType.text,
                      style: TextStyle
                      (
                        fontSize: 12,
                        //fontFamily: "Poppins",
                      ),
                    ),),
                    SizedBox(width: 10,),
                    Text(AppLocalizations.of(context)!.blockrespeedenable,),
                  ]
                ),
                Row
                (
                  children: 
                  [
                    SizedBox(width: 200,child:
                    TextFormField
                    (
                      initialValue: vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].revolume.toString(),
                      onChanged:
                      (text)
                      {
                        blockrevolume = text;
                      },
                      decoration: 
                      InputDecoration
                      (
                        contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        labelText: AppLocalizations.of(context)!.blockrevolume,
                        border: OutlineInputBorder
                        (
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(),
                        ),
                      ),
                      keyboardType: TextInputType.text,
                      style: TextStyle
                      (
                        fontSize: 12,
                        //fontFamily: "Poppins",
                      ),
                    ),),
                    SizedBox(width: 10,),
                    Text(AppLocalizations.of(context)!.blockrevolume,),
                  ]
                ),
                Row
                (
                  children: 
                  [
                    SizedBox(width: 200,child:
                    TextFormField
                    (
                      initialValue: vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].revolumeenable.toString(),
                      onChanged:
                      (text)
                      {
                        blockrevolumeenable = text;
                      },
                      decoration: 
                      InputDecoration
                      (
                        contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        labelText: AppLocalizations.of(context)!.blockrevolumeenable,
                        border: OutlineInputBorder
                        (
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(),
                        ),
                      ),
                      keyboardType: TextInputType.text,
                      style: TextStyle
                      (
                        fontSize: 12,
                        //fontFamily: "Poppins",
                      ),
                    ),),
                    SizedBox(width: 10,),
                    Text(AppLocalizations.of(context)!.blockrevolumeenable,),
                  ]
                ),
              ],
            ),
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
    builder: (BuildContext context)
    {
      return AlertDialog
      (
        title: Text(AppLocalizations.of(context)!.choosedialog),
        content: Text(AppLocalizations.of(context)!.suretoapply),
        actions: <Widget>
        [
          ElevatedButton
          (
            child: Text(AppLocalizations.of(context)!.yes),
            onPressed: () 
            async
            {
              try
              {
                vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].createstamp = DateTime.parse(blockcreatestamp
                //.substring(0,19)
                );
                vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].filename = blockfilename;
                vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].fromstamp = globals.packData.parseDuration(blockfromstamp);
                vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].tostamp = globals.packData.parseDuration(blocktostamp);
                vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].blocklength = globals.packData.parseDuration(blocklength);
                vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].fileclass = blockfileclass;
                vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].blockcolor = Color(int.parse(blockcolor,radix: 16));
                vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].similarity = double.parse(blocksimilarity);
                vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].blend = double.parse(blockblend);
                vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].filestartpos = globals.packData.parseDuration(blockfilestartpos);
                vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizeleft = int.parse(blockresizeleft);
                vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizetop = int.parse(blockresizetop);
                vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizewidth = int.parse(blockresizewidth);
                vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizeheight = int.parse(blockresizeheight);
                vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].resizeenable = blockresizeenable.toLowerCase() == 'true';
                vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].respeed = double.parse(blockrespeed);
                vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].respeedenable = blockrespeedenable.toLowerCase() == 'true';
                vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].revolume = double.parse(blockrevolume);
                vlu.vls.videolayers[globals.packData.taplayeridx].videoblocks[globals.packData.tapblockidx].revolumeenable = blockrevolumeenable.toLowerCase() == 'true';
              }
              catch(e)
              {
                await showDialog
                (
                context: context,
                builder: (_) => new 
                AlertDialog
                (
                  title: new Text(AppLocalizations.of(context)!.tip),
                  content: new Text(AppLocalizations.of(context)!.errorvalueconvert + e.toString()),
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
              }
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
  }

  Future<void> layerdown()
  async
  {
    if(globals.packData.tapvideolayerscrpos==0||globals.packData.tapvideolayerscrpos==-1)
    {
      await showDialog
      (
        context: context,
        builder: (_) => new 
        AlertDialog
        (
          title: new Text(AppLocalizations.of(context)!.tip),
          content: new Text(AppLocalizations.of(context)!.tapvideoblockfirst),
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
      return;
    }
    if(globals.packData.taplayeridx==vlu.vls.videolayers.length-1)
    {
      await showDialog
      (
        context: context,
        builder: (_) => new 
        AlertDialog
        (
          title: new Text(AppLocalizations.of(context)!.tip),
          content: new Text(AppLocalizations.of(context)!.alreadybottomlayer),
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
      return;
    }
    int zext = vlu.vls.videolayers[globals.packData.taplayeridx].zindex;
    vlu.vls.videolayers[globals.packData.taplayeridx].zindex = vlu.vls.videolayers[globals.packData.taplayeridx+1].zindex;
    vlu.vls.videolayers[globals.packData.taplayeridx+1].zindex = zext;
    vlu.sortLayersZ();
    globals.packData.taplayeridx=globals.packData.taplayeridx+1;
    globals.packData.mainsetstate.call();
  }

  Future<void> layerup()
  async
  {
    if(globals.packData.tapvideolayerscrpos==0||globals.packData.tapvideolayerscrpos==-1)
    {
      await showDialog
      (
        context: context,
        builder: (_) => new 
        AlertDialog
        (
          title: new Text(AppLocalizations.of(context)!.tip),
          content: new Text(AppLocalizations.of(context)!.tapvideoblockfirst),
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
      return;
    }
    if(globals.packData.taplayeridx==0)
    {
      await showDialog
      (
        context: context,
        builder: (_) => new 
        AlertDialog
        (
          title: new Text(AppLocalizations.of(context)!.tip),
          content: new Text(AppLocalizations.of(context)!.alreadytoplayer),
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
      return;
    }
    int zext = vlu.vls.videolayers[globals.packData.taplayeridx].zindex;
    vlu.vls.videolayers[globals.packData.taplayeridx].zindex = vlu.vls.videolayers[globals.packData.taplayeridx-1].zindex;
    vlu.vls.videolayers[globals.packData.taplayeridx-1].zindex = zext;
    vlu.sortLayersZ();
    globals.packData.taplayeridx=globals.packData.taplayeridx-1;
    globals.packData.mainsetstate.call();
  }

  Future<void> nextlayer()
  async
  {
    if(globals.packData.tapvideolayerscrpos==0||globals.packData.tapvideolayerscrpos==-1)
    {
      await showDialog
      (
        context: context,
        builder: (_) => new 
        AlertDialog
        (
          title: new Text(AppLocalizations.of(context)!.tip),
          content: new Text(AppLocalizations.of(context)!.tapvideoblockfirst),
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
      return;
    }
    int nexttaplayeridx;
    if(globals.packData.taplayeridx==vlu.vls.videolayers.length-1)
    {
      nexttaplayeridx=0;
    }
    else
    {
      nexttaplayeridx=globals.packData.taplayeridx+1;
    }
    for(int i=0;i<vlu.vls.videolayers[nexttaplayeridx].videoblocks.length;i++)
    {
      if(globals.packData.currentposinmilli>=vlu.vls.videolayers[nexttaplayeridx].videoblocks[i].fromstamp.inMilliseconds
      &&globals.packData.currentposinmilli<vlu.vls.videolayers[nexttaplayeridx].videoblocks[i].tostamp.inMilliseconds)
      {
        globals.packData.tapblockidx = i;
        globals.packData.taplayeridx = nexttaplayeridx;
        break;
      }
    }
    globals.packData.mainsetstate.call();
  }

  Future<void> icontapped(int index)
  async
  {
    try
    {
    switch (index) 
    {
      case 0:
        await filmcut();
        break;
      case 1:
        await filmblockcut();
        break;
      case 2:
        await filmblockcopy();
        break;
      case 3:
        await filmblockpasteahead();
        break;
      case 4:
        await filmblockpasteafter();
        break;
      case 5:
        await filmblockpastecover();
        break;
      case 6:
        await filmblockmove();
        break;
      case 7:
        await filmlayerdelete();
        break;
      case 8:
        await filmblockcombinenext();
        break;
      case 9:
        await separateaudio();
        break;
      case 10:
        await resizelayer();
        break;
      case 11:
        await setvolume();
        break;
      case 12:
        await setspeed();
        break;
      case 13:
        await createimage();
        break;
      case 14:
        await advancedargs();
        break;
      case 15:
        await layerdown();
        break;
      case 16:
        await layerup();
        break;
      case 17:
        await nextlayer();
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
        return Icon(Icons.content_cut);
      case 1:
        return Icon(Icons.content_paste_off);
      case 2:
        return Icon(Icons.file_copy);        
      case 3:
        return Icon(Icons.skip_previous);
      case 4:
        return Icon(Icons.skip_next);
      case 5:
        return Icon(Icons.slideshow);
      case 6:
        return Icon(Icons.drive_file_move);
      case 7:
        return Icon(Icons.remove_circle);
      case 8:
        return Icon(Icons.table_chart);
      case 9:
        return Icon(Icons.library_music);
      case 10:
        return Icon(Icons.photo_size_select_large);
      case 11:
        return Icon(Icons.volume_up);
      case 12:
        return Icon(Icons.shutter_speed);
      case 13:
        return Icon(Icons.collections);
      case 14:
        return Icon(Icons.fact_check);
      case 15:
        return Icon(Icons.keyboard_arrow_down);
      case 16:
        return Icon(Icons.keyboard_arrow_up);
      case 17:
        return Icon(Icons.subscriptions);

      default:
        return Icon(Icons.access_alarm);
    }
  }

  Text buildtext(int index)
  {
    switch (index) 
    {
      case 0:
        return Text(AppLocalizations.of(context)!.filmcut,style: TextStyle(fontSize: 10),);
      case 1:
        return Text(AppLocalizations.of(context)!.filmblockcut,style: TextStyle(fontSize: 10),);
      case 2:
        return Text(AppLocalizations.of(context)!.filmblockcopy,style: TextStyle(fontSize: 10),);
      case 3:
        return Text(AppLocalizations.of(context)!.filmblockpasteahead,style: TextStyle(fontSize: 10),);
      case 4:
        return Text(AppLocalizations.of(context)!.filmblockpasteafter,style: TextStyle(fontSize: 10),);
      case 5:
        return Text(AppLocalizations.of(context)!.filmblockpastecover,style: TextStyle(fontSize: 10),);
      case 6:
        return Text(AppLocalizations.of(context)!.filmblockmove,style: TextStyle(fontSize: 10),);
      case 7:
        return Text(AppLocalizations.of(context)!.filmlayerdelete,style: TextStyle(fontSize: 10),);
      case 8:
        return Text(AppLocalizations.of(context)!.filmblockcombinenext,style: TextStyle(fontSize: 10),);
      case 9:
        return Text(AppLocalizations.of(context)!.separateaudio,style: TextStyle(fontSize: 10),);
      case 10:
        return Text(AppLocalizations.of(context)!.resizethislayer,style: TextStyle(fontSize: 10),);
      case 11:
        return Text(AppLocalizations.of(context)!.setvolume,style: TextStyle(fontSize: 10),);
      case 12:
        return Text(AppLocalizations.of(context)!.setspeed,style: TextStyle(fontSize: 10),);
      case 13:
        return Text(AppLocalizations.of(context)!.createimage,style: TextStyle(fontSize: 10),);
      case 14:
        return Text(AppLocalizations.of(context)!.advancedargs,style: TextStyle(fontSize: 10),);
      case 15:
        return Text(AppLocalizations.of(context)!.layerdown,style: TextStyle(fontSize: 10),);
      case 16:
        return Text(AppLocalizations.of(context)!.layerup,style: TextStyle(fontSize: 10),);
      case 17:
        return Text(AppLocalizations.of(context)!.nextlayer,style: TextStyle(fontSize: 10),);


      default:
        return Text('test');
    }
  }

  @override
  Widget build(BuildContext context) 
  {
    return Container
    (
      child: 
      Column
      (
        children: 
        [
          Container
          (
            alignment: Alignment.center,
            height: globals.packData.titleheight,
            //width: globals.packData.scrwidth-globals.packData.videowidth-globals.packData.tabsize,
            color: globals.packData.color2(colorcase: 6),
            padding: EdgeInsets.all(0.0),
            child: 
            Text
            (
              AppLocalizations.of(context)!.regulareditor,
              style: TextStyle
              (
                fontSize: 10.0,
              ),
            ),
          ),
          SizedBox
          (
            height: globals.packData.videoheight-globals.packData.buttonheight-globals.packData.buttongap-globals.packData.titleheight-5.0,
            child:
            Align
            (
            alignment: Alignment.bottomCenter, 
            child:
StaggeredGridView.countBuilder
(
  reverse: true,
  //shrinkWrap: true,
  //addRepaintBoundaries: false,
  padding: EdgeInsets.all(0.0),
  crossAxisCount: 5,
  //((globals.packData.scrwidth-globals.packData.videowidth-globals.packData.tabsize)~/70),
  itemCount: 18,
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
  mainAxisSpacing: 0.0,
  crossAxisSpacing: 0.0,
),

            ),
          ),
          SizedBox
          (
            height: globals.packData.buttonheight+globals.packData.buttongap,
            child:
            Row
            (
              children:
              [
                SizedBox
                (
                  width: 10.0, 
                ),
                Text(AppLocalizations.of(context)!.panelcanscroll,style: TextStyle(fontSize: 10),),
                SizedBox
                (
                  width: globals.packData.optpanelwidth-250.0, 
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
        ],
      ),
    );
  }
}
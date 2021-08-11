// ignore_for_file: prefer_const_constructors

import 'package:flutter/painting.dart';
import 'globals.dart' as globals;

VideoLayerUtils vlu = VideoLayerUtils();

////////////////////////////////////////////////////////////////////////////////
/// video layers data struct function class
/// ////////////////////////////////////////////////////////////////////////////
class VideoLayerUtils
{
  //int currentblockid = 1;
  //int currentlayerid = 1;
  //int currentstructid = 1;
  //Duration lastblockend = Duration();
  VideoLayerStruct vls = VideoLayerStruct(0);
  VideoLayerItem vli = VideoLayerItem(0);
  VideoLayerBlock vlb = VideoLayerBlock(0);
  VideoLayerBlock vlbcopied = VideoLayerBlock(0);
  int maxlayercount = 12;
  int maxblockcount = 1024;
  int maxzindex = 65536;

  VideoLayerUtils()
  {
    //this.currentblockid = 1;
    //this.currentlayerid = 1;
    //this.currentstructid = 1;
    //this.lastblockend = Duration();
    vls = VideoLayerStruct(0);
    vli = VideoLayerItem(0);
    vlb = VideoLayerBlock(0);
  }

/*
  void resetids()
  {
    this.currentblockid = 1;
    this.currentlayerid = 1;
    this.currentstructid = 1;
  }
*/

  int getNewLayerid()
  {
    int iused = 0;
    for(int i=1;i<=maxlayercount;i++)
    {
      iused = 0;
      for(int j=0;j<vls.videolayers.length;j++)
      {
        if(vls.videolayers[j].layerid==i)
        {
          iused = 1;
          break;
        }
      }
      if(iused==0)
      {
        return i;
      }
    }
    return -1;
  }

  int getNewBlockid()
  {
    int iused = 0;
    for(int i=1;i<=maxblockcount;i++)
    {
      iused = 0;
      for(int j=0;j<vls.videolayers.length;j++)
      {
        for(int k=0;k<vls.videolayers[j].videoblocks.length;k++)
        {
          if(vls.videolayers[j].videoblocks[k].blockid==i)
          {
            iused = 1;
            break;
          }
        }
        if(iused==1)
        {
          break;
        }
      }
      if(iused==0)
      {
        return i;
      }
    }
    return -1;
  }

  int getNewZindex()
  {
    int iused = 0;
    for(int i=1000;i<=maxzindex;i+=100)
    {
      iused = 0;
      for(int j=0;j<vls.videolayers.length;j++)
      {
        if(vls.videolayers[j].zindex==i)
        {
          iused = 1;
          break;
        }
      }
      if(iused==0)
      {
        return i;
      }
    }
    return -1;
  }

  void sortLayersZ()
  {
    vls.videolayers.sort((b, a) => a.zindex.compareTo(b.zindex));
  }

  void sortBlocksD()
  {
    for(int i=0;i<vls.videolayers.length;i++)
    {
      vli=vls.videolayers[i];
      vli.videoblocks.sort((a, b) => a.fromstamp.compareTo(b.fromstamp));
    }
  }

  void calLayerslength()
  {
    for(int i=0;i<vls.videolayers.length;i++)
    {
      vls.videolayers[i].layerlength=Duration(milliseconds: 0);
      for(int j=0;j<vls.videolayers[i].videoblocks.length;j++)
      {
        if(vls.videolayers[i].videoblocks[j].fileclass!="placeholder")
        {
          if(vls.videolayers[i].videoblocks[j].respeedenable)
          {
            vls.videolayers[i].layerlength += Duration(milliseconds: vls.videolayers[i].videoblocks[j].blocklength.inMilliseconds~/vlu.vls.videolayers[i].videoblocks[j].respeed);
          }
          else
          {
            vls.videolayers[i].videoblocks[j].blocklength = 
            vls.videolayers[i].videoblocks[j].tostamp - 
            vls.videolayers[i].videoblocks[j].fromstamp;
            vls.videolayers[i].layerlength += vls.videolayers[i].videoblocks[j].blocklength;
          }
        }
        else if(j!=vls.videolayers[i].videoblocks.length-1)
        {
          /**/
          bool hasnoholdertail=false;
          for(int k=j;k<vls.videolayers[i].videoblocks.length-1;k++)
          {
            if(vls.videolayers[i].videoblocks[k].fileclass!="placeholder")
            {
              hasnoholdertail=true;
            }
          }
          if(hasnoholdertail)
          {
            vls.videolayers[i].videoblocks[j].blocklength = 
            vls.videolayers[i].videoblocks[j].tostamp - 
            vls.videolayers[i].videoblocks[j].fromstamp;
            vls.videolayers[i].layerlength += vls.videolayers[i].videoblocks[j].blocklength;
          }
          
        }
      }
    }
  }

  void refreshLayerlengthPlaceholder()
  {
    for(int i=0;i<vls.videolayers.length;i++)
    {
      for(int j=vls.videolayers[i].videoblocks.length-1;j>0;j--)
      {
        if(vls.videolayers[i].videoblocks[j].fileclass=="placeholder")
        {
          vls.videolayers[i].videoblocks.removeAt(j);
        }
        else
        {
          break;
        }
      }

      if(vls.videolayers[i].layerlength<getMaxLayerlength())
      {
        vlb = VideoLayerBlock(getNewBlockid());
        vlb.fileclass = "placeholder";
        vlb.fromstamp = vls.videolayers[i].layerlength;
        vlb.tostamp = getMaxLayerlength();
        vlb.blocklength = vlb.tostamp - vlb.fromstamp;
        vlb.blockcolor = globals.packData.color2(colorcase:10);
        vlb.filename = "placeholder.mp3";
        vlb.ispubliclib = true;
        vls.videolayers[i].videoblocks.add(vlb);
      }
    }
  }

  Duration getMaxLayerlength()
  {
    Duration rst = Duration();
    for(int i=0;i<vls.videolayers.length;i++)
    {
      if(vls.videolayers[i].layerlength>rst)
      {
        rst = vls.videolayers[i].layerlength;
      }
    }
    return rst;
  }

  void calRespeedStamp()
  {
    for(int i=0;i<vls.videolayers.length;i++)
    {
      for(int j=0;j<vls.videolayers[i].videoblocks.length;j++)
      {
        if(vls.videolayers[i].videoblocks[j].respeedenable)
        {
          vls.videolayers[i].videoblocks[j].blocklength = Duration(milliseconds: vls.videolayers[i].videoblocks[j].blocklength.inMilliseconds~/vls.videolayers[i].videoblocks[j].respeed);
          vls.videolayers[i].videoblocks[j].tostamp = vls.videolayers[i].videoblocks[j].fromstamp + vls.videolayers[i].videoblocks[j].blocklength;
          if(j<vls.videolayers[i].videoblocks.length-1)
          {
            if(vls.videolayers[i].videoblocks[j].tostamp>vls.videolayers[i].videoblocks[j+1].fromstamp)
            {
              vls.videolayers[i].videoblocks[j].tostamp= vls.videolayers[i].videoblocks[j+1].fromstamp;
              vls.videolayers[i].videoblocks[j].blocklength= vls.videolayers[i].videoblocks[j].tostamp-vls.videolayers[i].videoblocks[j].fromstamp;
            }       
          }
        }
      }
    }
  }

  double getListWidthLength()
  {
    return getMaxLayerlength().inMilliseconds*vls.scalefactor/1000.0;
  }

  int getposMilli(int layeridx,int blockidx,int picidx)
  {
    int startmilli = vlu.vls.videolayers[layeridx].videoblocks[blockidx].filestartpos.inMilliseconds;
    double picwidth = (globals.packData.layeritemheight-10)*globals.packData.videoaspect;
    double halfpicwidth = (globals.packData.layeritemheight-10)*globals.packData.videoaspect/2;
    double poslenth = halfpicwidth+(picwidth*picidx)+1;
    int posmilli = startmilli + (poslenth/vls.scalefactor*1000).toInt();
    if(vlu.vls.videolayers[layeridx].videoblocks[blockidx].respeedenable)
    {
      posmilli = startmilli + (poslenth/vlu.vls.scalefactor*1000*vlu.vls.videolayers[layeridx].videoblocks[blockidx].respeed).toInt();
    }
    return posmilli;
  }

  int getwavestartMilli(int layeridx,int blockidx)
  {
    int startmilli = vls.videolayers[layeridx].videoblocks[blockidx].filestartpos.inMilliseconds;
    return startmilli;
  }
  
  int getwavelengthMilli(int layeridx,int blockidx)
  {
    int lengthmilli = vls.videolayers[layeridx].videoblocks[blockidx].blocklength.inMilliseconds;
    return lengthmilli;
  }

/*
  VideoLayerStruct createDemoStruct()
  {
    vls = VideoLayerStruct(currentstructid);
    currentstructid += 1;
    for(int i=0;i<7;i++)
    {
      vls.videolayers.add(createDemoLayer(i));
      lastblockend = Duration();
    }
    calLayerslength();
    return vls;
  }

  VideoLayerItem createDemoLayer(int zindex)
  {
    vli = VideoLayerItem(currentlayerid);
    currentlayerid += 1;
    for(int i=0;i<10;i++)
    {
      vli.videoblocks.add(createDemoBlock(globals.packData.intFromRandom(60000)));
    }
    vli.zindex = zindex;
    return vli;
  }

  VideoLayerBlock createDemoBlock(int lengthMillisec)
  {
    vlb = VideoLayerBlock(currentblockid);
    currentblockid += 1;
    vlb.blocklength = Duration
    (
      days:0,hours:0,minutes:0,seconds:0,milliseconds:lengthMillisec,microseconds:0
    );
    vlb.filename = 'default.mp4';
    vlb.fileclass = 'mp4';
    vlb.fromstamp = lastblockend;
    vlb.tostamp = vlb.fromstamp + vlb.blocklength;
    lastblockend = vlb.tostamp;
    return vlb;
  }
*/
}

class VideoLayerStruct
{
  int structid = 0;
  DateTime createstamp = DateTime.now();
  double scalefactor = 10.0;
  //Layers' timeline ruler scalefactor
  //Higher values result in longer image list
  List<VideoLayerItem> videolayers =
  List<VideoLayerItem>.filled(0, VideoLayerItem(0), growable: true);

  VideoLayerStruct(this.structid)
  {
    createstamp = DateTime.now();
    scalefactor = 10.0;
    videolayers =
    List<VideoLayerItem>.filled(0, VideoLayerItem(0), growable: true);
  }
}

class VideoLayerItem
{
  int layerid = 0;
  DateTime createstamp = DateTime.now();
  int zindex = 100;
  //Like zindex in webdev div style
  //Higher values result in displaying more front.
  Duration layerlength = Duration();
  //Total time length of the layer
  List<VideoLayerBlock> videoblocks = 
  List<VideoLayerBlock>
  .filled(0, VideoLayerBlock(0), growable: true);
  //Blocks in the layer

  VideoLayerItem(this.layerid)
  {
    createstamp = DateTime.now();
    zindex = 100;
    layerlength = Duration();
    videoblocks = 
    List<VideoLayerBlock>
    .filled(0, VideoLayerBlock(0), growable: true);
  }
}

class VideoLayerBlock
{
  int blockid = 0;
  DateTime createstamp = DateTime.now();
  //Block creating timestamp
  String filename = '';
  //Resource filename that the block is adopting data from
  Duration fromstamp = Duration();
  //Start stamp of the block
  Duration tostamp = Duration();
  //End stamp of the block
  Duration blocklength = Duration();
  //Time length of the block
  String fileclass = '';
  //mp4 or mp3
  Color blockcolor = globals.packData.color2(colorcase: 8);
  //The color which will be replaced with transparency. 
  bool ispubliclib = false;
  //If use public resource lib or private lib
  double similarity = 0.1;
  //Similarity percentage with the key color.
  //0.01 matches only the exact key color, while 1.0 matches everything. 
  double blend = 0.2;         
  //Blend percentage. 
  //0.0 makes pixels either fully transparent, or not transparent at all.
  //Higher values result in semi-transparent pixels, 
  //with a higher transparency the more similar the pixels color is to the key color. 
  Duration filestartpos = Duration();
  //Where is the position in original video resource file of the block startpoint 
  int resizeleft=0;
  int resizetop=0;
  int resizewidth=1920;
  int resizeheight=1080;
  bool resizeenable = false;
  //Block resize arguments when layer combine together
  double respeed=1.0;
  bool respeedenable = false;
  //Block respeed arguments when layer combine together
  double revolume=1.0;
  bool revolumeenable = false;
  //Block revolume arguments when layer combine together

  VideoLayerBlock(this.blockid)
  {
    createstamp = DateTime.now();
    filename = '';
    fromstamp = Duration();
    tostamp = Duration();
    blocklength = Duration();
    fileclass = '';
    blockcolor = globals.packData.color2(colorcase: 8);
    ispubliclib = false;
    filestartpos = Duration();
    resizeenable = false;
    respeedenable = false;
    revolumeenable = false;
  }
}
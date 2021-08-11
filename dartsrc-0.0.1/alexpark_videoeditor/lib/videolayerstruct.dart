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
    this.vls = VideoLayerStruct(0);
    this.vli = VideoLayerItem(0);
    this.vlb = VideoLayerBlock(0);
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

  double getListWidthLength()
  {
    return getMaxLayerlength().inMilliseconds*vls.scalefactor/1000.0;
  }

  Future<VideoLayerStruct> createFirstStruct()
  async
  {
    vls.videolayers.add(await createFirstLayer(getNewZindex()));
    calLayerslength();
    return vls;
  }

  Future<void> insertLayerWithFile(
    bool ispubliclib,int taplayeridx,String resfilename,
    Color chroma,double simularity,double blend)
  async
  {
    int targetzindex = 0;
    String fileclass = "";
    if(taplayeridx==0)
    {
      if(vls.videolayers.length==0)
      {
        targetzindex = getNewZindex();
      }
      else
      {
        targetzindex = vls.videolayers[0].zindex+100;
      }
    }
    else
    {
      targetzindex = ((vls.videolayers[taplayeridx].zindex+vls.videolayers[taplayeridx-1].zindex)/2).floor();
    }
    int lengthMillisec = await getVideoTimeLength(ispubliclib,resfilename);
    vlb = VideoLayerBlock(getNewBlockid());
    vlb.blocklength = Duration
    (
      days:0,hours:0,minutes:0,seconds:0,milliseconds:lengthMillisec,microseconds:0
    );
    vlb.filename = resfilename;
    if(resfilename.endsWith("mp4"))fileclass="mp4";
    if(resfilename.endsWith("mp3"))fileclass="mp3";
    vlb.fileclass = fileclass;
    vlb.fromstamp = Duration();
    vlb.tostamp = vlb.fromstamp + vlb.blocklength;
    vlb.filestartpos = Duration();
    vlb.ispubliclib = ispubliclib;
    vlb.blockcolor = chroma;
    vlb.similarity = simularity;
    vlb.blend = blend;
    vli = VideoLayerItem(getNewLayerid());
    vli.videoblocks.add(vlb);
    vli.zindex = targetzindex;
    vls.videolayers.add(vli);
    calLayerslength();
    sortLayersZ();
    refreshLayerlengthPlaceholder();
  }

  Future<void> insertLayerWithPng(
    bool ispubliclib,int taplayeridx,String resfilename,
    Color chroma,double simularity,double blend)
  async
  {
    int targetzindex = 0;
    String fileclass = "";
    if(taplayeridx==0)
    {
      if(vls.videolayers.length==0)
      {
        targetzindex = getNewZindex();
      }
      else
      {
        targetzindex = vls.videolayers[0].zindex+100;
      }
    }
    else
    {
      targetzindex = ((vls.videolayers[taplayeridx].zindex+vls.videolayers[taplayeridx-1].zindex)/2).floor();
    }
    int lengthMillisec = getMaxLayerlength().inMilliseconds;
    if(lengthMillisec==0)lengthMillisec=60000;
    vlb = VideoLayerBlock(getNewBlockid());
    vlb.blocklength = Duration
    (
      days:0,hours:0,minutes:0,seconds:0,milliseconds:lengthMillisec,microseconds:0
    );
    vlb.filename = resfilename;
    if(resfilename.endsWith("png"))fileclass="png";
    vlb.fileclass = fileclass;
    vlb.fromstamp = Duration();
    vlb.tostamp = vlb.fromstamp + vlb.blocklength;
    vlb.filestartpos = Duration();
    vlb.ispubliclib = ispubliclib;
    vlb.blockcolor = chroma;
    vlb.similarity = simularity;
    vlb.blend = blend;
    vli = VideoLayerItem(getNewLayerid());
    vli.videoblocks.add(vlb);
    vli.zindex = targetzindex;
    vls.videolayers.add(vli);
    calLayerslength();
    sortLayersZ();
    refreshLayerlengthPlaceholder();
  }

  Future<VideoLayerItem> createFirstLayer(int zindex)
  async
  {
    vli = VideoLayerItem(getNewLayerid());
    vli.videoblocks.add(await createFirstBlock("demo.mp4"));
    vli.zindex = zindex;
    return vli;
  }

  Future<int> getVideoTimeLength(bool ispubliclib,String resfilename)
  async
  {
    int ib = 0;
    if(ispubliclib)ib=1;
    String rst = await globals.packData.jsonPostback("alexgetvideotimelength.php", ib.toString()+"|"+resfilename);
    int irst = 0;
    try
    {
      irst = int.parse(rst.trim());
      print(irst);
    }
    catch(e)
    {

    }
    return irst;
  }

  Future<VideoLayerBlock> createFirstBlock(String resfilename)
  async
  {
    int lengthMillisec = await getVideoTimeLength(false,resfilename);
    vlb = VideoLayerBlock(getNewBlockid());
    vlb.blocklength = Duration
    (
      days:0,hours:0,minutes:0,seconds:0,milliseconds:lengthMillisec,microseconds:0
    );
    vlb.filename = resfilename;
    vlb.fileclass = 'mp4';
    vlb.fromstamp = Duration();
    vlb.tostamp = vlb.fromstamp + vlb.blocklength;
    return vlb;
  }

  Future preparePosPics()
  async
  {
    for(int layeridx=0;layeridx<vls.videolayers.length;layeridx++)
    {
      for(int blockidx=0;blockidx<vls.videolayers[layeridx].videoblocks.length;blockidx++)
      {
        String imagepath = "";
        if(vls.videolayers[layeridx].videoblocks[blockidx].fileclass=="mp3")
        {
            if(!vls.videolayers[layeridx].videoblocks[blockidx].ispubliclib)
            {
              imagepath = globals.configFile.serveraddr+'alexgetposwave.php?key='+globals.packData.encodeDES3CBC(globals.configFile.apikey)
                              +'&file='+vls.videolayers[layeridx].videoblocks[blockidx].filename+'&start='+getwavestartMilli(layeridx,blockidx).toString()+'&len='+getwavelengthMilli(layeridx,blockidx).toString();
            }
            else
            {
              imagepath = globals.configFile.serveraddr+'alexgetposwave.php?key='+globals.packData.encodeDES3CBC(globals.configFile.publickey)
                              +'&file='+vls.videolayers[layeridx].videoblocks[blockidx].filename+'&start='+getwavestartMilli(layeridx,blockidx).toString()+'&len='+getwavelengthMilli(layeridx,blockidx).toString();
            }
            await globals.packData.jsonRawPostback(imagepath, "");
        }
        else if(vls.videolayers[layeridx].videoblocks[blockidx].fileclass=="placeholder")
        {

        }
        else if(vls.videolayers[layeridx].videoblocks[blockidx].fileclass=="png")
        {
            if(!vls.videolayers[layeridx].videoblocks[blockidx].ispubliclib)
            {
              imagepath = globals.configFile.serveraddr+'alexgetpospng.php?key='+globals.packData.encodeDES3CBC(globals.configFile.apikey)
                              +'&file='+vls.videolayers[layeridx].videoblocks[blockidx].filename;
            }
            else
            {
              imagepath = globals.configFile.serveraddr+'alexgetpospng.php?key='+globals.packData.encodeDES3CBC(globals.configFile.publickey)
                              +'&file='+vls.videolayers[layeridx].videoblocks[blockidx].filename;
            }
            await globals.packData.jsonRawPostback(imagepath, "");
        }
        else
        {
        double blockwidth = vls.videolayers[layeridx].videoblocks[blockidx].blocklength.inMilliseconds/1000*vls.scalefactor;
        int itemcount = ((blockwidth-2)/((globals.packData.layeritemheight-10)*globals.packData.videoaspect)).floor();
        for(int picidx=0;picidx<itemcount;picidx++)
        {
          
          if(vls.videolayers[layeridx].videoblocks[blockidx].fileclass=="mp4")
          {
            if(!vls.videolayers[layeridx].videoblocks[blockidx].ispubliclib)
            {
              imagepath = globals.configFile.serveraddr+'alexgetpospic.php?key='+globals.packData.encodeDES3CBC(globals.configFile.apikey)
                              +'&file='+vls.videolayers[layeridx].videoblocks[blockidx].filename+'&milli='+getposMilli(layeridx,blockidx,picidx).toString();
            }
            else
            {
              imagepath = globals.configFile.serveraddr+'alexgetpospic.php?key='+globals.packData.encodeDES3CBC(globals.configFile.publickey)
                              +'&file='+vls.videolayers[layeridx].videoblocks[blockidx].filename+'&milli='+getposMilli(layeridx,blockidx,picidx).toString();
            }
            await globals.packData.jsonRawPostback(imagepath, "");
          }
        }
        }
      }
    }
                  
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

  VideoLayerStruct(int structid)
  {
    this.structid = structid;
    this.createstamp = DateTime.now();
    this.scalefactor = 10.0;
    this.videolayers =
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

  VideoLayerItem(int layerid)
  {
    this.layerid = layerid;
    this.createstamp = DateTime.now();
    this.zindex = 100;
    this.layerlength = Duration();
    this.videoblocks = 
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
  int resizewidth=320;
  int resizeheight=240;
  bool resizeenable = false;
  //Block resize arguments when layer combine together
  double respeed=1.0;
  bool respeedenable = false;
  //Block respeed arguments when layer combine together
  double revolume=1.0;
  bool revolumeenable = false;
  //Block revolume arguments when layer combine together

  VideoLayerBlock(int blockid)
  {
    this.blockid = blockid;
    this.createstamp = DateTime.now();
    this.filename = '';
    this.fromstamp = Duration();
    this.tostamp = Duration();
    this.blocklength = Duration();
    this.fileclass = '';
    this.blockcolor = globals.packData.color2(colorcase: 8);
    this.ispubliclib = false;
    this.filestartpos = Duration();
    this.resizeenable = false;
    this.respeedenable = false;
    this.revolumeenable = false;
  }
}
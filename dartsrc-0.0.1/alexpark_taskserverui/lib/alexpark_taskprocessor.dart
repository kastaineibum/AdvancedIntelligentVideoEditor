// ignore_for_file: prefer_const_constructors

import 'dart:io';
import 'dart:async';
import 'package:flutter/painting.dart';
import 'package:mysql1/mysql1.dart';
import 'package:process_run/shell.dart';
import 'videolayerstruct.dart';
import 'globals.dart' as globals;

FunctionsPack fp=FunctionsPack();

class FunctionsPack
{
  FunctionsPack();

  late MySqlConnection dbconn;
  bool enablelog = false;
  String websitepath = "/var/www/html";
  String dbservername = "127.0.0.1";
  String dbusername = "root";
  String dbpassword = "123456";
  String dbname = "alexpark_videoeditor";
  int dbport = 3306;
  String aibackendpath = "/media/alexparkmz/data1/alexpark_server";
  String videoencoder = "rawvideo";
  String audioencoder = "aac";
  String pubkey = "3mn.net-public-common";

////////////////////////////////////////////////////////////////////////////////
/// database functions
////////////////////////////////////////////////////////////////////////////////

  Future<MySqlConnection> dbconnect()
  async
  {
    dbconn = await MySqlConnection.connect(ConnectionSettings(
      host: dbservername,
      port: dbport,
      user: dbusername,
      password: dbpassword,
      db: dbname,
      ));
    return dbconn;
  }
  
  Future<void> dbclose()
  async
  {
    await dbconn.close();
  }

  Future<Results> dbquery(String sql)
  async
  {
    return await dbconn.query(sql);
  }

  Future<Results> setdbvar(String keystr,String valuestr)
  async
  {
    String sql = "UPDATE globalcache SET valuestr='"+valuestr+"' WHERE keystr='"+keystr+"'";
    return await dbconn.query(sql);
  }

  Future<String> getdbvar(String keystr)
  async
  {
    String rst="";
    var results = await dbconn.query("SELECT valuestr FROM globalcache WHERE keystr='"+keystr+"'");
    for (var row in results) 
    {
      rst=row[0];
    }
    return rst;
  }

  Future<String> gettaskneedprocessing()
  async
  {
    String rst="0";
    var results = await dbconn.query("SELECT taskid FROM task WHERE taskstatus='processing' ORDER BY tid ASC");
    for (var row in results) 
    {
      rst=row[0];
    }
    return rst;
  }

  Future<String> gettaskkey(String taskid)
  async
  {
    String rst="-";
    var results = await dbconn.query("SELECT apikey FROM task WHERE taskid='"+taskid+"'");
    for (var row in results) 
    {
      rst=row[0];
    }
    return rst;
  }

  Future<String> gettaskclass(String taskid)
  async
  {
    String rst="-";
    var results = await dbconn.query("SELECT taskclass FROM task WHERE taskid='"+taskid+"'");
    for (var row in results) 
    {
      rst=row[0].toString();
    }
    return rst;
  }

  Future<String> gettaskwidth(String taskid)
  async
  {
    String rst="1920";
    var results = await dbconn.query("SELECT finalwidth FROM task WHERE taskid='"+taskid+"'");
    for (var row in results) 
    {
      rst=row[0].toString();
    }
    return rst;
  }

  Future<String> gettaskheight(String taskid)
  async
  {
    String rst="1080";
    var results = await dbconn.query("SELECT finalheight FROM task WHERE taskid='"+taskid+"'");
    for (var row in results) 
    {
      rst=row[0].toString();
    }
    return rst;
  }

  Future<String> gettaskdesc(String taskid)
  async
  {
    String rst="1080";
    var results = await dbconn.query("SELECT taskdesc FROM task WHERE taskid='"+taskid+"'");
    for (var row in results) 
    {
      rst=row[0].toString();
    }
    return rst;
  }

  Future<String> gettaskargs(String taskid)
  async
  {
    String rst="-";
    var results = await dbconn.query("SELECT taskargs FROM task WHERE taskid='"+taskid+"'");
    for (var row in results) 
    {
      rst=row[0].toString();
    }
    return rst;
  }

  Future<Results> appendecho(String valuestr)
  async
  {
    if(!enablelog)return await dbconn.query('SELECT TRUE;');
    String sql = "";
    /*
    String formerstr = "";
    
    var results = await dbconn.query("SELECT valuestr FROM globalcache WHERE keystr='echostring'");
    for (var row in results) 
    {
      formerstr=row[0];
    }
    if(formerstr.length+valuestr.length>4096)
    {
      sql = "UPDATE globalcache SET valuestr='-----===-----' WHERE keystr='echostring'";
    }
    else
    {
      sql = "UPDATE globalcache SET valuestr='"+formerstr+valuestr.replaceAll("\r\n", "\n").replaceAll("'", "’").replaceAll("\"", "”")+"' WHERE keystr='echostring'";
    }
    return await dbconn.query(sql);
    */
    if(valuestr.length>4000)valuestr=valuestr.substring(valuestr.length-4001,valuestr.length-1);
    valuestr = valuestr.replaceAll("\r\n", "\n").replaceAll("'", "-").replaceAll("\"", "=");
    if(valuestr.length<2)return await dbconn.query('SELECT TRUE;');
    sql = "INSERT INTO consolelog(log) VALUES('"+valuestr+"')";
    return await dbconn.query(sql);
  }

  Future<String> pumpecho()
  async
  {
    /*
    String formerstr = "";
    var results = await dbconn.query("SELECT valuestr FROM globalcache WHERE keystr='echostring'");
    for (var row in results) 
    {
      formerstr=row[0];
    }
    String sql = "UPDATE globalcache SET valuestr='' WHERE keystr='echostring'";
    await dbconn.query(sql);
    return formerstr.replaceAll("\n", "\r\n");
    */
    String formerstr = "";
    int cid = 0;
    var results = await dbconn.query("SELECT cid,log FROM consolelog WHERE readover=FALSE ORDER BY cid ASC LIMIT 1");
    for (var row in results) 
    {
      cid = row[0];
      formerstr=row[1];
    }
    String sql = "UPDATE consolelog SET readover=TRUE WHERE cid="+cid.toString();
    await dbconn.query(sql);
    return formerstr.replaceAll("\n", "\r\n");
  }

  Future<bool> ifenablelog()
  async
  {
    bool rst=false;
    var results = await dbconn.query("SELECT valuestr FROM globalcache WHERE keystr='enablelog'");
    for (var row in results) 
    {
      rst=(row[0].toString().toLowerCase()=="true"?true:false);
    }
    if(rst)enablelog=true;
    return rst;
  }

  Future<void> taskfailed(String taskid)
  async
  {
    String sql = "UPDATE task SET taskstatus='stopped' WHERE taskid='"+taskid+"'";
    await dbconn.query(sql);
  }

  Future<void> taskdone(String taskid)
  async
  {
    String sql = "UPDATE task SET taskstatus='done' WHERE taskid='"+taskid+"'";
    await dbconn.query(sql);
  }

  Future<String> addtoprivatelib(String keystr,String taskid,String taskdesc)
  async
  {
    return await globals.packData.jsonPostbackWithTaskid("alexaddprivatemp4.php","",keystr,taskid,taskdesc);
  }

  Future<String> addtoprivatelib2(String keystr,String taskid,String taskdesc)
  async
  {
    return await globals.packData.jsonPostbackWithTaskid("alexaddprivatemp4b.php","",keystr,taskid,taskdesc);
  }

  Future<String> addtoprivatelibi(String keystr,String taskid,String taskdesc)
  async
  {
    return await globals.packData.jsonPostbackWithTaskid("alexaddprivatemp4i.php","",keystr,taskid,taskdesc);
  } 
  
  Future<String> addtoprivatelibp(String keystr,String taskid,String taskdesc)
  async
  {
    return await globals.packData.jsonPostbackWithTaskid("alexaddprivatemp4p.php","",keystr,taskid,taskdesc);
  }   

  Future<String> addtoprivatelibs(String keystr,String taskid,String taskdesc)
  async
  {
    return await globals.packData.jsonPostbackWithTaskid("alexaddprivatemp4s.php","",keystr,taskid,taskdesc);
  }    

////////////////////////////////////////////////////////////////////////////////
/// server operations
////////////////////////////////////////////////////////////////////////////////
  
  Future<void> testshell()
  async
  {
    await shellexec(""+websitepath+"/test.sh test1 test2");
  }

  Future<void> shellexec2(String cmd)
  async
  {
  var shell = Shell();
  shell.run("#!/bin/bash\r\n"+cmd+"\r\n").then(
    (result)
    async
    {
      await appendecho(result.outText);
      await appendecho(result.errText);
    }).catchError((onError) 
    async
    {
      await appendecho(onError);
    });
  }

  Future<String> shellexec3(String cmd,String taskid)
  async
  {
    return (await globals.packData.jsonPostback("alexrunlocalcmd.php",cmd,await gettaskkey(taskid))).trim();
  }

  Future<void> shellexec4(String cmd)
  async
  {
    List<String> args = cmd.split(' ');
    args.insert(0, "alexparkmz@127.0.0.1");
    args.insert(0, "ssh");
    args.insert(0, "\"    \"");
    args.insert(0, "-p");
    late ProcessResult prst;
    try
    {
      prst = await Process.run("/usr/bin/sshpass", args);
    }
    catch(e)
    {
      //print(e);
    }

    await appendecho(prst.outText+"\n");
    await appendecho(prst.errText+"\n");
  }

  Future<void> shellexec(String cmd)
  async
  {
    List<String> args = cmd.split(' ');
    String cmdwithoutargs = args[0];
    args.removeAt(0);
    await Process.run(cmdwithoutargs, args).then(
    (result) 
    async
    {
      await appendecho(result.stdout);
      await appendecho(result.stderr);
    });
  }

  Future<void> shellexecraw(String cmd,List<String> args)
  async
  {
    await Process.run(cmd, args).then(
    (result) 
    async
    {
      await appendecho(result.stdout);
      await appendecho(result.stderr);
    });
  }

  Future<void> loadtovls(String taskid)
  async
  {
    String keystr= await gettaskkey(taskid);
    if(keystr=="-")
    {
      //await setdbvar("currenttaskid", "0");
      return;
    }
    String layercnt = (await globals.packData.jsonPostback("alexgetstructlayercnt.php", taskid,keystr)).trim();
    String rst = (await globals.packData.jsonPostback("alexgettaskstruct.php", taskid,keystr)).trim();
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
      VideoLayerBlock vlbb = VideoLayerBlock(int.parse(structits[1]));
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
  }

  Future<void> preparefiles(String taskid)
  async
  {
    String tw = await gettaskwidth(taskid);
    String th = await gettaskheight(taskid);
    String privatekeystr = await gettaskkey(taskid);
    String publickeystr = pubkey;
    String keystr = privatekeystr;
    String cmd = "";
    for(int i=0;i<vlu.vls.videolayers.length;i++)
    {
      for(int j=0;j<vlu.vls.videolayers[i].videoblocks.length;j++)
      {
        keystr = vlu.vls.videolayers[i].videoblocks[j].ispubliclib?publickeystr:privatekeystr;
        String resfilename = vlu.vls.videolayers[i].videoblocks[j].filename;
        String bnm = resfilename.substring(0,resfilename.lastIndexOf(".")).replaceAll('temp/', '');
        String ext = resfilename.substring(resfilename.lastIndexOf("."));

        String revolume = vlu.vls.videolayers[i].videoblocks[j].revolume.toString();
        String respeed = vlu.vls.videolayers[i].videoblocks[j].respeed.toString();
        String restp = (1/vlu.vls.videolayers[i].videoblocks[j].respeed).toString();
        if(revolume.length>4)revolume= revolume.substring(0,4);
        if(respeed.length>6)respeed= respeed.substring(0,6);
        if(restp.length>6)restp= restp.substring(0,6);

        String ss = globals.packData.timestrFromMillisec(vlu.vls.videolayers[i].videoblocks[j].filestartpos.inMilliseconds);
        String ts = globals.packData.timestrFromMillisec(vlu.vls.videolayers[i].videoblocks[j].blocklength.inMilliseconds);

//cut to file-block (filestartpos=0)
        if(vlu.vls.videolayers[i].videoblocks[j].filestartpos.inMilliseconds!=0
        &&(vlu.vls.videolayers[i].videoblocks[j].fileclass=="mp4"
        ||vlu.vls.videolayers[i].videoblocks[j].fileclass=="mp3"))
        {
          if(vlu.vls.videolayers[i].videoblocks[j].fileclass=="mp4")
          {
  cmd = "/usr/local/bin/ffmpeg -ss "+ss+" -t "+ts+" -i "+websitepath+"/"+keystr+"/"+resfilename
  +" -c:v "+videoencoder+" -y "+websitepath+"/"+privatekeystr+"/temp/"+bnm+"-cutss-"+i.toString()+"-"+j.toString()+".mkv";
  await shellexec(cmd);
  await appendecho(cmd+"\n");
  vlu.vls.videolayers[i].videoblocks[j].filename = "temp/"+bnm+"-cutss-"+i.toString()+"-"+j.toString()+".mkv";
  vlu.vls.videolayers[i].videoblocks[j].ispubliclib = false;
  vlu.vls.videolayers[i].videoblocks[j].filestartpos = Duration(milliseconds: 0);
  keystr = privatekeystr;
  resfilename = vlu.vls.videolayers[i].videoblocks[j].filename;
  bnm = resfilename.substring(0,resfilename.lastIndexOf(".")).replaceAll('temp/', '');
  ext = resfilename.substring(resfilename.lastIndexOf("."));
          }
          if(vlu.vls.videolayers[i].videoblocks[j].fileclass=="mp3")
          {
  cmd = "/usr/local/bin/ffmpeg -ss "+ss+" -t "+ts+" -i "+websitepath+"/"+keystr+"/"+resfilename
  +" -c:a "+audioencoder+" -y "+websitepath+"/"+privatekeystr+"/temp/"+bnm+"-cutss-"+i.toString()+"-"+j.toString()+".aac";
  await shellexec(cmd);
  await appendecho(cmd+"\n");
  vlu.vls.videolayers[i].videoblocks[j].filename = "temp/"+bnm+"-cutss-"+i.toString()+"-"+j.toString()+".aac";
  vlu.vls.videolayers[i].videoblocks[j].ispubliclib = false;
  vlu.vls.videolayers[i].videoblocks[j].filestartpos = Duration(milliseconds: 0);
  keystr = privatekeystr;
  resfilename = vlu.vls.videolayers[i].videoblocks[j].filename;
  bnm = resfilename.substring(0,resfilename.lastIndexOf(".")).replaceAll('temp/', '');
  ext = resfilename.substring(resfilename.lastIndexOf("."));
          }
        }

//fix to final size
        if(vlu.vls.videolayers[i].videoblocks[j].fileclass=="mp4")
        {
cmd = "/usr/local/bin/ffmpeg -i "+websitepath+"/"+keystr+"/"+resfilename
+" -c:v "+videoencoder+" -c:a copy -vf scale="+tw+":"+th
+",setsar=1 -y "+websitepath+"/"+privatekeystr+"/temp/"+bnm+"-fixed-"+i.toString()+"-"+j.toString()+".mkv";
await shellexec(cmd);
await appendecho(cmd+"\n");
vlu.vls.videolayers[i].videoblocks[j].filename = "temp/"+bnm+"-fixed-"+i.toString()+"-"+j.toString()+".mkv";
vlu.vls.videolayers[i].videoblocks[j].ispubliclib = false;
keystr = privatekeystr;
resfilename = vlu.vls.videolayers[i].videoblocks[j].filename;
bnm = resfilename.substring(0,resfilename.lastIndexOf(".")).replaceAll('temp/', '');
ext = resfilename.substring(resfilename.lastIndexOf("."));
        }
        if(vlu.vls.videolayers[i].videoblocks[j].fileclass=="png")
        {
cmd = "/usr/local/bin/convert "+websitepath+"/"+keystr+"/"+resfilename
+" -resize "+tw+"x"+th
+" "+websitepath+"/"+privatekeystr+"/temp/"+bnm+"-fixed-"+i.toString()+"-"+j.toString()+ext;
await shellexec(cmd);
await appendecho(cmd+"\n");
vlu.vls.videolayers[i].videoblocks[j].filename = "temp/"+bnm+"-fixed-"+i.toString()+"-"+j.toString()+ext;
vlu.vls.videolayers[i].videoblocks[j].ispubliclib = false;
keystr = privatekeystr;
resfilename = vlu.vls.videolayers[i].videoblocks[j].filename;
bnm = resfilename.substring(0,resfilename.lastIndexOf(".")).replaceAll('temp/', '');
ext = resfilename.substring(resfilename.lastIndexOf("."));
        }

        if(vlu.vls.videolayers[i].videoblocks[j].respeedenable)
        {
          if(vlu.vls.videolayers[i].videoblocks[j].fileclass=="mp4")
          {
cmd = "/usr/local/bin/ffmpeg -i "+websitepath+"/"+keystr+"/"+resfilename
+" -filter_complex [0:v]setpts="+restp+"*PTS[v];[0:a]atempo="+respeed
+"[a] -map [v] -map [a] -c:v "+videoencoder+" -y "+websitepath+"/"+privatekeystr+"/temp/"+bnm+"-respeed-"+i.toString()+"-"+j.toString()+".mkv";
await shellexec(cmd);
await appendecho(cmd+"\n");
vlu.vls.videolayers[i].videoblocks[j].filename = "temp/"+bnm+"-respeed-"+i.toString()+"-"+j.toString()+".mkv";
vlu.vls.videolayers[i].videoblocks[j].ispubliclib = false;
vlu.vls.videolayers[i].videoblocks[j].respeedenable = false;
vlu.vls.videolayers[i].videoblocks[j].blocklength = Duration(milliseconds: vlu.vls.videolayers[i].videoblocks[j].blocklength.inMilliseconds~/vlu.vls.videolayers[i].videoblocks[j].respeed);
vlu.vls.videolayers[i].videoblocks[j].tostamp = vlu.vls.videolayers[i].videoblocks[j].fromstamp+vlu.vls.videolayers[i].videoblocks[j].blocklength;
keystr = privatekeystr;
resfilename = vlu.vls.videolayers[i].videoblocks[j].filename;
bnm = resfilename.substring(0,resfilename.lastIndexOf(".")).replaceAll('temp/', '');
ext = resfilename.substring(resfilename.lastIndexOf("."));
          }
          else if(vlu.vls.videolayers[i].videoblocks[j].fileclass=="mp3")
          {
cmd = "/usr/local/bin/ffmpeg -i "+websitepath+"/"+keystr+"/"+resfilename
+" -filter:a atempo="+respeed+" -vn -y "+websitepath+"/"+privatekeystr+"/temp/"+bnm+"-respeed-"+i.toString()+"-"+j.toString()+ext;
await shellexec(cmd);
await appendecho(cmd+"\n");
vlu.vls.videolayers[i].videoblocks[j].filename = "temp/"+bnm+"-respeed-"+i.toString()+"-"+j.toString()+ext;
vlu.vls.videolayers[i].videoblocks[j].ispubliclib = false;
vlu.vls.videolayers[i].videoblocks[j].respeedenable = false;
vlu.vls.videolayers[i].videoblocks[j].blocklength = Duration(milliseconds: vlu.vls.videolayers[i].videoblocks[j].blocklength.inMilliseconds~/vlu.vls.videolayers[i].videoblocks[j].respeed);
vlu.vls.videolayers[i].videoblocks[j].tostamp = vlu.vls.videolayers[i].videoblocks[j].fromstamp+vlu.vls.videolayers[i].videoblocks[j].blocklength;
keystr = privatekeystr;
resfilename = vlu.vls.videolayers[i].videoblocks[j].filename;
bnm = resfilename.substring(0,resfilename.lastIndexOf(".")).replaceAll('temp/', '');
ext = resfilename.substring(resfilename.lastIndexOf("."));
          }
        }
        if(vlu.vls.videolayers[i].videoblocks[j].revolumeenable)
        {
          if(vlu.vls.videolayers[i].videoblocks[j].fileclass=="mp4")
          {
cmd = "/usr/local/bin/ffmpeg -i "+websitepath+"/"+keystr+"/"+resfilename
+" -filter:a volume="+revolume+" -c:v copy -y "+websitepath+"/"+privatekeystr+"/temp/"+bnm+"-revolumed-"+i.toString()+"-"+j.toString()+".mkv";
await shellexec(cmd);
await appendecho(cmd+"\n");
vlu.vls.videolayers[i].videoblocks[j].filename = "temp/"+bnm+"-revolumed-"+i.toString()+"-"+j.toString()+".mkv";
vlu.vls.videolayers[i].videoblocks[j].ispubliclib = false;
vlu.vls.videolayers[i].videoblocks[j].revolumeenable = false;
keystr = privatekeystr;
resfilename = vlu.vls.videolayers[i].videoblocks[j].filename;
bnm = resfilename.substring(0,resfilename.lastIndexOf(".")).replaceAll('temp/', '');
ext = resfilename.substring(resfilename.lastIndexOf("."));
          }
          else if(vlu.vls.videolayers[i].videoblocks[j].fileclass=="mp3")
          {
cmd = "/usr/local/bin/ffmpeg -i "+websitepath+"/"+keystr+"/"+resfilename
+" -filter:a volume="+revolume+" -y "+websitepath+"/"+privatekeystr+"/temp/"+bnm+"-revolumed-"+i.toString()+"-"+j.toString()+ext;
await shellexec(cmd);
await appendecho(cmd+"\n");
vlu.vls.videolayers[i].videoblocks[j].filename = "temp/"+bnm+"-revolumed-"+i.toString()+"-"+j.toString()+ext;
vlu.vls.videolayers[i].videoblocks[j].ispubliclib = false;
vlu.vls.videolayers[i].videoblocks[j].revolumeenable = false;
keystr = privatekeystr;
resfilename = vlu.vls.videolayers[i].videoblocks[j].filename;
bnm = resfilename.substring(0,resfilename.lastIndexOf(".")).replaceAll('temp/', '');
ext = resfilename.substring(resfilename.lastIndexOf("."));
          }
        }
        if(vlu.vls.videolayers[i].videoblocks[j].resizeenable)
        {
          if(vlu.vls.videolayers[i].videoblocks[j].fileclass=="mp4")
          {
cmd = "/usr/local/bin/ffmpeg -i "+websitepath+"/"+keystr+"/"+resfilename
+" -c:v "+videoencoder+" -vf scale="+vlu.vls.videolayers[i].videoblocks[j].resizewidth.toString()+":"+vlu.vls.videolayers[i].videoblocks[j].resizeheight.toString()
+",setsar=1 -y "+websitepath+"/"+privatekeystr+"/temp/"+bnm+"-resized-"+i.toString()+"-"+j.toString()+".mkv";
await shellexec(cmd);
await appendecho(cmd+"\n");
vlu.vls.videolayers[i].videoblocks[j].filename = "temp/"+bnm+"-resized-"+i.toString()+"-"+j.toString()+".mkv";
vlu.vls.videolayers[i].videoblocks[j].ispubliclib = false;
keystr = privatekeystr;
resfilename = vlu.vls.videolayers[i].videoblocks[j].filename;
bnm = resfilename.substring(0,resfilename.lastIndexOf(".")).replaceAll('temp/', '');
ext = resfilename.substring(resfilename.lastIndexOf("."));
          }
          else if(vlu.vls.videolayers[i].videoblocks[j].fileclass=="png")
          {
cmd = "/usr/local/bin/convert "+websitepath+"/"+keystr+"/"+resfilename
+" -resize "+vlu.vls.videolayers[i].videoblocks[j].resizewidth.toString()+"x"+vlu.vls.videolayers[i].videoblocks[j].resizeheight.toString()
+" "+websitepath+"/"+privatekeystr+"/temp/"+bnm+"-resized-"+i.toString()+"-"+j.toString()+ext;
await shellexec(cmd);
await appendecho(cmd+"\n");
vlu.vls.videolayers[i].videoblocks[j].filename = "temp/"+bnm+"-resized-"+i.toString()+"-"+j.toString()+ext;
vlu.vls.videolayers[i].videoblocks[j].ispubliclib = false;
keystr = privatekeystr;
resfilename = vlu.vls.videolayers[i].videoblocks[j].filename;
bnm = resfilename.substring(0,resfilename.lastIndexOf(".")).replaceAll('temp/', '');
ext = resfilename.substring(resfilename.lastIndexOf("."));
          }
        }
      }
    }
  }

  Future<void> preparefilespecified0(String taskid,int layeridx,int blockidx)
  async
  {
    String tw = await gettaskwidth(taskid);
    String th = await gettaskheight(taskid);
    String privatekeystr = await gettaskkey(taskid);
    String publickeystr = pubkey;
    String keystr = privatekeystr;
    String cmd = "";

    int i=layeridx;
    int j=blockidx;

        keystr = vlu.vls.videolayers[i].videoblocks[j].ispubliclib?publickeystr:privatekeystr;
        String resfilename = vlu.vls.videolayers[i].videoblocks[j].filename;
        String bnm = resfilename.substring(0,resfilename.lastIndexOf(".")).replaceAll('temp/', '');
        String ext = resfilename.substring(resfilename.lastIndexOf("."));

        String revolume = vlu.vls.videolayers[i].videoblocks[j].revolume.toString();
        String respeed = vlu.vls.videolayers[i].videoblocks[j].respeed.toString();
        String restp = (1/vlu.vls.videolayers[i].videoblocks[j].respeed).toString();
        if(revolume.length>4)revolume= revolume.substring(0,4);
        if(respeed.length>6)respeed= respeed.substring(0,6);
        if(restp.length>6)restp= restp.substring(0,6);

        String ss = globals.packData.timestrFromMillisec(vlu.vls.videolayers[i].videoblocks[j].filestartpos.inMilliseconds);
        String ts = globals.packData.timestrFromMillisec(vlu.vls.videolayers[i].videoblocks[j].blocklength.inMilliseconds);

//cut to file-block (filestartpos=0)
        if(vlu.vls.videolayers[i].videoblocks[j].fileclass=="mp4")
        {
cmd = "/usr/local/bin/ffmpeg -ss "+ss+" -t "+ts+" -i "+websitepath+"/"+keystr+"/"+resfilename
+" -c:v "+videoencoder+" -y "+websitepath+"/"+privatekeystr+"/temp/"+bnm+"-cutss-"+i.toString()+"-"+j.toString()+".mkv";
await shellexec(cmd);
await appendecho(cmd+"\n");
vlu.vls.videolayers[i].videoblocks[j].filename = "temp/"+bnm+"-cutss-"+i.toString()+"-"+j.toString()+".mkv";
vlu.vls.videolayers[i].videoblocks[j].ispubliclib = false;
vlu.vls.videolayers[i].videoblocks[j].filestartpos = Duration(milliseconds: 0);
keystr = privatekeystr;
resfilename = vlu.vls.videolayers[i].videoblocks[j].filename;
bnm = resfilename.substring(0,resfilename.lastIndexOf(".")).replaceAll('temp/', '');
ext = resfilename.substring(resfilename.lastIndexOf("."));
        }
        if(vlu.vls.videolayers[i].videoblocks[j].fileclass=="mp3")
        {
cmd = "/usr/local/bin/ffmpeg -ss "+ss+" -t "+ts+" -i "+websitepath+"/"+keystr+"/"+resfilename
+" -c:a "+audioencoder+" -y "+websitepath+"/"+privatekeystr+"/temp/"+bnm+"-cutss-"+i.toString()+"-"+j.toString()+".aac";
await shellexec(cmd);
await appendecho(cmd+"\n");
vlu.vls.videolayers[i].videoblocks[j].filename = "temp/"+bnm+"-cutss-"+i.toString()+"-"+j.toString()+".aac";
vlu.vls.videolayers[i].videoblocks[j].ispubliclib = false;
vlu.vls.videolayers[i].videoblocks[j].filestartpos = Duration(milliseconds: 0);
keystr = privatekeystr;
resfilename = vlu.vls.videolayers[i].videoblocks[j].filename;
bnm = resfilename.substring(0,resfilename.lastIndexOf(".")).replaceAll('temp/', '');
ext = resfilename.substring(resfilename.lastIndexOf("."));
        }

//fix to final size
        if(vlu.vls.videolayers[i].videoblocks[j].fileclass=="mp4")
        {
cmd = "/usr/local/bin/ffmpeg -i "+websitepath+"/"+keystr+"/"+resfilename
+" -c:v "+videoencoder+" -c:a copy -vf scale="+tw+":"+th
+",setsar=1 -y "+websitepath+"/"+privatekeystr+"/temp/"+bnm+"-fixed-"+i.toString()+"-"+j.toString()+".mkv";
await shellexec(cmd);
await appendecho(cmd+"\n");
vlu.vls.videolayers[i].videoblocks[j].filename = "temp/"+bnm+"-fixed-"+i.toString()+"-"+j.toString()+".mkv";
vlu.vls.videolayers[i].videoblocks[j].ispubliclib = false;
keystr = privatekeystr;
resfilename = vlu.vls.videolayers[i].videoblocks[j].filename;
bnm = resfilename.substring(0,resfilename.lastIndexOf(".")).replaceAll('temp/', '');
ext = resfilename.substring(resfilename.lastIndexOf("."));
        }
        if(vlu.vls.videolayers[i].videoblocks[j].fileclass=="png")
        {
cmd = "/usr/local/bin/convert "+websitepath+"/"+keystr+"/"+resfilename
+" -resize "+tw+"x"+th
+" "+websitepath+"/"+privatekeystr+"/temp/"+bnm+"-fixed-"+i.toString()+"-"+j.toString()+ext;
await shellexec(cmd);
await appendecho(cmd+"\n");
vlu.vls.videolayers[i].videoblocks[j].filename = "temp/"+bnm+"-fixed-"+i.toString()+"-"+j.toString()+ext;
vlu.vls.videolayers[i].videoblocks[j].ispubliclib = false;
keystr = privatekeystr;
resfilename = vlu.vls.videolayers[i].videoblocks[j].filename;
bnm = resfilename.substring(0,resfilename.lastIndexOf(".")).replaceAll('temp/', '');
ext = resfilename.substring(resfilename.lastIndexOf("."));
        }

        if(vlu.vls.videolayers[i].videoblocks[j].respeedenable)
        {
          if(vlu.vls.videolayers[i].videoblocks[j].fileclass=="mp4")
          {
cmd = "/usr/local/bin/ffmpeg -i "+websitepath+"/"+keystr+"/"+resfilename
+" -filter_complex [0:v]setpts="+restp+"*PTS[v];[0:a]atempo="+respeed
+"[a] -map [v] -map [a] -c:v "+videoencoder+" -y "+websitepath+"/"+privatekeystr+"/temp/"+bnm+"-respeed-"+i.toString()+"-"+j.toString()+".mkv";
await shellexec(cmd);
await appendecho(cmd+"\n");
vlu.vls.videolayers[i].videoblocks[j].filename = "temp/"+bnm+"-respeed-"+i.toString()+"-"+j.toString()+".mkv";
vlu.vls.videolayers[i].videoblocks[j].ispubliclib = false;
vlu.vls.videolayers[i].videoblocks[j].respeedenable = false;
vlu.vls.videolayers[i].videoblocks[j].blocklength = Duration(milliseconds: vlu.vls.videolayers[i].videoblocks[j].blocklength.inMilliseconds~/vlu.vls.videolayers[i].videoblocks[j].respeed);
vlu.vls.videolayers[i].videoblocks[j].tostamp = vlu.vls.videolayers[i].videoblocks[j].fromstamp+vlu.vls.videolayers[i].videoblocks[j].blocklength;
keystr = privatekeystr;
resfilename = vlu.vls.videolayers[i].videoblocks[j].filename;
bnm = resfilename.substring(0,resfilename.lastIndexOf(".")).replaceAll('temp/', '');
ext = resfilename.substring(resfilename.lastIndexOf("."));
          }
          else if(vlu.vls.videolayers[i].videoblocks[j].fileclass=="mp3")
          {
cmd = "/usr/local/bin/ffmpeg -i "+websitepath+"/"+keystr+"/"+resfilename
+" -filter:a atempo="+respeed+" -vn -y "+websitepath+"/"+privatekeystr+"/temp/"+bnm+"-respeed-"+i.toString()+"-"+j.toString()+ext;
await shellexec(cmd);
await appendecho(cmd+"\n");
vlu.vls.videolayers[i].videoblocks[j].filename = "temp/"+bnm+"-respeed-"+i.toString()+"-"+j.toString()+ext;
vlu.vls.videolayers[i].videoblocks[j].ispubliclib = false;
vlu.vls.videolayers[i].videoblocks[j].respeedenable = false;
vlu.vls.videolayers[i].videoblocks[j].blocklength = Duration(milliseconds: vlu.vls.videolayers[i].videoblocks[j].blocklength.inMilliseconds~/vlu.vls.videolayers[i].videoblocks[j].respeed);
vlu.vls.videolayers[i].videoblocks[j].tostamp = vlu.vls.videolayers[i].videoblocks[j].fromstamp+vlu.vls.videolayers[i].videoblocks[j].blocklength;
keystr = privatekeystr;
resfilename = vlu.vls.videolayers[i].videoblocks[j].filename;
bnm = resfilename.substring(0,resfilename.lastIndexOf(".")).replaceAll('temp/', '');
ext = resfilename.substring(resfilename.lastIndexOf("."));
          }
        }
        if(vlu.vls.videolayers[i].videoblocks[j].revolumeenable)
        {
          if(vlu.vls.videolayers[i].videoblocks[j].fileclass=="mp4")
          {
cmd = "/usr/local/bin/ffmpeg -i "+websitepath+"/"+keystr+"/"+resfilename
+" -filter:a volume="+revolume+" -c:v copy -y "+websitepath+"/"+privatekeystr+"/temp/"+bnm+"-revolumed-"+i.toString()+"-"+j.toString()+".mkv";
await shellexec(cmd);
await appendecho(cmd+"\n");
vlu.vls.videolayers[i].videoblocks[j].filename = "temp/"+bnm+"-revolumed-"+i.toString()+"-"+j.toString()+".mkv";
vlu.vls.videolayers[i].videoblocks[j].ispubliclib = false;
vlu.vls.videolayers[i].videoblocks[j].revolumeenable = false;
keystr = privatekeystr;
resfilename = vlu.vls.videolayers[i].videoblocks[j].filename;
bnm = resfilename.substring(0,resfilename.lastIndexOf(".")).replaceAll('temp/', '');
ext = resfilename.substring(resfilename.lastIndexOf("."));
          }
          else if(vlu.vls.videolayers[i].videoblocks[j].fileclass=="mp3")
          {
cmd = "/usr/local/bin/ffmpeg -i "+websitepath+"/"+keystr+"/"+resfilename
+" -filter:a volume="+revolume+" -y "+websitepath+"/"+privatekeystr+"/temp/"+bnm+"-revolumed-"+i.toString()+"-"+j.toString()+ext;
await shellexec(cmd);
await appendecho(cmd+"\n");
vlu.vls.videolayers[i].videoblocks[j].filename = "temp/"+bnm+"-revolumed-"+i.toString()+"-"+j.toString()+ext;
vlu.vls.videolayers[i].videoblocks[j].ispubliclib = false;
vlu.vls.videolayers[i].videoblocks[j].revolumeenable = false;
keystr = privatekeystr;
resfilename = vlu.vls.videolayers[i].videoblocks[j].filename;
bnm = resfilename.substring(0,resfilename.lastIndexOf(".")).replaceAll('temp/', '');
ext = resfilename.substring(resfilename.lastIndexOf("."));
          }
        }
        if(vlu.vls.videolayers[i].videoblocks[j].resizeenable)
        {
          if(vlu.vls.videolayers[i].videoblocks[j].fileclass=="mp4")
          {
cmd = "/usr/local/bin/ffmpeg -i "+websitepath+"/"+keystr+"/"+resfilename
+" -c:v "+videoencoder+" -vf scale="+vlu.vls.videolayers[i].videoblocks[j].resizewidth.toString()+":"+vlu.vls.videolayers[i].videoblocks[j].resizeheight.toString()
+",setsar=1 -y "+websitepath+"/"+privatekeystr+"/temp/"+bnm+"-resized-"+i.toString()+"-"+j.toString()+".mkv";
await shellexec(cmd);
await appendecho(cmd+"\n");
vlu.vls.videolayers[i].videoblocks[j].filename = "temp/"+bnm+"-resized-"+i.toString()+"-"+j.toString()+".mkv";
vlu.vls.videolayers[i].videoblocks[j].ispubliclib = false;
keystr = privatekeystr;
resfilename = vlu.vls.videolayers[i].videoblocks[j].filename;
bnm = resfilename.substring(0,resfilename.lastIndexOf(".")).replaceAll('temp/', '');
ext = resfilename.substring(resfilename.lastIndexOf("."));
          }
          else if(vlu.vls.videolayers[i].videoblocks[j].fileclass=="png")
          {
cmd = "/usr/local/bin/convert "+websitepath+"/"+keystr+"/"+resfilename
+" -resize "+vlu.vls.videolayers[i].videoblocks[j].resizewidth.toString()+"x"+vlu.vls.videolayers[i].videoblocks[j].resizeheight.toString()
+" "+websitepath+"/"+privatekeystr+"/temp/"+bnm+"-resized-"+i.toString()+"-"+j.toString()+ext;
await shellexec(cmd);
await appendecho(cmd+"\n");
vlu.vls.videolayers[i].videoblocks[j].filename = "temp/"+bnm+"-resized-"+i.toString()+"-"+j.toString()+ext;
vlu.vls.videolayers[i].videoblocks[j].ispubliclib = false;
keystr = privatekeystr;
resfilename = vlu.vls.videolayers[i].videoblocks[j].filename;
bnm = resfilename.substring(0,resfilename.lastIndexOf(".")).replaceAll('temp/', '');
ext = resfilename.substring(resfilename.lastIndexOf("."));
          }
        }
  }

  Future<void> preparefilespecified1(String taskid,int layeridx,int blockidx)
  async
  {
    String tw = await gettaskwidth(taskid);
    String th = await gettaskheight(taskid);
    String privatekeystr = await gettaskkey(taskid);
    String publickeystr = pubkey;
    String keystr = privatekeystr;
    String cmd = "";

    if(int.parse(th)>360)
    {
      double ar = int.parse(tw)/int.parse(th);
      th="360";      
      tw=(int.parse(th)*ar).toInt().toString();
    }

    int i=layeridx;
    int j=blockidx;

        keystr = vlu.vls.videolayers[i].videoblocks[j].ispubliclib?publickeystr:privatekeystr;
        String resfilename = vlu.vls.videolayers[i].videoblocks[j].filename;
        String bnm = resfilename.substring(0,resfilename.lastIndexOf(".")).replaceAll('temp/', '');
        String ext = resfilename.substring(resfilename.lastIndexOf("."));

        String revolume = vlu.vls.videolayers[i].videoblocks[j].revolume.toString();
        String respeed = vlu.vls.videolayers[i].videoblocks[j].respeed.toString();
        String restp = (1/vlu.vls.videolayers[i].videoblocks[j].respeed).toString();
        if(revolume.length>4)revolume= revolume.substring(0,4);
        if(respeed.length>6)respeed= respeed.substring(0,6);
        if(restp.length>6)restp= restp.substring(0,6);

        String ss = globals.packData.timestrFromMillisec(vlu.vls.videolayers[i].videoblocks[j].filestartpos.inMilliseconds);
        String ts = globals.packData.timestrFromMillisec(vlu.vls.videolayers[i].videoblocks[j].blocklength.inMilliseconds);

//cut to file-block (filestartpos=0)
        if(vlu.vls.videolayers[i].videoblocks[j].fileclass=="mp4")
        {
cmd = "/usr/local/bin/ffmpeg -ss "+ss+" -t "+ts+" -i "+websitepath+"/"+keystr+"/"+resfilename
+" -c:v "+videoencoder+" -y "+websitepath+"/"+privatekeystr+"/temp/"+bnm+"-cutss-"+i.toString()+"-"+j.toString()+".mkv";
await shellexec(cmd);
await appendecho(cmd+"\n");
vlu.vls.videolayers[i].videoblocks[j].filename = "temp/"+bnm+"-cutss-"+i.toString()+"-"+j.toString()+".mkv";
vlu.vls.videolayers[i].videoblocks[j].ispubliclib = false;
vlu.vls.videolayers[i].videoblocks[j].filestartpos = Duration(milliseconds: 0);
keystr = privatekeystr;
resfilename = vlu.vls.videolayers[i].videoblocks[j].filename;
bnm = resfilename.substring(0,resfilename.lastIndexOf(".")).replaceAll('temp/', '');
ext = resfilename.substring(resfilename.lastIndexOf("."));
        }
        if(vlu.vls.videolayers[i].videoblocks[j].fileclass=="mp3")
        {
cmd = "/usr/local/bin/ffmpeg -ss "+ss+" -t "+ts+" -i "+websitepath+"/"+keystr+"/"+resfilename
+" -c:a "+audioencoder+" -y "+websitepath+"/"+privatekeystr+"/temp/"+bnm+"-cutss-"+i.toString()+"-"+j.toString()+".aac";
await shellexec(cmd);
await appendecho(cmd+"\n");
vlu.vls.videolayers[i].videoblocks[j].filename = "temp/"+bnm+"-cutss-"+i.toString()+"-"+j.toString()+".aac";
vlu.vls.videolayers[i].videoblocks[j].ispubliclib = false;
vlu.vls.videolayers[i].videoblocks[j].filestartpos = Duration(milliseconds: 0);
keystr = privatekeystr;
resfilename = vlu.vls.videolayers[i].videoblocks[j].filename;
bnm = resfilename.substring(0,resfilename.lastIndexOf(".")).replaceAll('temp/', '');
ext = resfilename.substring(resfilename.lastIndexOf("."));
        }

//fix to final size
        if(vlu.vls.videolayers[i].videoblocks[j].fileclass=="mp4")
        {
cmd = "/usr/local/bin/ffmpeg -i "+websitepath+"/"+keystr+"/"+resfilename
+" -c:v "+videoencoder+" -c:a copy -vf scale="+tw+":"+th
+",setsar=1 -y "+websitepath+"/"+privatekeystr+"/temp/"+bnm+"-fixed-"+i.toString()+"-"+j.toString()+".mkv";
await shellexec(cmd);
await appendecho(cmd+"\n");
vlu.vls.videolayers[i].videoblocks[j].filename = "temp/"+bnm+"-fixed-"+i.toString()+"-"+j.toString()+".mkv";
vlu.vls.videolayers[i].videoblocks[j].ispubliclib = false;
keystr = privatekeystr;
resfilename = vlu.vls.videolayers[i].videoblocks[j].filename;
bnm = resfilename.substring(0,resfilename.lastIndexOf(".")).replaceAll('temp/', '');
ext = resfilename.substring(resfilename.lastIndexOf("."));
        }
        if(vlu.vls.videolayers[i].videoblocks[j].fileclass=="png")
        {
cmd = "/usr/local/bin/convert "+websitepath+"/"+keystr+"/"+resfilename
+" -resize "+tw+"x"+th
+" "+websitepath+"/"+privatekeystr+"/temp/"+bnm+"-fixed-"+i.toString()+"-"+j.toString()+ext;
await shellexec(cmd);
await appendecho(cmd+"\n");
vlu.vls.videolayers[i].videoblocks[j].filename = "temp/"+bnm+"-fixed-"+i.toString()+"-"+j.toString()+ext;
vlu.vls.videolayers[i].videoblocks[j].ispubliclib = false;
keystr = privatekeystr;
resfilename = vlu.vls.videolayers[i].videoblocks[j].filename;
bnm = resfilename.substring(0,resfilename.lastIndexOf(".")).replaceAll('temp/', '');
ext = resfilename.substring(resfilename.lastIndexOf("."));
        }

        if(vlu.vls.videolayers[i].videoblocks[j].respeedenable)
        {
          if(vlu.vls.videolayers[i].videoblocks[j].fileclass=="mp4")
          {
cmd = "/usr/local/bin/ffmpeg -i "+websitepath+"/"+keystr+"/"+resfilename
+" -filter_complex [0:v]setpts="+restp+"*PTS[v];[0:a]atempo="+respeed
+"[a] -map [v] -map [a] -c:v "+videoencoder+" -y "+websitepath+"/"+privatekeystr+"/temp/"+bnm+"-respeed-"+i.toString()+"-"+j.toString()+".mkv";
await shellexec(cmd);
await appendecho(cmd+"\n");
vlu.vls.videolayers[i].videoblocks[j].filename = "temp/"+bnm+"-respeed-"+i.toString()+"-"+j.toString()+".mkv";
vlu.vls.videolayers[i].videoblocks[j].ispubliclib = false;
vlu.vls.videolayers[i].videoblocks[j].respeedenable = false;
vlu.vls.videolayers[i].videoblocks[j].blocklength = Duration(milliseconds: vlu.vls.videolayers[i].videoblocks[j].blocklength.inMilliseconds~/vlu.vls.videolayers[i].videoblocks[j].respeed);
vlu.vls.videolayers[i].videoblocks[j].tostamp = vlu.vls.videolayers[i].videoblocks[j].fromstamp+vlu.vls.videolayers[i].videoblocks[j].blocklength;
keystr = privatekeystr;
resfilename = vlu.vls.videolayers[i].videoblocks[j].filename;
bnm = resfilename.substring(0,resfilename.lastIndexOf(".")).replaceAll('temp/', '');
ext = resfilename.substring(resfilename.lastIndexOf("."));
          }
          else if(vlu.vls.videolayers[i].videoblocks[j].fileclass=="mp3")
          {
cmd = "/usr/local/bin/ffmpeg -i "+websitepath+"/"+keystr+"/"+resfilename
+" -filter:a atempo="+respeed+" -vn -y "+websitepath+"/"+privatekeystr+"/temp/"+bnm+"-respeed-"+i.toString()+"-"+j.toString()+ext;
await shellexec(cmd);
await appendecho(cmd+"\n");
vlu.vls.videolayers[i].videoblocks[j].filename = "temp/"+bnm+"-respeed-"+i.toString()+"-"+j.toString()+ext;
vlu.vls.videolayers[i].videoblocks[j].ispubliclib = false;
vlu.vls.videolayers[i].videoblocks[j].respeedenable = false;
vlu.vls.videolayers[i].videoblocks[j].blocklength = Duration(milliseconds: vlu.vls.videolayers[i].videoblocks[j].blocklength.inMilliseconds~/vlu.vls.videolayers[i].videoblocks[j].respeed);
vlu.vls.videolayers[i].videoblocks[j].tostamp = vlu.vls.videolayers[i].videoblocks[j].fromstamp+vlu.vls.videolayers[i].videoblocks[j].blocklength;
keystr = privatekeystr;
resfilename = vlu.vls.videolayers[i].videoblocks[j].filename;
bnm = resfilename.substring(0,resfilename.lastIndexOf(".")).replaceAll('temp/', '');
ext = resfilename.substring(resfilename.lastIndexOf("."));
          }
        }
        if(vlu.vls.videolayers[i].videoblocks[j].revolumeenable)
        {
          if(vlu.vls.videolayers[i].videoblocks[j].fileclass=="mp4")
          {
cmd = "/usr/local/bin/ffmpeg -i "+websitepath+"/"+keystr+"/"+resfilename
+" -filter:a volume="+revolume+" -c:v copy -y "+websitepath+"/"+privatekeystr+"/temp/"+bnm+"-revolumed-"+i.toString()+"-"+j.toString()+".mkv";
await shellexec(cmd);
await appendecho(cmd+"\n");
vlu.vls.videolayers[i].videoblocks[j].filename = "temp/"+bnm+"-revolumed-"+i.toString()+"-"+j.toString()+".mkv";
vlu.vls.videolayers[i].videoblocks[j].ispubliclib = false;
vlu.vls.videolayers[i].videoblocks[j].revolumeenable = false;
keystr = privatekeystr;
resfilename = vlu.vls.videolayers[i].videoblocks[j].filename;
bnm = resfilename.substring(0,resfilename.lastIndexOf(".")).replaceAll('temp/', '');
ext = resfilename.substring(resfilename.lastIndexOf("."));
          }
          else if(vlu.vls.videolayers[i].videoblocks[j].fileclass=="mp3")
          {
cmd = "/usr/local/bin/ffmpeg -i "+websitepath+"/"+keystr+"/"+resfilename
+" -filter:a volume="+revolume+" -y "+websitepath+"/"+privatekeystr+"/temp/"+bnm+"-revolumed-"+i.toString()+"-"+j.toString()+ext;
await shellexec(cmd);
await appendecho(cmd+"\n");
vlu.vls.videolayers[i].videoblocks[j].filename = "temp/"+bnm+"-revolumed-"+i.toString()+"-"+j.toString()+ext;
vlu.vls.videolayers[i].videoblocks[j].ispubliclib = false;
vlu.vls.videolayers[i].videoblocks[j].revolumeenable = false;
keystr = privatekeystr;
resfilename = vlu.vls.videolayers[i].videoblocks[j].filename;
bnm = resfilename.substring(0,resfilename.lastIndexOf(".")).replaceAll('temp/', '');
ext = resfilename.substring(resfilename.lastIndexOf("."));
          }
        }
        if(vlu.vls.videolayers[i].videoblocks[j].resizeenable)
        {
          if(vlu.vls.videolayers[i].videoblocks[j].fileclass=="mp4")
          {
cmd = "/usr/local/bin/ffmpeg -i "+websitepath+"/"+keystr+"/"+resfilename
+" -c:v "+videoencoder+" -vf scale="+vlu.vls.videolayers[i].videoblocks[j].resizewidth.toString()+":"+vlu.vls.videolayers[i].videoblocks[j].resizeheight.toString()
+",setsar=1 -y "+websitepath+"/"+privatekeystr+"/temp/"+bnm+"-resized-"+i.toString()+"-"+j.toString()+".mkv";
await shellexec(cmd);
await appendecho(cmd+"\n");
vlu.vls.videolayers[i].videoblocks[j].filename = "temp/"+bnm+"-resized-"+i.toString()+"-"+j.toString()+".mkv";
vlu.vls.videolayers[i].videoblocks[j].ispubliclib = false;
keystr = privatekeystr;
resfilename = vlu.vls.videolayers[i].videoblocks[j].filename;
bnm = resfilename.substring(0,resfilename.lastIndexOf(".")).replaceAll('temp/', '');
ext = resfilename.substring(resfilename.lastIndexOf("."));
          }
          else if(vlu.vls.videolayers[i].videoblocks[j].fileclass=="png")
          {
cmd = "/usr/local/bin/convert "+websitepath+"/"+keystr+"/"+resfilename
+" -resize "+vlu.vls.videolayers[i].videoblocks[j].resizewidth.toString()+"x"+vlu.vls.videolayers[i].videoblocks[j].resizeheight.toString()
+" "+websitepath+"/"+privatekeystr+"/temp/"+bnm+"-resized-"+i.toString()+"-"+j.toString()+ext;
await shellexec(cmd);
await appendecho(cmd+"\n");
vlu.vls.videolayers[i].videoblocks[j].filename = "temp/"+bnm+"-resized-"+i.toString()+"-"+j.toString()+ext;
vlu.vls.videolayers[i].videoblocks[j].ispubliclib = false;
keystr = privatekeystr;
resfilename = vlu.vls.videolayers[i].videoblocks[j].filename;
bnm = resfilename.substring(0,resfilename.lastIndexOf(".")).replaceAll('temp/', '');
ext = resfilename.substring(resfilename.lastIndexOf("."));
          }
        }
  }  

  Future<void> preparefilespecified2(String taskid,int layeridx,int blockidx)
  async
  {
    String tw = await gettaskwidth(taskid);
    String th = await gettaskheight(taskid);
    String privatekeystr = await gettaskkey(taskid);
    String publickeystr = pubkey;
    String keystr = privatekeystr;
    String cmd = "";

    if(int.parse(th)>540)
    {
      double ar = int.parse(tw)/int.parse(th);
      th="540";      
      tw=(int.parse(th)*ar).toInt().toString();
    }

    int i=layeridx;
    int j=blockidx;

        keystr = vlu.vls.videolayers[i].videoblocks[j].ispubliclib?publickeystr:privatekeystr;
        String resfilename = vlu.vls.videolayers[i].videoblocks[j].filename;
        String bnm = resfilename.substring(0,resfilename.lastIndexOf(".")).replaceAll('temp/', '');
        String ext = resfilename.substring(resfilename.lastIndexOf("."));

        String revolume = vlu.vls.videolayers[i].videoblocks[j].revolume.toString();
        String respeed = vlu.vls.videolayers[i].videoblocks[j].respeed.toString();
        String restp = (1/vlu.vls.videolayers[i].videoblocks[j].respeed).toString();
        if(revolume.length>4)revolume= revolume.substring(0,4);
        if(respeed.length>6)respeed= respeed.substring(0,6);
        if(restp.length>6)restp= restp.substring(0,6);

        String ss = globals.packData.timestrFromMillisec(vlu.vls.videolayers[i].videoblocks[j].filestartpos.inMilliseconds);
        String ts = globals.packData.timestrFromMillisec(vlu.vls.videolayers[i].videoblocks[j].blocklength.inMilliseconds);

//cut to file-block (filestartpos=0)
        if(vlu.vls.videolayers[i].videoblocks[j].fileclass=="mp4")
        {
cmd = "/usr/local/bin/ffmpeg -ss "+ss+" -t "+ts+" -i "+websitepath+"/"+keystr+"/"+resfilename
+" -c:v "+videoencoder+" -y "+websitepath+"/"+privatekeystr+"/temp/"+bnm+"-cutss-"+i.toString()+"-"+j.toString()+".mkv";
await shellexec(cmd);
await appendecho(cmd+"\n");
vlu.vls.videolayers[i].videoblocks[j].filename = "temp/"+bnm+"-cutss-"+i.toString()+"-"+j.toString()+".mkv";
vlu.vls.videolayers[i].videoblocks[j].ispubliclib = false;
vlu.vls.videolayers[i].videoblocks[j].filestartpos = Duration(milliseconds: 0);
keystr = privatekeystr;
resfilename = vlu.vls.videolayers[i].videoblocks[j].filename;
bnm = resfilename.substring(0,resfilename.lastIndexOf(".")).replaceAll('temp/', '');
ext = resfilename.substring(resfilename.lastIndexOf("."));
        }
        if(vlu.vls.videolayers[i].videoblocks[j].fileclass=="mp3")
        {
cmd = "/usr/local/bin/ffmpeg -ss "+ss+" -t "+ts+" -i "+websitepath+"/"+keystr+"/"+resfilename
+" -c:a "+audioencoder+" -y "+websitepath+"/"+privatekeystr+"/temp/"+bnm+"-cutss-"+i.toString()+"-"+j.toString()+".aac";
await shellexec(cmd);
await appendecho(cmd+"\n");
vlu.vls.videolayers[i].videoblocks[j].filename = "temp/"+bnm+"-cutss-"+i.toString()+"-"+j.toString()+".aac";
vlu.vls.videolayers[i].videoblocks[j].ispubliclib = false;
vlu.vls.videolayers[i].videoblocks[j].filestartpos = Duration(milliseconds: 0);
keystr = privatekeystr;
resfilename = vlu.vls.videolayers[i].videoblocks[j].filename;
bnm = resfilename.substring(0,resfilename.lastIndexOf(".")).replaceAll('temp/', '');
ext = resfilename.substring(resfilename.lastIndexOf("."));
        }

//fix to final size
        if(vlu.vls.videolayers[i].videoblocks[j].fileclass=="mp4")
        {
cmd = "/usr/local/bin/ffmpeg -i "+websitepath+"/"+keystr+"/"+resfilename
+" -c:v "+videoencoder+" -c:a copy -vf scale="+tw+":"+th
+",setsar=1 -y "+websitepath+"/"+privatekeystr+"/temp/"+bnm+"-fixed-"+i.toString()+"-"+j.toString()+".mkv";
await shellexec(cmd);
await appendecho(cmd+"\n");
vlu.vls.videolayers[i].videoblocks[j].filename = "temp/"+bnm+"-fixed-"+i.toString()+"-"+j.toString()+".mkv";
vlu.vls.videolayers[i].videoblocks[j].ispubliclib = false;
keystr = privatekeystr;
resfilename = vlu.vls.videolayers[i].videoblocks[j].filename;
bnm = resfilename.substring(0,resfilename.lastIndexOf(".")).replaceAll('temp/', '');
ext = resfilename.substring(resfilename.lastIndexOf("."));
        }
        if(vlu.vls.videolayers[i].videoblocks[j].fileclass=="png")
        {
cmd = "/usr/local/bin/convert "+websitepath+"/"+keystr+"/"+resfilename
+" -resize "+tw+"x"+th
+" "+websitepath+"/"+privatekeystr+"/temp/"+bnm+"-fixed-"+i.toString()+"-"+j.toString()+ext;
await shellexec(cmd);
await appendecho(cmd+"\n");
vlu.vls.videolayers[i].videoblocks[j].filename = "temp/"+bnm+"-fixed-"+i.toString()+"-"+j.toString()+ext;
vlu.vls.videolayers[i].videoblocks[j].ispubliclib = false;
keystr = privatekeystr;
resfilename = vlu.vls.videolayers[i].videoblocks[j].filename;
bnm = resfilename.substring(0,resfilename.lastIndexOf(".")).replaceAll('temp/', '');
ext = resfilename.substring(resfilename.lastIndexOf("."));
        }

        if(vlu.vls.videolayers[i].videoblocks[j].respeedenable)
        {
          if(vlu.vls.videolayers[i].videoblocks[j].fileclass=="mp4")
          {
cmd = "/usr/local/bin/ffmpeg -i "+websitepath+"/"+keystr+"/"+resfilename
+" -filter_complex [0:v]setpts="+restp+"*PTS[v];[0:a]atempo="+respeed
+"[a] -map [v] -map [a] -c:v "+videoencoder+" -y "+websitepath+"/"+privatekeystr+"/temp/"+bnm+"-respeed-"+i.toString()+"-"+j.toString()+".mkv";
await shellexec(cmd);
await appendecho(cmd+"\n");
vlu.vls.videolayers[i].videoblocks[j].filename = "temp/"+bnm+"-respeed-"+i.toString()+"-"+j.toString()+".mkv";
vlu.vls.videolayers[i].videoblocks[j].ispubliclib = false;
vlu.vls.videolayers[i].videoblocks[j].respeedenable = false;
vlu.vls.videolayers[i].videoblocks[j].blocklength = Duration(milliseconds: vlu.vls.videolayers[i].videoblocks[j].blocklength.inMilliseconds~/vlu.vls.videolayers[i].videoblocks[j].respeed);
vlu.vls.videolayers[i].videoblocks[j].tostamp = vlu.vls.videolayers[i].videoblocks[j].fromstamp+vlu.vls.videolayers[i].videoblocks[j].blocklength;
keystr = privatekeystr;
resfilename = vlu.vls.videolayers[i].videoblocks[j].filename;
bnm = resfilename.substring(0,resfilename.lastIndexOf(".")).replaceAll('temp/', '');
ext = resfilename.substring(resfilename.lastIndexOf("."));
          }
          else if(vlu.vls.videolayers[i].videoblocks[j].fileclass=="mp3")
          {
cmd = "/usr/local/bin/ffmpeg -i "+websitepath+"/"+keystr+"/"+resfilename
+" -filter:a atempo="+respeed+" -vn -y "+websitepath+"/"+privatekeystr+"/temp/"+bnm+"-respeed-"+i.toString()+"-"+j.toString()+ext;
await shellexec(cmd);
await appendecho(cmd+"\n");
vlu.vls.videolayers[i].videoblocks[j].filename = "temp/"+bnm+"-respeed-"+i.toString()+"-"+j.toString()+ext;
vlu.vls.videolayers[i].videoblocks[j].ispubliclib = false;
vlu.vls.videolayers[i].videoblocks[j].respeedenable = false;
vlu.vls.videolayers[i].videoblocks[j].blocklength = Duration(milliseconds: vlu.vls.videolayers[i].videoblocks[j].blocklength.inMilliseconds~/vlu.vls.videolayers[i].videoblocks[j].respeed);
vlu.vls.videolayers[i].videoblocks[j].tostamp = vlu.vls.videolayers[i].videoblocks[j].fromstamp+vlu.vls.videolayers[i].videoblocks[j].blocklength;
keystr = privatekeystr;
resfilename = vlu.vls.videolayers[i].videoblocks[j].filename;
bnm = resfilename.substring(0,resfilename.lastIndexOf(".")).replaceAll('temp/', '');
ext = resfilename.substring(resfilename.lastIndexOf("."));
          }
        }
        if(vlu.vls.videolayers[i].videoblocks[j].revolumeenable)
        {
          if(vlu.vls.videolayers[i].videoblocks[j].fileclass=="mp4")
          {
cmd = "/usr/local/bin/ffmpeg -i "+websitepath+"/"+keystr+"/"+resfilename
+" -filter:a volume="+revolume+" -c:v copy -y "+websitepath+"/"+privatekeystr+"/temp/"+bnm+"-revolumed-"+i.toString()+"-"+j.toString()+".mkv";
await shellexec(cmd);
await appendecho(cmd+"\n");
vlu.vls.videolayers[i].videoblocks[j].filename = "temp/"+bnm+"-revolumed-"+i.toString()+"-"+j.toString()+".mkv";
vlu.vls.videolayers[i].videoblocks[j].ispubliclib = false;
vlu.vls.videolayers[i].videoblocks[j].revolumeenable = false;
keystr = privatekeystr;
resfilename = vlu.vls.videolayers[i].videoblocks[j].filename;
bnm = resfilename.substring(0,resfilename.lastIndexOf(".")).replaceAll('temp/', '');
ext = resfilename.substring(resfilename.lastIndexOf("."));
          }
          else if(vlu.vls.videolayers[i].videoblocks[j].fileclass=="mp3")
          {
cmd = "/usr/local/bin/ffmpeg -i "+websitepath+"/"+keystr+"/"+resfilename
+" -filter:a volume="+revolume+" -y "+websitepath+"/"+privatekeystr+"/temp/"+bnm+"-revolumed-"+i.toString()+"-"+j.toString()+ext;
await shellexec(cmd);
await appendecho(cmd+"\n");
vlu.vls.videolayers[i].videoblocks[j].filename = "temp/"+bnm+"-revolumed-"+i.toString()+"-"+j.toString()+ext;
vlu.vls.videolayers[i].videoblocks[j].ispubliclib = false;
vlu.vls.videolayers[i].videoblocks[j].revolumeenable = false;
keystr = privatekeystr;
resfilename = vlu.vls.videolayers[i].videoblocks[j].filename;
bnm = resfilename.substring(0,resfilename.lastIndexOf(".")).replaceAll('temp/', '');
ext = resfilename.substring(resfilename.lastIndexOf("."));
          }
        }
        if(vlu.vls.videolayers[i].videoblocks[j].resizeenable)
        {
          if(vlu.vls.videolayers[i].videoblocks[j].fileclass=="mp4")
          {
cmd = "/usr/local/bin/ffmpeg -i "+websitepath+"/"+keystr+"/"+resfilename
+" -c:v "+videoencoder+" -vf scale="+vlu.vls.videolayers[i].videoblocks[j].resizewidth.toString()+":"+vlu.vls.videolayers[i].videoblocks[j].resizeheight.toString()
+",setsar=1 -y "+websitepath+"/"+privatekeystr+"/temp/"+bnm+"-resized-"+i.toString()+"-"+j.toString()+".mkv";
await shellexec(cmd);
await appendecho(cmd+"\n");
vlu.vls.videolayers[i].videoblocks[j].filename = "temp/"+bnm+"-resized-"+i.toString()+"-"+j.toString()+".mkv";
vlu.vls.videolayers[i].videoblocks[j].ispubliclib = false;
keystr = privatekeystr;
resfilename = vlu.vls.videolayers[i].videoblocks[j].filename;
bnm = resfilename.substring(0,resfilename.lastIndexOf(".")).replaceAll('temp/', '');
ext = resfilename.substring(resfilename.lastIndexOf("."));
          }
          else if(vlu.vls.videolayers[i].videoblocks[j].fileclass=="png")
          {
cmd = "/usr/local/bin/convert "+websitepath+"/"+keystr+"/"+resfilename
+" -resize "+vlu.vls.videolayers[i].videoblocks[j].resizewidth.toString()+"x"+vlu.vls.videolayers[i].videoblocks[j].resizeheight.toString()
+" "+websitepath+"/"+privatekeystr+"/temp/"+bnm+"-resized-"+i.toString()+"-"+j.toString()+ext;
await shellexec(cmd);
await appendecho(cmd+"\n");
vlu.vls.videolayers[i].videoblocks[j].filename = "temp/"+bnm+"-resized-"+i.toString()+"-"+j.toString()+ext;
vlu.vls.videolayers[i].videoblocks[j].ispubliclib = false;
keystr = privatekeystr;
resfilename = vlu.vls.videolayers[i].videoblocks[j].filename;
bnm = resfilename.substring(0,resfilename.lastIndexOf(".")).replaceAll('temp/', '');
ext = resfilename.substring(resfilename.lastIndexOf("."));
          }
        }
  }

  Future<String> calbackgroundmattingv2(String taskid)
  async
  {
    String resultfile = "-";
    String cmd = "";
    String args = "-";

    if(vlu.vls.videolayers.isEmpty)
    {
      await taskfailed(taskid);
      await appendecho("task: "+taskid+" failed (video layer struct empty)\n");
      return resultfile;
    }

    vlu.sortBlocksD();
    vlu.sortLayersZ();

    args = await gettaskargs(taskid);
    List<String> argblocks = args.split("*");
    List<String> blockitm = argblocks[0].split("^");
    int vsrclayeridx = int.parse(blockitm[0]);
    int vsrcblockidx = int.parse(blockitm[1]);
    blockitm = argblocks[1].split("^");
    int obglayeridx = int.parse(blockitm[0]);
    int obgblockidx = int.parse(blockitm[1]);

    if(vlu.vls.videolayers[vsrclayeridx].videoblocks[vsrcblockidx].fileclass!="mp4"
  ||vlu.vls.videolayers[obglayeridx].videoblocks[obgblockidx].fileclass!="png")
    {
      await taskfailed(taskid);
      await appendecho("task: "+taskid+" failed (blocktype error)\n");
      return resultfile;
    }

    await preparefilespecified0(taskid,vsrclayeridx,vsrcblockidx);
    await preparefilespecified0(taskid,obglayeridx,obgblockidx);

    //$1 aibackendpath $2 video $3 png $4 outputdir
    String privatekeystr = await gettaskkey(taskid);
    //String publickeystr = pubkey;
    String keystr = privatekeystr;
    cmd = "rm -rf "+websitepath+"/"+privatekeystr+"/temp/backgroundmattingv2";
    await appendecho(await shellexec3(cmd,taskid)+"\n");
    await appendecho(cmd+"\n");
    cmd = "bash "+aibackendpath + "/matting1/alexpark_runner.sh "+aibackendpath+" "
    +websitepath+"/"+keystr+"/"+vlu.vls.videolayers[vsrclayeridx].videoblocks[vsrcblockidx].filename+" "
    +websitepath+"/"+keystr+"/"+vlu.vls.videolayers[obglayeridx].videoblocks[obgblockidx].filename+" "
    +websitepath+"/"+privatekeystr+"/temp/backgroundmattingv2/";
    await appendecho(await shellexec3(cmd,taskid)+"\n");
    await appendecho(cmd+"\n");
    cmd = "cp -f "+websitepath+"/"+privatekeystr+"/temp/backgroundmattingv2/com.mp4 "+websitepath+"/"+privatekeystr+"/"+taskid+".mp4";
    await appendecho(await shellexec3(cmd,taskid)+"\n");
    await appendecho(cmd+"\n");
    cmd = "cp -f "+websitepath+"/"+privatekeystr+"/temp/backgroundmattingv2/pha.mp4 "+websitepath+"/"+privatekeystr+"/"+taskid+"-pha.mp4";
    await appendecho(await shellexec3(cmd,taskid)+"\n");
    await appendecho(cmd+"\n");

    if(await File(""+websitepath+"/"+privatekeystr+"/"+taskid+".mp4").exists())
    {
      await taskdone(taskid);
      await appendecho("task: "+taskid+" done\n");
      String addlibrst = await addtoprivatelib(privatekeystr,taskid,await gettaskdesc(taskid));
      await addtoprivatelib2(privatekeystr,taskid,"mask"+await gettaskdesc(taskid));
      await appendecho("task: "+taskid+" add to privatelib "+addlibrst+"\n");
    }
    else
    {
      await taskfailed(taskid);
      await appendecho("task: "+taskid+" failed\n");
    }

    resultfile = taskid+".mp4";
    return resultfile;
  }
  
  Future<String> calfreeformvideoinpainting(String taskid)
  async
  {
    String resultfile = "-";
    String cmd = "";
    String args = "-";

    if(vlu.vls.videolayers.isEmpty)
    {
      await taskfailed(taskid);
      await appendecho("task: "+taskid+" failed (video layer struct empty)\n");
      return resultfile;
    }

    vlu.sortBlocksD();
    vlu.sortLayersZ();

    args = await gettaskargs(taskid);
    List<String> argblocks = args.split("*");
    List<String> blockitm = argblocks[0].split("^");
    int srclayeridx = int.parse(blockitm[0]);
    int srcblockidx = int.parse(blockitm[1]);
    blockitm = argblocks[1].split("^");
    int masklayeridx = int.parse(blockitm[0]);
    int maskblockidx = int.parse(blockitm[1]);

    if(vlu.vls.videolayers[srclayeridx].videoblocks[srcblockidx].fileclass!="mp4"
  ||vlu.vls.videolayers[masklayeridx].videoblocks[maskblockidx].fileclass!="mp4")
    {
      await taskfailed(taskid);
      await appendecho("task: "+taskid+" failed (blocktype error)\n");
      return resultfile;
    }

    await preparefilespecified1(taskid,srclayeridx,srcblockidx);
    await preparefilespecified1(taskid,masklayeridx,maskblockidx);

    
    String privatekeystr = await gettaskkey(taskid);
    //String publickeystr = pubkey;
    String keystr = privatekeystr;
    cmd = "rm -rf "+websitepath+"/"+privatekeystr+"/temp/freeformvideoinpainting";
    await appendecho(await shellexec3(cmd,taskid)+"\n");
    await appendecho(cmd+"\n");
    cmd = "mkdir "+websitepath+"/"+privatekeystr+"/temp/freeformvideoinpainting";
    await appendecho(await shellexec3(cmd,taskid)+"\n");
    await appendecho(cmd+"\n");
    cmd = "mkdir "+websitepath+"/"+privatekeystr+"/temp/freeformvideoinpainting/sourcefps";
    await appendecho(await shellexec3(cmd,taskid)+"\n");
    await appendecho(cmd+"\n");
    cmd = "mkdir "+websitepath+"/"+privatekeystr+"/temp/freeformvideoinpainting/maskfps";
    await appendecho(await shellexec3(cmd,taskid)+"\n");
    await appendecho(cmd+"\n");
    cmd = "mkdir "+websitepath+"/"+privatekeystr+"/temp/freeformvideoinpainting/result";
    await appendecho(await shellexec3(cmd,taskid)+"\n");
    await appendecho(cmd+"\n");
    cmd = "/usr/local/bin/ffmpeg -i "+websitepath+"/"+keystr+"/"+vlu.vls.videolayers[srclayeridx].videoblocks[srcblockidx].filename
    +" -vf fps=25 -y "+websitepath+"/"+privatekeystr+"/temp/freeformvideoinpainting/sourcefps/%d.png";
    await shellexec(cmd);
    await appendecho(cmd+"\n");
    cmd = "/usr/local/bin/ffmpeg -i "+websitepath+"/"+keystr+"/"+vlu.vls.videolayers[masklayeridx].videoblocks[maskblockidx].filename
    +" -vf fps=25 -y "+websitepath+"/"+privatekeystr+"/temp/freeformvideoinpainting/maskfps/%d.png";
    await shellexec(cmd);
    await appendecho(cmd+"\n");

    Directory dir = Directory(websitepath+"/"+privatekeystr+"/temp/freeformvideoinpainting/sourcefps");
    int filecount = 0;
    await dir.list(recursive: false).forEach(
    (f)
    {
      filecount++;
      //print(f);
    });

/*
    //$1 aibackendpath $2 sourcevideo $3 maskvideo $4 outputdir base $5 current frame number
    for(int i=1;i<filecount;i+=9)
    {
      cmd = "bash "+aibackendpath + "/Free-Form-Video-Inpainting/alexpark_runner_bk.sh "+aibackendpath+" "
      +websitepath+"/"+keystr+"/"+vlu.vls.videolayers[srclayeridx].videoblocks[srcblockidx].filename+" "
      +websitepath+"/"+keystr+"/"+vlu.vls.videolayers[masklayeridx].videoblocks[maskblockidx].filename+" "
      +websitepath+"/"+privatekeystr+"/temp/freeformvideoinpainting"+" "+i.toString();
      await appendecho(await shellexec3(cmd,taskid)+"\n");
      await appendecho(cmd+"\n");
    }
*/

    //$1 aibackendpath $2 sourcevideo $3 maskvideo $4 outputdir base $5 frames in total
    cmd = "bash "+aibackendpath + "/inpainting1/alexpark_runner.sh "+aibackendpath+" "
      +websitepath+"/"+keystr+"/"+vlu.vls.videolayers[srclayeridx].videoblocks[srcblockidx].filename+" "
      +websitepath+"/"+keystr+"/"+vlu.vls.videolayers[masklayeridx].videoblocks[maskblockidx].filename+" "
      +websitepath+"/"+privatekeystr+"/temp/freeformvideoinpainting"+" "+filecount.toString();
    await appendecho(await shellexec3(cmd,taskid)+"\n");
    await appendecho(cmd+"\n");


    cmd = "/usr/local/bin/ffmpeg -r 25 -start_number 0 -i "
    +websitepath+"/"+privatekeystr+"/temp/freeformvideoinpainting/result/%d.png"
    +" -c:v libx264 -vf fps=25,format=yuv420p -y "+websitepath+"/"+privatekeystr+"/"+taskid+".mp4";
    await shellexec(cmd);
    await appendecho(cmd+"\n");
    

    if(await File(""+websitepath+"/"+privatekeystr+"/"+taskid+".mp4").exists())
    {
      await taskdone(taskid);
      await appendecho("task: "+taskid+" done\n");
      String addlibrst = await addtoprivatelib(privatekeystr,taskid,await gettaskdesc(taskid));
      await appendecho("task: "+taskid+" add to privatelib "+addlibrst+"\n");
    }
    else
    {
      await taskfailed(taskid);
      await appendecho("task: "+taskid+" failed\n");
    }

    resultfile = taskid+".mp4";
    return resultfile;
  }

  Future<String> calpanopticdeeplab(String taskid)
  async
  {
    String resultfile = "-";
    String cmd = "";
    String args = "-";

    if(vlu.vls.videolayers.isEmpty)
    {
      await taskfailed(taskid);
      await appendecho("task: "+taskid+" failed (video layer struct empty)\n");
      return resultfile;
    }

    vlu.sortBlocksD();
    vlu.sortLayersZ();

    args = await gettaskargs(taskid);
    List<String> argblocks = args.split("*");
    List<String> blockitm = argblocks[0].split("^");
    int srclayeridx = int.parse(blockitm[0]);
    int srcblockidx = int.parse(blockitm[1]);
    List<String> colorsets = argblocks[1].split("^");
    List<String> rsets = List.filled(0, "",growable: true);
    for(int i=0;i<19;i++)
    {
      rsets.add("colormap["+i.toString()+"] = "+colorsets[i]+"#");
    }

    File fds = File(aibackendpath + "/panopticseg1/tools/demomod.py");
    String scritpy = await fds.readAsString();
    scritpy = scritpy.replaceAll("colormap[0]", rsets[0]);
    scritpy = scritpy.replaceAll("colormap[1]", rsets[1]);
    scritpy = scritpy.replaceAll("colormap[2]", rsets[2]);
    scritpy = scritpy.replaceAll("colormap[3]", rsets[3]);
    scritpy = scritpy.replaceAll("colormap[4]", rsets[4]);
    scritpy = scritpy.replaceAll("colormap[5]", rsets[5]);
    scritpy = scritpy.replaceAll("colormap[6]", rsets[6]);
    scritpy = scritpy.replaceAll("colormap[7]", rsets[7]);
    scritpy = scritpy.replaceAll("colormap[8]", rsets[8]);
    scritpy = scritpy.replaceAll("colormap[9]", rsets[9]);
    scritpy = scritpy.replaceAll("colormap[10]", rsets[10]);
    scritpy = scritpy.replaceAll("colormap[11]", rsets[11]);
    scritpy = scritpy.replaceAll("colormap[12]", rsets[12]);
    scritpy = scritpy.replaceAll("colormap[13]", rsets[13]);
    scritpy = scritpy.replaceAll("colormap[14]", rsets[14]);
    scritpy = scritpy.replaceAll("colormap[15]", rsets[15]);
    scritpy = scritpy.replaceAll("colormap[16]", rsets[16]);
    scritpy = scritpy.replaceAll("colormap[17]", rsets[17]);
    scritpy = scritpy.replaceAll("colormap[18]", rsets[18]);
    

    if(vlu.vls.videolayers[srclayeridx].videoblocks[srcblockidx].fileclass!="mp4")
    {
      await taskfailed(taskid);
      await appendecho("task: "+taskid+" failed (blocktype error)\n");
      return resultfile;
    }

    await preparefilespecified2(taskid,srclayeridx,srcblockidx);
    
    String privatekeystr = await gettaskkey(taskid);
    //String publickeystr = pubkey;
    String keystr = privatekeystr;

    cmd = "rm -rf "+aibackendpath + "/panopticseg1/tools/demo-"+privatekeystr+".py";
    await appendecho(await shellexec3(cmd,taskid)+"\n");
    await appendecho(cmd+"\n");

    File fdn = File(aibackendpath + "/panopticseg1/tools/demo-"+privatekeystr+".py");
    await fdn.writeAsString(scritpy);

    cmd = "rm -rf "+websitepath+"/"+privatekeystr+"/temp/panopticdeeplab";
    await appendecho(await shellexec3(cmd,taskid)+"\n");
    await appendecho(cmd+"\n");
    cmd = "mkdir "+websitepath+"/"+privatekeystr+"/temp/panopticdeeplab";
    await appendecho(await shellexec3(cmd,taskid)+"\n");
    await appendecho(cmd+"\n");
    cmd = "mkdir "+websitepath+"/"+privatekeystr+"/temp/panopticdeeplab/sourcefps";
    await appendecho(await shellexec3(cmd,taskid)+"\n");
    await appendecho(cmd+"\n");
    cmd = "mkdir "+websitepath+"/"+privatekeystr+"/temp/panopticdeeplab/result";
    await appendecho(await shellexec3(cmd,taskid)+"\n");
    await appendecho(cmd+"\n");
    cmd = "/usr/local/bin/ffmpeg -i "+websitepath+"/"+keystr+"/"+vlu.vls.videolayers[srclayeridx].videoblocks[srcblockidx].filename
    +" -vf fps=25 -y "+websitepath+"/"+privatekeystr+"/temp/panopticdeeplab/sourcefps/%04d.png";
    await shellexec(cmd);
    await appendecho(cmd+"\n");

    Directory dir = Directory(websitepath+"/"+privatekeystr+"/temp/panopticdeeplab/sourcefps");
    int filecount = 0;
    await dir.list(recursive: false).forEach(
    (f)
    {
      filecount++;
      //print(f);
    });

    //$1 aibackendpath $2 sourcevideo $3 maskvideo $4 outputdir base $5 frames in total $6 taskid
    cmd = "bash "+aibackendpath + "/panopticseg1/alexpark_runner.sh "+aibackendpath+" "
      +websitepath+"/"+keystr+"/"+vlu.vls.videolayers[srclayeridx].videoblocks[srcblockidx].filename+" "
      +websitepath+"/"+keystr+"/"+vlu.vls.videolayers[srclayeridx].videoblocks[srcblockidx].filename+" "
      +websitepath+"/"+privatekeystr+"/temp/panopticdeeplab"+" "+filecount.toString()+" "+taskid;
    await appendecho(await shellexec3(cmd,taskid)+"\n");
    await appendecho(cmd+"\n");

    cmd = "/usr/local/bin/ffmpeg -r 25 -start_number 0 -i "
    +websitepath+"/"+privatekeystr+"/temp/panopticdeeplab/result/instance/%d.png"
    +" -c:v libx264 -vf fps=25,format=yuv420p -y "+websitepath+"/"+privatekeystr+"/"+taskid+"-i.mp4";
    await shellexec(cmd);
    await appendecho(cmd+"\n");

    cmd = "/usr/local/bin/ffmpeg -r 25 -start_number 0 -i "
    +websitepath+"/"+privatekeystr+"/temp/panopticdeeplab/result/panoptic/%d.png"
    +" -c:v libx264 -vf fps=25,format=yuv420p -y "+websitepath+"/"+privatekeystr+"/"+taskid+".mp4";
    await shellexec(cmd);
    await appendecho(cmd+"\n");
    
    /*    */
    cmd = "/usr/local/bin/ffmpeg -r 25 -start_number 0 -i "
    +websitepath+"/"+privatekeystr+"/temp/panopticdeeplab/result/semantic/%d.png"
    +" -c:v libx264 -vf fps=25,format=yuv420p -y "+websitepath+"/"+privatekeystr+"/"+taskid+"-s.mp4";
    await shellexec(cmd);
    await appendecho(cmd+"\n");


    if(await File(""+websitepath+"/"+privatekeystr+"/"+taskid+".mp4").exists())
    {
      await taskdone(taskid);
      await appendecho("task: "+taskid+" done\n");
      String addlibrst = "";
      addlibrst = await addtoprivatelibi(privatekeystr,taskid,"ins"+await gettaskdesc(taskid));
      await appendecho("task: "+taskid+"-i add to privatelib "+addlibrst+"\n"); 
      addlibrst = await addtoprivatelib(privatekeystr,taskid,"pnt"+await gettaskdesc(taskid));
      await appendecho("task: "+taskid+"-p add to privatelib "+addlibrst+"\n");  
      addlibrst = await addtoprivatelibs(privatekeystr,taskid,"smt"+await gettaskdesc(taskid));
      await appendecho("task: "+taskid+"-s add to privatelib "+addlibrst+"\n");            
    }
    else
    {
      await taskfailed(taskid);
      await appendecho("task: "+taskid+" failed\n");
    }

    resultfile = taskid+".mp4";
    return resultfile;
  }

  Future<String> calskyar(String taskid)
  async
  {
    String resultfile = "-";
    String cmd = "";
    String args = "-";

    if(vlu.vls.videolayers.isEmpty)
    {
      await taskfailed(taskid);
      await appendecho("task: "+taskid+" failed (video layer struct empty)\n");
      return resultfile;
    }

    vlu.sortBlocksD();
    vlu.sortLayersZ();

    args = await gettaskargs(taskid);
    List<String> argblocks = args.split("*");
    List<String> blockitm = argblocks[0].split("^");
    int srclayeridx = int.parse(blockitm[0]);
    int srcblockidx = int.parse(blockitm[1]);
    blockitm = argblocks[1].split("^");
    int skylayeridx = int.parse(blockitm[0]);
    int skyblockidx = int.parse(blockitm[1]);

    if(vlu.vls.videolayers[srclayeridx].videoblocks[srcblockidx].fileclass!="mp4"
  ||(vlu.vls.videolayers[skylayeridx].videoblocks[skyblockidx].fileclass!="png"&&vlu.vls.videolayers[skylayeridx].videoblocks[skyblockidx].fileclass!="mp4"))
    {
      await taskfailed(taskid);
      await appendecho("task: "+taskid+" failed (blocktype error)\n");
      return resultfile;
    }

    //await preparefilespecified0(taskid,srclayeridx,srcblockidx);
    //await preparefilespecified0(taskid,skylayeridx,skyblockidx);

    //$1 aibackendpath $2 video $3 png $4 outputdir
    String privatekeystr = await gettaskkey(taskid);
    //String publickeystr = pubkey;
    String keystr = privatekeystr;

    if(vlu.vls.videolayers[skylayeridx].videoblocks[skyblockidx].fileclass=="png")
    {
      cmd = "/usr/local/bin/convert "+websitepath+"/"+keystr+"/"+vlu.vls.videolayers[skylayeridx].videoblocks[skyblockidx].filename+" "+websitepath+"/"+keystr+"/temp/skybox.jpg";
      await shellexec(cmd);
      await appendecho(cmd+"\n");    
    }


    File fds = File(aibackendpath + "/changesky1/config/alexparkmod.json");
    String scritpy = await fds.readAsString();
    scritpy = scritpy.replaceAll("/home/alexparkmz/Videos/annarbor.mp4",websitepath+"/"+keystr+"/"+vlu.vls.videolayers[srclayeridx].videoblocks[srcblockidx].filename);
    if(vlu.vls.videolayers[skylayeridx].videoblocks[skyblockidx].fileclass=="png")
    {
      scritpy = scritpy.replaceAll("/home/alexparkmz/Pictures/district9ship.jpg",websitepath+"/"+keystr+"/temp/skybox.jpg");
    }
    else
    {
      scritpy = scritpy.replaceAll("/home/alexparkmz/Pictures/district9ship.jpg",websitepath+"/"+keystr+"/"+vlu.vls.videolayers[skylayeridx].videoblocks[skyblockidx].filename);
    }
    File fdn = File(aibackendpath + "/changesky1/config/alexpark.json");
    await fdn.writeAsString(scritpy);

    cmd = "rm -rf "+aibackendpath + "/changesky1/demo.mp4";
    await appendecho(await shellexec3(cmd,taskid)+"\n");
    await appendecho(cmd+"\n");

    cmd = "bash "+aibackendpath + "/changesky1/alexpark_runner.sh "+aibackendpath+" "
    +websitepath+"/"+keystr+"/"+vlu.vls.videolayers[srclayeridx].videoblocks[srcblockidx].filename+" "
    +websitepath+"/"+keystr+"/"+vlu.vls.videolayers[skylayeridx].videoblocks[skyblockidx].filename+" "
    +websitepath+"/"+privatekeystr+"/temp/skyar/";
    await appendecho(await shellexec3(cmd,taskid)+"\n");
    await appendecho(cmd+"\n");
    cmd = "cp -f "+aibackendpath + "/changesky1/demo.mp4 "+websitepath+"/"+privatekeystr+"/"+taskid+".mp4";
    await appendecho(await shellexec3(cmd,taskid)+"\n");
    await appendecho(cmd+"\n");

    if(await File(""+websitepath+"/"+privatekeystr+"/"+taskid+".mp4").exists())
    {
      await taskdone(taskid);
      await appendecho("task: "+taskid+" done\n");
      String addlibrst = await addtoprivatelib(privatekeystr,taskid,await gettaskdesc(taskid));
      await appendecho("task: "+taskid+" add to privatelib "+addlibrst+"\n");
    }
    else
    {
      await taskfailed(taskid);
      await appendecho("task: "+taskid+" failed\n");
    }

    resultfile = taskid+".mp4";
    return resultfile;
  }
  
  Future<String> calwav2lip(String taskid)
  async
  {
    String resultfile = "-";
    String cmd = "";
    String args = "-";
    String fmb = "/usr/local/bin/ffmpeg";

    if(vlu.vls.videolayers.isEmpty)
    {
      await taskfailed(taskid);
      await appendecho("task: "+taskid+" failed (video layer struct empty)\n");
      return resultfile;
    }

    vlu.sortBlocksD();
    vlu.sortLayersZ();

    args = await gettaskargs(taskid);
    List<String> argblocks = args.split("*");
    List<String> blockitm = argblocks[0].split("^");
    int vspklayeridx = int.parse(blockitm[0]);
    int vspkblockidx = int.parse(blockitm[1]);
    blockitm = argblocks[1].split("^");
    int voicelayeridx = int.parse(blockitm[0]);
    int voiceblockidx = int.parse(blockitm[1]);

    if(vlu.vls.videolayers[vspklayeridx].videoblocks[vspkblockidx].fileclass!="mp4"
  ||vlu.vls.videolayers[voicelayeridx].videoblocks[voiceblockidx].fileclass!="mp3")
    {
      await taskfailed(taskid);
      await appendecho("task: "+taskid+" failed (blocktype error)\n");
      return resultfile;
    }

    late Duration fbl;
    if(vlu.vls.videolayers[vspklayeridx].videoblocks[vspkblockidx].blocklength>
  vlu.vls.videolayers[voicelayeridx].videoblocks[voiceblockidx].blocklength)
    {
      fbl=vlu.vls.videolayers[voicelayeridx].videoblocks[voiceblockidx].blocklength;
    }
    else
    {
      fbl=vlu.vls.videolayers[vspklayeridx].videoblocks[vspkblockidx].blocklength;
    }

    await preparefilespecified0(taskid,vspklayeridx,vspkblockidx);
    await preparefilespecified0(taskid,voicelayeridx,voiceblockidx);

    //$1 aibackendpath $2 video $3 png $4 outputdir
    String privatekeystr = await gettaskkey(taskid);
    //String publickeystr = pubkey;
    String keystr = privatekeystr;

    cmd = "rm -rf "+websitepath+"/"+privatekeystr+"/temp/wav2lip";
    await appendecho(await shellexec3(cmd,taskid)+"\n");
    await appendecho(cmd+"\n");
    cmd = "mkdir "+websitepath+"/"+privatekeystr+"/temp/wav2lip";
    await appendecho(await shellexec3(cmd,taskid)+"\n");
    await appendecho(cmd+"\n"); 
    cmd = "mkdir "+websitepath+"/"+privatekeystr+"/temp/wav2lip/result";
    await appendecho(await shellexec3(cmd,taskid)+"\n");
    await appendecho(cmd+"\n");  
    cmd = "mkdir "+websitepath+"/"+privatekeystr+"/temp/wav2lip/video";
    await appendecho(await shellexec3(cmd,taskid)+"\n");
    await appendecho(cmd+"\n");   
    cmd = "mkdir "+websitepath+"/"+privatekeystr+"/temp/wav2lip/voice";
    await appendecho(await shellexec3(cmd,taskid)+"\n");
    await appendecho(cmd+"\n"); 

    int totallength = fbl.inMilliseconds;
    int segcount=(totallength/15000).ceil();

    for(int i=0;i<segcount;i++)
    {
cmd = "/usr/local/bin/ffmpeg -ss "+globals.packData.timestrFromMillisec(i*15000)+" -t 15 -i "+websitepath+"/"+keystr+"/"+vlu.vls.videolayers[vspklayeridx].videoblocks[vspkblockidx].filename
+" -c:v "+videoencoder+" -y "+websitepath+"/"+privatekeystr+"/temp/wav2lip/video/"+i.toString()+".mkv";
await shellexec(cmd);
await appendecho(cmd+"\n");

cmd = "/usr/local/bin/ffmpeg -ss "+globals.packData.timestrFromMillisec(i*15000)+" -t 15 -i "+websitepath+"/"+keystr+"/"+vlu.vls.videolayers[voicelayeridx].videoblocks[voiceblockidx].filename
+" -c:a "+audioencoder+" -y "+websitepath+"/"+privatekeystr+"/temp/wav2lip/voice/"+i.toString()+".aac";
await shellexec(cmd);
await appendecho(cmd+"\n");
    }

    for(int i=0;i<segcount;i++)
    {
      cmd = "bash "+aibackendpath + "/speakersim1/alexpark_runner.sh "+aibackendpath+" "
      +websitepath+"/"+privatekeystr+"/temp/wav2lip/video/"+i.toString()+".mkv "
      +websitepath+"/"+privatekeystr+"/temp/wav2lip/voice/"+i.toString()+".aac "
      +websitepath+"/"+privatekeystr+"/temp/wav2lip/";
      await appendecho(await shellexec3(cmd,taskid)+"\n");
      await appendecho(cmd+"\n");
      cmd = "cp -f "+aibackendpath + "/speakersim1/results/result_voice.mp4 "+websitepath+"/"+privatekeystr+"/temp/wav2lip/result/"+i.toString()+".mp4";
      await appendecho(await shellexec3(cmd,taskid)+"\n");
      await appendecho(cmd+"\n");
    }

    final File file = File(""+websitepath+"/"+privatekeystr+"/temp/"+taskid+"-concatlist.txt");
    String texttowrite = "";
    for(int i=0;i<segcount;i++)
    {
        texttowrite += "file '"+websitepath+"/"+privatekeystr+"/temp/wav2lip/result/"+i.toString()+".mp4"+"'\r\n";   
    }
    await file.writeAsString(texttowrite);
    String finalconcatcmd = fmb+" -f concat -safe 0 -i "+""+websitepath+"/"+privatekeystr+"/temp/"+taskid+"-concatlist.txt"+" -c copy -y "+websitepath+"/"+privatekeystr+"/temp/"+taskid+".mkv";
    await shellexec(finalconcatcmd);
    await appendecho(finalconcatcmd+"\n");    
    finalconcatcmd = fmb+" -i "+websitepath+"/"+privatekeystr+"/temp/"+taskid+".mkv -c:v libx264 -c:a aac -map 0:v -map 0:a -y "+websitepath+"/"+privatekeystr+"/"+taskid+".mp4";
    await shellexec(finalconcatcmd);
    await appendecho(finalconcatcmd+"\n");  

    if(await File(""+websitepath+"/"+privatekeystr+"/"+taskid+".mp4").exists())
    {
      await taskdone(taskid);
      await appendecho("task: "+taskid+" done\n");
      String addlibrst = await addtoprivatelib(privatekeystr,taskid,await gettaskdesc(taskid));
      await appendecho("task: "+taskid+" add to privatelib "+addlibrst+"\n");
    }
    else
    {
      await taskfailed(taskid);
      await appendecho("task: "+taskid+" failed\n");
    }

    resultfile = taskid+".mp4";
    return resultfile;
  }

  Future<String> calcurrentvls(String taskid)
  async
  {
    String resultfile = "-";
    String cmd = "";

    if(vlu.vls.videolayers.isEmpty)
    {
      await taskfailed(taskid);
      await appendecho("task: "+taskid+" failed (video layer struct empty)\n");
      return resultfile;
    }

    vlu.sortBlocksD();
    vlu.sortLayersZ();
    await preparefiles(taskid);

    VideoLayerStruct vns = VideoLayerStruct(0);
    vns.scalefactor = vlu.vls.scalefactor; 
    for(int i=0;i<vlu.vls.videolayers.length;i++)
    {
      vns.videolayers.add(vlu.vls.videolayers[i]);
    }   

    for(int i=vlu.vls.videolayers.length-1;i>0;i--)
    {
      VideoLayerItem vnl = await blendtwolayers(i,i-1,taskid);
      vlu.vls.videolayers[i-1]=vnl;
    }

    String fmb = "/usr/local/bin/ffmpeg";
    //String imb = "/usr/local/bin/convert";
    String tw = await gettaskwidth(taskid);
    String th = await gettaskheight(taskid);
    String privatekeystr = await gettaskkey(taskid);
    String publickeystr = pubkey;
    String keystr = privatekeystr;
    for(int i=0;i<vlu.vls.videolayers[0].videoblocks.length;i++)
    {
      String resfname = vlu.vls.videolayers[0].videoblocks[i].filename;
      String bnm = resfname.substring(0,resfname.lastIndexOf(".")).replaceAll('temp/', '');
      //String ext = resfname.substring(resfname.lastIndexOf("."));
      
      if(vlu.vls.videolayers[0].videoblocks[i].fileclass=="mp3")
      {
        if(vlu.vls.videolayers[0].videoblocks[i].ispubliclib)
        {
          keystr = publickeystr;
        }
        else
        {
          keystr = privatekeystr;
        }
        cmd = fmb+" -f lavfi -i color=size="+tw+"x"+th
        +":rate=25:color=black -i "+websitepath+"/"+keystr+"/"+resfname+" -c:a copy -c:v "+videoencoder+" -shortest -y "+websitepath+"/"+privatekeystr+"/temp/"+bnm+".mkv";
        await shellexec(cmd);
        await appendecho(cmd+"\n");
        vlu.vls.videolayers[0].videoblocks[i].filename = "temp/"+bnm+".mkv";
        vlu.vls.videolayers[0].videoblocks[i].fileclass="mp4";
        vlu.vls.videolayers[0].videoblocks[i].ispubliclib = false;
      }
      if(vlu.vls.videolayers[0].videoblocks[i].fileclass=="png")
      {
        cmd = fmb+" -loop 1 -i "+resfname+" -ss 00:00:00.000 -t "
        +globals.packData.timestrFromMillisec(vlu.vls.videolayers[0].videoblocks[i].blocklength.inMilliseconds)
        +" -i "+websitepath+"/"+publickeystr+"/placeholder.mp3 -c:a copy -c:v "+videoencoder+" -shortest -y "+websitepath+"/"+privatekeystr+"/temp/"+bnm+".mkv";
        await shellexec(cmd);
        await appendecho(cmd+"\n");
        vlu.vls.videolayers[0].videoblocks[i].filename = "temp/"+bnm+".mkv";
        vlu.vls.videolayers[0].videoblocks[i].fileclass="mp4";
        vlu.vls.videolayers[0].videoblocks[i].ispubliclib = false;
      }
      if(vlu.vls.videolayers[0].videoblocks[i].fileclass=="placeholder")
      {
        cmd = fmb+" -f lavfi -i color=size="+tw+"x"+th
        +":rate=25:color=black -f lavfi -i anullsrc=channel_layout=stereo:sample_rate=44100 -t "
        +globals.packData.timestrFromMillisec(vlu.vls.videolayers[0].videoblocks[i].blocklength.inMilliseconds)+" -c:v "+videoencoder+" -y "+websitepath+"/"+privatekeystr+"/temp/"+bnm+".mkv";
        await shellexec(cmd);
        await appendecho(cmd+"\n");
        vlu.vls.videolayers[0].videoblocks[i].filename = "temp/"+bnm+".mkv";
        vlu.vls.videolayers[0].videoblocks[i].fileclass="mp4";
        vlu.vls.videolayers[0].videoblocks[i].ispubliclib = false;
      }
      if(await File(""+websitepath+"/"+privatekeystr+"/temp/"+bnm+".mkv").exists())
      {

      }
      else
      {
        await appendecho("file lost: "+bnm+".mkv"+"\n");
      }
    }

/*
//for old version ffmpeg. abandoned.
    String concatfs = "";
    String filters = "";
    for(int i=0;i<vlu.vls.videolayers[0].videoblocks.length;i++)
    {
        if(vlu.vls.videolayers[0].videoblocks[i].ispubliclib)
        {
          keystr = publickeystr;
        }
        else
        {
          keystr = privatekeystr;
        }
      concatfs += ("-i "+websitepath+"/"+keystr+"/"+vlu.vls.videolayers[0].videoblocks[i].filename+" ");
      filters += ("["+i.toString()+":v] ["+i.toString()+":a] ");
    }
    concatfs = concatfs.substring(0,concatfs.length-1);
    String finalconcatcmd = fmb+" "+concatfs+" -filter_complex \""+filters+"concat=n="+vlu.vls.videolayers[0].videoblocks.length.toString()+":v=1:a=1 [v] [a]\" -map \"[v]\" -map \"[a]\" -y "+websitepath+"/"+privatekeystr+"/"+taskid+".mp4";
    //await shellexec(finalconcatcmd); //failed because space split problem

    List<String> args=List.filled(0, "",growable: true);
    for(int i=0;i<vlu.vls.videolayers[0].videoblocks.length;i++)
    {
        if(vlu.vls.videolayers[0].videoblocks[i].ispubliclib)
        {
          keystr = publickeystr;
        }
        else
        {
          keystr = privatekeystr;
        }
      //concatfs += ("-i "+websitepath+"/"+keystr+"/"+vlu.vls.videolayers[0].videoblocks[i].filename+" ");
      //filters += ("["+i.toString()+":v] ["+i.toString()+":a] ");
      args.add("-i");
      args.add(""+websitepath+"/"+keystr+"/"+vlu.vls.videolayers[0].videoblocks[i].filename);
    }
    args.add("-filter_complex");
    args.add(filters+"concat=n="+vlu.vls.videolayers[0].videoblocks.length.toString()+":v=1:a=1 [v] [a]");
    args.add("-map");
    args.add("[v]");
    args.add("-map");
    args.add("[a]");
    args.add("-y");
    args.add(""+websitepath+"/"+privatekeystr+"/"+taskid+".mp4");
    await shellexecraw(fmb,args);

*/
/*
this way is too slow. abandoned.
    String concatfs = "";
    String filters = "";
    for(int i=0;i<vlu.vls.videolayers[0].videoblocks.length;i++)
    {
        if(vlu.vls.videolayers[0].videoblocks[i].ispubliclib)
        {
          keystr = publickeystr;
        }
        else
        {
          keystr = privatekeystr;
        }
      concatfs += ("-i "+websitepath+"/"+keystr+"/"+vlu.vls.videolayers[0].videoblocks[i].filename+" ");
      filters += ("["+i.toString()+":v:0]["+i.toString()+":a:0]");
    }
    concatfs = concatfs.substring(0,concatfs.length-1);
    String finalconcatcmd = fmb+" "+concatfs+" -filter_complex "+filters+"concat=n="+vlu.vls.videolayers[0].videoblocks.length.toString()+":v=1:a=1[v][a] -map [v] -map [a] -y "+websitepath+"/"+privatekeystr+"/"+taskid+".mp4";
    await shellexec(finalconcatcmd);
    await appendecho(finalconcatcmd+"\n");
*/

    final File file = File(""+websitepath+"/"+privatekeystr+"/temp/"+taskid+"-concatlist.txt");
    String texttowrite = "";
    for(int i=0;i<vlu.vls.videolayers[0].videoblocks.length;i++)
    {
        if(vlu.vls.videolayers[0].videoblocks[i].ispubliclib)
        {
          keystr = publickeystr;
        }
        else
        {
          keystr = privatekeystr;
        }
        texttowrite += "file '"+websitepath+"/"+keystr+"/"+vlu.vls.videolayers[0].videoblocks[i].filename+"'\r\n";   
    }
    await file.writeAsString(texttowrite);
    String finalconcatcmd = fmb+" -f concat -safe 0 -i "+""+websitepath+"/"+privatekeystr+"/temp/"+taskid+"-concatlist.txt"+" -c copy -y "+websitepath+"/"+privatekeystr+"/temp/"+taskid+".mkv";
    await shellexec(finalconcatcmd);
    await appendecho(finalconcatcmd+"\n");    
    finalconcatcmd = fmb+" -i "+websitepath+"/"+privatekeystr+"/temp/"+taskid+".mkv -c:v libx264 -c:a aac -map 0:v -map 0:a -y "+websitepath+"/"+privatekeystr+"/"+taskid+".mp4";
    await shellexec(finalconcatcmd);
    await appendecho(finalconcatcmd+"\n");  

    if(await File(""+websitepath+"/"+privatekeystr+"/"+taskid+".mp4").exists())
    {
      await taskdone(taskid);
      await appendecho("task: "+taskid+" done\n");
      String addlibrst = await addtoprivatelib(privatekeystr,taskid,await gettaskdesc(taskid));
      await appendecho("task: "+taskid+" add to privatelib "+addlibrst+"\n");
    }
    else
    {
      await taskfailed(taskid);
      await appendecho("task: "+taskid+" failed\n");
    }
    resultfile = taskid+".mp4";
    return resultfile;
  }

  Future<VideoLayerItem> blendtwolayers(int bottomlayer,int toplayer,String taskid)
  async
  {
    VideoLayerItem vnl = VideoLayerItem(vlu.getNewLayerid());
    vnl.zindex = vlu.vls.videolayers[toplayer].zindex;
    List<Duration> cutpoint = List.filled(0, Duration(),growable: true);
    for(int i=0;i<vlu.vls.videolayers[bottomlayer].videoblocks.length;i++)
    {
      cutpoint.add(Duration(milliseconds: vlu.vls.videolayers[bottomlayer].videoblocks[i].tostamp.inMilliseconds));
    }
    for(int i=0;i<vlu.vls.videolayers[toplayer].videoblocks.length;i++)
    {
      int found=0;
      for(int j=0;j<cutpoint.length;j++)
      {
        if(cutpoint[j].inMilliseconds==vlu.vls.videolayers[toplayer].videoblocks[i].tostamp.inMilliseconds)
        {
          found=1;
        }
      }
      if(found==1)
      {

      }
      else
      {
        cutpoint.add(Duration(milliseconds: vlu.vls.videolayers[toplayer].videoblocks[i].tostamp.inMilliseconds));
      }
    }
    cutpoint.sort((a, b) => a.inMilliseconds.compareTo(b.inMilliseconds));
    Duration lastcutpoint = Duration(milliseconds: 0);
    for(int i=0;i<cutpoint.length;i++)
    {
      VideoLayerBlock vnb = await blendtwoblocks(lastcutpoint,cutpoint[i],bottomlayer,toplayer,taskid);
      vnl.videoblocks.add(vnb);
      vnl.layerlength+=vnb.blocklength;
      lastcutpoint = Duration(milliseconds: cutpoint[i].inMilliseconds);
    }
    return vnl;
  }

  Future<VideoLayerBlock> blendtwoblocks(Duration fromcut,Duration tocut,int bottomlayer,int toplayer,String taskid)
  async
  {
    String tw = await gettaskwidth(taskid);
    String th = await gettaskheight(taskid);
    String privatekeystr = await gettaskkey(taskid);
    String publickeystr = pubkey;
    String tmpdir = ""+websitepath+"/"+privatekeystr+"/temp/";
    String bkeystr = privatekeystr;
    String tkeystr = privatekeystr;
    String botc = "";
    String topc = ""; //block file class
    VideoLayerBlock bottomblk = VideoLayerBlock(vlu.getNewBlockid());
    VideoLayerBlock topblk = VideoLayerBlock(vlu.getNewBlockid());
    //Color botcr=Color(0);
    Color topcr=Color(0x00000000); //nearest video block chroma color
    int fc = fromcut.inMilliseconds;
    int tc = tocut.inMilliseconds;
    //String fcs = globals.packData.timestrFromMillisec(fc);
    //String tcs = globals.packData.timestrFromMillisec(tc);
    String ts = globals.packData.timestrFromMillisec(tc-fc); //cut length
    String bss = "00:00:00.000";
    String tss = "00:00:00.000"; //file start position
    String bf = "";
    String tf = ""; //file name
    for(int i=0;i<vlu.vls.videolayers[bottomlayer].videoblocks.length;i++)
    {
      //if(vlu.vls.videolayers[bottomlayer].videoblocks[i].fileclass=="mp4")
      //{
      //  botcr=vlu.vls.videolayers[bottomlayer].videoblocks[i].blockcolor;
      //}
      if( fromcut.inMilliseconds >= vlu.vls.videolayers[bottomlayer].videoblocks[i].fromstamp.inMilliseconds
        && fromcut.inMilliseconds < vlu.vls.videolayers[bottomlayer].videoblocks[i].tostamp.inMilliseconds)
      {
        bottomblk.blend = vlu.vls.videolayers[bottomlayer].videoblocks[i].blend;
        bottomblk.blockcolor = vlu.vls.videolayers[bottomlayer].videoblocks[i].blockcolor;
        bottomblk.blocklength = Duration(milliseconds: tocut.inMilliseconds-fromcut.inMilliseconds);
        bottomblk.fileclass = vlu.vls.videolayers[bottomlayer].videoblocks[i].fileclass;
        bottomblk.filename = vlu.vls.videolayers[bottomlayer].videoblocks[i].filename;
        bottomblk.filestartpos = Duration(milliseconds: 
        vlu.vls.videolayers[bottomlayer].videoblocks[i].filestartpos.inMilliseconds+
        (fromcut.inMilliseconds-vlu.vls.videolayers[bottomlayer].videoblocks[i].fromstamp.inMilliseconds));
        bottomblk.fromstamp = Duration(milliseconds: fromcut.inMilliseconds);
        bottomblk.ispubliclib = vlu.vls.videolayers[bottomlayer].videoblocks[i].ispubliclib;
        bottomblk.resizeenable = vlu.vls.videolayers[bottomlayer].videoblocks[i].resizeenable;
        bottomblk.resizeheight = vlu.vls.videolayers[bottomlayer].videoblocks[i].resizeheight;
        bottomblk.resizeleft = vlu.vls.videolayers[bottomlayer].videoblocks[i].resizeleft;
        bottomblk.resizetop = vlu.vls.videolayers[bottomlayer].videoblocks[i].resizetop;
        bottomblk.resizewidth =vlu.vls.videolayers[bottomlayer].videoblocks[i].resizewidth;
        bottomblk.respeed = vlu.vls.videolayers[bottomlayer].videoblocks[i].respeed;
        bottomblk.respeedenable = vlu.vls.videolayers[bottomlayer].videoblocks[i].respeedenable;
        bottomblk.revolume = vlu.vls.videolayers[bottomlayer].videoblocks[i].revolume;
        bottomblk.revolumeenable = vlu.vls.videolayers[bottomlayer].videoblocks[i].revolumeenable;
        bottomblk.similarity = vlu.vls.videolayers[bottomlayer].videoblocks[i].similarity;
        bottomblk.tostamp = Duration(milliseconds: tocut.inMilliseconds);
        botc = bottomblk.fileclass;
        bss = globals.packData.timestrFromMillisec(bottomblk.filestartpos.inMilliseconds);
        if(bottomblk.ispubliclib)
        {
          bkeystr = publickeystr;
        }
        else
        {
          bkeystr = privatekeystr;
        }
        bf = ""+websitepath+"/"+bkeystr+"/"+bottomblk.filename;
        break;
      }
    }
    
    for(int i=0;i<vlu.vls.videolayers[toplayer].videoblocks.length;i++)
    {
      if(vlu.vls.videolayers[toplayer].videoblocks[i].fileclass=="mp4")
      {
        topcr=vlu.vls.videolayers[toplayer].videoblocks[i].blockcolor;
      }
      if( fromcut.inMilliseconds >= vlu.vls.videolayers[toplayer].videoblocks[i].fromstamp.inMilliseconds
        && fromcut.inMilliseconds < vlu.vls.videolayers[toplayer].videoblocks[i].tostamp.inMilliseconds)
      {
        topblk.blend = vlu.vls.videolayers[toplayer].videoblocks[i].blend;
        topblk.blockcolor = vlu.vls.videolayers[toplayer].videoblocks[i].blockcolor;
        topblk.blocklength = Duration(milliseconds: tocut.inMilliseconds-fromcut.inMilliseconds);
        topblk.fileclass = vlu.vls.videolayers[toplayer].videoblocks[i].fileclass;
        topblk.filename = vlu.vls.videolayers[toplayer].videoblocks[i].filename;
        topblk.filestartpos = Duration(milliseconds: 
        vlu.vls.videolayers[toplayer].videoblocks[i].filestartpos.inMilliseconds+
        (fromcut.inMilliseconds-vlu.vls.videolayers[toplayer].videoblocks[i].fromstamp.inMilliseconds));
        topblk.fromstamp = Duration(milliseconds: fromcut.inMilliseconds);
        topblk.ispubliclib = vlu.vls.videolayers[toplayer].videoblocks[i].ispubliclib;
        topblk.resizeenable = vlu.vls.videolayers[toplayer].videoblocks[i].resizeenable;
        topblk.resizeheight = vlu.vls.videolayers[toplayer].videoblocks[i].resizeheight;
        topblk.resizeleft = vlu.vls.videolayers[toplayer].videoblocks[i].resizeleft;
        topblk.resizetop = vlu.vls.videolayers[toplayer].videoblocks[i].resizetop;
        topblk.resizewidth =vlu.vls.videolayers[toplayer].videoblocks[i].resizewidth;
        topblk.respeed = vlu.vls.videolayers[toplayer].videoblocks[i].respeed;
        topblk.respeedenable = vlu.vls.videolayers[toplayer].videoblocks[i].respeedenable;
        topblk.revolume = vlu.vls.videolayers[toplayer].videoblocks[i].revolume;
        topblk.revolumeenable = vlu.vls.videolayers[toplayer].videoblocks[i].revolumeenable;
        topblk.similarity = vlu.vls.videolayers[toplayer].videoblocks[i].similarity;
        topblk.tostamp = Duration(milliseconds: tocut.inMilliseconds);
        topc = topblk.fileclass;
        tss = globals.packData.timestrFromMillisec(topblk.filestartpos.inMilliseconds);
        if(topblk.ispubliclib)
        {
          tkeystr = publickeystr;
        }
        else
        {
          tkeystr = privatekeystr;
        }
        tf = ""+websitepath+"/"+tkeystr+"/"+topblk.filename;
        break;
      }
    }

    String cc = topc+"|"+botc;
    String cmdstr = "whoami";
    String outfilebase = tmpdir+taskid+"-"+toplayer.toString()+"-"+bottomlayer.toString()+"-"+fc.toString()+"-"+tc.toString();
    String fmb = "/usr/local/bin/ffmpeg";
    String imb = "/usr/local/bin/convert";
    String colorstr = "0x"+topblk.blockcolor.red.toRadixString(16).toUpperCase()+topblk.blockcolor.green.toRadixString(16).toUpperCase()+topblk.blockcolor.blue.toRadixString(16).toUpperCase();
    String sml = topblk.similarity.toString();
    if(sml.length>4)sml=sml.substring(0,4);
    String bld = topblk.blend.toString();
    if(bld.length>4)bld=bld.substring(0,4);
    switch (cc) 
    {
      case "placeholder|mp4":
        cmdstr = fmb+" -ss "+bss+" -t "+ts+" -i "+bf+" -c copy -y "+outfilebase+".mkv";
        topblk.filename="temp/"+taskid+"-"+toplayer.toString()+"-"+bottomlayer.toString()+"-"+fc.toString()+"-"+tc.toString()+".mkv";
        topblk.fileclass = "mp4";
        topblk.ispubliclib = false;
        topblk.filestartpos = Duration(milliseconds: 0);
        break;
      case "placeholder|mp3":
        cmdstr = fmb+" -ss "+bss+" -t "+ts+" -i "+bf+" -y "+outfilebase+".aac";
        topblk.filename="temp/"+taskid+"-"+toplayer.toString()+"-"+bottomlayer.toString()+"-"+fc.toString()+"-"+tc.toString()+".aac";
        topblk.fileclass = "mp3";
        topblk.ispubliclib = false;
        topblk.filestartpos = Duration(milliseconds: 0);
        break;
      case "placeholder|png":
        topblk.filename = bottomblk.filename;
        topblk.fileclass = "png";
        topblk.ispubliclib = bottomblk.ispubliclib;
        break;
      case "placeholder|placeholder":
        break;
      case "png|mp4":
        if(topblk.resizeenable)
        {
          cmdstr = fmb+" -ss "+bss+" -t "+ts+" -i "+bf+" -i "+tf+" -filter_complex [0:v][1:v]overlay=x="+topblk.resizeleft.toString()+":y="+topblk.resizetop.toString()+" -c:v "+videoencoder+" -y "+outfilebase+".mkv";
          topblk.resizeenable = false;
        }
        else
        {
          cmdstr = fmb+" -ss "+bss+" -t "+ts+" -i "+bf+" -i "+tf+" -filter_complex [0:v][1:v]overlay -c:v "+videoencoder+" -y "+outfilebase+".mkv";
        }
        topblk.filename="temp/"+taskid+"-"+toplayer.toString()+"-"+bottomlayer.toString()+"-"+fc.toString()+"-"+tc.toString()+".mkv";
        topblk.fileclass = "mp4";
        topblk.ispubliclib = false;
        topblk.filestartpos = Duration(milliseconds: 0);
        break;
      case "png|mp3":
        cmdstr = fmb+" -loop 1 -i "+tf+" -ss "+bss+" -t "+ts+" -i "+bf+" -c:a copy -c:v "+videoencoder+" -shortest -y "+outfilebase+".mkv";
        topblk.filename="temp/"+taskid+"-"+toplayer.toString()+"-"+bottomlayer.toString()+"-"+fc.toString()+"-"+tc.toString()+".mkv";
        topblk.fileclass = "mp4";
        topblk.ispubliclib = false;
        topblk.filestartpos = Duration(milliseconds: 0);
        break;
      case "png|png":
        if(topblk.resizeenable)
        {
          cmdstr = imb+" "+bf+" "+tf+" -geometry +"+topblk.resizeleft.toString()+"+"+topblk.resizetop.toString()+" -compose luminize -composite "+outfilebase+".png";
          topblk.resizeenable = false;
        }
        else
        {
          cmdstr = imb+" "+bf+" "+tf+" -compose luminize -composite "+outfilebase+".png";
        }
        topblk.filename="temp/"+taskid+"-"+toplayer.toString()+"-"+bottomlayer.toString()+"-"+fc.toString()+"-"+tc.toString()+".png";
        topblk.fileclass = "png";
        topblk.ispubliclib = false;
        break;
      case "png|placeholder":
        break;
      case "mp3|mp4":
        cmdstr = fmb+" -ss "+bss+" -t "+ts+" -i "+bf+" -ss "+tss+" -t "+ts+" -i "+tf+" -filter_complex [0:a][1:a]amix=duration=shortest[a];[0:v]scale="+tw+":"+th+",setsar=1[outv] -map [outv] -map [a] -c:v "+videoencoder+" -y "+outfilebase+".mkv";
        topblk.filename="temp/"+taskid+"-"+toplayer.toString()+"-"+bottomlayer.toString()+"-"+fc.toString()+"-"+tc.toString()+".mkv";
        topblk.fileclass = "mp4";
        topblk.ispubliclib = false;
        topblk.filestartpos = Duration(milliseconds: 0);
        break;
      case "mp3|mp3":
        cmdstr = fmb+" -ss "+bss+" -t "+ts+" -i "+bf+" -ss "+tss+" -t "+ts+" -i "+tf+" -filter_complex [0:a][1:a]amix=duration=shortest[a] -map [a] -vn -y "+outfilebase+".aac";
        topblk.filename="temp/"+taskid+"-"+toplayer.toString()+"-"+bottomlayer.toString()+"-"+fc.toString()+"-"+tc.toString()+".aac";
        topblk.fileclass = "mp3";
        topblk.ispubliclib = false;
        topblk.filestartpos = Duration(milliseconds: 0);
        break;
      case "mp3|png":
        cmdstr = fmb+" -loop 1 -i "+bf+" -ss "+tss+" -t "+ts+" -i "+tf+" -c:a copy -c:v "+videoencoder+" -shortest -y "+outfilebase+".mkv";
        topblk.filename="temp/"+taskid+"-"+toplayer.toString()+"-"+bottomlayer.toString()+"-"+fc.toString()+"-"+tc.toString()+".mkv";
        topblk.fileclass = "mp4";
        topblk.ispubliclib = false;
        topblk.filestartpos = Duration(milliseconds: 0);
        break;
      case "mp3|placeholder":
        cmdstr = fmb+" -ss "+tss+" -t "+ts+" -i "+tf+" -vn -y "+outfilebase+".aac";
        topblk.filename="temp/"+taskid+"-"+toplayer.toString()+"-"+bottomlayer.toString()+"-"+fc.toString()+"-"+tc.toString()+".aac";
        topblk.fileclass = "mp3";
        topblk.ispubliclib = false;
        topblk.filestartpos = Duration(milliseconds: 0);
        break;
      case "mp4|mp4":
        if(topblk.resizeenable)
        {
          cmdstr = fmb +" -ss "+bss+" -t "+ts+" -i "+bf+" -ss "+tss+" -t "+ts+" -i "+tf+" -filter_complex [1:v]colorkey="+colorstr+":"+sml+":"+bld+"[ckout];[0:v][ckout]overlay=x="+topblk.resizeleft.toString()+":y="+topblk.resizetop.toString()+"[out];[0:a][1:a]amix=duration=shortest[a] -map [out] -map [a] -c:v "+videoencoder+" -shortest -y "+outfilebase+".mkv";
          topblk.resizeenable = false;
        }
        else
        {
          cmdstr = fmb +" -ss "+bss+" -t "+ts+" -i "+bf+" -ss "+tss+" -t "+ts+" -i "+tf+" -filter_complex [1:v]colorkey="+colorstr+":"+sml+":"+bld+"[ckout];[0:v][ckout]overlay[out];[0:a][1:a]amix=duration=shortest[a] -map [out] -map [a] -c:v "+videoencoder+" -shortest -y "+outfilebase+".mkv";
        }
        topblk.filename="temp/"+taskid+"-"+toplayer.toString()+"-"+bottomlayer.toString()+"-"+fc.toString()+"-"+tc.toString()+".mkv";
        topblk.fileclass = "mp4";
        topblk.ispubliclib = false;
        topblk.filestartpos = Duration(milliseconds: 0);
        break;
      case "mp4|mp3":
        cmdstr = fmb+" -ss "+tss+" -t "+ts+" -i "+tf+" -ss "+bss+" -t "+ts+" -i "+bf+" -filter_complex [0:a][1:a]amix=duration=shortest[a] -map 0:v -map [a] -c:v copy -y "+outfilebase+".mkv";
        topblk.filename="temp/"+taskid+"-"+toplayer.toString()+"-"+bottomlayer.toString()+"-"+fc.toString()+"-"+tc.toString()+".mkv";
        topblk.fileclass = "mp4";
        topblk.ispubliclib = false;
        topblk.filestartpos = Duration(milliseconds: 0);
        break;
      case "mp4|png":
        if(topblk.resizeenable)
        {
          cmdstr = fmb +" -loop 1 -i "+bf+" -ss "+tss+" -t "+ts+" -i "+tf+" -filter_complex [1:v]colorkey="+colorstr+":"+sml+":"+bld+"[ckout];[0:v][ckout]overlay=x="+topblk.resizeleft.toString()+":y="+topblk.resizetop.toString()+"[out];[1:a]volume=1.0[a] -map [out] -map [a] -c:v "+videoencoder+" -y "+outfilebase+".mkv";
          topblk.resizeenable = false;
        }
        else
        {
          cmdstr = fmb +" -loop 1 -i "+bf+" -ss "+tss+" -t "+ts+" -i "+tf+" -filter_complex [1:v]colorkey="+colorstr+":"+sml+":"+bld+"[ckout];[0:v][ckout]overlay[out];[1:a]volume=1.0[a] -map [out] -map [a] -c:v "+videoencoder+" -y "+outfilebase+".mkv";
        }
        topblk.filename="temp/"+taskid+"-"+toplayer.toString()+"-"+bottomlayer.toString()+"-"+fc.toString()+"-"+tc.toString()+".mkv";
        topblk.fileclass = "mp4";
        topblk.ispubliclib = false;
        topblk.filestartpos = Duration(milliseconds: 0);
        break;
      case "mp4|placeholder":
        if(topblk.resizeenable)
        {
          cmdstr = fmb +" -f lavfi -i color=size="+tw+"x"+th+":color="+colorstr+" -ss "+tss+" -t "+ts+" -i "+tf+" -filter_complex [1:v]colorkey="+colorstr+":"+sml+":"+bld+"[ckout];[0:v][ckout]overlay=x="+topblk.resizeleft.toString()+":y="+topblk.resizetop.toString()+"[out];[1:a]volume=1.0[a] -map [out] -map [a] -c:v "+videoencoder+" -y "+outfilebase+".mkv";
          topblk.resizeenable = false;
        }
        else
        {
          cmdstr = fmb+" -ss "+tss+" -t "+ts+" -i "+tf+" -vf scale="+tw+":"+th+",setsar=1 -c:v "+videoencoder+" -y "+outfilebase+".mkv";
        }
        topblk.filename="temp/"+taskid+"-"+toplayer.toString()+"-"+bottomlayer.toString()+"-"+fc.toString()+"-"+tc.toString()+".mkv";
        topblk.fileclass = "mp4";
        topblk.ispubliclib = false;
        topblk.filestartpos = Duration(milliseconds: 0);
        break;
      default:
    }
    await shellexec(cmdstr);
    await appendecho(cmdstr+"\n");
    if(topblk.fileclass!="mp4")topblk.blockcolor = topcr;
    return topblk;
  }



/*
  Future<String> concatresultblocks(List<Duration> cps,int bottomlayer,int toplayer,String taskid)
  async
  {
    String rst="";

    return rst;
  }

  Future<void> rebuildtoplayer(int toplayer,String resultfilename,String taskid)
  async
  {

  }


  ByteData bd=ByteData(255);

  String getStringFromBytes(ByteData data) 
  {
    final buffer = data.buffer;
    var list = buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    return utf8.decode(list);
  }

  ByteData setStringToBytes(String str)
  {
    Uint8List lis =Uint8List.fromList(utf8.encode(str));
    return ByteData.view(lis.buffer);
  }

  void testBd()
  {
    ByteData b = setStringToBytes("hello!你好！");
    var listbd = bd.buffer.asUint8List(bd.offsetInBytes, bd.lengthInBytes);
    var listb = b.buffer.asUint8List(b.offsetInBytes, b.lengthInBytes);
    for(int i=0;i<listb.length;i++)
    {
      listbd[i] = listb[i];
    }
    String str = getStringFromBytes(bd);
    print(str);
  }

  void storetobd(String s)
  {
    ByteData b = setStringToBytes(s);
    var listbd = bd.buffer.asUint8List(bd.offsetInBytes, bd.lengthInBytes);
    for(int i=0;i<listbd.length;i++)
    {
      listbd[i] = 0;
    }  
    var listb = b.buffer.asUint8List(b.offsetInBytes, b.lengthInBytes);
    for(int i=0;i<listb.length;i++)
    {
      listbd[i] = listb[i];
    }
  }

  String loadfrombd()
  {
    return getStringFromBytes(bd);
  }
*/

}
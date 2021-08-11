import 'dart:async';
import 'dart:convert';
import 'package:dart_des/dart_des.dart';
import 'package:mysql1/mysql1.dart';


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

////////////////////////////////////////////////////////////////////////////////
/// tools functions
////////////////////////////////////////////////////////////////////////////////

String encodeDES3CBC(String message)
{
    String result='';
    List<int> encrypted;
    //List<int> decrypted;
    List<int> iv = [7, 8, 1, 4, 5, 2, 3, 6];
    String key = datetimetokey(); // 24-byte
    DES3 des3CBC = DES3(key: key.codeUnits, mode: DESMode.CBC, iv: iv);
    encrypted = des3CBC.encrypt(message.codeUnits);
    //decrypted = des3CBC.decrypt(encrypted);
    /*
    print('Triple DES mode: CBC');
    print('encrypted: $encrypted');
    print('encrypted (hex): ${hex.encode(encrypted)}');
    print('encrypted (base64): ${base64.encode(encrypted)}');
    print('decrypted: $decrypted');
    print('decrypted (hex): ${hex.encode(decrypted)}');
    print('decrypted (utf8): ${utf8.decode(decrypted)}');
    */
    for(int i=0;i<encrypted.length;i++)
    {
      result += (encrypted[i].toString() + "-");
    }
    return result;
}

String decodeDES3CBC(String message)
{
    String result='';
    List<int> encrypted = List.filled(0, 0, growable: true);
    List<int> decrypted;
    List<int> iv = [7, 8, 1, 4, 5, 2, 3, 6];
    String key = datetimetokey();
    DES3 des3CBC = DES3(key: key.codeUnits, mode: DESMode.CBC, iv: iv);

    List<String> mls = message.split("-");
    for(int i=0;i<mls.length;i++)
    {
      if(mls[i].isNotEmpty)
      {
        encrypted.add(int.parse(mls[i]));
      }
      
    }

    //encrypted = des3CBC.encrypt(message.codeUnits);
    decrypted = des3CBC.decrypt(encrypted);
    /*
    print('Triple DES mode: CBC');
    print('encrypted: $encrypted');
    print('encrypted (hex): ${hex.encode(encrypted)}');
    print('encrypted (base64): ${base64.encode(encrypted)}');
    print('decrypted: $decrypted');
    print('decrypted (hex): ${hex.encode(decrypted)}');
    print('decrypted (utf8): ${utf8.decode(decrypted)}');
    */
    result = utf8.decode(decrypted,allowMalformed: true);
    return result;
}

String decodeDES3CBC1minago(String message)
{
    String result='';
    List<int> encrypted = List.filled(0, 0, growable: true);
    List<int> decrypted;
    List<int> iv = [7, 8, 1, 4, 5, 2, 3, 6];
    String key = formerdatetimetokey();
    DES3 des3CBC = DES3(key: key.codeUnits, mode: DESMode.CBC, iv: iv);

    List<String> mls = message.split("-");
    for(int i=0;i<mls.length;i++)
    {
      if(mls[i].isNotEmpty)
      {
        encrypted.add(int.parse(mls[i]));
      }
      
    }

    //encrypted = des3CBC.encrypt(message.codeUnits);
    decrypted = des3CBC.decrypt(encrypted);
    /*
    print('Triple DES mode: CBC');
    print('encrypted: $encrypted');
    print('encrypted (hex): ${hex.encode(encrypted)}');
    print('encrypted (base64): ${base64.encode(encrypted)}');
    print('decrypted: $decrypted');
    print('decrypted (hex): ${hex.encode(decrypted)}');
    print('decrypted (utf8): ${utf8.decode(decrypted)}');
    */
    result = utf8.decode(decrypted,allowMalformed: true);
    return result;
}

String datetimetokey()
{
  String result='';
  int lkey = 24;
  List<int> key=List.filled(lkey, 32);
  int t = DateTime.now().millisecondsSinceEpoch~/60000;
  //print(t);
  String ts = t.toString();
  List<int> tls = ts.codeUnits;
  int keyidx = lkey-1;
  for(int j=0;j<3;j++)
  {
    for(int i=0;i<tls.length;i++)
    {
      key[keyidx]=tls[i];
      keyidx--;
      if(keyidx<0)keyidx=lkey-1;
    }
  }
  result = utf8.decode(key,allowMalformed: true);
  return result;
}

String formerdatetimetokey()
{
  String result='';
  int lkey = 24;
  List<int> key=List.filled(lkey, 32);
  int t = (DateTime.now().millisecondsSinceEpoch~/60000)-1;
  String ts = t.toString();
  List<int> tls = ts.codeUnits;
  int keyidx = lkey-1;
  for(int j=0;j<3;j++)
  {
    for(int i=0;i<tls.length;i++)
    {
      key[keyidx]=tls[i];
      keyidx--;
      if(keyidx<0)keyidx=lkey-1;
    }
  }
  result = utf8.decode(key,allowMalformed: true);
  return result;
}


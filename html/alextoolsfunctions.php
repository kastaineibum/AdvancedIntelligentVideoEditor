<?php
require_once('vendor/autoload.php');
use phpseclib3\Net\SSH2;

require("alexpathconfig.php");

if (!function_exists('str_contains'))
{
    function str_contains(string $haystack, string $needle): bool
    {
        return '' === $needle || false !== strpos($haystack, $needle);
    }
}

function dbquery($sql)
{
    require("alexdbconfig.php");
    $conn = new mysqli($dbservername, $dbusername, $dbpassword, $dbname);
    if ($conn->connect_error) 
    {
      return "mariadb error:" . $conn->connect_error;
    }
    if ($conn->query($sql) === TRUE) 
    {
      $conn->close();
      return "done";
    } 
    else 
    {
      $conn->close();
      return "mariadb error:".$sql."|".$conn->error;
    }
    
}

function addtask($finalwidthstr,$finalheightstr,$taskclass,$taskdesc,$taskargs,$finallengthmilli,$apikey)
{
  $taskidstr = generatestamp();
  $sql="INSERT INTO task(taskid,taskclass,taskdesc,taskstatus,resultfile,finalwidth,finalheight,taskargs,finallength,apikey) VALUES('".$taskidstr."','".$taskclass."','".$taskdesc."','structuploading','".$taskidstr.".mp4',$finalwidthstr,$finalheightstr,'".$taskargs."',".$finallengthmilli.",'".$apikey."');";
  $dbrst = dbquery($sql);
  if($dbrst=="done")
  {
    return $taskidstr;
  }
  else
  {
    return $dbrst;
  }
}

function dbgetvideofiles($apikey)
{
  $resultstr="";
  require("alexdbconfig.php");
  $conn = new mysqli($dbservername, $dbusername, $dbpassword, $dbname);
  if ($conn->connect_error) 
  {
    return "mariadb error:" . $conn->connect_error;
  }  
  $sql = "SELECT resfilename,restimelength,resfiledesc FROM privatelib WHERE apikey='".$apikey."' ORDER BY itemid DESC";
  $result = $conn->query($sql); 
  if ($result->num_rows > 0) 
  {
    while($row = $result->fetch_assoc()) 
    {
      if(file_exists($apikey.'/'.$row["resfilename"]))
      {
        $resultstr .= ($row["resfilename"]."^".$row["restimelength"]."^".$row["resfiledesc"]."|");
      }
    }
  } 
  else 
  {
    $resultstr="";
  }
  $conn->close();
  return $resultstr;
}

function dbgetvideofilespublic()
{
  $resultstr="";
  require("alexdbconfig.php");
  $conn = new mysqli($dbservername, $dbusername, $dbpassword, $dbname);
  if ($conn->connect_error) 
  {
    return "mariadb error:" . $conn->connect_error;
  }  
  $sql = "SELECT resfilename,restimelength,resfiledesc FROM publiclib ORDER BY itemid DESC";
  $result = $conn->query($sql); 
  if ($result->num_rows > 0) 
  {
    while($row = $result->fetch_assoc()) 
    {
      if(file_exists($publickey.'/'.$row["resfilename"]))
      {
        $resultstr .= ($row["resfilename"]."^".$row["restimelength"]."^".$row["resfiledesc"]."|");
      }
    }
  } 
  else 
  {
    $resultstr="";
  }
  $conn->close();
  return $resultstr;
}

function dbgettasks($apikey)
{
  $resultstr="";
  require("alexdbconfig.php");
  $conn = new mysqli($dbservername, $dbusername, $dbpassword, $dbname);
  if ($conn->connect_error) 
  {
    return "mariadb error:" . $conn->connect_error;
  }  
  $sql = "SELECT taskid,taskclass,taskdesc,taskstatus,resultfile,finallength FROM task WHERE apikey='".$apikey."' ORDER BY tid DESC";
  $result = $conn->query($sql); 
  if ($result->num_rows > 0) 
  {
    while($row = $result->fetch_assoc()) 
    {
        $resultstr .= ($row["taskid"]."^".$row["taskclass"]."^".$row["taskdesc"]."^".$row["taskstatus"]."^".$row["resultfile"]."^".$row["finallength"]."|");
    }
  } 
  else 
  {
    $resultstr="";
  }
  $conn->close();
  return $resultstr;
}

function dbgettaskstruct($taskid)
{
  $resultstr="";
  require("alexdbconfig.php");
  $conn = new mysqli($dbservername, $dbusername, $dbpassword, $dbname);
  if ($conn->connect_error) 
  {
    return "mariadb error:" . $conn->connect_error;
  }  
  $sql = "SELECT * FROM videolayerstruct WHERE taskid='".$taskid."' ORDER BY slbid ASC";
  $result = $conn->query($sql); 
  if ($result->num_rows > 0) 
  {
    while($row = $result->fetch_assoc()) 
    {
        $resultstr .= ($row["blockidx"]."^".$row["blockid"]."^".
        $row["resfilename"]."^".$row["createstamp"]."^".$row["fromstamp"]."^".$row["tostamp"]."^".$row["blocklength"]."^".$row["fileclass"]."^".
        $row["blockcolor"]."^".$row["ispubliclib"]."^".$row["simularity"]."^".$row["blend"]."^".$row["filestartpos"]."^".$row["resizeleft"]."^".
        $row["resizetop"]."^".$row["resizewidth"]."^".$row["resizeheight"]."^".$row["resizeenable"]."^".$row["respeed"]."^".$row["respeedenable"]."^".
        $row["revolume"]."^".$row["revolumeenable"]."^".$row["layercreatestamp"]."^".$row["zindex"]."^".$row["layerlength"]."^".$row["layeridx"]."^".
        $row["layerid"]."^".$row["structcreatestamp"]."^".$row["scalefactor"]."^".$row["taskid"]."|");
    }
  } 
  else 
  {
    $resultstr="";
  }
  $conn->close();
  return $resultstr;
}

function dbgetstructlayercnt($taskid)
{
  $resultstr="";
  require("alexdbconfig.php");
  $conn = new mysqli($dbservername, $dbusername, $dbpassword, $dbname);
  if ($conn->connect_error) 
  {
    return "mariadb error:" . $conn->connect_error;
  }  
  $sql = "SELECT COUNT(DISTINCT layeridx) as total FROM videolayerstruct WHERE taskid='".$taskid."' ORDER BY slbid ASC";
  $result = $conn->query($sql); 
  if ($result->num_rows > 0) 
  {
    while($row = $result->fetch_assoc()) 
    {
        $resultstr = trim($row["total"]);
    }
  } 
  else 
  {
    $resultstr="0";
  }
  $conn->close();
  return $resultstr;
}

function strtomillisec($str)
{
    $totalmillisec = 0;
    try 
    {
        $strparts = explode(":", $str);
        $hour = intval($strparts[0]);
        $min = intval($strparts[1]);
        $secand = $strparts[2];
        $strparts2 = explode(".", $secand);
        $sec = intval($strparts2[0]);
        if(strlen($strparts2[1])==3)
        {
          $millisec = intval($strparts2[1]);
        }
        else if(strlen($strparts2[1])==2)
        {
          $millisec = intval($strparts2[1])*10;
        }
        else if(strlen($strparts2[1])==1)
        {
          $millisec = intval($strparts2[1])*100;
        }
        else if(strlen($strparts2[1])==6)
        {
          $millisec = intval($strparts2[1])/1000;
        }
        else
        {
          $millisec = 0;
        }
        $totalmillisec = $millisec+$sec*1000+$min*60000+$hour*3600000;
    } 
    catch (Exception $e) 
    {
      return 0;
    }
    return $totalmillisec;
}

function millisectostr($milli)
{
    $finalstr = "00:00:00.000";
    try 
    {
        $millisec = intval($milli);
        $hour = intval(floor($millisec/3600000));
        $min = (intval(floor($millisec/60000)))%60;
        $sec = (intval(floor($millisec/1000)))%60;
        $millisec = $millisec%1000;
        $finalstr = sprintf('%02d:%02d:%02d.%03d', $hour,$min,$sec,$millisec);
    } 
    catch (Exception $e) 
    {
      return "00:00:00.000";
    }
    return $finalstr;
}

function preparepermission($apikey)
{
    require('alexsshconfig.php');
    $ssh = new SSH2($sshserveraddr);
    if (!$ssh->login($sshserverusername,$sshserverpassword)) 
    {
      return "ssh error: login failed.";
    }
    $ssh->exec("echo \"".$sshserverpassword."\" | sudo -S chmod 777 ".$websitepath."/".$apikey." -R");
    $ssh->disconnect();
    unset($ssh);
    return "done";
}

//ffmpeg -i ./demo.mp4 >> demo.txt
//Duration: ...
//ffmpeg -i ./demo.mp4 -y -f mjpeg -ss 00:00:08.010 -vframes 1 -s 89x50 ./demo.jpg

function getvideolength($apikey,$resfilename)
{
    require('alexsshconfig.php');
    $ssh = new SSH2($sshserveraddr);
    if (!$ssh->login($sshserverusername,$sshserverpassword)) 
    {
      return "00:00:00.001";
    }
    $ffmpegtaskid = generatestamp();
    $ssh->exec("/usr/local/bin/ffmpeg -i ".$websitepath."/".$apikey."/".$resfilename." >>".$websitepath."/task/".$ffmpegtaskid.".txt 2>&1");
    $shbk = file_get_contents("".$websitepath."/task/".$ffmpegtaskid.".txt");
    unlink("".$websitepath."/task/".$ffmpegtaskid.".txt");
    $ssh->disconnect();
    unset($ssh);
    $restimelength = "00:00:00.00";
    
    //if (str_contains($shbk, 'Duration:'))
    {
      try 
      {
        $startpos = strpos($shbk, 'Duration:')+9;
        $endpos = strpos($shbk, ', start:',strpos($shbk, 'Duration:')+9);
        $restimelength = substr($shbk,$startpos,$endpos-$startpos);
      } 
      catch (Exception $e) 
      {
        return "00:00:00.001";
      }
    }

    return trim($restimelength.'0');
}

function getmusiclength($apikey,$resfilename)
{
    require('alexsshconfig.php');
    $ssh = new SSH2($sshserveraddr);
    if (!$ssh->login($sshserverusername,$sshserverpassword)) 
    {
      return "00:00:00.001";
    }
    $ffmpegtaskid = generatestamp();
    $ssh->exec("/usr/local/bin/ffmpeg -i ".$websitepath."/".$apikey."/".$resfilename." >>".$websitepath."/task/".$ffmpegtaskid.".txt 2>&1");
    $shbk = file_get_contents("".$websitepath."/task/".$ffmpegtaskid.".txt");
    unlink("".$websitepath."/task/".$ffmpegtaskid.".txt");
    $ssh->disconnect();
    unset($ssh);
    $restimelength = "00:00:00.00";
    
    //if (str_contains($shbk, 'Duration:'))
    {
      try 
      {
        $startpos = strpos($shbk, 'Duration:')+9;
        $endpos = strpos($shbk, ', start:',strpos($shbk, 'Duration:')+9);
        $restimelength = substr($shbk,$startpos,$endpos-$startpos);
      } 
      catch (Exception $e) 
      {
        return "00:00:00.001";
      }
    }

    return trim($restimelength.'0');
}

function getvideofps($apikey,$resfilename)
{
    require('alexsshconfig.php');
    $ssh = new SSH2($sshserveraddr);
    if (!$ssh->login($sshserverusername,$sshserverpassword)) 
    {
      return "0";
    }
    $ffmpegtaskid = generatestamp();
    $ssh->exec("/usr/local/bin/ffmpeg -i ".$websitepath."/".$apikey."/".$resfilename." >>".$websitepath."/task/".$ffmpegtaskid.".txt 2>&1");
    $shbk = file_get_contents("".$websitepath."/task/".$ffmpegtaskid.".txt");
    unlink("".$websitepath."/task/".$ffmpegtaskid.".txt");
    $ssh->disconnect();
    unset($ssh);
    $resfpsstr = "0";
    
    //if (str_contains($shbk, 'Duration:'))
    {
      try 
      {
        $startpos = strpos($shbk, 'kb/s,')+5;
        $endpos = strpos($shbk, ' fps',strpos($shbk, 'kb/s,')+5);
        $resfpsstr = substr($shbk,$startpos,$endpos-$startpos);
      } 
      catch (Exception $e) 
      {
        return "0";
      }
    }

    return trim($resfpsstr);
}

//ffmpeg -i ./demo.mp4 >> demo.txt
//Duration: ...
//ffmpeg -i ./demo.mp4 -y -f mjpeg -ss 00:00:08.010 -vframes 1 -s 89x50 ./demo.jpg

function generatevideopic($apikey,$resfilename)
{
    require('alexsshconfig.php');
    $ssh = new SSH2($sshserveraddr);
    if (!$ssh->login($sshserverusername,$sshserverpassword)) 
    {
      return "ssh error: login failed.";
    }
    $ffmpegtaskid = generatestamp();
    $cmd = "/usr/local/bin/ffmpeg -i ".$websitepath."/".$apikey."/".$resfilename." >>".$websitepath."/task/".$ffmpegtaskid.".txt 2>&1";
    //$ssh->exec("echo \"".$cmd."\" >>".$websitepath."/task/".$ffmpegtaskid.".txt 2>&1");
    $ssh->exec($cmd);
    $shbk = file_get_contents("".$websitepath."/task/".$ffmpegtaskid.".txt");
    unlink("".$websitepath."/task/".$ffmpegtaskid.".txt");
    $restimelength = "00:00:00.000";
    
    //if (str_contains($shbk, 'Duration:'))
    {
      try 
      {
        $startpos = strpos($shbk, 'Duration:')+9;
        $endpos = strpos($shbk, ', start:',strpos($shbk, 'Duration:')+9);
        $restimelength = substr($shbk,$startpos,$endpos-$startpos);
        //$ssh->exec("echo \"shbk ".$shbk."\" >>".$websitepath."/task/test.txt 2>&1");
        //$ssh->exec("echo \"start end ".$startpos." ".$endpos."\" >>".$websitepath."/task/test.txt 2>&1");
      } 
      catch (Exception $e) 
      {
        return "getlength error:" . $e->getMessage();
      }
      $resmilli = strtomillisec($restimelength);
      $picpos = intval(floor($resmilli/2));
      $picposstr = millisectostr($picpos);
      $bnm = substr($resfilename,0,strripos($resfilename,'.'));
      $ffmpegtaskid = generatestamp();
      $cmd = "/usr/local/bin/ffmpeg -i ".$websitepath."/".$apikey."/".$resfilename."  -y -f mjpeg -ss ".$picposstr." -vframes 1 -s 89x50 ".$websitepath."/".$apikey."/".$bnm.".jpg >>".$websitepath."/task/".$ffmpegtaskid.".txt 2>&1";
      //$ssh->exec("echo \"".$cmd."\" >>".$websitepath."/task/".$ffmpegtaskid.".txt 2>&1");
      //$ssh->exec("echo \"".$restimelength."\" >>".$websitepath."/task/".$ffmpegtaskid.".txt 2>&1");
      $ssh->exec($cmd);
      $shbk = file_get_contents("".$websitepath."/task/".$ffmpegtaskid.".txt");
      unlink("".$websitepath."/task/".$ffmpegtaskid.".txt");
      $ssh->disconnect();
      unset($ssh);
      return "done";
    }
    return "command failed";
}

function generatevideopic2($apikey,$resfilename)
{
    require('alexsshconfig.php');
    $ssh = new SSH2($sshserveraddr);
    if (!$ssh->login($sshserverusername,$sshserverpassword)) 
    {
      return "ssh error: login failed.";
    }
    $ffmpegtaskid = generatestamp();
    $cmd = "/usr/local/bin/ffmpeg -i ".$websitepath."/".$apikey."/".$resfilename." >>".$websitepath."/task/".$ffmpegtaskid.".txt 2>&1";
    //$ssh->exec("echo \"".$cmd."\" >>".$websitepath."/task/".$ffmpegtaskid.".txt 2>&1");
    $ssh->exec($cmd);
    $shbk = file_get_contents("".$websitepath."/task/".$ffmpegtaskid.".txt");
    unlink("".$websitepath."/task/".$ffmpegtaskid.".txt");
    $restimelength = "00:00:00.000";
    
    //if (str_contains($shbk, 'Duration:'))
    {
      try 
      {
        $startpos = strpos($shbk, 'Duration:')+9;
        $endpos = strpos($shbk, ', start:',strpos($shbk, 'Duration:')+9);
        $restimelength = substr($shbk,$startpos,$endpos-$startpos);
        //$ssh->exec("echo \"shbk ".$shbk."\" >>".$websitepath."/task/test.txt 2>&1");
        //$ssh->exec("echo \"start end ".$startpos." ".$endpos."\" >>".$websitepath."/task/test.txt 2>&1");
      } 
      catch (Exception $e) 
      {
        return "getlength error:" . $e->getMessage();
      }
      $resmilli = strtomillisec($restimelength);
      $picpos = intval(floor($resmilli/2));
      $picposstr = ((string)(floor(intval($picpos)/1000))).'.png';
      $bnm = substr($resfilename,0,strripos($resfilename,'.'));
      $ffmpegtaskid = generatestamp();
      $cmd = "/usr/local/bin/convert ".$websitepath."/".$apikey."/".$bnm."/".$picposstr." -resize 89x50 ".$websitepath."/".$apikey."/".$bnm.".jpg >>".$websitepath."/task/".$ffmpegtaskid.".txt 2>&1";
      //$ssh->exec("echo \""+$cmd+"\" >>".$websitepath."/task/".$ffmpegtaskid.".txt 2>&1");
      $ssh->exec($cmd);
      $shbk = file_get_contents("".$websitepath."/task/".$ffmpegtaskid.".txt");
      unlink("".$websitepath."/task/".$ffmpegtaskid.".txt");
      $ssh->disconnect();
      unset($ssh);
      return "done";
    }
    return "command failed";
}

function generatemusicpic2($apikey,$resfilename)
{
  require('alexsshconfig.php');
  $ssh = new SSH2($sshserveraddr);
  if (!$ssh->login($sshserverusername,$sshserverpassword)) 
  {
    return "ssh error: login failed.";
  }

  $bnm = substr($resfilename,0,strripos($resfilename,'.'));
  $ffmpegtaskid = generatestamp();
  $ssh->exec("cp ".$websitepath."/musicicon.jpg ".$websitepath."/".$apikey."/".$bnm.".jpg -f >>".$websitepath."/task/".$ffmpegtaskid.".txt 2>&1");
  $shbk = file_get_contents("".$websitepath."/task/".$ffmpegtaskid.".txt");
  unlink("".$websitepath."/task/".$ffmpegtaskid.".txt");
  $ssh->disconnect();
  unset($ssh);
  return "done";
}

function generatepngpic2($apikey,$resfilename)
{
  require('alexsshconfig.php');
  $ssh = new SSH2($sshserveraddr);
  if (!$ssh->login($sshserverusername,$sshserverpassword)) 
  {
    return "ssh error: login failed.";
  }

  $bnm = substr($resfilename,0,strripos($resfilename,'.'));
  $picposstr = $bnm.'.jpg';
  $ffmpegtaskid = generatestamp();
  $ssh->exec("/usr/local/bin/convert ".$websitepath."/".$apikey."/".$bnm."/".$picposstr." -resize 89x50 ".$websitepath."/".$apikey."/".$bnm.".jpg >>".$websitepath."/task/".$ffmpegtaskid.".txt 2>&1");
  $shbk = file_get_contents("".$websitepath."/task/".$ffmpegtaskid.".txt");
  unlink("".$websitepath."/task/".$ffmpegtaskid.".txt");
  $ssh->disconnect();
  unset($ssh);
  return "done";
}

function generatevideosecpic($apikey,$resfilename)
{
    require('alexsshconfig.php');
    $ssh = new SSH2($sshserveraddr);
    if (!$ssh->login($sshserverusername,$sshserverpassword)) 
    {
      return "ssh error: login failed.";
    }

      $bnm = substr($resfilename,0,strripos($resfilename,'.'));
      $ffmpegtaskid = generatestamp();
      $cmd = "/usr/local/bin/ffmpeg -i ".$websitepath."/".$apikey."/".$resfilename." -y -vf fps=1 ".$websitepath."/".$apikey."/".$bnm."/%d.png >>".$websitepath."/task/".$ffmpegtaskid.".txt 2>&1";
      //$ssh->exec("echo \""+$cmd+"\" >>".$websitepath."/task/".$ffmpegtaskid.".txt 2>&1");
      $ssh->exec($cmd);

      $shbk = file_get_contents("".$websitepath."/task/".$ffmpegtaskid.".txt");
      unlink("".$websitepath."/task/".$ffmpegtaskid.".txt");
      $ssh->disconnect();
      unset($ssh);
      return "done";

}

function generatevideoaudio1($apikey,$resfilename)
{
    require('alexsshconfig.php');
    $ssh = new SSH2($sshserveraddr);
    if (!$ssh->login($sshserverusername,$sshserverpassword)) 
    {
      return "ssh error: login failed.";
    }
      $bnm = substr($resfilename,0,strripos($resfilename,'.'));
      $cmd = "/usr/local/bin/ffmpeg -i ".$websitepath."/".$apikey."/".$resfilename." -c copy -an -y ".$websitepath."/".$apikey."/".$bnm."-silent0.mp4";
      $ssh->exec($cmd);
      //$cmd = "/usr/local/bin/ffmpeg -f lavfi -t 1 -i anullsrc=cl=mono ".$websitepath."/".$apikey."/temp/dummy.opus";
      //$ssh->exec($cmd);
      
      $ssh->disconnect();
      unset($ssh);
      return "done";

}
function generatevideoaudio2($apikey,$resfilename)
{
    require('alexsshconfig.php');
    $ssh = new SSH2($sshserveraddr);
    if (!$ssh->login($sshserverusername,$sshserverpassword)) 
    {
      return "ssh error: login failed.";
    }
      $bnm = substr($resfilename,0,strripos($resfilename,'.'));

      //$cmd = "/usr/local/bin/ffmpeg -f lavfi -t 1 -i anullsrc=cl=mono ".$websitepath."/".$apikey."/temp/dummy.opus";
      //$ssh->exec($cmd);
      $cmd = "/usr/local/bin/ffmpeg -f lavfi -i anullsrc=channel_layout=stereo:sample_rate=44100 -i ".$websitepath."/".$apikey."/".$bnm."-silent0.mp4 -c:v copy -c:a aac -shortest ".$websitepath."/".$apikey."/".$bnm."-silent.mp4";
      $ssh->exec($cmd);

      //$shbk = file_get_contents("".$websitepath."/task/".$ffmpegtaskid.".txt");
      //unlink("".$websitepath."/task/".$ffmpegtaskid.".txt");
      $ssh->disconnect();
      unset($ssh);
      return "done";

}
function generatevideoaudio3($apikey,$resfilename)
{
    require('alexsshconfig.php');
    $ssh = new SSH2($sshserveraddr);
    if (!$ssh->login($sshserverusername,$sshserverpassword)) 
    {
      return "ssh error: login failed.";
    }
      $bnm = substr($resfilename,0,strripos($resfilename,'.'));
          
      $cmd = "/usr/local/bin/ffmpeg -i ".$websitepath."/".$apikey."/".$resfilename." -vn -ac 2 -ar 44100 -ab 320k -f mp3 ".$websitepath."/".$apikey."/".$bnm."-audio.mp3";
      ///usr/local/bin/ffmpeg -i ".$websitepath."/3mn.net-123456789987654321/1625457745173.mp4 -vn -ac 2 -ar 44100 -ab 320k -f mp3 ".$websitepath."/3mn.net-123456789987654321/1625457745173-audio.mp3
      $ssh->exec($cmd);
      //if(!file_exists("".$websitepath."/".$apikey."/".$bnm."-audio.mp3"))
      //{
      //  $cmd = "cp -f ".$websitepath."/".$apikey."/".$bnm."-silent.mp4 ".$websitepath."/".$apikey."/".$resfilename;
      //  $ssh->exec($cmd);  
      //}

      $ssh->disconnect();
      unset($ssh);
      return "done";

}

function generatevideoaudio4($apikey,$resfilename)
{
    require('alexsshconfig.php');
    $ssh = new SSH2($sshserveraddr);
    if (!$ssh->login($sshserverusername,$sshserverpassword)) 
    {
      return "ssh error: login failed.";
    }
      $bnm = substr($resfilename,0,strripos($resfilename,'.'));
      if(!file_exists("".$websitepath."/".$apikey."/".$bnm."-audio.mp3"))
      {
        $cmd = "cp -f ".$websitepath."/".$apikey."/".$bnm."-silent.mp4 ".$websitepath."/".$apikey."/".$resfilename;
        $ssh->exec($cmd);  
      }
      $ssh->disconnect();
      unset($ssh);
      return "done";

}


function generatemusicsecpic($apikey,$resfilename,$lengthmilli)
{
    require('alexsshconfig.php');
    $ssh = new SSH2($sshserveraddr);
    if (!$ssh->login($sshserverusername,$sshserverpassword)) 
    {
      return "ssh error: login failed.";
    }

      $bnm = substr($resfilename,0,strripos($resfilename,'.'));
      $ffmpegtaskid = generatestamp();
      $cmd = "/usr/local/bin/ffmpeg -i ".$websitepath."/".$apikey."/".$resfilename." -y -filter_complex \"compand,showwavespic=s=".floor($lengthmilli/100)."x50\" -frames:v 1 ".$websitepath."/".$apikey."/".$bnm."/wave.png >>".$websitepath."/task/".$ffmpegtaskid.".txt 2>&1";
      //$ssh->exec("echo \""+$cmd+"\" >>".$websitepath."/task/".$ffmpegtaskid.".txt 2>&1");
      $ssh->exec($cmd);
      $shbk = file_get_contents("".$websitepath."/task/".$ffmpegtaskid.".txt");
      unlink("".$websitepath."/task/".$ffmpegtaskid.".txt");
      $ssh->disconnect();
      unset($ssh);
      return "done";

}

function generatepngsecpic($apikey,$resfilename)
{
    require('alexsshconfig.php');
    $ssh = new SSH2($sshserveraddr);
    if (!$ssh->login($sshserverusername,$sshserverpassword)) 
    {
      return "ssh error: login failed.";
    }

      $bnm = substr($resfilename,0,strripos($resfilename,'.'));
      $ffmpegtaskid = generatestamp();
      $cmd = "/usr/local/bin/convert ".$websitepath."/".$apikey."/".$resfilename." ".$websitepath."/".$apikey."/".$bnm."/".$bnm.".jpg >>".$websitepath."/task/".$ffmpegtaskid.".txt 2>&1";
      //$ssh->exec("echo \""+$cmd+"\" >>".$websitepath."/task/".$ffmpegtaskid.".txt 2>&1");
      $ssh->exec($cmd);
      $shbk = file_get_contents("".$websitepath."/task/".$ffmpegtaskid.".txt");
      unlink("".$websitepath."/task/".$ffmpegtaskid.".txt");
      $ssh->disconnect();
      unset($ssh);
      return "done";

}

function generatevideopospic($apikey,$resfilename,$milli)
{
    require('alexsshconfig.php');
    $ssh = new SSH2($sshserveraddr);
    if (!$ssh->login($sshserverusername,$sshserverpassword)) 
    {
      return "ssh error: login failed.";
    }

      $picposstr = millisectostr($milli);
      $bnm = substr($resfilename,0,strripos($resfilename,'.'));
      $ffmpegtaskid = generatestamp();
      $cmd = "/usr/local/bin/ffmpeg -i ".$websitepath."/".$apikey."/".$resfilename." -y -f mjpeg -ss ".$picposstr." -vframes 1 -s 89x50 ".$websitepath."/".$apikey."/temp"."/".$bnm."-".$milli.".jpg >>".$websitepath."/task/".$ffmpegtaskid.".txt 2>&1";
      //$ssh->exec("echo \""+$cmd+"\" >>".$websitepath."/task/".$ffmpegtaskid.".txt 2>&1");
      $ssh->exec($cmd);
      $shbk = file_get_contents("".$websitepath."/task/".$ffmpegtaskid.".txt");
      unlink("".$websitepath."/task/".$ffmpegtaskid.".txt");
      $ssh->disconnect();
      unset($ssh);
      return "done";

}

function generatevideopospic2($apikey,$resfilename,$milli)
{
    require('alexsshconfig.php');
    $ssh = new SSH2($sshserveraddr);
    if (!$ssh->login($sshserverusername,$sshserverpassword)) 
    {
      return "ssh error: login failed.";
    }

      $picposstr = floor(intval($milli)/1000).'.png';
      $bnm = substr($resfilename,0,strripos($resfilename,'.'));
      if(!file_exists("".$websitepath."/".$apikey."/".$bnm."/".$picposstr))
      {
        $picposstr = '1.png';
      }
      $ffmpegtaskid = generatestamp();
      $cmd = "/usr/local/bin/convert ".$websitepath."/".$apikey."/".$bnm."/".$picposstr." -resize 89x50 ".$websitepath."/".$apikey."/temp"."/".$bnm."-".$milli.".jpg >>".$websitepath."/task/".$ffmpegtaskid.".txt 2>&1";
      //$ssh->exec("echo \""+$cmd+"\" >>".$websitepath."/task/".$ffmpegtaskid.".txt 2>&1");
      $ssh->exec($cmd);
      $shbk = file_get_contents("".$websitepath."/task/".$ffmpegtaskid.".txt");
      unlink("".$websitepath."/task/".$ffmpegtaskid.".txt");
      $ssh->disconnect();
      unset($ssh);
      return "done";

}

function generatemusicpospic2($apikey,$resfilename,$millistart,$millilength)
{
    require('alexsshconfig.php');
    $ssh = new SSH2($sshserveraddr);
    if (!$ssh->login($sshserverusername,$sshserverpassword)) 
    {
      return "ssh error: login failed.";
    }

    $ffmpegtaskid = generatestamp();
    $ssh->exec("/usr/local/bin/ffmpeg -i ".$websitepath."/".$apikey."/".$resfilename." >>".$websitepath."/task/".$ffmpegtaskid.".txt 2>&1");
    $shbk = file_get_contents("".$websitepath."/task/".$ffmpegtaskid.".txt");
    unlink("".$websitepath."/task/".$ffmpegtaskid.".txt");
    $restimelength = "00:00:00.00";
    //if (str_contains($shbk, 'Duration:'))
    {
      try 
      {
        $startpos = strpos($shbk, 'Duration:')+9;
        $endpos = strpos($shbk, ', start:',strpos($shbk, 'Duration:')+9);
        $restimelength = substr($shbk,$startpos,$endpos-$startpos);
      } 
      catch (Exception $e) 
      {
        $restimelength = "00:00:00.001";
      }
    }
    $restimelength = trim($restimelength.'0');
    $filelengthmilli = strtomillisec($restimelength);
    $lengthpercent = sprintf("%.2f", $millilength/$filelengthmilli*100);
    $startpercent = sprintf("%.2f", $millistart/$filelengthmilli);

      $picposstr = 'wave.png';
      $bnm = substr($resfilename,0,strripos($resfilename,'.'));
      $ffmpegtaskid = generatestamp();
      $cmd = "/usr/local/bin/magick ".$websitepath."/".$apikey."/".$bnm."/wave.png -crop \"".$lengthpercent."%x100%+%[fx:".$startpercent."*w]+%[fx:0]\" +repage ".$websitepath."/".$apikey."/"."temp/".$bnm."-".$millistart."-".$millilength.".jpg >>".$websitepath."/task/".$ffmpegtaskid.".txt 2>&1";
      //$ssh->exec("echo ".$lengthpercent."%x100%+%[fx:".$startpercent."*w]+%[fx:0] >>".$websitepath."/task/test.txt 2>&1");
      $ssh->exec($cmd);
      $shbk = file_get_contents("".$websitepath."/task/".$ffmpegtaskid.".txt");
      unlink("".$websitepath."/task/".$ffmpegtaskid.".txt");
      $ssh->disconnect();
      unset($ssh);
      return "done";

}

function generatepngpospic2($apikey,$resfilename)
{
  require('alexsshconfig.php');
  $ssh = new SSH2($sshserveraddr);
  if (!$ssh->login($sshserverusername,$sshserverpassword)) 
  {
    return "ssh error: login failed.";
  }

  $bnm = substr($resfilename,0,strripos($resfilename,'.'));
  $bnm0 = str_replace("temp/", "", $bnm);
  
  $ffmpegtaskid = generatestamp();
  $ssh->exec("cp ".$websitepath."/".$apikey."/".$bnm.".jpg ".$websitepath."/".$apikey."/"."temp/".$bnm0.".jpg -f >>".$websitepath."/task/".$ffmpegtaskid.".txt 2>&1");
  $shbk = file_get_contents("".$websitepath."/task/".$ffmpegtaskid.".txt");
  unlink("".$websitepath."/task/".$ffmpegtaskid.".txt");
  $ssh->disconnect();
  unset($ssh);
  return "done";
}

function removetaskfiles($taskid,$apikey)
{
  require('alexsshconfig.php');
  $ssh = new SSH2($sshserveraddr);
  if (!$ssh->login($sshserverusername,$sshserverpassword)) 
  {
    return "ssh error: login failed.";
  }
  
  //$ffmpegtaskid = generatestamp();

  //$ssh->exec("rm -f ".$websitepath."/".$apikey."/".$taskid.".mp4");
  //$ssh->exec("rm -f ".$websitepath."/".$apikey."/temp"."/".$taskid."*");
  $ssh->exec("rm -rf ".$websitepath."/".$apikey."/temp"."/"."*");

  //$shbk = file_get_contents("".$websitepath."/task/".$ffmpegtaskid.".txt");
  //unlink("".$websitepath."/task/".$ffmpegtaskid.".txt");
  $ssh->disconnect();
  unset($ssh);
  return "done";
}

function separateaudio($apikey,$resfilename,$startpos,$optlen)
{
  require('alexsshconfig.php');
  $ssh = new SSH2($sshserveraddr);
  if (!$ssh->login($sshserverusername,$sshserverpassword)) 
  {
    return "ssh error: login failed.";
  }

  $bnm = substr($resfilename,0,strripos($resfilename,'.'));
  if(!file_exists("".$websitepath."/".$apikey."/".$bnm."-audio.mp3"))
  {
    $cmd = "/usr/local/bin/ffmpeg -i ".$websitepath."/".$apikey."/".$bnm."-silent.mp4 -vn -ac 2 -ar 44100 -ab 320k -f mp3 ".$websitepath."/".$apikey."/".$bnm."-audio.mp3";
    ///usr/local/bin/ffmpeg -i ".$websitepath."/3mn.net-123456789987654321/1625457745173.mp4 -vn -ac 2 -ar 44100 -ab 320k -f mp3 ".$websitepath."/3mn.net-123456789987654321/1625457745173-audio.mp3
    $ssh->exec($cmd);
  }
  if(!file_exists("".$websitepath."/".$apikey."/".$bnm."-audio.mp3"))
  {
    $ssh->exec("/usr/local/bin/ffmpeg -f lavfi -t 1 -i anullsrc=cl=mono ".$websitepath."/".$apikey."/dummy.opus");
    $ssh->exec("/usr/local/bin/ffmpeg -i ".$websitepath."/".$apikey."/".$bnm.".mp4 -i ".$websitepath."/".$apikey."/dummy.opus -af apad -shortest ".$websitepath."/".$apikey."/".$bnm."-rebuild.mp4");
    $ssh->exec("cp -f ".$websitepath."/".$apikey."/".$bnm."-rebuild.mp4 ".$websitepath."/".$apikey."/".$bnm."-silent.mp4");
    $ssh->exec("/usr/local/bin/ffmpeg -i ".$websitepath."/".$apikey."/".$bnm."-rebuild.mp4 -q:a 0 -map a ".$websitepath."/".$apikey."/".$bnm."-audio.mp3");
  }
  $resfilename2 = $bnm ."-audio.mp3";
  $restimelength2 = getmusiclength($apikey,$resfilename2);
  generatemusicsecpic($apikey,$resfilename2,strtomillisec($restimelength2));

  /*
  $startposmilli = strtomillisec($startpos);
  $endposmilli = $startposmilli + strtomillisec($optlen);

  $ffmpegtaskid = generatestamp();
  $ssh->exec("/usr/local/bin/ffmpeg -i ".$websitepath."/".$apikey."/".$bnm."-audio.mp3 -y -ss ".$startpos." -t ".$optlen." ".$websitepath."/".$apikey."/"."temp/".$bnm."-".$startposmilli."-".$endposmilli.".mp3 -f >>".$websitepath."/task/".$ffmpegtaskid.".txt 2>&1");
  $shbk = file_get_contents("".$websitepath."/task/".$ffmpegtaskid.".txt");
  unlink("".$websitepath."/task/".$ffmpegtaskid.".txt");
  $ssh->disconnect();
  unset($ssh);
  return $bnm."-".$startposmilli."-".$endposmilli.".mp3^".$startpos."^".$optlen;
  */
  return $bnm."-audio.mp3^".$startpos."^".$optlen;
}

function imageputtext($apikey,$resfilename,$puttext)
{
  require('alexsshconfig.php');
  $ssh = new SSH2($sshserveraddr);
  if (!$ssh->login($sshserverusername,$sshserverpassword)) 
  {
    return "ssh error: login failed.";
  }

  $bnm = substr($resfilename,0,strripos($resfilename,'.'));
  $charwidth=strlen($puttext)*43;
  $ffmpegtaskid = generatestamp();
  $ssh->exec("/usr/local/bin/convert -size ".$charwidth."x80 xc:transparent -pointsize 60 -fill black -annotate +10+60 \"".$puttext."\" -annotate +12+60 \"".$puttext."\" -annotate +12+62 \"".$puttext."\" -annotate +14+62 \"".$puttext."\" -fill white -annotate +11+61 \"".$puttext."\" -font Source-Han-Sans-Normal ".$websitepath."/".$apikey."/".$resfilename." >>".$websitepath."/task/".$ffmpegtaskid.".txt 2>&1");
  $shbk = file_get_contents("".$websitepath."/task/".$ffmpegtaskid.".txt");
  unlink("".$websitepath."/task/".$ffmpegtaskid.".txt");
  $ssh->disconnect();
  unset($ssh);
  return "done";
}

function imageconvertjpg($apikey,$resfilename)
{
  require('alexsshconfig.php');
  $ssh = new SSH2($sshserveraddr);
  if (!$ssh->login($sshserverusername,$sshserverpassword)) 
  {
    return "ssh error: login failed.";
  }

  $bnm = substr($resfilename,0,strripos($resfilename,'.'));
  $charwidth=strlen($puttext)*43;
  $ffmpegtaskid = generatestamp();
  $ssh->exec("/usr/local/bin/convert ".$websitepath."/".$apikey."/".$resfilename." ".$websitepath."/".$apikey."/".$bnm.".jpg >>".$websitepath."/task/".$ffmpegtaskid.".txt 2>&1");
  $shbk = file_get_contents("".$websitepath."/task/".$ffmpegtaskid.".txt");
  unlink("".$websitepath."/task/".$ffmpegtaskid.".txt");
  $ssh->disconnect();
  unset($ssh);
  return "done";
}

function runlocalcmd($localcmd)
{
  require('alexsshconfig.php');
  $ssh = new SSH2($sshserveraddr);
  if (!$ssh->login($sshserverusername,$sshserverpassword)) 
  {
    return "ssh error: login failed.";
  }

  $ffmpegtaskid = generatestamp();
  $ssh->exec($localcmd." >>".$websitepath."/task/".$ffmpegtaskid.".txt 2>&1");
  $shbk = file_get_contents("".$websitepath."/task/".$ffmpegtaskid.".txt");
  unlink("".$websitepath."/task/".$ffmpegtaskid.".txt");
  $ssh->disconnect();
  unset($ssh);
  return $shbk;
}

//$laststamp = round(microtime(true) * 1000);
function generatestamp()
{
    $milliseconds = round(microtime(true) * 1000);
    //if($milliseconds==$laststamp)$milliseconds+=1;
    //$laststamp = $milliseconds;
    return $milliseconds;
}

function remove_utf8_bom($text)
{
    $bom = pack('H*','EFBBBF');
    $text = preg_replace("/^$bom/", '', $text);
    return $text;
}
?>
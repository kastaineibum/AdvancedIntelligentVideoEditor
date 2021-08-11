<?php
//error_reporting(E_ALL);
//ini_set('display_errors', 'on');

require("verifyapikey.php");
require_once("alextoolsfunctions.php");

$target_dir = $publickey;
if(!file_exists($target_dir))
{
    mkdir($target_dir);
}

$resfilename = basename($_FILES["file"]["name"]);
$ext = substr($resfilename,strripos($resfilename,'.'));
$bnm = substr($resfilename,0,strripos($resfilename,'.'));
$resfileclass = substr($ext,1);
$resfiledesc = $_REQUEST["desc"];
$target_file = trim($target_dir) .'/'. trim($resfilename);
$titlepic = $bnm.'.jpg';
$restimelength = '00:00:00.00';

mkdir($target_dir.'/'.$bnm);
mkdir($target_dir.'/'.$bnm."-audio");
if (move_uploaded_file($_FILES["file"]["tmp_name"], $target_file)) 
{
  preparepermission($publickey);
  
  $restimelength = getvideolength($publickey,$resfilename);
  $resfps = getvideofps($publickey,$resfilename);
  //$genrst = generatevideopic($finalkey,$resfilename);

  generatevideosecpic($publickey,$resfilename);
  generatevideoaudio1($publickey,$resfilename);
  generatevideoaudio2($publickey,$resfilename);
  generatevideoaudio3($publickey,$resfilename);
  generatevideoaudio4($publickey,$resfilename);
  $genrst = generatevideopic2($publickey,$resfilename);
  
  $resfilename2 = $bnm."-audio.mp3";
  $restimelength2 = getmusiclength($publickey,$resfilename2);
  generatemusicsecpic($publickey,$resfilename2,strtomillisec($restimelength2));

  if($genrst=="done")
  {
    $sql = "INSERT INTO publiclib (resfilename, apikey, titlepic, resfileclass, resfiledesc, restimelength, resfps) VALUES ('".$resfilename."', '".$finalkey."', '".$titlepic."','".$resfileclass."','".$resfiledesc."','".$restimelength."',".$resfps.")";
    $dbrst = dbquery($sql);
    if ($dbrst == "done") 
    {
      echo("done");
    } 
    else 
    {
      echo($dbrst);
    }
  }
  else
  {
    echo($genrst);
  }
}
else
{
  echo("failed");
}

?>
<?php
//error_reporting(E_ALL);
//ini_set('display_errors', 'on');

require("verifyapikey.php");
require_once("alextoolsfunctions.php");

$target_dir = $finalkey;
if(!file_exists($target_dir))
{
    mkdir($target_dir);
}

$taskid = $_REQUEST["taskid"];

$resfilename = $taskid.".mp4";
$ext = substr($resfilename,strripos($resfilename,'.'));
$bnm = substr($resfilename,0,strripos($resfilename,'.'));
$resfileclass = substr($ext,1);
$resfiledesc = $_REQUEST["desc"];
$target_file = trim($target_dir) .'/'. trim($resfilename);
$titlepic = $bnm.'.jpg';
$restimelength = '00:00:00.00';

mkdir($target_dir.'/'.$bnm);
mkdir($target_dir.'/'.$bnm."-audio");
if (file_exists($target_file)) 
{
  preparepermission($target_dir);
  
  $restimelength = getvideolength($target_dir,$resfilename);
  $resfps = getvideofps($target_dir,$resfilename);
  //$genrst = generatevideopic($target_dir,$resfilename);

  generatevideosecpic($target_dir,$resfilename);
  generatevideoaudio1($target_dir,$resfilename);
  generatevideoaudio2($target_dir,$resfilename);
  generatevideoaudio3($target_dir,$resfilename);
  generatevideoaudio4($target_dir,$resfilename);
  $genrst = generatevideopic2($target_dir,$resfilename);
  
  $resfilename2 = $bnm."-audio.mp3";
  $restimelength2 = getmusiclength($target_dir,$resfilename2);
  generatemusicsecpic($target_dir,$resfilename2,strtomillisec($restimelength2));

  if($genrst=="done")
  {
    $sql = "INSERT INTO privatelib (resfilename, apikey, titlepic, resfileclass, resfiledesc, restimelength, resfps) VALUES ('".$resfilename."', '".$target_dir."', '".$titlepic."','".$resfileclass."','".$resfiledesc."','".$restimelength."',".$resfps.")";
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
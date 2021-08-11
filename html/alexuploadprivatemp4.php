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
  preparepermission($finalkey);
  
  $restimelength = getvideolength($finalkey,$resfilename);
  $resfps = getvideofps($finalkey,$resfilename);
  //$genrst = generatevideopic($finalkey,$resfilename);

  generatevideosecpic($finalkey,$resfilename);
  generatevideoaudio1($finalkey,$resfilename);
  generatevideoaudio2($finalkey,$resfilename);
  generatevideoaudio3($finalkey,$resfilename);
  generatevideoaudio4($finalkey,$resfilename);
  $genrst = generatevideopic2($finalkey,$resfilename);
  
  $resfilename2 = $bnm."-audio.mp3";
  $restimelength2 = getmusiclength($finalkey,$resfilename2);
  generatemusicsecpic($finalkey,$resfilename2,strtomillisec($restimelength2));

  if($genrst=="done")
  {
    $sql = "INSERT INTO privatelib (resfilename, apikey, titlepic, resfileclass, resfiledesc, restimelength, resfps) VALUES ('".$resfilename."', '".$finalkey."', '".$titlepic."','".$resfileclass."','".$resfiledesc."','".$restimelength."',".$resfps.")";
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
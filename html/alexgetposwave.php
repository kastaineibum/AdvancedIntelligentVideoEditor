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
$target_dir = $finalkey."/temp";
if(!file_exists($target_dir))
{
    mkdir($target_dir);
    preparepermission($finalkey);
}
$resfilename = $_REQUEST["file"];
$millistart = $_REQUEST["start"];
$millilength = $_REQUEST["len"];
$ext = substr($resfilename,strripos($resfilename,'.'));
$bnm = substr($resfilename,0,strripos($resfilename,'.'));
$name = trim($finalkey)."/temp"."/".trim($bnm).'-'.$millistart.'-'.$millilength.'.jpg';
if(!file_exists($name))
{
    //create jpeg with millisec stamp
    generatemusicpospic2($finalkey,$resfilename,$millistart,$millilength);
    
    $content = file_get_contents($name);
    header('Content-Type: image/jpeg');
    echo($content);
}
else
{
    $content = file_get_contents($name);
    header('Content-Type: image/jpeg');
    echo($content);
}

?>
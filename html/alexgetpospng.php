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
$ext = substr($resfilename,strripos($resfilename,'.'));
$bnm = substr($resfilename,0,strripos($resfilename,'.'));
$bnm = str_replace("temp/", "", $bnm);
$name = trim($finalkey)."/temp"."/".trim($bnm).'.jpg';
if(!file_exists($name))
{
    generatepngpospic2($finalkey,$resfilename);
    
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
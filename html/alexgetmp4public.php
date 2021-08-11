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
$resfilename = $_REQUEST["file"];
$ext = substr($resfilename,strripos($resfilename,'.'));
$bnm = substr($resfilename,0,strripos($resfilename,'.'));
if($ext==".mp4")
{
    $name = trim($publickey)."/".trim($bnm).'.mp4';
}
if($ext==".mp3")
{
    $name = trim($publickey)."/".trim($bnm).'.mp3';
}
if($ext==".png")
{
    $name = trim($publickey)."/".trim($bnm).'.png';
}

if(!file_exists($name))
{
    echo('');
}
else
{
    if($ext==".mp4")
    {
        $content = file_get_contents($name);
        $filelength = filesize($name);
        header('Content-Type: video/mp4');
        header('Content-Length: '.$filelength);
        echo($content);
    }
    if($ext==".mp3")
    {
        $content = file_get_contents($name);
        $filelength = filesize($name);
        header('Content-Type: audio/mpeg');
        header('Content-Length: '.$filelength);
        echo($content);
    }
    if($ext==".png")
    {
        $content = file_get_contents($name);
        $filelength = filesize($name);
        header('Content-Type: image/png');
        header('Content-Length: '.$filelength);
        echo($content);
    }

}
?>
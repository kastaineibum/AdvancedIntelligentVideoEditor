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
$name = trim($publickey)."/".trim($bnm).'.jpg';
if(!file_exists($name))
{
    echo($name);
}
else
{
    /*
    $fp = fopen($name, 'rb');
    header("Content-Type: image/jpeg");
    header("Content-Length: " . filesize($name));
    fpassthru($fp);
    exit;
    */

    ///*
    $content = file_get_contents($name);
    header('Content-Type: image/jpeg');
    echo($content);
    //*/

    /*
    $myImage = imagecreatefromjpeg($name);
    ob_start();
    imagejpeg($myImage);
    printf('<img src="data:image/jpeg;base64,%s"/>', 
            base64_encode(ob_get_clean()));
    imagedestroy($myImage);
*/
}

?>
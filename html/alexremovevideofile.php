<?php
require("verifyapikeyfunc.php");
require_once("alextoolsfunctions.php");

function isValidJSON($str)
{
    json_decode($str);
    return json_last_error() == JSON_ERROR_NONE;
}

$strpostin = file_get_contents('php://input');
if(!isValidJSON($strpostin))
{
    echo($strpostin);
    die('json error');
}

$strdecoded = json_decode($strpostin,true);

/* */
$finalk = findapikey($strdecoded['apikey']);
//echo($finalk);

if(strlen($finalk)<2)
{
    die('key error');
}

//echo($finalk);
//echo('</br>');
//echo($strdecoded['content']);
$removefilename=$strdecoded['content'];
$sql="DELETE FROM privatelib WHERE resfilename='".$removefilename."' AND apikey='".$finalk."'";
$drst = dbquery($sql);
$resfilename = $removefilename;
$ext = substr($resfilename,strripos($resfilename,'.'));
$bnm = substr($resfilename,0,strripos($resfilename,'.'));
$picname = trim($finalk)."/".trim($bnm).'.jpg';
$audioname = trim($finalk)."/".trim($bnm).'-audio.mp3';
$silentname = trim($finalk)."/".trim($bnm).'-silent.mp4';
$silent0name = trim($finalk)."/".trim($bnm).'-silent0.mp4';
$rebuiltname = trim($finalk)."/".trim($bnm).'-rebuild.mp4';
$videoname = trim($finalk)."/".trim($resfilename);
unlink($picname);
unlink($videoname);
shell_exec('rm -rf '.trim($finalk)."/".trim($bnm));
shell_exec('rm -rf '.trim($finalk)."/".trim($bnm).'-audio');
unlink($audioname);
unlink($silentname);
unlink($silent0name);
unlink($rebuiltname);
//shell_exec('rm -rf '.trim($finalk)."/".trim($bnm)."/*.*");
//shell_exec('rmdir '.trim($finalk)."/".trim($bnm));
echo($drst);
?>
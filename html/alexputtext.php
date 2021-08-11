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

$fileandtext = trim($strdecoded['content']);
$pfi = explode("|", $fileandtext);
$resfilename = $pfi[0];
$puttext = $pfi[1];
imageputtext($finalk,$resfilename,$puttext);
imageconvertjpg($finalk,$resfilename);
?>
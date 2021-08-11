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
$taskid=$strdecoded['content'];
$sql="UPDATE task SET taskstatus='processing' WHERE taskid='".$taskid."' AND apikey='".$finalk."'";

echo(dbquery($sql));
?>
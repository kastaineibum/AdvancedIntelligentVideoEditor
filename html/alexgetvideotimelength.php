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
$vflstr = "00:00:00.000";
$ppf = $strdecoded['content'];
$ppfi = explode("|", $ppf);
$ispubliclib = intval($ppfi[0]);
$resfilename = $ppfi[1];
if($ispubliclib==0)
{
    $vflstr = getvideolength($finalk,$resfilename);
}
else
{
    $vflstr = getvideolength($publickey,$resfilename);
}
echo(strtomillisec($vflstr));

?>
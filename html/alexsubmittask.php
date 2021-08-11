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

$pstr = $strdecoded['content'];

//echo($pf);

/**/
$tasktsi = explode("|", $pstr);
$finalwidthstr = $tasktsi[0];
$finalheightstr = $tasktsi[1];
$taskclass = $tasktsi[2];
$taskdesc = $tasktsi[3];
$taskargs = $tasktsi[4];
$finallengthmilli = intval($tasktsi[5]);

$rstaskid = addtask($finalwidthstr,$finalheightstr,$taskclass,$taskdesc,$taskargs,$finallengthmilli,$finalk);

echo($rstaskid);

?>
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

/**/
$tasktsi = explode("|", $pstr);

$sql="INSERT INTO videolayerstruct(blockidx,blockid,resfilename,createstamp,fromstamp,tostamp,blocklength,fileclass,blockcolor,ispubliclib,simularity,blend,filestartpos,resizeleft,resizetop,resizewidth,resizeheight,resizeenable,respeed,respeedenable,revolume,revolumeenable,layercreatestamp,zindex,layerlength,layeridx,layerid,structcreatestamp,scalefactor,taskid) VALUES(".$tasktsi[0].",".$tasktsi[1].",'".$tasktsi[2]."','".$tasktsi[3]."',".$tasktsi[4].",".$tasktsi[5].",".$tasktsi[6].",'".$tasktsi[7]."',".$tasktsi[8].",".$tasktsi[9].",".$tasktsi[10].",".$tasktsi[11].",".$tasktsi[12].",".$tasktsi[13].",".$tasktsi[14].",".$tasktsi[15].",".$tasktsi[16].",".$tasktsi[17].",".$tasktsi[18].",".$tasktsi[19].",".$tasktsi[20].",".$tasktsi[21].",'".$tasktsi[22]."',".$tasktsi[23].",".$tasktsi[24].",".$tasktsi[25].",".$tasktsi[26].",'".$tasktsi[27]."',".$tasktsi[28].",'".$tasktsi[29]."');";

$rst = dbquery($sql);

echo($rst);

?>
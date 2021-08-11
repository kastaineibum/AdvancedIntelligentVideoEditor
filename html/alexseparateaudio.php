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

$pf = $strdecoded['content'];

//echo($pf);

/**/
$pfi = explode("|", $pf);
$pdi = '';
$rstr = '';
for($i=0;$i<count($pfi);$i++)
{
    if(strlen($pfi[$i])>3)
    {
        $pdi = explode("^", $pfi[$i]);
        $ispubliclib = intval($pdi[0]);
        $sfilename = $pdi[1];
        $spos = $pdi[2];
        $slen = $pdi[3];
        if($ispubliclib==0)
        {
            $rstr .= ("0^".(separateaudio($finalk,$sfilename,$spos,$slen))."^".$pdi[4]."|");
        }
        else
        {
            $rstr .= ("1^".(separateaudio($publickey,$sfilename,$spos,$slen))."^".$pdi[4]."|");
        }
    }
}

echo($rstr);

?>
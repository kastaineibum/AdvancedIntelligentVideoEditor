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

echo(dbgetvideofilespublic());

?>
<?php
require("verifyapikey.php");

$target_dir = $finalkey;
if(!file_exists($target_dir))
{
    mkdir($target_dir);
}
$target_file = $target_dir .'/'. basename($_FILES["file"]["name"]);
if (move_uploaded_file($_FILES["file"]["tmp_name"], $target_file)) 
{
    echo "The file ". htmlspecialchars( basename( $_FILES["file"]["name"])). " has been uploaded.";
}
else
{
    echo "Sorry, there was an error uploading your file.";
}

?>

<?php
require("alexpathconfig.php");

function findapikey($keyencoded)
{
require("alexdbconfig.php");
$finalkey = "-";

$key0 = trim(shell_exec("./alexpark_apikeydecryptor ".$keyencoded." 0"));
$key1 = trim(shell_exec("./alexpark_apikeydecryptor ".$keyencoded." 1"));

$conn = new mysqli($dbservername, $dbusername, $dbpassword, $dbname);
if ($conn->connect_error) 
{
    $finalkey = "-";
}
$sql = "SELECT apikey, groupid FROM apikey WHERE apikey='".$key0."';";
$result = $conn->query($sql);
if ($result->num_rows > 0) 
{
  while($row = $result->fetch_assoc()) 
  {
    $finalkey = $key0;
  }
} 
else 
{
  $finalkey = "-";
}
$conn->close();

if($finalkey == "-")
{
$conn = new mysqli($dbservername, $dbusername, $dbpassword, $dbname);
if ($conn->connect_error) 
{
    $finalkey = "-";
}
$sql = "SELECT apikey, groupid FROM apikey WHERE apikey='".$key1."';";
$result = $conn->query($sql);
if ($result->num_rows > 0) 
{
  while($row = $result->fetch_assoc()) 
  {
    $finalkey = $key1;
  }
} 
else 
{
  $finalkey = "-";
}
$conn->close();
}

return $finalkey;
}
?>
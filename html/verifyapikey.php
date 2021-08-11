<?php
require("alexdbconfig.php");
require("alexpathconfig.php");
$apikeyexist = 0;

$key0 = trim(shell_exec("./alexpark_apikeydecryptor ".$_REQUEST["key"]." 0"));
$key1 = trim(shell_exec("./alexpark_apikeydecryptor ".$_REQUEST["key"]." 1"));
$finalkey = "";

$conn = new mysqli($dbservername, $dbusername, $dbpassword, $dbname);
if ($conn->connect_error) 
{
    $apikeyexist = 0;
}
$sql = "SELECT apikey, groupid FROM apikey WHERE apikey='".$key0."';";
$result = $conn->query($sql);
if ($result->num_rows > 0) 
{
  while($row = $result->fetch_assoc()) 
  {
    $apikeyexist = 1;
    $finalkey = $key0;
  }
} 
else 
{
  $apikeyexist = 0;
}
$conn->close();

if($apikeyexist == 0)
{
$conn = new mysqli($dbservername, $dbusername, $dbpassword, $dbname);
if ($conn->connect_error) 
{
    $apikeyexist = 0;
}
$sql = "SELECT apikey, groupid FROM apikey WHERE apikey='".$key1."';";
$result = $conn->query($sql);
if ($result->num_rows > 0) 
{
  while($row = $result->fetch_assoc()) 
  {
    $apikeyexist = 1;
    $finalkey = $key1;
  }
} 
else 
{
  $apikeyexist = 0;
}
$conn->close();
}

if($apikeyexist == 0)
{
    die("key error");
}
?>
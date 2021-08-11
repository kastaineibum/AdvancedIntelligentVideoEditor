<?php
require("verifyapikey.php");
require("alexdbconfig.php");

$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) 
{
  die("mariadb error:" . $conn->connect_error);
}

$sql = "SELECT apikey, groupid FROM apikey WHERE apikey='".$finalkey."'";
$result = $conn->query($sql);

if ($result->num_rows > 0) 
{
  while($row = $result->fetch_assoc()) 
  {
    echo "apikey: " . $row["apikey"]. " | groupid: " . $row["groupid"]. "<br>";
  }
} 
else 
{
  echo "0 record";
}
$conn->close();

//echo shell_exec("echo hello world");

//3mn.net-123456789987654321: 250-177-117-143-22-132-24-114-27-53-35-238-49-236-110-64-76-72-26-78-22-160-20-216-77-21-218-188-252-148-132-228-

?> 



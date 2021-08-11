<?php
require_once 'vendor/autoload.php';

use phpseclib3\Net\SSH2;

$ssh = new SSH2('localhost');
if (!$ssh->login('alexparkmz', '    ')) 
{
    echo('Login failed');
}

//echo $ssh->exec('eval "$(conda shell.bash hook)"');
//echo $ssh->exec('source ~/anaconda3/bin/activate');
//echo $ssh->exec('export PATH=~/anaconda3/bin:$PATH');
//echo $ssh->exec('source ".$websitepath."/condabashrc.sh');
//echo $ssh->exec('echo $PATH');
echo $ssh->exec('".$websitepath."/test.sh>>".$websitepath."/test.txt');

//$script = file_get_contents("".$websitepath."/test.sh");
//$ssh->exec($script);

?>


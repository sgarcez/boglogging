<?php
$host = "184.106.156.81"; //database location
$user = "boglogging"; //database username
$pass = "Uranus666"; //database password
$db_name = "boglogging"; //database name
//database connection
$link = mysql_connect($host, $user, $pass);
mysql_select_db($db_name);
//sets encoding to utf8
mysql_query("SET NAMES utf8");
?>
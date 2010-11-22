<?php
$host = "localhost"; //database location
$user = "root"; //database username
$pass = "root"; //database password
$db_name = "boglog"; //database name
//database connection
$link = mysql_connect($host, $user, $pass);
mysql_select_db($db_name);
//sets encoding to utf8
mysql_query("SET NAMES utf8");
?>
<?php
$host = "boglog.db.4844803.hostedresource.com"; //database location
$user = "boglog"; //database username
$pass = "Uranus666"; //database password
$db_name = "boglog"; //database name
//database connection
$link = mysql_connect($host, $user, $pass);
mysql_select_db($db_name);
//sets encoding to utf8
mysql_query("SET NAMES utf8");
?>
<?php

ini_set("error_reporting","E_ALL");

require('api/db.live_remote.php');

date_default_timezone_set('Europe/London');


		$from = date("Y.m.d"); 
		$to  = date("Y.m.d H-i-s", mktime(23, 59, 59, date("m"), date("d"), date("Y")));

		$sql = sprintf( 
			"SELECT * FROM session 
			WHERE start_time >= '%s' 
			AND start_time <='%s'",
				mysql_real_escape_string($from),
				mysql_real_escape_string($to));
				
		$query = mysql_query($sql);
		//echo $query;
		$oneorless = 0;
		$twoorless = 0;
		$fiveorless = 0;
		$tenorless = 0;
		$fifteenorless = 0;
		
		while($result = mysql_fetch_array($query))
		{
			$diff = getDiffMinutes( strtotime($result['end_time']), strtotime($result['start_time']) );
			if($diff <=1) $oneorless++;
			else if($diff <=2) $twoorless++;
			else if($diff <=5) $fiveorless++;
			else if($diff <=10) $tenorless++;
			else if($diff <=15) $fifteenorless++;
			
			//echo $diff."<br/>";
			//echo getDiffMinutes( strtotime($result['end_time']), strtotime($result['start_time']) ) .'<br/>';
		}
		//echo $fifteenorless;
//echo $oneorless;

print "<img src='http://chart.apis.google.com/chart?chs=300x225&cht=p3&chds=0,80&chd=t1:".$oneorless.",".$twoorless.",".$fifteenorless.",".$tenorless.",".$fifteenorless."&chdl=<1|1-2|2-5|5-10|10-15&chtt=Todays+sessions+in+minutes'  width='300' height='225' alt='' />";

function getDiffMinutes($epoch_1,$epoch_2)
{
$diff_seconds  = $epoch_1 - $epoch_2;
$diff_weeks    = floor($diff_seconds/604800);
$diff_seconds -= $diff_weeks   * 604800;
$diff_days     = floor($diff_seconds/86400);
$diff_seconds -= $diff_days    * 86400;
$diff_hours    = floor($diff_seconds/3600);
$diff_seconds -= $diff_hours   * 3600;
$diff_minutes  = floor($diff_seconds/60);
$diff_seconds -= $diff_minutes * 60;
return $diff_minutes;
}

?>
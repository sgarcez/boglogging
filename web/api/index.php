<?php

ini_set("error_reporting","E_ALL");

require('RestUtils.php');
require('db.php');

date_default_timezone_set('Europe/London');

$data = RestUtils::processRequest();


switch($data->getMethod())  
{  
    // this is a request for all users, not one in particular  
    case 'get':

		$params = $data->getRequestVars();
		
		if( $params != NULL && $params['action']!= null)
		{
			if( $params['action'] == 'retrieveState')
			{
				RestUtils::sendResponse(200, getBogState());
			}else if( $params['action'] == 'setState' )
			{
				if($params['new'])
				{
					if( $params['new'] == 'engage')
						RestUtils::sendResponse(200, engage());
					else if( $params['new'] == 'disengage')
						RestUtils::sendResponse(200, disengage());
					else
						RestUtils::sendResponse(400);
				}else
				{
					RestUtils::sendResponse(400);
				}
			
			}else if( $params['action'] == 'retrieveHistory' )
			{
				if($params['mode'])
				{
					//echo $params['mode'];
					if($params['mode'] =='today')
					{
						$from = date("Y.m.d"); 
						$to  = date("Y.m.d H-i-s", mktime(23, 59, 59, date("m"), date("d"), date("Y")));
						RestUtils::sendResponse(200, json_encode(getSessionsInRange($from, $to)), 'application/json');
					}else if( $params['mode'] == 'all')
					{
						RestUtils::sendResponse(200, json_encode(getSessions()), 'application/json');
					}else
					{
						RestUtils::sendResponse(400);
					}
				}else if($params['rangeFrom'] != NULL && $params['rangeTo'] != NULL)
				{
					$from = date("Y.m.d  H-i-s", strtotime($params['rangeFrom']));
					$to = date("Y.m.d  H-i-s", strtotime($params['rangeTo']));
					
					if ( $from === false ||  $to === false) {
					    RestUtils::sendResponse(400);
					} else {
						RestUtils::sendResponse(200, json_encode(getSessionsInRange($from, $to)), 'application/json');
					}
				}else if($params['rangeFrom'] != NULL)
				{
					$from = date("Y.m.d", strtotime($params['rangeFrom']));
					$to  = date("Y.m.d H-i-s", mktime(23, 59, 59, date("m",strtotime($params['rangeFrom'])), date("d",strtotime($params['rangeFrom'])), date("Y",strtotime($params['rangeFrom']))));
					//echo $to;
					RestUtils::sendResponse(200, json_encode(getSessionsInRange($from, $to)), 'application/json');
				}else
				{
					RestUtils::sendResponse(400);
				}
			}else
			{
				RestUtils::sendResponse(400);
			}
		}else
		{
			RestUtils::sendResponse(400);
		}
       // 
        break;
}
	//returns 1, 0, or -1
	// engaged, vacant, error
	function getBogState()
	{
		$query="SELECT * FROM boglog.session WHERE end_time IS NULL ORDER BY start_time DESC LIMIT 1";
		mysql_query($query);
		return strval(mysql_affected_rows());
	}
	
	//returns success boolean
	function disengage()
	{
		if( getBogState() == '1')
		{
			$now = date(DATE_ATOM, mktime());
			$sql = sprintf( "UPDATE boglog.session as t1 set t1.end_time = '%s' WHERE t1.end_time IS NULL ORDER BY start_time DESC LIMIT 1",
			    mysql_real_escape_string($now) );
			
			mysql_query($sql);
			return strval(mysql_affected_rows());
		}else
		{
			return '-1';
		}
	}
	
	//returns success boolean
	function engage()
	{
		disengage();
		$now = date(DATE_ATOM, mktime());
		$sql = sprintf( "INSERT INTO boglog.session (start_time) VALUES ('%s');",
			    mysql_real_escape_string($now) );
		
		mysql_query($sql);
		return strval(mysql_affected_rows());
	}
	
	//retrieve all sessions
	function getSessions()
	{
		$sql = "SELECT * FROM boglog.session";
		$query = mysql_query($sql);
		return prepareResultSet($query);
	}
	
	//retrieve sessions in range
	function getSessionsInRange($from, $to)
	{
		$sql = sprintf( 
			"SELECT * FROM boglog.session 
			WHERE start_time >= '%s' 
			AND start_time <='%s'",
				mysql_real_escape_string($from),
				mysql_real_escape_string($to));
				
		$query = mysql_query($sql);
		return prepareResultSet($query);
	}
	
	//prepares array from queries 
	function prepareResultSet($query)
	{
		$resultSet = array();
		while($result = mysql_fetch_array($query))
		{
		    $resultSet[] = array('id' => $result['id'], 'start_time' => $result['start_time'], 'end_time' => $result['end_time']);
		}
		return $resultSet;
	}

?>
# Select number of bogs, in descending order of how long the bog was for, on a certain date.
SELECT start_time, TIMEDIFF(end_time, start_time) AS 'length'
FROM session
WHERE start_time LIKE '2010-11-23%' AND end_time IS NOT NULL
ORDER BY length DESC;
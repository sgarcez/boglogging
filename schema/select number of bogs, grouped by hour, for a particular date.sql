# Select number of bogs, grouped by hour, for a particular date.
SELECT COUNT(*), HOUR(start_time)
FROM session
WHERE start_time LIKE '2010-11-19%'
GROUP BY HOUR (start_time);
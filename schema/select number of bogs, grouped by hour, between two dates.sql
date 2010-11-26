# Select number of bogs, grouped by hour, between two dates.
SELECT COUNT(*), HOUR(start_time)
FROM session
WHERE start_time BETWEEN '2010-11-19 00:00:00' AND '2010-11-19 23:59:59'
GROUP BY HOUR (start_time);
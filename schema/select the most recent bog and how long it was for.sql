# Select the most recent bog and how long it was for.
SELECT start_time, TIMEDIFF(end_time, start_time) AS 'length'
FROM session
WHERE start_time LIKE '2011-01-21%' AND end_time IS NOT NULL
ORDER BY start_time DESC
LIMIT 1;
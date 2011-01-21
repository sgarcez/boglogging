# Select current bog and the its length.
SELECT start_time, TIMEDIFF(NOW(), start_time) AS 'length'
FROM session
WHERE end_time IS NULL
ORDER BY length ASC
LIMIT 1;
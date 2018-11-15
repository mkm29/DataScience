# 1. What are the three longest trips on rainy days?

WITH rainy
AS 
(
	SELECT 
		DATE(date) rain_date
	FROM 
		weather
	WHERE 
		events = 'Rain'
	GROUP BY 1
)
SELECT
	t.trip_id, t.duration, t.start_date
FROM
	trips t
JOIN
	rainy r
ON
	Date(t.start_date) = r.rain_date
ORDER BY
	t.duration DESC
LIMIT 3;


# 2. Which station is full most often?


SELECT
	ss.name, st.station_id, COUNT(st.*) as num_full
FROM
	status st
JOIN
	stations ss
ON
	st.station_id = ss.station_id
WHERE
	st.bikes_available = 0
GROUP BY
	1, 2
ORDER BY
	num_full DESC
LIMIT
	1;


# 3. Return a list of stations with a count of number of trips starting at that station but ordered by dock count.

SELECT
	s.name, SUM(s.dockcount) as total_dock
FROM
	stations s
JOIN
	trips t
ON
	s.name = t.start_station
GROUP BY
	name
ORDER BY
	total_dock DESC;




# 4. (Challenge) What's the length of the longest trip for each day it rains anywhere?

WITH rainy
AS 
(
	SELECT 
		DATE(date) rain_date
	FROM 
		weather
	WHERE 
		events = 'Rain'
	GROUP BY 1
)

SELECT
	Date(t.start_date), MAX(t.duration)
FROM
	trips t
JOIN
	rainy r
ON
	Date(t.start_date) = r.rain_date
GROUP BY
	Date(t.start_date)
ORDER BY
	Date(t.start_date);

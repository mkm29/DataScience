# What was the hottest day in our data set? Where was that?

SELECT
	weather.date, zip
FROM
	weather
ORDER BY
	maxtemperaturef DESC
LIMIT 1;

# How many trips started at each station?

SELECT 
	start_station, COUNT(*)
FROM
	trips
GROUP BY
	start_station;

# What's the shortest trip that happened?

SELECT 
	trip_id, duration
FROM
	trips
ORDER BY
	duration
LIMIT 1;

# What is the average trip duration, by end station?

SELECT 
	end_station, AVG(duration)
FROM
	trips
GROUP BY
	end_station;
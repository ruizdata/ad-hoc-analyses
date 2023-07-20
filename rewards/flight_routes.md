## Task 2

The news that we’re analyzing this data has made its way to the route planning team, and they’ve asked us to prepare for them a table in the SQLite database containing all of the flight routes flown in 2022. Because their request is high-priority and time-sensitive, we'd like to do this before moving on to our own analysis.

Each Amazing Airlines flight repeats on either a daily or weekly cadence. Using the information in the `flights_2022` table of `member_data.db` (which contains a row for each *individual flight* flown in 2022), please create a table in the SQLite database called `flight_routes_2022`, which should contain a single row for each *flight route* included in the `flights_2022` table of `member_data.db`, with the following columns:

- departure_airport
- arrival_airport
- departure_weekday
- departure_time
- arrival_time
- distance_miles

`departure_weekday` should be an abbreviated weekday ("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", or "Sun") if the flight departs weekly, or "All" if the flight departs daily. `departure_time` and `arrival_time` should be in the `HH:MM:SS` format.


A) Create flight_routes_2022. Unable to create new table in read-only SQLite DB so resorted to temporary table.

-- Create a temporary table called flight_routes_2022 to store the selected flight route data
CREATE TEMP TABLE flight_routes_2022 AS

-- Select the departure_airport, arrival_airport, departure_weekday, departure_time, arrival_time, and distance_miles
SELECT
    departure_airport,
    arrival_airport,

    -- Use the `CASE` statement to convert the weekday number into an abbreviated weekday name
    CASE
        WHEN strftime('%w', scheduled_departure_datetime) = '0' THEN 'Sun'
        WHEN strftime('%w', scheduled_departure_datetime) = '1' THEN 'Mon'
        WHEN strftime('%w', scheduled_departure_datetime) = '2' THEN 'Tue'
        WHEN strftime('%w', scheduled_departure_datetime) = '3' THEN 'Wed'
        WHEN strftime('%w', scheduled_departure_datetime) = '4' THEN 'Thu'
        WHEN strftime('%w', scheduled_departure_datetime) = '5' THEN 'Fri'
        WHEN strftime('%w', scheduled_departure_datetime) = '6' THEN 'Sat'
    END AS departure_weekday,

    -- Convert the scheduled_departure_datetime and actual_arrival_datetime into the 'HH:MM:SS' format
    strftime('%H:%M:%S', scheduled_departure_datetime) AS departure_time,
    strftime('%H:%M:%S', actual_arrival_datetime) AS arrival_time,

    -- Select the distance in miles
    distance_miles

-- From the flights_2022 table, group the flights based on departure_airport, arrival_airport, departure_weekday, departure_time, arrival_time, and distance_miles
GROUP BY departure_airport, arrival_airport, departure_weekday, departure_time, arrival_time, distance_miles

-- Exclude routes that occur exactly twice on any given day of the week (Sundays to Saturdays)
HAVING
    COUNT(CASE WHEN strftime('%w', scheduled_departure_datetime) = '0' THEN 1 END) != 2 -- Exclude routes flown twice on Sundays
    AND COUNT(CASE WHEN strftime('%w', scheduled_departure_datetime) = '1' THEN 1 END) != 2 -- Exclude routes flown twice on Mondays
    AND COUNT(CASE WHEN strftime('%w', scheduled_departure_datetime) = '2' THEN 1 END) != 2 -- Exclude routes flown twice on Tuesdays
    AND COUNT(CASE WHEN strftime('%w', scheduled_departure_datetime) = '3' THEN 1 END) != 2 -- Exclude routes flown twice on Wednesdays
    AND COUNT(CASE WHEN strftime('%w', scheduled_departure_datetime) = '4' THEN 1 END) != 2 -- Exclude routes flown twice on Thursdays
    AND COUNT(CASE WHEN strftime('%w', scheduled_departure_datetime) = '5' THEN 1 END) != 2 -- Exclude routes flown twice on Fridays
    AND COUNT(CASE WHEN strftime('%w', scheduled_departure_datetime) = '6' THEN 1 END) != 2; -- Exclude routes flown twice on Saturdays




**Important:** There is one route that is flown twice daily, and two routes that are flown twice weekly. Because of the nature of their analysis, the route planning team has asked us to **exclude these routes** from the `flight_routes_2022` dataset entirely. In addition to excluding them from the dataset, can you please note below which routes these are?

B) Which route is flown twice daily, and which two routes are flown twice weekly?
    
Unable to find route flow twice daily. Query below attempts to groups flights by departure and arrival airports, filtering only routes with 14 occurrences in the flights_2022 dataset, indicating routes flown twice daily during 2022. 

SELECT
    departure_airport,
    arrival_airport,
    COUNT(*) AS total_occurrences
FROM flights_2022
GROUP BY departure_airport, arrival_airport
HAVING total_occurrences = 14;

Two routes flown twice weekly: EWR > CLE, RSW > DEN

SELECT
    departure_airport,
    arrival_airport
FROM flights_2022
GROUP BY departure_airport, arrival_airport
HAVING COUNT(DISTINCT strftime('%w', scheduled_departure_datetime)) = 2;

Query groups the flights by departure and arrival airports and then filters the results to only show routes that have exactly two distinct weekdays (i.e., twice weekly flights)



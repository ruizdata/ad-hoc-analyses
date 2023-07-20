## Task 3

Based on user feedback, we’re exploring the introduction of a new, three-tier rewards program. The tiers would be called Amazing Rewards **Bronze**, Amazing Rewards **Silver**, and Amazing Rewards **Gold**.
As with the Basic tier in the current program, all members will automatically receive Bronze status simply by creating an account. Our goal is for ~50% of our users to *attain* Silver status in a given year, and ~10% of users to also *attain* Gold status. (Note: Because rewards status lasts until the end of the following year, the share of users who *have* a status level in a given year will be somewhat higher than the share who *attain* status that year.)
Using the data in the SQLite database, please find an answer to the following question:
- In order to meet our goals, how many miles should a member have to fly in a given year to achieve the Silver and Gold statuses, respectively?
 
WITH member_stats AS (
    SELECT
        user_id,
        MAX(strftime('%Y', actual_departure_datetime)) AS year,
        SUM(distance_miles) OVER (PARTITION BY user_id) AS total_miles
    FROM tickets_2022
    JOIN flights_2022 ON tickets_2022.flight_id = flights_2022.flight_id
    WHERE tickets_2022.flight_completed = 1
)
SELECT
    tier,
    MAX(miles_required) AS miles_required
FROM (
    SELECT
        user_id,
        CASE
            WHEN total_miles >= 0.5 * 75000 THEN 'Silver'
            WHEN total_miles >= 0.1 * 75000 THEN 'Gold'
            ELSE 'Bronze'
        END AS tier,
        total_miles AS miles_required
    FROM member_stats
    GROUP BY user_id
)
GROUP BY tier;

1920 miles required for Bronze

Query attempted to calculate the miles required for each tier (Bronze, Silver, and Gold) in a new three-tier rewards program based on the total miles flown by users in the year 2022. It uses a CTE called member_stats to compute the total miles for each user and classifies them into tiers (Silver, Gold, or Bronze) based on their total miles compared to the program's goals. The final output shows the tier and the maximum miles required for each tier.
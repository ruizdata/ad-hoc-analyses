## Task 1

Recent user studies have found that customers aren’t satisfied with our current rewards membership tiers. We plan to re-work them to be more appealing, but in order to do so, we need to investigate our data to uncover answers to a few questions.
We’ve pulled three tables from our databases for your use in this project:

  - `members_2022`: All of our rewards members as of December 31, 2022. (Note: members with elite status may have earned that status in either 2021 or 2022.)

  - `flights_2022`: All Amazing Airlines flights that departed in 2022.

  - `tickets_2022`: All airline tickets purchased by rewards members for flights that departed in 2022.

These tables are included in the `member_data.db` SQLite file in this directory. Additionally, we've included `sqlite_database_structure.png`, an image describing the structure of the data. Use this information to complete the following tasks.

---

Our rewards program has two membership tiers: **Amazing Rewards Basic**, and **Amazing Rewards Elite**. Anyone who creates an account on our website instantly becomes a Basic member, which allows them to collect miles in their account, and spend their miles on free flights and seat upgrades. In order to become an Elite member, a customer must fly at least 75,000 miles with Amazing Airlines within a calendar year. (They then retain Elite membership until the end of the following calendar year.)
Some customers have expressed that the 75,000 mile requirement makes Elite status too difficult to achieve. We want to validate this claim. Using the data in the `members_2022` table of `member_data.db` and the `flights_2022` table of `member_data.db`, please find answers to the following questions:
- What percentage of rewards members had Elite status on December 31, 2022?

A) Calculate the percentage of rewards members who had Elite status on December 31, 2022. [10.71%]

SELECT 
    (COUNT(CASE WHEN lifetime_miles_earned >= 75000 THEN 1 END) * 100.0 / COUNT(*)) AS percentage_elite

FROM members_2022

-- Join the members_2022 table with the tickets_2022 table on the user_id to link rewards members with their flights

JOIN tickets_2022 ON members_2022.user_id = tickets_2022.user_id

-- Join the tickets_2022 table with the flights_2022 table on the flight_id to link flights with their associated tickets

JOIN flights_2022 ON tickets_2022.flight_id = flights_2022.flight_id

-- Filter the data to only include completed flights (flight_completed = 1) to consider only flights that were completed by the user

WHERE tickets_2022.flight_completed = 1;


B) On average, how many Amazing Airlines flights would a user have to take in a calendar year in order to reach Elite status? [38.48 flights]

-- Calculate the average number of Amazing Airlines flights a user would have to take in a calendar year to reach Elite status

SELECT AVG(total_flights) AS average_flights_to_elite

FROM (

    -- Count the total number of flights taken by each user in 2022 and group the results by user_id

    SELECT members_2022.user_id, COUNT(*) AS total_flights
    FROM members_2022

    -- Join the members_2022 table with the tickets_2022 table on the user_id to link rewards members with their flights

    JOIN tickets_2022 ON members_2022.user_id = tickets_2022.user_id

    -- Join the tickets_2022 table with the flights_2022 table on the flight_id to link flights with their associated tickets

    JOIN flights_2022 ON tickets_2022.flight_id = flights_2022.flight_id

    -- Group the data by user_id to calculate the total number of flights taken by each user

    GROUP BY members_2022.user_id

) AS user_flight_counts

-- Join the user_flight_counts subquery with the members_2022 table on user_id to include the user's lifetime_miles_earned

JOIN members_2022 ON user_flight_counts.user_id = members_2022.user_id

-- Filter the data to only include users who have a lifetime_miles_earned of at least 75,000 (the requirement for Elite status)

WHERE members_2022.lifetime_miles_earned >= 75000;




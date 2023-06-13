/* Rank the top cities of each state by population count */

SELECT * FROM (
	SELECT city,
		     state, 
		     population,
		     row_number() over (partition by state order by population desc) as state_rank
	FROM [us-cities-top-1k])
ranks WHERE state_rank = 1;

/* List states whose total population is less than or equal to the top 3 most populous cities in the country. */

SELECT State, SUM(Population) AS TotalPopulation
FROM [us-cities-top-1k]
GROUP BY State
HAVING SUM(Population) <= (
  SELECT SUM(Population)
  FROM (
    SELECT TOP 3 Population
    FROM [us-cities-top-1k]
    ORDER BY Population DESC
  ) AS TopCities
);

/* List the top 3 fast and slowest growing cities using the multi-year dataset */

SELECT top 3 city, state, max(population) / min(population) - 1 AS growth_rate
FROM [us-cities-top-1k-multi-year]
GROUP BY city, state
ORDER BY growth_rate desc;

SELECT top 3 city, state, max(population) / min(population) - 1 AS growth_rate
FROM [us-cities-top-1k-multi-year]
GROUP BY city, state
ORDER BY growth_rate asc;

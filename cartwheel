Technical Interview

-- Below are descriptions of tables in Cartwheel's data warehouse, which are pipelined from our App's database.
-- All 'id' fields are primary keys, and link as you would expect to similarly named fields. For example, 
-- the referrals.id field can be joined to the referral_services.referral_id field.


public.referrals
id 					STRING NOT NULLABLE
created_at			TIMESTAMP NOT NULLABLE
updated_at			TIMESTAMP NOT NULLABLE
approved_at			TIMESTAMP
reliable_wifi		BOOLEAN NOT NULLABLE
campus_sessions		BOOLEAN NOT NULLABLE
at_home_sessions	BOOLEAN NOT NULLABLE
status				STRING NOT NULLABLE
referrer_id			STRING NOT NULLABLE
client_id			STRING NOT NULLABLE
-- Possible Referral statuses:
--   Outreach
--   Ready for Assignment

public.referral_services
id  				STRING NOT NULLABLE		
referral_id			STRING NOT NULLABLE
service_id 			STRING NOT NULLABLE

public.clients
id 					STRING NOT NULLABLE
pronouns			STRING NOT NULLABLE
created_at			TIMESTAMP NOT NULLABLE
updated_at			TIMESTAMP NOT NULLABLE
healthie_id			STRING
reference_code		STRING
organization_id 	STRING NOT NULLABLE

public.organizations
id 					STRING NOT NULLABLE
name 				STRING NOT NULLABLE
email_domain 		STRING NOT NULLABLE
state_id  			STRING NOT NULLABLE
created_at			TIMESTAMP NOT NULLABLE
updated_at			TIMESTAMP NOT NULLABLE

public.journeys
id 					STRING NOT NULLABLE
status				STRING NOT NULLABLE
referral_id			STRING NOT NULLABLE
service_id			STRING NOT NULLABLE
created_at			TIMESTAMP NOT NULLABLE
updated_at			TIMESTAMP NOT NULLABLE
-- Possible journey statuses:
--   Intake Ongoing
--   Intake Scheduled
--   Care Ongoing
--   Care Ended

public.services
id 					STRING NOT NULLABLE
name				STRING NOT NULLABLE
created_at			TIMESTAMP NOT NULLABLE
updated_at			TIMESTAMP NOT NULLABLE
-- Possible service names:
--  Individual Therapy
--  Parent Guidance
--  Psychopharmaceutical Treatment


1. Find the organization with the most approved referrals in November 2023. 

SELECT public.organization.name, COUNT(public.referrals.id) AS count_of_referrals
FROM public.referrals
JOIN public.clients ON public.referrals.client_id = public.clients.id
JOIN public.organization ON public.clients.organization_id = public.organization.id
WHERE public.referrals.approved_at IS NOT NULL
  AND DATE_TRUNC('month', public.referrals.approved_at) = '2023-11-01'
GROUP BY public.organization.name
ORDER BY count_of_referrals DESC
LIMIT 1;


2. Find the most recently approved referral in December 2023 at the organization with highest number of approved referrals in December 2023. 
Ideally, your solution should use one SELECT statement and a window function. 


SELECT
    r.organization_name,
    r.referral_id,
    r.approved_at
FROM (
    SELECT
        r.id AS referral_id,
        r.approved_at,
        o.name AS organization_name,
        COUNT(r.id) OVER (PARTITION BY o.name) AS referral_count,
        RANK() OVER (PARTITION BY o.name ORDER BY r.approved_at DESC) AS rank
    FROM public.referrals r
    JOIN public.clients c ON r.client_id = c.id
    JOIN public.organization o ON c.organization_id = o.id
    WHERE r.approved_at BETWEEN '2023-12-01' AND '2023-12-31'
) r
WHERE r.organization_name = (
    SELECT o.name
    FROM public.referrals r
    JOIN public.clients c ON r.client_id = c.id
    JOIN public.organization o ON c.organization_id = o.id
    WHERE r.approved_at BETWEEN '2023-12-01' AND '2023-12-31'
    GROUP BY o.name
    ORDER BY COUNT(r.id) DESC
    LIMIT 1
)
AND r.rank = 1
ORDER BY r.approved_at DESC
LIMIT 1;


3. Pipeline Design

-- One of the main tools we support on the data team is the School Success Dashboard. The school success dashboard shows 3 metrics at the month level:
	-- Approved referrals
	-- Individual therapy referrals in outreach
	-- Referrals with at least 1 journey in care ongoing

-- Write a query which will serve as the data source for the school success team's dashboard. As you write the query, tell me about your process. For example:
	-- Why the query has the granularity you choose
	-- How you would explain any nuances in the data to the school success team
	-- Walk me through what you would do to check your results before sharing it
	-- Do you have any concerns about the query's fragility? What are the edge cases/failure cases? 
	-- Are there any automated checks that you would create? 

SELECT
    DATE_TRUNC('month', r.approved_at) AS month,
    COUNT(DISTINCT r.id) AS approved_referrals,
    COUNT(DISTINCT CASE WHEN r.status = 'Outreach' THEN r.id END) AS individual_therapy_referrals_in_outreach,
    COUNT(DISTINCT j.referral_id) AS referrals_with_journeys
FROM public.referrals r
LEFT JOIN public.journeys j ON r.id = j.referral_id AND j.status = 'Ongoing'
WHERE r.approved_at BETWEEN '2023-12-01' AND '2023-12-31'
GROUP BY month
ORDER BY month;

-- Aggregation and Granularity: Group data by month using DATE_TRUNC to align with the dashboard’s monthly metrics and ensure accurate reporting.
-- Metric Calculation: Use COUNT(DISTINCT) to tally approved referrals, individual therapy referrals in outreach, and referrals with ongoing journeys, incorporating relevant statuses.
-- Validation: Check results by manually reviewing a sample, cross-referencing with source data, and verifying accuracy to ensure reliable metrics.
-- Automated Checks: Implement automated validations to monitor data integrity, flag anomalies, and handle potential issues like missing or incorrect statuses.

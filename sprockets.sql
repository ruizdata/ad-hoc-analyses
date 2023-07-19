/* 

Background

We operate a sprocket marketplace that sells hundreds of millions of different sprockets on behalf of a large number of providers to a North American customer base. A
customer order may include a varying set of sprockets from a variety of providers. The price of sprockets changes frequently so we update their prices and track those
changes in a change log that is over a billion records. Due to overwhelming demand for our sprockets, our database is pushed to its limits during the business day processing millions of orders during our peak hours of operation.

Task 1: Querying data
A provider (ID: 1024) has asked for a report of their top 25 (in purchase total) customers from the past three months.

Describe how you would approach fulfilling this request.
Write the query.

*/ 

SELECT 
    customers.customer_id,
    customers.customer_name,
    SUM(order_items.order_amount * sprockets.sprocket_price) AS purchase_total
FROM 
    customers
JOIN 
    sprockets ON customers.customer_id = sprockets.customer_id
JOIN
    orders ON customers.customer_id = orders.customer_id
JOIN
    order_items ON orders.order_id = order_items.order_id
WHERE 
    orders.ordered_at >= DATE_SUB(CURRENT_DATE, INTERVAL 3 MONTH) -- Three months ago from today
GROUP BY 
    customers.customer_id, customers.customer_name
ORDER BY 
    purchase_total DESC
LIMIT 
    25;

/*

Task 2: Reverting a change

A provider (ID: 2048) mistakenly imported a new sprocket price list causing many of their sprockets to be priced incorrectly. Sadly, their inventory manager is on vacation so
they do not have access to the old price list and they need to restore the previous prices quickly. Fortunately, we have a table that stores any changes to the sprockets table. We
need to revert the unit_price values to the values that were changed at exactly 12PM UTC on July 1, 2023 with a source of “employee_id_4”.

Describe how you would approach fulfilling this request.
Write the query

*/

-- Step 1: Identify the previous unit_price values for provider ID 2048 at the specified date and time
SELECT
    sprocket_id,
    old_data AS previous_unit_price
FROM
    sprocket_change_log
WHERE
    sprocket_id IN (
        SELECT
            sprocket_id
        FROM
            sprockets
        WHERE
            provider_id = 2048
    )
    AND change_source = 'employee_id_4'
    AND changed_at = '2023-07-01 12:00:00';

-- Step 2: Update the sprockets table with the previous unit_price values
UPDATE
    sprockets
JOIN
    sprocket_change_log
ON
    sprockets.sprocket_id = sprocket_change_log.sprocket_id
SET
    sprockets.unit_price = sprocket_change_log.old_data
WHERE
    sprockets.sprocket_id IN (
        SELECT
            sprocket_id
        FROM
            sprockets
        WHERE
            provider_id = 2048
    )
    AND sprocket_change_log.change_source = 'employee_id_4'
    AND sprocket_change_log.changed_at = '2023-07-01 12:00:00';

/*

Task 3: Dealing with a large data update via CSV

A provider (id: 4096) has provided you a 10 million row csv file with each row having the columns: “name", “description", “unit_price”. They would like you to insert the data into
the sprockets table.

Describe how you would approach fulfilling this request.
Write the query.

*/

-- Step 1: Prepare the CSV file with columns "name", "description", and "unit_price".

-- Step 2: Create a temporary staging table
CREATE TABLE temp_sprockets (
    name VARCHAR(255),
    description VARCHAR(500),
    unit_price DECIMAL(10, 2)
);

-- Step 3: Load the data into the staging table
LOAD DATA INFILE '/path/to/your/csv/file.csv'
INTO TABLE temp_sprockets
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n' -- Use '\n' for Unix-based systems

-- Step 4: Optimize the staging table (Optional)
-- You may add relevant indexes on columns if needed.

-- Step 5: Perform the insert into the sprockets table
INSERT INTO sprockets (name, description, unit_price)
SELECT name, description, unit_price
FROM temp_sprockets
WHERE provider_id = 4096;

-- Step 6: Cleanup
DROP TABLE temp_sprockets;

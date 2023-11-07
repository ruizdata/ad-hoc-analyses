Problem:
You've joined a manufacturing company as an analyst. You're asked to produce an analysis of the database that answers the questions below and characterizes the dataset.

Deliverable:
Open the attached SQLite database file with https://sqlitebrowser.org/ or https://sqlite.org/fiddle/index.html or another tool of your choosing and start examining the tables and rows it contains.

1. Answer the following questions about the dataset

How many items without a tax code were sold as finished goods? 177

SELECT COUNT(*)
FROM sales_order_item
JOIN product ON sales_order_item.product_id = product.id
WHERE product.tax_code IS NULL;

How many line items are on each order? Range 2 to 5, average 3.68

SELECT order_id, 
       COUNT(*) + 
       COALESCE(COUNT(component_1_id), 0) +
       COALESCE(COUNT(component_2_id), 0) +
       COALESCE(COUNT(component_3_id), 0) +
       COALESCE(COUNT(component_4_id), 0) +
       COALESCE(COUNT(continues_item_id), 0) AS num_line_items
FROM sales_order_item
WHERE order_id IS NOT NULL
GROUP BY order_id;

How often are we not fulfilling the order with the right amount of items? 5252

SELECT COUNT(*) AS num_incomplete_orders
FROM (
    SELECT soi.order_id, 
           COUNT(*) +
           COALESCE(SUM(CASE WHEN soi.component_1_id IS NOT NULL THEN 1 ELSE 0 END), 0) +
           COALESCE(SUM(CASE WHEN soi.component_2_id IS NOT NULL THEN 1 ELSE 0 END), 0) +
           COALESCE(SUM(CASE WHEN soi.component_3_id IS NOT NULL THEN 1 ELSE 0 END), 0) +
           COALESCE(SUM(CASE WHEN soi.component_4_id IS NOT NULL THEN 1 ELSE 0 END), 0) +
           COALESCE(SUM(CASE WHEN soi.continues_item_id IS NOT NULL THEN 1 ELSE 0 END), 0) AS total_items_ordered,
           COALESCE(s.num_items_fulfilled, 0) AS num_items_fulfilled
    FROM sales_order_item soi
    LEFT JOIN (
        SELECT order_id, SUM(num_items_fulfilled) AS num_items_fulfilled
        FROM shipment
        GROUP BY order_id
    ) s ON soi.order_id = s.order_id
    GROUP BY soi.order_id, s.num_items_fulfilled
) AS subquery
WHERE total_items_ordered != num_items_fulfilled;

2. Paint a strategic picture of our orders; are there any patterns, recommendations or insights?

Most popular product / Product with most shipments - ACME Turbo-Powered Umbrella with 157 shipments

SELECT soi.product_id, COUNT(*) AS num_shipments
FROM sales_order_item AS soi
JOIN shipment AS s ON soi.order_id = s.order_id
WHERE soi.product_id IS NOT NULL
GROUP BY soi.product_id
ORDER BY num_shipments DESC
LIMIT 1;

Most popular city - City with most shipments - Iron River

SELECT address.city, COUNT(*) AS num_shipments
FROM shipment
JOIN address ON shipment.address_id = address.id
GROUP BY address.city
ORDER BY num_shipments DESC
LIMIT 1;

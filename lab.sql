USE sakila;

-- Step 1: Create or Replace View for rental summary
CREATE OR REPLACE VIEW rental_summary AS
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    COUNT(r.rental_id) AS rental_count
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.email;

-- Step 2: Create a Temporary Table for total payments
CREATE TEMPORARY TABLE customer_payment_summary AS
SELECT 
    p.customer_id,
    SUM(p.amount) AS total_paid
FROM payment p
GROUP BY p.customer_id;

-- Step 3: Create a CTE for final customer summary report
WITH customer_summary_cte AS (
    SELECT 
        rs.customer_name,
        rs.email,
        rs.rental_count,
        cps.total_paid
    FROM rental_summary rs
    JOIN customer_payment_summary cps ON rs.customer_id = cps.customer_id
)

-- Final report: rentals, payments, and average payment per rental
SELECT 
    customer_name,
    email,
    rental_count,
    total_paid,
    ROUND(total_paid / NULLIF(rental_count, 0), 2) AS average_payment_per_rental
FROM customer_summary_cte
ORDER BY total_paid DESC;

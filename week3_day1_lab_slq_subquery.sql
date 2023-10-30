-- Write SQL queries to perform the following tasks using the Sakila database:
use sakila;
-- 1. Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system.
SELECT 
    COUNT(*)
FROM
    inventory
WHERE
    film_id = (SELECT 
            film_id
        FROM
            film
        WHERE
            title = 'Hunchback Impossible');

-- 2. List all films whose length is longer than the average length of all the films in the Sakila database.
SELECT AVG(length) FROM film;   -- keep in mind that avg length is 115 so we can check that the subquery do the job 
SELECT 
    title, length
FROM
    film
WHERE
    length > (SELECT 
            AVG(length)
        FROM
            film)
ORDER BY length ASC; -- filtering just so we can see lowest avg duration


-- trying to do it with a join and no subqueries (just because erin said its hard without subqueries)
SELECT film1.title, film1.length FROM film as film1
JOIN film AS film2 ON film1.length > film2.length
GROUP BY film1.title, film1.length
HAVING COUNT(film2.film_id) > (SELECT COUNT(*) FROM film) / 2
ORDER BY length ASC;

-- 3. Use a subquery to display all actors who appear in the film "Alone Trip".
SELECT film_id FROM film WHERE title = "Alone Trip"; -- helps me building the subquery if i first watch it as a normal query

SELECT 
    actor_id, CONCAT(first_name, ' ', last_name)
FROM
    actor
WHERE
    actor_id IN (SELECT 
            actor_id
        FROM
            film_actor
        WHERE
            film_id = (SELECT 
                    film_id
                FROM
                    film
                WHERE
                    title = 'Alone Trip'));
-- **Bonus**:

-- 4. Sales have been lagging among young families, and you want to target family movies for a promotion. 
-- Identify all movies categorized as family films. 
SELECT name FROM category;

SELECT 
    film_id, title
FROM
    film
WHERE
    film_id IN (SELECT 
            film_id
        FROM
            film_category
        WHERE
            category_id = (SELECT 
                    category_id
                FROM
                    category
                WHERE
                    name = 'Family'));
                    
                    

-- 5. Retrieve the name and email of customers from Canada using both subqueries and joins. To use joins, 
-- you will need to identify the relevant tables and their primary and foreign keys.

-- only subqueries
SELECT 
    *
FROM
    address;
SELECT 
    *
FROM
    country;
SELECT 
    CONCAT(first_name, ' ', last_name), email
FROM
    customer
WHERE
    address_id IN (SELECT 
            address_id
        FROM
            address
        WHERE
            city_id IN (SELECT 
                    city_id
                FROM
                    city
                WHERE
                    country_id IN (SELECT 
                            country_id
                        FROM
                            country
                        WHERE
                            country = 'Canada')));
                            
-- using a mix of both joins and subqueries

SELECT 
    c.first_name, c.last_name, c.email
FROM
    customer c
        CROSS JOIN
    address a ON c.address_id = a.address_id
        JOIN
    city ci ON a.city_id = ci.city_id
        JOIN
    country co ON ci.country_id = co.country_id
WHERE
    co.country_id IN (SELECT 
            country_id
        FROM
            country
        WHERE
            country = 'Canada');
            
-- 6. Determine which films were starred by the most prolific actor in the Sakila database. A prolific actor is defined
--  as the actor who has acted in the most number of films.
--  First, you will need to find the most prolific actor and then use that actor_id to find the different films that he or 
--  she starred in.
SELECT 
    title
FROM
    film
WHERE
    film_id IN (SELECT 
            film_id
        FROM
            film_actor
        WHERE
            actor_id = (SELECT 
                    actor_id
                FROM
                    (SELECT 
                        actor_id, COUNT(film_id) AS film_count
                    FROM
                        film_actor
                    GROUP BY actor_id
                    ORDER BY film_count DESC
                    LIMIT 1) AS profilic_actor));

-- 7. Find the films rented by the most profitable customer in the Sakila database. You can use the customer and payment 
-- tables to find the most profitable customer, i.e., the customer who has made the largest sum of payments.
SELECT 
    f.title
FROM
    film f
        JOIN
    inventory i ON f.film_id = i.film_id
        JOIN
    rental r ON i.inventory_id = r.inventory_id
WHERE
    r.customer_id = (SELECT 
            customer_id
        FROM
            (SELECT 
                customer_id, SUM(amount) AS total_payment
            FROM
                payment
            GROUP BY customer_id
            ORDER BY total_payment DESC
            LIMIT 1) AS profitable_customer);


-- 8. Retrieve the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount
--  spent by each client. You can use subqueries to accomplish this.
-- this exercise really feeling like a final boss query

-- lets break down this big guy,first we can see that is actually easy to get the total spent for each customer id by grouping and suming.
SELECT customer_id ,SUM(amount) AS total_amount_spent FROM payment GROUP BY customer_id;

-- but we want to know the average spending across all the customers,so thats why we do the subquery which actually only gets all the averages we got from each customer_id and make an average from that.

SELECT AVG(total_amount_spent) FROM (SELECT SUM(amount) as total_amount_spent FROM payment GROUP BY customer_id) as subquery_for_avg;

-- so to wrap everything we just have to make sure that we use the second query as a condition to the first query to only get the customers that spent more than the AVG of the total_amount_spent of everybody together.

SELECT 
    customer_id, SUM(amount) AS total_amount_spent
FROM
    payment
GROUP BY customer_id
HAVING total_amount_spent > (SELECT 
        AVG(total_amount_spents)
    FROM
        (SELECT 
            SUM(amount) AS total_amount_spents
        FROM
            payment
        GROUP BY customer_id) AS subquery_for_avg);
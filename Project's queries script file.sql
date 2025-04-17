
#Q1. Find the total number of products sold by each store along with the store name.


SELECT 
    stores.store_name,
    SUM(order_items.quantity) AS Number_of_products_sold
FROM
    orders
        JOIN
    stores ON orders.store_id = stores.store_id
        JOIN
    order_items ON order_items.order_id = orders.order_id
GROUP BY stores.store_name;


#Q2. Calculate the cumulative sum of quantities sold for each product over time.

SELECT 
    products.product_name, 
    orders.order_date, 
    order_items.quantity, 
    SUM(order_items.quantity) OVER (
        PARTITION BY products.product_name 
        ORDER BY orders.order_date
    ) AS Running_sum_of_quantities
FROM 
    products 
JOIN 
    order_items 
    ON products.product_id = order_items.product_id 
JOIN 
    orders 
    ON orders.order_id = order_items.order_id;




#Q3.Find the product with the highest total sales (quantity * price) for each category.

WITH k AS (
    SELECT 
        categories.category_name, 
        products.product_id, 
        products.product_name, 
        SUM(order_items.quantity * order_items.list_price) AS total_sales
    FROM 
        products 
    JOIN 
        categories 
        ON products.category_id = categories.category_id 
    JOIN 
        order_items 
        ON order_items.product_id = products.product_id 
    GROUP BY 
        1, 2, 3
), 

P AS (
    SELECT 
        *, 
        DENSE_RANK() OVER (
            PARTITION BY category_name 
            ORDER BY total_sales DESC
        ) AS RNK 
    FROM k
) 

SELECT * 
FROM P 
WHERE RNK = 1;




#Q4. Find the customer who spent the most money on orders.


SELECT 
    customers.customer_id,
    CONCAT(customers.first_name,
            ' ',
            customers.last_name) Full_Name,
    SUM(order_items.quantity * order_items.list_price) Money_spent
FROM
    orders
        JOIN
    customers ON orders.customer_id = customers.customer_id
        JOIN
    order_items ON order_items.order_id = orders.order_id
GROUP BY 1 , 2
ORDER BY Money_spent DESC
LIMIT 1;




#Q5.Find the highest-priced product for each category name


WITH k AS (
    SELECT 
        categories.category_name, 
        products.product_id, 
        products.product_name, 
        products.list_price, 
        DENSE_RANK() OVER (
            PARTITION BY categories.category_name 
            ORDER BY products.list_price DESC
        ) AS RNK
    FROM 
        categories 
    JOIN 
        products 
        ON categories.category_id = products.category_id
)
SELECT * 
FROM k 
WHERE RNK = 1;



#Q6. Find the total number of orders placed by each customer per store.



SELECT 
    customers.customer_id,
    CONCAT(customers.first_name,
            ' ',
            customers.last_name) AS Full_Name,
    stores.store_id,
    stores.store_name,
    COUNT(orders.order_id) AS Total_Number_of_Orders
FROM
    customers
        LEFT JOIN
    orders ON customers.customer_id = orders.customer_id
        JOIN
    stores ON stores.store_id = orders.store_id
GROUP BY 1 , 2 , 3 , 4;



#Q7. Find the names of staff members who have not made any sales.



SELECT 
    staff_id, CONCAT(first_Name, ' ', last_name) AS Full_Name
FROM
    Staffs
WHERE
    staff_id NOT IN (SELECT DISTINCT
            staff_id
        FROM
            orders);



#Q8. Find the top 3 most sold products in terms of quantity.



SELECT 
    products.product_id,
    products.product_name,
    SUM(order_items.quantity) AS Quantities_Sold
FROM
    products
        JOIN
    order_items ON products.product_id = order_items.product_id
GROUP BY 1 , 2
ORDER BY Quantities_Sold DESC
LIMIT 3;



#Q9. Find the median value of the price list.



WITH k AS (
    SELECT 
        list_price, 
        ROW_NUMBER() OVER (ORDER BY list_price) AS rnk, 
        COUNT(*) OVER() AS n 
    FROM products
) 

SELECT 
    CASE
        WHEN n % 2 = 0 THEN (
            SELECT AVG(list_price) 
            FROM k 
            WHERE rnk IN (n / 2, (n / 2) + 1)
        )
        ELSE (
            SELECT list_price 
            FROM k 
            WHERE rnk = (n + 1) / 2
        )
    END AS MEDIAN
FROM k
LIMIT 1;




#Q10. List all products that have never been ordered.



SELECT 
    products.product_id, products.product_name
FROM
    products
WHERE
    NOT EXISTS( SELECT 
            *
        FROM
            order_items
        WHERE
            order_items.product_id = products.product_id);




#Q11. List the names of staff members who have made more sales than the average number of sales by all staff members.

WITH k AS (
    SELECT 
        staffs.staff_id, 
        CONCAT(staffs.first_name, " ", staffs.last_name) AS Full_Name, 
        COALESCE(SUM(order_items.quantity * order_items.list_price), 0) AS SALES
    FROM staffs LEFT JOIN orders 
    ON orders.staff_id = staffs.staff_id 
    LEFT JOIN order_items
    ON order_items.order_id = orders.order_id 
    GROUP BY 1, 2
) 
SELECT * FROM k WHERE SALES > (SELECT AVG(SALES) FROM k);








#Q12. Identify the customers who have ordered all types of products (i.e.,from every category).



WITH k AS (
    SELECT customers.customer_id, CONCAT(customers.first_name, " ", customers.last_name)
    AS Full_Name, COUNT(DISTINCT products.category_id)
    AS Category_count 
    FROM customers JOIN orders
    ON customers.customer_id = orders.customer_id 
    JOIN order_items 
    ON order_items.order_id = orders.order_id 
    JOIN products 
    ON products.product_id = order_items.product_id 
    GROUP BY 1, 2
) 
SELECT * FROM k 
HAVING Category_count = (SELECT COUNT(*) FROM categories);



















































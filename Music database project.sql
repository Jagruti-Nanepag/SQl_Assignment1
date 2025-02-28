 SELECT * FROM employee;
-- Q1: Who is the senior most employee based on job title?
 Select title,first_name,last_name from employee order by levels desc limit 1 ; 
-- Q2: Which countries have the most Invoices?
 SELECT count(*) as c, billing_country from invoice group by billing_country order by c desc limit 1;
-- Q3: What are top 3 values of total invoice?
 SELECT * FROM INVOICE ORDER BY TOTAL DESC LIMIT 3;
-- Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
-- Write a query that returns one city that has the highest sum of invoice totals. 
-- Return both the city name & sum of all invoice totals
SELECT BILLING_CITY, SUM(TOTAL) AS total_invoice FROM INVOICE GROUP BY BILLING_CITY ORDER BY total_invoice DESC;
SELECT c.City, SUM(i.Total) AS Total_Sales
FROM Customer c
JOIN Invoice i ON c.Customer_Id = i.Customer_Id
GROUP BY c.City
ORDER BY Total_Sales DESC
LIMIT 1;
-- Who is the best customer? The customer who has spent the most money will be declared the best customer. 
-- Write a query that returns the person who has spent the most money.
SELECT Customer_Id, First_Name, Last_Name 
FROM Customer 
WHERE Customer_Id = (
    SELECT Customer_Id 
    FROM Invoice 
    GROUP BY Customer_Id 
    ORDER BY SUM(Total) DESC 
    LIMIT 1
);

SELECT C.CUSTOMER_ID,C.FIRST_NAME,C.LAST_NAME, SUM(I.TOTAL) AS MONEY FROM CUSTOMER AS C JOIN INVOICE AS I ON C.CUSTOMER_ID = I.CUSTOMER_ID GROUP BY C.CUSTOMER_ID ORDER BY MONEY DESC LIMIT 1;
-- Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
-- Return your list ordered alphabetically by email starting with A.
-- SELECT C.FIRST_NAME,C.LAST_NAME, C.EMAIL, G.GENRE_ID,G.NAME FROM CUSTOMER AS C 
SELECT DISTINCT EMAIL,FIRST_NAME,LAST_NAME FROM CUSTOMER JOIN INVOICE ON CUSTOMER.CUSTOMER_ID = INVOICE.CUSTOMER_ID
JOIN INVOICE_LINE ON INVOICE_LINE.INVOICE_ID=INVOICE.INVOICE_ID WHERE TRACK_ID IN (SELECT track_id FROM track
JOIN genre ON track.genre_id = genre.genre_id
WHERE genre.name LIKE 'Rock') ORDER BY EMAIL;


/* Method 2 */

SELECT DISTINCT email AS Email,first_name AS FirstName, last_name AS LastName, genre.name AS Name
FROM customer
JOIN invoice ON invoice.customer_id = customer.customer_id
JOIN invoice_line ON invoice_line.invoice_id = invoice.invoice_id
JOIN track ON track.track_id = invoice_line.track_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
ORDER BY email;

-- Let's invite the artists who have written the most rock music in our dataset. 
-- Write a query that returns the Artist name and total track count of the top 10 rock bands. *
SELECT ARTIST.ARTIST_ID,ARTIST.name,COUNT(ARTIST.ARTIST_ID) AS SONGS FROM ARTIST JOIN ALBUM ON ARTIST.ARTIST_ID = ALBUM.ARTIST_ID
JOIN TRACK ON ALBUM.ALBUM_ID = TRACK.ALBUM_ID WHERE TRACK_ID IN 
(SELECT track_id FROM track
JOIN genre ON track.genre_id = genre.genre_id
WHERE genre.name LIKE 'Rock') GROUP BY ARTIST.ARTIST_ID ORDER BY  SONGS DESC LIMIT 10;

SELECT artist.artist_id, artist.name,COUNT(artist.artist_id) AS number_of_songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY number_of_songs DESC
LIMIT 10;

-- Return all the track names that have a song length longer than the average song length. 
-- Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */
SELECT NAME,MILLISECONDS FROM TRACK WHERE MILLISECONDS >
(SELECT ROUND(AVG(MILLISECONDS),2) AS "SONG LENGTH" FROM TRACK) 
ORDER BY MILLISECONDS DESC;

 -- Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */
 
-- Steps to Solve: First, find which artist has earned the most according to the InvoiceLines. Now use this artist to find 
-- which customer spent the most on this artist. For this query, you will need to use the Invoice, InvoiceLine, Track, Customer, 
-- Album, and Artist tables. Note, this one is tricky because the Total spent in the Invoice table might not be on a single product, 
-- so you need to use the InvoiceLine table to find out how many of each product was purchased, and then multiply this by the price
-- for each artist.
WITH SELLING_ARTIST AS( select ARTIST.ARTIST_ID AS ARTIST_ID,ARTIST.NAME AS ARTIST_NAME, SUM(INVOICE_LINE.UNIT_PRICE * INVOICE_LINE.QUANTITY) AS TOTAL_AMOUNT
FROM INVOICE_LINE  JOIN  TRACK ON INVOICE_LINE.TRACK_ID=TRACK.TRACK_ID JOIN ALBUM ON ALBUM.ALBUM_ID = TRACK.ALBUM_ID JOIN ARTIST ON ARTIST.ARTIST_ID =
ALBUM.ARTIST_ID GROUP BY 1 ORDER BY 3 DESC) SELECT * FROM SELLING_ARTIST;

WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON invoice_line.track_id =track.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)

SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

-- : We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
-- with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
-- the maximum number of purchases is shared return all Genres.
WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1


-- Write a query that determines the customer that has spent the most on music for each country. 
-- Write a query that returns the country along with the top customer and how much they spent. 
-- For countries where the top amount spent is shared, provide all customers who spent this amount. 

WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1





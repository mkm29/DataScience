**I chose Denver as the city**


# What's the most expensive listing?
  * It is important to take a look at the data first, as sorting by only the price can lead to misleading results: 9 listings share the top price. 
  So lets include the cleaning fee and security deposit to get a total price. If we do not specify any contraints, then the topp listing returned has no reviews, so this would be
  quite risky (as it is the most expensive listing), so we add this contraint. Two listings share this total price. 

## SQL  

SELECT
	*,
	COALESCE(CAST(cleaning_fee as NUMERIC)::integer,0) as cleaning_fee,
	COALESCE(CAST(security_deposit as NUMERIC)::integer,0) as deposit,
	COALESCE(CAST((cleaning_fee + security_deposit + price) as NUMERIC)::integer,0) as total_price
FROM
	den_listings
WHERE
	number_of_reviews > 0
ORDER BY
	total_price DESC
LIMIT 2;


## Interpretation

  * Both cost $9,999 a night, with the deposit plus cleaning fee it will run you $10,574
  * Quick response time
  * One is a super host the other is not
  * Both have 3 listings
  * Neither host is verified
  * One accommodates 4
    * Has 1 bedroom, 2 bathrooms
  * The other accommodates 8
    * Has 3 bedrooms, 1 bath
  * Both are "quiet" areas: no partying!
  * The larger one has perfect ratings across the board, the other has near perfect
  * The larger one gets 3.89 reviews a month, the other gets 3.85


# What neighborhoods seem to be the most popular?

  * The first question I have is how is "popular" defined? I take it as the average number of reviews.


## SQL

SELECT
	neighbourhood, ROUND(AVG(number_of_reviews),1) as avg_reviews
FROM
	den_listings
GROUP BY
	neighbourhood
ORDER BY
	avg_reviews DESC
LIMIT
	10;



# What time of year is the cheapest time to go to your city?

  * Again, define "time": day, week, month?  I will compute daily.


## SQL

SELECT
	calender_date, ROUND(AVG(CAST(price as NUMERIC)),2) as avg_price
FROM
	den_calendar
GROUP BY
	calender_date
ORDER BY
	avg_price								
LIMIT
	10;




## Interpretation

  * The cheapest is on October 18, 2019 ($102.49), but it is interesting to note that of the top 10 lowest prices, October is listed 6 times, November 3 and December once. 
  This information leads me to believe that October would be the best month to visit Denver (in terms of cost). We can validate this:



### SQL

SELECT
	ROUND(AVG(CAST(price as NUMERIC)),2) as avg_price, EXTRACT(MONTH FROM calender_date) as month
FROM
	den_calendar
GROUP BY
	month
ORDER BY
	avg_price;

  * So according to this, November, December and January are actually the cheapest (be average). Note that the average is sensitive to outliers, so creating a median function
  might be better here. Maybe there are more listings during these months, so supply and demand would decrease the price. 



#  What about the busiest? 

## SQL


SELECT
	EXTRACT(WEEK FROM review_date) as week, COUNT(*) as num_reviews
FROM
	den_reviews
GROUP BY
	week
ORDER BY
	num_reviews DESC;

## Interpretation

  * So March and April appear to have the most reviews.

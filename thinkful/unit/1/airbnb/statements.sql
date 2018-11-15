
# get the most expensive listing
# then get the average score

# number of reviews (join)




SELECT
	*
FROM
	den_listings
ORDER BY
	price DESC
LIMIT
	1;




# what are the top 5 neighbourhoods by average score?

SELECT
	neighbourhood, AVG(review_scores_rating) as average_score
FROM
	den_listings
GROUP BY
	neighbourhood
ORDER BY
	average_score DESC
LIMIT
	5;


# most expensive neighbourhoods?
SELECT
	neighbourhood, AVG(price) as average_price
FROM
	den_listings
GROUP BY
	neighbourhood
ORDER BY
	average_price DESC
LIMIT
	5;
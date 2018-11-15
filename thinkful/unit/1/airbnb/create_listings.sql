BEGIN TRANSACTION;
DROP TABLE IF EXISTS sfo_listings;
CREATE TABLE den_listings (
	id BIGINT,
	listing_url TEXT,
	scrape_id BIGINT,
	last_scraped DATE,
	name TEXT,
	summary TEXT,
	space TEXT,
	description TEXT,
	experiences_offered TEXT,
	neighborhood_overview TEXT,
	notes TEXT,
	transit TEXT,
	access TEXT,
	interaction TEXT,
	house_rules TEXT,
	thumbnail_url TEXT,
	medium_url TEXT,
	picture_url TEXT,
	xl_picture_url TEXT,
	host_id BIGINT,
	host_url TEXT,
	host_name TEXT,
	host_since DATE,
	host_location TEXT,
	host_about TEXT,
	host_response_time TEXT,
	host_response_rate TEXT,
	host_acceptance_rate TEXT,
	host_is_superhost BOOLEAN,
	host_thumbnail_url TEXT,
	host_picture_url TEXT,
	host_neighbourhood TEXT,
	host_listings_count SMALLINT,
	host_total_listings_count SMALLINT,
	host_verifications TEXT,
	host_has_profile_pic BOOLEAN,
	host_identity_verified BOOLEAN,
	street TEXT,
	neighbourhood TEXT,
	neighbourhood_cleansed TEXT,
	neighbourhood_group_cleansed TEXT,
	city TEXT,
	state TEXT,
	zipcode TEXT,
	market TEXT,
	smart_location TEXT,
	country_code TEXT,
	country TEXT,
	latitude REAL,
	longitude REAL,
	is_location_exact BOOLEAN,
	property_type TEXT,
	room_type TEXT,
	accommodates SMALLINT,
	bathrooms NUMERIC(2,0),
	bedrooms NUMERIC(2,0),
	beds NUMERIC(2,0),
	bed_type TEXT,
	amenities TEXT[],
	square_feet SMALLINT,
	price MONEY,
	weekly_price MONEY,
	monthly_price MONEY,
	security_deposit MONEY,
	cleaning_fee MONEY,
	guests_included SMALLINT,
	extra_people MONEY,
	minimum_nights SMALLINT,
	maximum_nights INTEGER,
	calendar_updated TEXT,
	has_availability BOOLEAN,
	availability_30 SMALLINT,
	availability_60 SMALLINT,
	availability_90 SMALLINT,
	availability_365 SMALLINT,
	calendar_last_scraped DATE,
	number_of_reviews SMALLINT,
	first_review DATE,
	last_review DATE,
	review_scores_rating REAL,
	review_scores_accuracy SMALLINT,
	review_scores_cleanliness SMALLINT,
	review_scores_checkin SMALLINT,
	review_scores_communication SMALLINT,
	review_scores_location SMALLINT,
	review_scores_value SMALLINT,
	requires_license BOOLEAN,
	license TEXT,
	jurisdiction_names TEXT,
	instant_bookable BOOLEAN,
	is_business_travel_ready BOOLEAN,
	cancellation_policy TEXT,
	require_guest_profile_picture BOOLEAN,
	require_guest_phone_verification BOOLEAN,
	calculated_host_listings_count SMALLINT,
	reviews_per_month REAL
);
COMMIT;
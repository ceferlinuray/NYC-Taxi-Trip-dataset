# NYC-Taxi-Trip-dataset
This project analyzes New York City Yellow Taxi trip data for October 2019 using PostgreSQL. The goal is to explore trip patterns, fare amounts, tips, payment methods, trip durations, and pickup-location performance through SQL-based analysis.

The project demonstrates practical SQL skills and the ability to answer business questions using real-world transportation data.

Tools and Technologies

Database: PostgreSQL

Language: SQL

Techniques: Aggregations, subqueries, CTEs, window functions, date and time analysis, conditional logic, and percentile analysis

Key Columns:

•	tpep_pickup_datetime: The date and time when the meter was activated.

•	tpep_dropoff_datetime: The date and time when the meter was turned off.

•	Passenger_count: The number of passengers in the vehicle, as entered by the driver.

•	Trip_distance: The distance of the trip in miles, as recorded by the taximeter.

•	PULocationID: TLC Taxi Zone where the meter was engaged.

•	DOLocationID: TLC Taxi Zone where the meter was disengaged.


 SQL Analysis

1. Basic Analysis and Data Quality

Count total trips and determine the dataset's time coverage.

Check missing values in important fields.

Identify negative fares, zero-distance trips, and invalid timestamps.

Calculate total recorded charges, average fare, and average tip.

Analyze trip volume by payment method, pickup hour, and weekday.

Identify trips with high recorded amounts and locations with at least 1,000 trips.

2. Subqueries and CTEs

Find trips with total amounts above the overall average.

Compare pickup-location trip counts with the average location trip count.

Identify payment methods with above-average trip amounts.

Compare individual trip amounts with the average for their payment method.

Find pickup locations with above-average fares.

Summarize location performance and identify high-charge or high-distance locations.

Classify trips into short, medium, and long distance categories.

3. Advanced Analysis and Window Functions

Rank pickup locations by trip volume.

Rank payment methods by total recorded charges.

Calculate each pickup location's percentage contribution to trips.

Calculate running totals of recorded charges.

Compare average tips across payment methods.

Calculate the distribution of trip durations.

Compare fare per mile across payment methods.

Identify potential outliers using the 95th percentile of total amount.

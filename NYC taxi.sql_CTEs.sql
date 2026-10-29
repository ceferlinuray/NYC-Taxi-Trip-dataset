--Create a CTE that calculates the number of trips and total recorded amount for each pickup location.
with location_summary as ( select
 pulocationid,
        count(*) as trip_count,
        sum(total_amount) as total_charges
    from taxi_trips
    where pulocationid is not null
    group by pulocationid
)
select
    pulocationid,
    trip_count,
    round(total_charges, 2) as total_charges
from location_summary
order by trip_count desc;


--Using a CTE, find the 10 pickup locations with the highest trip counts.
with location_count as (
select
        pulocationid,
        count(*) as trip_count
    from taxi_trips
    where pulocationid is not null
    group by pulocationid
)

select  * from location_count
order by trip_count desc
limit 10;

--Create a CTE for average trip duration by pickup hour, then return the busiest hours with their average durations.
with hourly_status as
(
select extract(hour from tpep_pickup_datetime) as pickup_hour,
count(*) trip_count,
avg(extract(epoch from (
            tpep_dropoff_datetime - tpep_pickup_datetime
        )) / 60)  trip_duration
from taxi_trips
where tpep_pickup_datetime is not null
      and tpep_dropoff_datetime is not null
      and tpep_dropoff_datetime >= tpep_pickup_datetime
    group by extract(hour from tpep_pickup_datetime))

select   pickup_hour,trip_count,round(trip_duration::numeric, 2) as avg_duration_minutes from hourly_status
order by trip_count desc;

--Calculate each payment method's trip count and average total amount, then return methods with more than 1,000 trips.
with payment_method_analysis as (
select payment_type, count(*) trip_count,avg(total_amount) avg_amount from taxi_trips
group by payment_type
)
select payment_type,round(trip_count,2) trip_count,avg_amount from payment_method_analysis 
where trip_count>1000
order by trip_count desc;

--Use a CTE to identify trips with unusually high total amounts, defined as amounts greater than twice the overall average
with avg_amount as (
    select avg(total_amount) as average_amount
    from taxi_trips
)
select
    tpep_pickup_datetime,
    trip_distance,
    fare_amount,
    total_amount
from taxi_trips
where total_amount > (
    select average_amount * 2
    from avg_amount
)
order by total_amount desc;

--Calculate total recorded charges by pickup location and identify locations contributing at least 5% of the overall amount.
with location_summary as ( select
 pulocationid,
        sum(total_amount) as total_charges
    from taxi_trips
    where pulocationid is not null
    group by pulocationid
), 
overall as (
select sum(total_amount)  overall_amount from taxi_trips
)

select pulocationid,total_charges from location_summary
where total_charges>(select overall_amount*0.05 from overall) 
order by total_charges desc;

--Find pickup locations where average trip distance is above the overall average distance.
with location_distance as (
    select
        pulocationid,
        avg(trip_distance) as avg_distance
    from taxi_trips
    where pulocationid is not null
      and trip_distance is not null
    group by pulocationid
)
select
    pulocationid,
    round(avg_distance, 2) as avg_distance
from location_distance
where avg_distance > (
    select avg(trip_distance)
    from taxi_trips
    where trip_distance is not null
)
order by avg_distance desc;

--Create a CTE that classifies trips as Short, Medium, or Long based on distance, then count trips in each category. Use under 2 miles, 2–5 miles, and over 5 miles.
with classified_trips as (
select case
            when trip_distance < 2 then 'Short'
            when trip_distance <= 5 then 'Medium'
            else 'Long'
			end as distance_category
			from taxi_trips
            where trip_distance>0
)
select distance_category, count(*) as trip_count
from classified_trips
group by distance_category
order by trip_count desc;
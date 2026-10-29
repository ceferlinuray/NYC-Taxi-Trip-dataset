--Rank pickup locations by their number of trips.
with location_counts as (
    select
        pulocationid,
        count(*) as trip_count
    from taxi_trips
    where pulocationid is not null
    group by pulocationid
)
select pulocationid,trip_count,
rank() over(order by trip_count desc) as location_rank
from location_counts
order by location_rank;

--Return the top five pickup locations by trip count using a window function.
with location_counts as (
    select
        pulocationid,
        count(*) as trip_count
    from taxi_trips
    where pulocationid is not null
    group by pulocationid
),
ranked_locations as (
    select
        *,
        dense_rank() over (order by trip_count desc) as location_rank
    from location_counts
)
select
    pulocationid,
    trip_count,
    location_rank
from ranked_locations
where location_rank <= 5
order by location_rank;


--Rank payment methods by total recorded amount.
select payment_type, round(sum(total_amount),2),
rank() over(order by sum(total_amount) desc) type_rank
from taxi_trips
group by payment_type
order by type_rank;

--Calculate each pickup location's percentage contribution to all trips.

with location_counts as (
    select
        pulocationid,
        count(*) as trip_count
    from taxi_trips
    where pulocationid is not null
    group by pulocationid
)
select
    pulocationid,
    trip_count,
    round(
        100.0 * trip_count
        / nullif(sum(trip_count) over (), 0),
        2
    ) as percentage_of_location_trips
from location_counts
order by trip_count desc;

--Calculate the running total of recorded amounts by pickup timestamp.
select
    tpep_pickup_datetime,
    total_amount,
    sum(total_amount) over (
        order by tpep_pickup_datetime
        rows between unbounded preceding and current row
    ) as running_total
from taxi_trips
where tpep_pickup_datetime is not null
  and total_amount is not null
order by tpep_pickup_datetime;


--Which payment method has the highest average tip amount, considering only trips with positive tips?
select
    payment_type,
    count(*) as tipped_trips,
    round(avg(tip_amount), 2) as avg_tip
from taxi_trips
where payment_type is not null
  and tip_amount > 0
group by payment_type
order by avg(tip_amount) desc
limit 1;

--What percentage of trips are completed in under 10 minutes, between 10 and 30 minutes, and over 30 minutes?
with trip_durations as (
    select
        extract(epoch from (
            tpep_dropoff_datetime - tpep_pickup_datetime
        )) / 60 as duration_minutes
    from taxi_trips
    where tpep_pickup_datetime is not null
      and tpep_dropoff_datetime is not null
      and tpep_dropoff_datetime >= tpep_pickup_datetime
),
duration_categories as (
    select
        case
            when duration_minutes < 10 then 'Under 10 minutes'
            when duration_minutes <= 30 then '10 to 30 minutes'
            else 'Over 30 minutes'
        end as duration_category
    from trip_durations
)
select
    duration_category,
    count(*) as trip_count,
    round(
        100.0 * count(*) / nullif(sum(count(*)) over (), 0),
        2
    ) as percentage
from duration_categories
group by duration_category
order by trip_count desc;


--Fare per mile by payment method
select
    payment_type,
    count(*) as trip_count,
    round(avg(fare_amount), 2) as avg_fare,
    round(avg(trip_distance), 2) as avg_distance,
    round(
        sum(fare_amount) / nullif(sum(trip_distance), 0),
        2
    ) as fare_per_mile
from taxi_trips
where payment_type is not null
  and fare_amount is not null
  and trip_distance > 0
group by payment_type
order by fare_per_mile desc;

--Identify potential outlier trips using the 95th percentile of total amount.
with percentile_threshold as (
    select
        percentile_cont(0.95) within group (
            order by total_amount
        ) as p95_amount
    from taxi_trips
    where total_amount is not null
)
select
    t.tpep_pickup_datetime,
    t.trip_distance,
    t.fare_amount,
    t.total_amount,
    round(p.p95_amount::numeric, 2) as p95_threshold
from taxi_trips t
cross join percentile_threshold p
where t.total_amount > p.p95_amount
order by t.total_amount desc;
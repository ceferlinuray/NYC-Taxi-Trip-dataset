

create table taxi_trips (
    vendorid integer,
    tpep_pickup_datetime timestamp,
    tpep_dropoff_datetime timestamp,
    passenger_count integer,
    trip_distance numeric(10,2),
    ratecodeid integer,
    store_and_fwd_flag varchar(5),
    pulocationid integer,
    dolocationid integer,
    payment_type integer,
    fare_amount numeric(10,2),
    extra numeric(10,2),
    mta_tax numeric(10,2),
    tip_amount numeric(10,2),
    tolls_amount numeric(10,2),
    improvement_surcharge numeric(10,2),
    total_amount numeric(10,2),
    congestion_surcharge numeric(10,2)
);


--How many taxi trips are recorded, and what period does the dataset cover?
select
    count(*) as total_trips,
    min(tpep_pickup_datetime) as first_pickup,
    max(tpep_dropoff_datetime) as last_dropoff
from taxi_trips;

--Are important fields missing, and how many records are affected?
select
    count(*) as total_rows,
    count(*) filter (
        where tpep_pickup_datetime is null
    ) as missing_pickup,
    count(*) filter (
        where tpep_dropoff_datetime is null
    ) as missing_dropoff,
    count(*) filter (
        where fare_amount is null
    ) as missing_fare,
    count(*) filter (
        where total_amount is null
    ) as missing_total
from taxi_trips;

--How many records have negative fares, zero distances, or drop-off times before pickup?
select count(*) filter
(where fare_amount<0) as negative_fare,
count(*) filter 
(where trip_distance=0) as zero_distance,
count(*) filter (where tpep_pickup_datetime>tpep_dropoff_datetime) from taxi_trips;

--How much recorded revenue did taxi trips generate, and what was the average trip value?
select count(*) number_of_taxi_trips,
    round(sum(total_amount)::numeric, 2) as total_amount,
    round(avg(total_amount)::numeric, 2) as avg_trip_amount,
    round(avg(fare_amount)::numeric, 2) as avg_fare,
    round(avg(tip_amount)::numeric, 2) as avg_tip
from taxi_trips;

--Which payment method is used most frequently, and which generates the highest total recorded amount?
select payment_type,count(*), round(sum(total_amount)::numeric, 2) as total_amount from taxi_trips
group by payment_type
order by count(*) desc;

--At what time of day are the most trips recorded?
select extract(hour from tpep_pickup_datetime) pickup_hour,count(*) trip_count from taxi_trips
group by pickup_hour
order by trip_count desc;

--Which days of the week have the highest trip volume and recorded amount?
select trim(TO_CHAR(tpep_pickup_datetime, 'Day')) pickup_day, count(*) trip_count from taxi_trips
group by pickup_day
order by trip_count desc;

--What is the average trip duration, and how many trips last longer than 30 minutes?
select
    round(avg(
            extract(epoch from (
                tpep_dropoff_datetime - tpep_pickup_datetime
            )) / 60
        ), 2)  avg_duration_minutes,
count(*) filter
(where (extract(epoch from (
                tpep_dropoff_datetime - tpep_pickup_datetime
            )) / 60)>30)
from taxi_trips
where tpep_pickup_datetime is not null
  and tpep_dropoff_datetime is not null
  and tpep_dropoff_datetime >= tpep_pickup_datetime;


--Which trips have a recorded total amount above $100?
select
    tpep_pickup_datetime,
    tpep_dropoff_datetime,
    trip_distance,
    fare_amount,
    total_amount
from taxi_trips
where total_amount>100
order by total_amount desc;

--Which pickup locations have at least 1,000 trips?
select pulocationid,count(*) trip_count,sum(total_amount)
from taxi_trips
group by pulocationid
having count(*)>=1000
order by trip_count desc;

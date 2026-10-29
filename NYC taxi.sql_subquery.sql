--Which trips have a total amount higher than the average total amount of all trips?
select tpep_pickup_datetime,tpep_dropoff_datetime,payment_type,total_amount
from taxi_trips where total_amount>(select avg(total_amount) from taxi_trips);

--Which pickup locations have more trips than the average number of trips per pickup location?
select pulocationid,count(*) trip_count
from taxi_trips 
where pulocationid is not null
group by pulocationid
having count(*)>(select 
avg(trip_count) from (select count(*) as trip_count
        from taxi_trips
        where pulocationid is not null
        group by pulocationid
    ) as location_counts)
order by  trip_count desc;

--Which pickup locations have total recorded charges higher than the average total charges per pickup location?
select pulocationid,count(*) trip_count
from taxi_trips 
where pulocationid is not null
group by pulocationid
having count(*)>(select 
avg(trip_count) from (select count(*) as trip_count
        from taxi_trips
        where pulocationid is not null
        group by pulocationid
    ) as location_counts)
order by  trip_count desc;



--Which payment methods have an average trip amount higher than the overall average trip amount? 
select payment_type,avg(total_amount) as avg_trip_amount from taxi_trips
where payment_type is not null
group by payment_type
having  avg(total_amount)>(select avg(total_amount) from taxi_trips)
order by avg_trip_amount desc;

--Which trips have a total amount higher than the average for their payment method?
select t.payment_type,t.total_amount from taxi_trips t
where  t.total_amount>(select avg(t2.total_amount) from taxi_trips  t2
where t.payment_type=t2.payment_type);


--Which pickup locations have a higher average fare than the overall average fare?
select pulocationid,avg(fare_amount) average_fare  from taxi_trips
group by pulocationid 
having avg(fare_amount)>(select avg(fare_amount) from taxi_trips)
order by average_fare desc;


--Pickup locations with more trips than another location that has a higher average fare
select pulocationid, count(*) as trip_count,
    round(avg(fare_amount), 2) as avg_fare from taxi_trips
	 where pulocationid is not null
group by pulocationid
having count(*)> any (select count(*) as trip_count from taxi_trips
	 where pulocationid is not null
group by pulocationid
having avg(fare_amount)>(select avg(fare_amount) from taxi_trips))
order by trip_count desc;





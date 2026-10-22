# Data Cleaning & Integrity Management :

use bike_sharing_analysis ;

-- Q.1  How should duplicate trip records be handled while ensuring a valid ride history ? . 

-- this temperorly disables safe update mode 
set sql_safe_updates = 0 ;

-- Identify and delete duplicate rows keeping only the first instance

with rankedtrips as (
select Trip_ID, 
row_number () over(
partition by Trip_ID ,User_ID ,Bike_ID, Start_Time
order by Trip_ID) as row__number from final_trips_data)

delete from final_trips_data
where Trip_ID in (
select Trip_ID 
from rankedtrips 
where row__number > 1) ;

-- re-enable safe mode update 
set sql_safe_updates = 1 ;



-- Q.2 What is the best approach to handle missing User IDs in the dataset ?

-- Investigation Step: Check Clustering by Station or Hour

select Start_Station_ID , 
extract(hour from Start_Time) as departed_hour , 
count(*) as missing_user_count 
from  final_trips_data 
where User_ID is null 
group by Start_Station_ID , 
extract(hour from Start_Time)
order by missing_user_count desc ; 

-- verification query 
select Ride_Type , 
count(*) as total_rides , 
count(*) - count(User_ID) as missing_user_ids 
from final_trips_data 
group by Ride_Type ;

--  Assign "CASUAL_UNKNOWN" only to casual rides to maintain data clarity and consistency .
set sql_safe_updates = 0 ;

update final_trips_data 
set User_ID='CASUAL_UNKNOWN'
where User_ID is null 
and 
ride_type = 'Casual' ; 

set sql_safe_updates = 1 ;


-- Q.3  What adjustments should be made to correct negative trip durations ?

select Trip_ID , Trip_Duration_Min , count(*) as negative_trip_duration 
from final_trips_data 
where Trip_Duration_Min < 0 
group by Trip_ID , Trip_Duration_Min ;

-- "Data validation performed on Trip_Duration_Min. 
-- Zero negative trip duration records were detected, 
-- confirming timestamp integrity for all logged rides.
-- No data cleaning or deletion was required for this metric."



-- Q.4  How should station names be standardized to avoid inconsistencies in trip aggregation ? 

-- Check for any names that don't match the standard "Station X" pattern :
select * from final_stations_data 
where Station_Name not like 'Station %' ;

-- Ensure no hidden leading/trailing spaces exist :
set sql_safe_updates = 0 ;

update final_stations_data
set Station_Name = trim(Station_Name) ;

set sql_safe_updates = 1 ;
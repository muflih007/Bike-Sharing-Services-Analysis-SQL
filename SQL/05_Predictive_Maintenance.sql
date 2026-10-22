# Predictive Maintenance & Bike Longevity : 
 
 use bike_sharing_analysis ;
 
--  Q.1  What are the most common types of bike issues, and do they vary by season
--    or location?
 
 with issuestats as (
select issue_reported , station_name ,
case 
when month(Maintenance_Date) in (12,1,2) then 'Winter' 
when month(Maintenance_Date) in (3,4,5) then 'Spring'
when month(Maintenance_Date) in (6,7,8) then 'Summer' 
else 'Fall'
end as season ,
count(*) as Incident_Count 
from  final_maintenance_data as m 
join final_trips_data as t 
on m.Bike_ID=t.Bike_ID 
join final_stations_data as s 
on t.Start_Station_ID=s.Station_ID
where Issue_Reported is not null 
group by issue_reported , station_name ,season
),
Top_station as (
select issue_reported , station_name as most_affected_station, 
row_number() over(partition by issue_reported 
order by sum(Incident_Count) desc) as station_rank
from issuestats
group by issue_reported , station_name 
), 
Top_season as (
select issue_reported , season as Peak_Season ,
row_number() over(partition by issue_reported 
order by sum(Incident_Count) desc) as seanson_rank
from issuestats
group by issue_reported , season
), 
overall_count as (
select issue_reported , 
count(*) as Total_Occurances 
from final_maintenance_data
where issue_reported is not null 
group by issue_reported 
 )

select o.issue_reported , 
o.Total_Occurances , 
st. most_affected_station ,
se.Peak_Season 
from overall_count as o 
join Top_station as st 
on o.issue_reported=st.issue_reported and st.station_rank=1
join Top_Season as se 
on o.issue_reported=se.issue_reported and se.seanson_rank=1 
order by o.Total_Occurances desc ;

#Analytical Takeaways :

-- Most Frequent Failure Mode: Flat Tires represent the highest overall maintenance volume (2,586 occurrences), 
-- peaking in Spring—likely driven by post-winter road debris, thaw conditions, and increased spring usage.

-- Component-Specific Seasonality: Brake Wear in Summer: Brake Issues (2,527 occurrences) peak during Summer, 
-- aligning with maximum seasonal rider volume, higher speeds, and increased heat wear.

-- Battery Failures in Fall: Battery Issues (2,440 occurrences) peak in Fall, 
-- signaling capacity loss after heavy summer exposure and cooler temperatures affecting charge efficiency.

-- Chain Wear in Winter: Chain Issues (2,447 occurrences) peak during Winter due to road salt,
--  mud, moisture, and rust accumulation.





-- Q.2 How does maintenance downtime affect bike availability at stations? :
 
with combinedstationbikes as (
    select start_station_id as station_id, bike_id from final_trips_data
    union 
    select end_station_id as station_id, bike_id from final_trips_data
),
stationtotalbikes as (
    select station_id, 
    count(distinct bike_id) as total_engaged_bikes 
    from combinedstationbikes
    group by station_id
), 
lastbikelocation as (
    select 
        t.start_station_id as station_id,
        m.bike_id,
        row_number() over (
            partition by m.bike_id 
            order by t.start_time desc
        ) as rn
    from final_maintenance_data m
    join final_trips_data t on m.bike_id = t.bike_id
),
stationmaintenancebikes as (
    select 
        station_id,
        count(distinct bike_id) as bikes_in_maintanance
    from lastbikelocation
    where rn = 1
    group by station_id 
)
select 
    s.station_name, 
    coalesce(m.bikes_in_maintanance, 0) as bikes_in_maintanance,
    concat(
        round(
            (coalesce(m.bikes_in_maintanance, 0) * 100.0) / nullif(t.total_engaged_bikes, 0), 2
        ), '%'
    ) as fleet_affected
from final_stations_data as s 
join stationtotalbikes as t on s.station_id = t.station_id
left join stationmaintenancebikes as m on s.station_id = m.station_id 
where coalesce(m.bikes_in_maintanance, 0) > 0
order by (coalesce(m.bikes_in_maintanance, 0) * 100.0 / nullif(t.total_engaged_bikes, 0)) desc;                                     



-- Q.3 How does maintenance history correlate with trip characteristics, and can
--     we identify problem trends?

with BikeInfos as (
select Bike_ID , round(avg(Distance_KM),2) as Avg_Trip_Distance , 
round(avg(Trip_Duration_Min),2) as Avg_Drive_Duration
from final_trips_data 
where Bike_ID is not null 
group by  Bike_ID  
), 
MaintananceCount as (
select Bike_ID , count(*) as Maintanance_Count 
from final_maintenance_data 
where Bike_ID is not null 
group by Bike_ID
)

select b.Bike_ID , b.Avg_Trip_Distance ,b.Avg_Drive_Duration ,
coalesce(Maintanance_Count , 0) as Maintanance_Count 
from BikeInfos  as b 
left join MaintananceCount as m 
on b.Bike_ID = m.Bike_ID 
where coalesce(Maintanance_Count , 0) > 0 
order by b.Avg_Trip_Distance desc ,b.Avg_Drive_Duration desc ;

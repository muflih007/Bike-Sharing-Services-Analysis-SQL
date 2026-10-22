# Demand Insights & Peak Usage Analysis : 

use bike_sharing_analysis ;

-- Q.1 How does bike usage fluctuate throughout the day, and how does peak-hour
-- demand vary across users?


with hourly_stats as (
select hour(Start_Time) as hours , 
count(*) as total_trips 
from  final_trips_data 
group by hour(Start_Time)
)

select hours , 
total_trips , 
case 
when total_trips >= avg(total_trips) over() then 'Peak'
else 'Off-peak'
end as Peak_Off_Peak 
from hourly_stats 
order by hours  asc ;

-- Total trip counts across all 24 hours are exceptionally uniform, 
-- ranging narrowly between 2,030 (lowest) and 2,145 (highest) trips per hour.

#Peak Demand Hours:
-- Absolute Peak: 8 AM (2,145 trips) 
-- Mid-Day Sustained Usage: Hours 9 AM to 12 PM
-- Lowest Demand: Midnight (0) and 6 PM (18) . 



-- Q.2 How do weekday and weekend ride patterns differ across different locations?

select * from final_trips_data ;

with ride_patterns as (
select case 
when weekday(Start_Time) between 0 and 4 then 'Weekday'
else 'Weekend' 
end as Day_Type , Trip_Duration_Min
from final_trips_data
)
select day_type , 
count(*) as Total_Rides , 
round(avg(Trip_Duration_Min),4) as Avg_Trip_Duration ,
case 
when day_type='Weekday' then 'Work Commute'
else 'Leisure trips' 
end as Main_Ride_Purpose 
from ride_patterns 
group by day_type 
order by field(day_type , 'Weekday' , 'Weekend') ;


-- Q.3 How does net bike usage vary across stations based on arrivals and departures? :

with departures as (
select Start_Station_ID as Station_ID , 
count(*) as Total_Departures 
from final_trips_data
group by Start_Station_ID),

Arrivals as (
select End_Station_ID  as Station_ID, 
count(*) as Total_Arrivals 
from final_trips_data
group by End_Station_ID ) 

select s.station_name , 
coalesce(d.Total_departures , 0) as Total_Departures ,
coalesce(a.Total_Arrivals , 0) as Total_Arrivals ,
coalesce(a.Total_Arrivals , 0) -coalesce(d.Total_departures , 0)   as Net_Usage
from final_stations_data as s 
left join departures as d on s.Station_ID=d.Station_ID
left join arrivals as a on s.Station_ID=a.Station_ID
order by Net_Usage desc ;


-- Q.4 How do peak-hour trips compare to off-peak trips in terms of duration and distance ? 

with categoriestrips as (
select case 
when  hour(Start_Time) in (7, 8, 9, 16, 17, 18) then 'Peak Hours'
else 'Off-Peak Hours'
end as Time_Period ,
 Trip_Duration_Min , Distance_KM 
 from final_trips_data )
 select Time_Period , 
 round(avg(Trip_Duration_Min),2) as Avg_Trip_Duration ,
 round(avg(Distance_KM),2) as Avg_Distance_Km ,
 case 
 when Time_period='Peak Hours' then 'Commute'
 else 'Leisure'
 end as Primary_Ride_Type 
 from categoriestrips 
 group by Time_period 
 order by field(Time_period , 'Peak Hours' , 'Off-Peak Hours ') ;
 
 #Analytical Takeaways : 
 -- Velocity & Efficiency: Minimal variance in trip distance alongside similar or higher peak
 --  durations typically points to traffic congestion or higher dock-search  delays during
 -- peak hours.
 
 
 
 -- Q.5 Which stations experience peak-hour demand patterns that differ from
--      standard commuter trends?
 
 with StationHourlyTrips as (
 select s.Station_Name , 
 hour(t.Start_Time) as Usage_hours , 
 count(*) as Total_Rides , 
 row_number() over(partition by s.Station_Name 
 order by count(*) desc ) as Rank_num 
 from final_trips_data as t 
 join final_stations_data as s 
 on t.Start_Station_ID=s.Station_ID
 group by s.Station_Name , hour(t.Start_Time)
 )
 select station_name , usage_hours as Peak_Usage_Hours , 
 total_rides as Total_Rides_During_Peak , 
 case 
 when usage_hours not in(7, 8, 9, 17, 18, 19) then 'Yes'
 else 'No'
 end as Unusual_Peak_Pattern 
 from StationHourlyTrips
 where rank_num=1 
 and usage_hours not in (7, 8, 9, 17, 18, 19) 
 order by Total_Rides_During_Peak desc  ; 
 
 #Strategic & Operations Takeaways :
  -- Targeted Nightlife / Afternoon Rebalancing: Stations peaking late at night
  -- (e.g., 10 PM – 2 AM) require evening dock clearance rather than morning stocking, 
 --   preventing midnight dock saturation near entertainment venues.
 
--  Non-Commuter Operations: Midday peak stations (10 AM – 2 PM) often align with shopping -
--  centers, parks, or university hubs and benefit from midday micro-rebalancing runs.
 
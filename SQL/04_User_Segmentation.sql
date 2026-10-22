# User Behavior & Segmentation : 
 
 use bike_sharing_analysis ;
 
 -- Q.1 How does ride behavior differ across user types? 
 
 select Ride_Type , round(avg(Trip_Duration_Min),2) as Avg_Trip_Duration ,
 round(avg(Distance_KM),2) as Avg_Distance , 
 count(*) Total_Rides 
 from final_trips_data 
 group by Ride_Type 
 order by Total_Rides desc ;
 
 
 -- Q.2 Which user segments ride most frequently, and how does this relate to
 --     lifetime engagement ?
 
 select User_ID , Ride_Type ,
 count(*) as Total_Trips , 
 round(sum(Distance_KM),2) as Total_Km 
 from final_trips_data 
 group by User_ID , Ride_Type 
 order by Total_Trips desc 
 limit 10 ;
 
 -- User (4647) takes most Rides 14 and distance covered Above 80 Km's .
 
 
 -- Q.3 How do users vary in their preference for time-of-day travel?
 
 select hour(Start_Time) as Hour_Of_The_Day ,
 Ride_Type , 
 count(*) as Trip_Count 
 from final_trips_data 
 group by hour(Start_Time)  , Ride_Type 
 order by  Hour_Of_The_Day asc , Ride_Type asc  ;
 
 
 #key insights and takeaways from  User Behavior & Segmentation: 
 
 
 -- Commute vs. Leisure Split: Subscribers heavily concentrate trips around peak morning and evening commute windows, 
 -- whereas casual users dominate afternoon and weekend leisure hours.

-- Duration & Distance Alignment: Average trip duration and distance remain strikingly similar across both user types, 
-- indicating that both segments utilize bikes for comparable travel lengths despite differing trip intentions.

-- Core Volume Drivers: Casual riders account for the higher proportion of total volume, making targeted conversion campaigns 
-- (turning high-frequency casuals into subscribers) a prime revenue opportunity.

-- Lifetime Engagement Anchor: A small subset of high-frequency users drives a disproportionate amount of total mileage,
--  representing the core user base with the highest Customer Lifetime Value (LTV).

-- Targeted Retention Priority: Power users identified by total trips and cumulative kilometers should be prioritized for loyalty rewards, 
-- corporate discounts, and churn-prevention programs.

-- Time-Based Fleet Optimization: Morning fleet deployment must prioritize high-capacity docking near business districts and transit hubs 
-- for subscribers, shifting toward parks, venues, and commercial centers for afternoon casual users.
 
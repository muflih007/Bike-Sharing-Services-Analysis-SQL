# Data Exploration & Initial Assessment :

 use bike_sharing_analysis ;
 
 -- Q.1 How does the volume of records in each dataset compare to expected operational usage ? .

with table_counts as (
select 'Bikes' as table_name , count(*) as total_records from final_bikes_data
union all 
select 'Maintenance' as table_name , count(*) as total_records from final_maintenance_data
union all 
select 'Revenue' as table_name , count(*) as total_records from final_revenue_data
union all 
select 'Stations' as table_name , count(*) as total_records  from final_stations_data
union all 
select 'Trips' as table_name , count(*) as total_records from final_trips_data 
union all 
select 'Users' as table_name , count(*) as total_records from final_users_data
union all 
select 'Weather' as table_name , count(*) as total_records from final_weather_data)

select table_name , total_records , 
case 
when table_name='Bikes' and total_records >=1000 then 'Yes'
 when table_name='maintenance'and total_records >=10000 then 'Yes'
 when table_name='Revenue' and total_records >= 5000 then 'Yes'
 when table_name='Stations' and total_records >=200 then 'Yes'
 when table_name='Trips' and total_records >=50000 then 'Yes'
 when table_name='Users' and total_records >=5000 then 'Yes'
 when table_name='Weather' and total_records >=8760 then 'Yes'
 end as Expected_Volume_Verified from table_counts ;
 
 
 -- Q.2  How do missing values in key fields impact the reliability of trip analysis ?.

 with missing_ids as (
 select 'Start_Time' as column_name , count(*) - count(Start_Time) as missing_values ,
 round((count(*) - count(Start_Time)) * 100 /count(*),3) as missing_percentage from final_trips_data 
 union all 
 select 'End_Time' as column_name , count(*) - count(End_Time) as missing_values ,
 round((count(*) - count(End_Time)) * 100 / count(*),3) as missing_percentage from final_trips_data
 union all 
 select 'User_ID' as column_name , count(*) - count(User_ID) as missing_values , 
 round((count(*) - count(User_ID)) * 100 / count(*),3) as missing_percentage from final_trips_data
 ) 
 select column_name , missing_values , missing_percentage ,
 case 
 when missing_percentage >0 then 'High'
 else 'low'
 end as impact_lvl
 from missing_ids ;
 
 
  # Q.3 How are missing User IDs distributed across ride types, and what are the implications ? 
  
  with missing_userids as (
  select Ride_Type , 
  count(case when User_ID is null then 1 end  ) as missing_user_id_count ,
  count(Trip_ID) as total_trips 
  from final_trips_data
  group by Ride_Type
  )
  select Ride_Type , missing_user_id_count , total_trips  , 
  round((missing_user_id_count * 100) / total_trips ,3) as percentage 
  from missing_userids ;

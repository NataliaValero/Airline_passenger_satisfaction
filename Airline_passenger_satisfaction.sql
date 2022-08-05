-- create database
CREATE database airline_data;
USE airline_data;

-- create table

CREATE TABLE airline_passenger_satisfaction
  (
     id                      INT,
     gender                  VARCHAR(10),
     age                     INT,
     customer_type           VARCHAR(20),
     type_of_travel          VARCHAR(20),
     class                   VARCHAR(20),
     flight_distance         INT,
     departure_delay         INT,
     arrival_delay           INT,
     departure_and_arrival   INT,
     ease_of_online_book     INT,
     check_in_service        INT,
     online_boarding         INT,
     gate_location           INT,
     on_board_service        INT,
     seat_comfort            INT,
     leg_room_service        INT,
     cleanliness             INT,
     food_and_drink          INT,
     in_flight_service       INT,
     in_flight_wifi_service  INT,
     in_flight_entertainment INT,
     baggage_handling        INT,
     satisfaction            VARCHAR(50)
  ); 


SELECT * 
FROM airline_passenger_satisfaction;


-- DATA 

-- Customer Satisfaction rate
SELECT Concat(Round(Count(satisfaction) / (SELECT Count(*)
                                           FROM   airline_passenger_satisfaction
                                          ) * 100
                     ), '%') AS 'Satisfied percentage'
FROM   airline_passenger_satisfaction
WHERE  satisfaction = 'Satisfied'; 

-- Customer satisfaction rate (Satisfied and Dissatisfied)
SELECT satisfaction,
       Concat(Round(Count(*) * 100 / Sum(Count(*))
                                       OVER ()), '%') 'Satisfied percentage'
FROM   airline_passenger_satisfaction
GROUP  BY satisfaction; 

-- How many passengers do we have?
SELECT Count(*) AS 'Total Passengers' 
FROM airline_passenger_satisfaction ;

-- How are the passengers distributed?

SELECT gender,
       Count(*)
       AS 'Passengers by gender',
       Concat(Round(Count(*) / (SELECT Count(*)
                                FROM   airline_passenger_satisfaction) * 100),
       '%') AS
       Porcentaje_gender
FROM   airline_passenger_satisfaction
GROUP  BY gender
ORDER  BY porcentaje_gender DESC; 

-- Age split

SELECT CASE
         WHEN age < 18 THEN 'Under 18'
         WHEN age BETWEEN 18 AND 30 THEN '18-30'
         WHEN age BETWEEN 31 AND 59 THEN '31-59'
         ELSE '60 & Above'
       END
       AS Age_Split,
       Count(*)
       AS 'Total by age range',
       Concat(Round(Count(*) / (SELECT Count(*)
                                FROM   airline_passenger_satisfaction) * 100),
       '%') AS
       percentage_age
FROM   airline_passenger_satisfaction
GROUP  BY age_split
ORDER  BY percentage_age; 



-- Customer Type
SELECT customer_type,
       Count(*)
       AS 'Total by category',
       Concat(Round(Count(*) / (SELECT Count(*)
                                FROM   airline_passenger_satisfaction) * 100),
       '%') AS
       percentage_category
FROM   airline_passenger_satisfaction
GROUP  BY customer_type
ORDER  BY percentage_category DESC;

-- Purpose
SELECT type_of_travel,
       Count(*)
       AS 'Total por type of travel',
       Concat(Round(Count(*) / (SELECT Count(*)
                                FROM   airline_passenger_satisfaction) * 100),
       '%') AS
       Porcentaje_type_travel
FROM   airline_passenger_satisfaction
GROUP  BY type_of_travel; 


-- KEY DISSATISFIED CUSTOMER SEGMENTS

	-- TYPE OF TRAVEL

WITH seg_type_travel
     AS (SELECT type_of_travel,
                Count(*) AS total_surveys,
                Sum(CASE
                      WHEN satisfaction = 'Neutral or Dissatisfied' THEN 1
                    END) total_dissatisfied
         FROM   airline_passenger_satisfaction
         GROUP  BY type_of_travel)
SELECT type_of_travel,
       total_surveys,
       total_dissatisfied,
       Concat(Round(total_dissatisfied / total_surveys * 100), '%') AS
       percentage_dissatisfied
FROM   seg_type_travel
ORDER  BY percentage_dissatisfied; 


	-- CLASS

WITH seg_class AS 
(SELECT 
	Class,
    COUNT(*) as Total_Passengers,
    SUM(CASE
		WHEN Satisfaction = 'Neutral or Dissatisfied' THEN 1 END) Dissatisfied
FROM airline_passenger_satisfaction
GROUP BY Class)
SELECT Class, Total_Passengers, Dissatisfied, CONCAT(ROUND(Dissatisfied / Total_Passengers * 100),'%') AS Percentage
FROM seg_class;


  -- CUSTOMER TYPE
WITH seg_customer
     AS (SELECT customer_type,
                Count(*) AS total_passengers,
                Sum(CASE
                      WHEN satisfaction = 'Neutral or Dissatisfied' THEN 1
                    END) total_dissatisfied
         FROM   airline_passenger_satisfaction
         GROUP  BY customer_type)
SELECT customer_type,
       total_passengers,
       total_dissatisfied,
       Concat(Round(total_dissatisfied / total_passengers * 100), '%') AS percentage
FROM   seg_customer;

-- BY AGE
WITH seg_edad
     AS (SELECT CASE
                  WHEN age < 18 THEN 'Under 18'
                  WHEN age BETWEEN 18 AND 30 THEN '18-30'
                  WHEN age BETWEEN 31 AND 59 THEN '31-59'
                  ELSE '60 & Above'
                END      AS Age_Split,
                Count(*) AS total_by_age,
                Sum(CASE
                      WHEN satisfaction = 'Neutral or Dissatisfied' THEN 1
                    END) dissatisfied
         FROM   airline_passenger_satisfaction
         GROUP  BY age_split)
SELECT age_split,
       total_by_age,
       dissatisfied,
       Concat(Round(dissatisfied / total_by_age * 100), '%') AS percentage
FROM   seg_edad; 
 
 
-- THREE MAJOR CONTRIBUTORS TO CUSTOMER DISSATISFACTION

-- Average Rate per Service

SELECT Round(Avg(in_flight_service), 1)       AS 'In flight Service',
       Round(Avg(baggage_handling), 1)        AS 'Baggage Handling',
       Round(Avg(departure_and_arrival), 1)   AS 'Departure and arrival',
       Round(Avg(ease_of_online_book), 1)     AS 'Easy Online Book',
       Round(Avg(gate_location), 1)           AS 'Gate Location',
       Round(Avg(check_in_service), 1)        AS 'Check in Service',
       Round(Avg(seat_comfort), 1)            AS 'Seat_Comfort',
       Round(Avg(leg_room_service), 1)        AS 'Leg Room Service',
       Round(Avg(cleanliness), 1)             AS 'Cleanliness',
       Round(Avg(food_and_drink), 1)          AS 'Food andDrink',
       Round(Avg(in_flight_wifi_service), 1)  AS 'In flight Wifi Service',
       Round(Avg(in_flight_entertainment), 1) AS 'In flight Entertainment',
       Round(Avg(online_boarding), 1)         AS 'Online Boarding'
FROM   airline_passenger_satisfaction; 

-- Less Rate = In flight wifi service, Easy Online book, Gate location

-- DISTRIBUTION OF THREE MAJOR CONTRIBUTORS TO CUSTOMER DISSATISFACTION

-- 1. In_flight_Wifi_Service
SELECT CASE
         WHEN in_flight_wifi_service = 5 THEN 'Very Satisfied'
         WHEN in_flight_wifi_service = 4 THEN 'Satisfied'
         WHEN in_flight_wifi_service = 3 THEN 'Neutral'
         WHEN in_flight_wifi_service = 2 THEN 'Dissatisfied'
         WHEN in_flight_wifi_service <= 1 THEN 'Very Dissatisfied'
       END
       AS scale_In_flight_wifi_Service,
       Count(*)
       AS rate,
       Concat(Round(Count(*) / (SELECT Count(*)
                                FROM   airline_passenger_satisfaction) * 100),
       '%') AS
       Percentage
FROM   airline_passenger_satisfaction
GROUP  BY scale_in_flight_wifi_service
ORDER  BY rate DESC; 


-- 2. Easy_Online_Book
SELECT CASE
         WHEN ease_of_online_book = 5 THEN 'Very Satisfied'
         WHEN ease_of_online_book = 4 THEN 'Satisfied'
         WHEN ease_of_online_book = 3 THEN 'Neutral'
         WHEN ease_of_online_book = 2 THEN 'Dissatisfied'
         WHEN ease_of_online_book <= 1 THEN 'Very Dissatisfied'
       END
       AS scale_easy_online_book,
       Count(*)
       AS rate,
       Concat(Round(Count(*) / (SELECT Count(*)
                                FROM   airline_passenger_satisfaction) * 100),
       '%') AS
       Percentage
FROM   airline_passenger_satisfaction
GROUP  BY scale_easy_online_book
ORDER  BY rate DESC; 

-- 3 Gate location
SELECT CASE
         WHEN gate_location = 5 THEN 'Very Satisfied'
         WHEN gate_location = 4 THEN 'Satisfied'
         WHEN gate_location = 3 THEN 'Neutral'
         WHEN gate_location = 2 THEN 'Dissatisfied'
         WHEN gate_location <= 1 THEN 'Very Dissatisfied'
       END
       AS scale_gate_location,
       Count(*)
       AS rate,
       Concat(Round(Count(*) / (SELECT Count(*)
                                FROM   airline_passenger_satisfaction) * 100),
       '%') AS
       Percentage
FROM   airline_passenger_satisfaction
GROUP  BY scale_gate_location
ORDER  BY rate DESC; 
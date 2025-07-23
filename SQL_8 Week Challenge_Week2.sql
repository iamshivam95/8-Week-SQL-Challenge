create database week2sql_challenges;
use week2sql_challenges;
CREATE TABLE runners (runner_id INT,registration_date DATE);
INSERT INTO runners
  (runner_id, registration_date)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');
DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  order_id INTEGER,
  customer_id INTEGER,
  pizza_id INTEGER,
  exclusions VARCHAR(4),
  extras VARCHAR(4),
  order_time TIMESTAMP
);

INSERT INTO customer_orders
  (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES
  (1, 101, 1, '', '', '2020-01-01 18:05:02'),
  (2, 101, 1, '', '', '2020-01-01 19:00:52'),
  (3, 102, 1, '', '', '2020-01-02 23:51:23'),
  (3, 102, 2, '', NULL, '2020-01-02 23:51:23'),
  (4, 103, 1, '4', '', '2020-01-04 13:23:46'),
  (4, 103, 1, '4', '', '2020-01-04 13:23:46'),
  (4, 103, 2, 4, '', '2020-01-04 13:23:46'),
  (5, 104, 1, 'null', '1', '2020-01-08 21:00:29'),
  (6, 101, 2, 'null', 'null', '2020-01-08 21:03:13'),
  (7, 105, 2, 'null', '1', '2020-01-08 21:20:29'),
  (8, 102, 1, 'null', 'null', '2020-01-09 23:54:33'),
  (9, 103, 1, '4', '1, 5', '2020-01-10 11:22:59'),
  (10, 104, 1, 'null', 'null', '2020-01-11 18:34:49'),
  (10, 104, 1, '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  order_id INTEGER,
  runner_id INTEGER,
  pickup_time VARCHAR(19),
  distance VARCHAR(7),
  duration  VARCHAR(10),
  cancellation VARCHAR(23)
);

INSERT INTO runner_orders
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  (1, 1, '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  (2, 1, '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  (3, 1, '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  (4, 2, '2020-01-04 13:53:03', '23.4', '40', NULL),
  (5, 3, '2020-01-08 21:10:57', '10', '15', NULL),
  (6, 3, 'null', 'null', 'null', 'Restaurant Cancellation'),
  (7, 2, '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  (8, 2, '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  (9, 2, 'null', 'null', 'null', 'Customer Cancellation'),
  (10, 1, '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  pizza_id INTEGER,
  pizza_name TEXT
);
INSERT INTO pizza_names
  (pizza_id, pizza_name)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  pizza_id INTEGER,
  toppings TEXT
);
INSERT INTO pizza_recipes
  (pizza_id, toppings)
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  topping_id  INTEGER,
  topping_name TEXT
);
INSERT INTO pizza_toppings
  (topping_id, topping_name)
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
  Select * from customer_orders limit 5;
  #/A. Pizza Metrics/#
  #/Q1 How many pizzas were ordered?/#
  Select count(pizza_id) from customer_orders;
  #/Q2 How many unique customer orders were made? /#
  Select count(distinct(customer_id)) from customer_orders;
  #/Q3 How many successful orders were delivered by each runner?/#
  Select runner_id,count(pickup_time) from runner_orders
  where pickup_time <> 'null' group by runner_id ;
  #/Q4 How many of each type of pizza was delivered?/#
  with ct1 as (
  Select r1.order_id,r1.pickup_time, x1.pizza_id from runner_orders as r1
  left join customer_orders as x1 on x1.order_id=r1.order_id
  where pickup_time <> 'null')
  Select pizza_id,count(pizza_id) from ct1 group by pizza_id;
  #/Q5 How many Vegetarian and Meatlovers were ordered by each customer?/#
with ct2 as (
  Select x1.customer_id,p1.pizza_name from customer_orders as x1
  left join pizza_names as p1 ON p1.pizza_id= x1.pizza_id),
  ct3 as (
  Select customer_id,pizza_name,
  case when pizza_name ="Meatlovers" then 1 else 0 end as 'Meatlover',
  case when pizza_name ="Vegetarian" then 1 else 0 end as 'Vegetarian'
   from ct2 )
   Select customer_id,sum(Meatlover) as "Meatlover_count",sum(Vegetarian) as "Vegetarian_count"
   from ct3 group by customer_id with rollup;
#/Q6 What was the maximum number of pizzas delivered in a single order?/#
with ct1 as (
  Select r1.order_id,count(x1.pizza_id) as pizza_order from runner_orders as r1
  left join customer_orders as x1 on x1.order_id=r1.order_id
  where pickup_time <>'null'
  group by r1.order_id 
  order by pizza_order desc)
  Select * from ct1 where pizza_order=(Select max(pizza_order) from ct1);
#/Q8 How many pizzas were delivered that had both exclusions and extras?/#
Select count(*) from customer_orders where length(exclusions)>0 and length(extras)>0;
#/Q9 What was the total volume of pizzas ordered for each hour of the day/#
with ct1 as (
Select order_id,hour(order_time) as hr_time from customer_orders)
Select hr_time,count(order_id) as ct_order from ct1 group by hr_time order by ct_order desc;
#/Q10 What was the total volume of pizzas ordered for each weekday of the day/#
with ct1 as (
Select order_id,weekday(order_time) as week_day from customer_orders)
Select week_day,count(order_id) as ct_order from ct1 group by week_day order by ct_order desc;
#/Q7 pending /#
---------------------------------------------------
#/B. Runner and Customer Experience/#
#/Q1 'How many runners signed up for each 1 week period? (i.e. week starts 2020-01-01)'/#
with ct1 as (
Select  *,ceiling((datediff(date(pickup_time),'2020-01-01'))/7) +1 as week_num 
from runner_orders
where pickup_time <>'null')
Select week_num,count(runner_id) from ct1 group by week_num with rollup;
#/Q2 'What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?'/#
with ct1 as (Select p1.*,x1.order_time,timestampdiff(minute,x1.order_time,p1.pickup_time) as time_to_pick from runner_orders p1
left join customer_orders x1
on p1.order_id = x1.order_id
where pickup_time <>'null')
Select round(avg(time_to_pick),2) as avg_time_to_pick_in_min from ct1;
#/Q3 'Is there any relationship between the number of pizzas and how long the order takes to prepare'/#
with ct1 as (Select p1.*,x1.order_time,timestampdiff(minute,x1.order_time,p1.pickup_time) as time_to_pick from runner_orders p1
left join customer_orders x1
on p1.order_id = x1.order_id
where pickup_time <>'null'),
ct2 as (
Select order_id,count(order_id) as order_ct ,avg(time_to_pick) as avg_ct from ct1 group by order_id)
Select order_ct, avg_ct from ct2 order by  order_ct,avg_ct;
#/"Yes no of order increase increase the time in order to executive"/#
#/Q4 What was the average distance travelled for each customer /#
with ct1 as (Select p1.*,x1.customer_id from runner_orders p1
left join customer_orders x1
on p1.order_id = x1.order_id
where pickup_time <>'null'),
ct2 as (
Select ct1.customer_id,distance,runner_id,order_id,cast(replace(lower(distance),'km','') as float) as dist_in_km from ct1
)
Select customer_id,round(avg(dist_in_km),2) from ct2 group by customer_id;

#/ Q5What was the difference between the longest and shortest delivery times for all orders?/#
with ct1 as (Select p1.*,x1.customer_id from runner_orders p1
left join customer_orders x1
on p1.order_id = x1.order_id
where pickup_time <>'null'),
 ct2 as (
 Select * ,cast(replace((left(duration,(locate('m',lower(duration))-1)))," ","" )as float) as dur_in_min from ct1
 ),
 ct3 as (
 Select customer_id,
 case when dur_in_min >0 then dur_in_min else duration end as final_dur
 from ct2)
 Select customer_id,min(final_dur) as max_dur,max(final_dur) as min_dur from ct3 group by customer_id;
 #/ Q6 What was the average speed for each runner for each delivery and do you notice any trend for these values /#
with ct1 as (Select p1.*,x1.customer_id from runner_orders p1
left join customer_orders x1
on p1.order_id = x1.order_id
where pickup_time <>'null'),
 ct2 as (
 Select * ,cast(replace((left(duration,(locate('m',lower(duration))-1)))," ","" )as float) as dur_in_min,
 cast(replace(lower(distance),'km','') as float) as dist_in_km from ct1
),ct3 as (
Select runner_id,dist_in_km,case when dur_in_min >0 then dur_in_min else duration end as final_dur
from ct2)
Select runner_id,round(avg(dist_in_km/final_dur),2) as avg_speed_kmhr,count(runner_id) as ord_ct from ct3 group by runner_id;
 
 #/What is the successful delivery percentage for each runner?/#
 with ct1 as ( Select runner_id,count(runner_id) as tot_assign from runner_orders group by runner_id),
 ct2 as ( Select runner_id,count(runner_id)  as pick_done from runner_orders  where distance <>'null' group by runner_id)
 Select ct1.*,pick_done,round(100.0*pick_done/tot_assign,2) as del_per from ct1
 left join ct2 on ct1.runner_id= ct2.runner_id;



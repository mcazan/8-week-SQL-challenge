CREATE database pizza_runner;
use pizza_runner;

DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  runner_id INTEGER,
  registration_date DATE
);
INSERT INTO runners
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
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  order_id INTEGER,
  runner_id INTEGER,
  pickup_time VARCHAR(19),
  distance VARCHAR(7),
  duration VARCHAR(10),
  cancellation VARCHAR(23)
);

INSERT INTO runner_orders
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  pizza_id INTEGER,
  pizza_name TEXT
);
INSERT INTO pizza_names
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  pizza_id INTEGER,
  toppings TEXT
);
INSERT INTO pizza_recipes
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  topping_id INTEGER,
  topping_name TEXT
);
INSERT INTO pizza_toppings
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

# Data cleaning - table customer_orders, columns exclusions and extras; table runner_orders, columns duration, distance
update customer_orders
set exclusions='0' 
where exclusions='' or exclusions='null'
;

update customer_orders
set extras='0'
where extras='null' or extras='' or extras is null
;

update runner_orders
set duration=regexp_replace(duration, '[a-z]+', '') 
where duration<>'null'
;

update runner_orders
set distance=regexp_replace(distance, '[a-z]+', '')
where distance<>'null'
;

#A. Pizza Metrics
#How many pizzas were ordered?
select count(*) as pizza_ordered_count
from customer_orders
;

#How many unique customer orders were made?
select count(distinct order_id) unique_order_count
from customer_orders
;

#How many successful orders were delivered by each runner?
select runner_id,
		count(order_id) as orders_delevered_count
from runner_orders
where distance != 0
group by runner_id
;

#How many of each type of pizza was delivered?
select p.pizza_name, 
		count(o.pizza_id) as pizza_type_count
from customer_orders as o
left join pizza_names as p
on o.pizza_id=p.pizza_id
left join runner_orders as r
on o.order_id=r.order_id
where distance<>0
group by p.pizza_name
;

#How many Vegetarian and Meatlovers were ordered by each customer?
select o.customer_id,
		p.pizza_name, 
		count(o.pizza_id) as pizza_type_count
from customer_orders as o
left join pizza_names as p
on o.pizza_id=p.pizza_id
group by o.customer_id,
		 p.pizza_name
order by customer_id asc         
;         

#What was the maximum number of pizzas delivered in a single order?
select count(c.pizza_id) as max_pizza_delivered_count
from customer_orders as c
left join runner_orders as r
on c.order_id=r.order_id
where r.distance <> 0
group by c.order_id
order by max_pizza_delivered_count desc
limit 1
; 

#For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
select c.customer_id,
		sum(if(exclusions<>0 or extras<>0,1,0)) as changed_pizza_count,
        sum(if(exclusions=0 and extras=0,1,0)) as no_changes_pizza_count
from customer_orders as c
left join runner_orders as r
on c.order_id=r.order_id
where r.distance <> 0
group by c.customer_id       
;

#How many pizzas were delivered that had both exclusions and extras?
select sum(if(exclusions<>0 and extras<>0,1,0)) as pizza_with_exclusions_and_extras_count
from customer_orders as c
left join runner_orders as r
on c.order_id=r.order_id
where r.distance <> 0 and exclusions<>'0' and extras<>'0'
;   
    
#What was the total volume of pizzas ordered for each hour of the day?
select hour(order_time) as order_hour,
		count(pizza_id) as pizza_volume
from customer_orders
group by order_hour
order by order_hour
;

#What was the volume of orders for each day of the week?
select weekday(order_time)+1 as day,
		dayname(order_time) as order_day,
		count(order_id) as order_volume
from customer_orders
group by order_day, day
order by day
;

#B. Runner and Customer Experience
#How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
select week(registration_date,1)+1 as week_registration,
		count(runner_id) as runner_count
from runners
group by week_registration
;        

#What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
select runner_id,
		avg(timestampdiff(minute, order_time, pickup_time)) as avg_time_minutes
from runner_orders as r
left join customer_orders as c
on r.order_id=c.order_id
where distance<>0
group by runner_id
order by runner_id
;        

#Is there any relationship between the number of pizzas and how long the order takes to prepare?
with prep_duration as (
	select c.order_id,
			count(c.pizza_id) as pizza_count,
			timestampdiff(minute,c.order_time, r.pickup_time) as time_minutes
	from customer_orders as c
	left join runner_orders as r
	on c.order_id=r.order_id
	where distance<>0
	group by c.order_id, time_minutes
	order by c.order_id	
    )
select pizza_count,
		avg(time_minutes)
from prep_duration
group by pizza_count        
;

#What was the average distance travelled for each customer?
select c.customer_id,
		round(avg(r.distance),2) as avg_distance
from customer_orders as c
left join runner_orders as r
on c.order_id=r.order_id        
where r.distance<>0        
group by c.customer_id
;

#What was the difference between the longest and shortest delivery times for all orders?
select max(duration)-min(duration) as delivery_duration_diff
from runner_orders
where duration<>'null'
;        

#What was the average speed for each runner for each delivery and do you notice any trend for these values?
select runner_id,
        order_id,
        distance,
        round(avg(distance/duration*60),2) as avg_speed
from runner_orders
where distance<>0
group by runner_id, order_id, distance
order by runner_id
;        

#What is the successful delivery percentage for each runner?
select r.runner_id,
		round((sum(if(distance<>'null', 1, 0))/count(*))*100,0) as success_delivery_perc
from runner_orders as r
group by r.runner_id
;

#C. Ingredient Optimisation
#What are the standard ingredients for each pizza?
#What was the most commonly added extra?
#What was the most common exclusion?
#Generate an order item for each record in the customers_orders table in the format of one of the following:
	#Meat Lovers
	#Meat Lovers - Exclude Beef
	#Meat Lovers - Extra Bacon
	#Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
#Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
	#For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
#What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

#D. Pricing and Ratings
#If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
#What if there was an additional $1 charge for any pizza extras?
	#Add cheese is $1 extra
#The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
#Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
	#customer_id
	#order_id
	#runner_id	
	#rating
	#order_time
	#pickup_time
	#Time between order and pickup
	#Delivery duration
	#Average speed
	#Total number of pizzas
#If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?

#E. Bonus Questions
#If Danny wants to expand his range of pizzas - how would this impact the existing data design? Write an INSERT statement to demonstrate what would happen if a new Supreme pizza with all the toppings was added to the Pizza Runner menu?  
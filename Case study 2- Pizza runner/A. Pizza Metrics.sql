#A. Pizza Metrics
#How many pizzas were ordered?
select count(*) as pizza_ordered_count
from customer_orders_temp
;

#How many unique customer orders were made?
select count(distinct order_id) unique_order_count
from customer_orders_temp
;

#How many successful orders were delivered by each runner?
select runner_id,
	count(order_id) as orders_delevered_count
from runner_orders_temp
where cancellation is null
group by runner_id
;

#How many of each type of pizza was delivered?
select p.pizza_name, 
	count(o.pizza_id) as pizza_type_count
from customer_orders_temp as o
left join pizza_names as p
on o.pizza_id=p.pizza_id
left join runner_orders_temp as r
on o.order_id=r.order_id
where cancellation is null
group by p.pizza_name
;

#How many Vegetarian and Meatlovers were ordered by each customer?
select customer_id,
	sum(if(pizza_id=1,1,0)) as Meatlovers,
        sum(if(pizza_id=2,1,0)) as Vegetarian
from customer_orders_temp 
group by customer_id
order by customer_id        
;         

#What was the maximum number of pizzas delivered in a single order?
select count(c.pizza_id) as max_pizza_delivered_count
from customer_orders_temp as c
left join runner_orders_temp as r
on c.order_id=r.order_id
where r.cancellation is null
group by c.order_id
order by max_pizza_delivered_count desc
limit 1
; 

#For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
select c.customer_id,
	sum(if(exclusions is not null or extras is not null,1,0)) as changed_pizza_count,
        sum(if(exclusions is null and extras is null,1,0)) as no_changes_pizza_count
from customer_orders_temp as c
left join runner_orders_temp as r
on c.order_id=r.order_id
where r.cancellation is null
group by c.customer_id       
;

#How many pizzas were delivered that had both exclusions and extras?
select sum(if(exclusions is not null and extras is not null,1,0)) as pizza_with_exclusions_and_extras_count
from customer_orders_temp as c
left join runner_orders_temp as r
on c.order_id=r.order_id
where r.cancellation is null and exclusions is not null and extras is not null
;   
    
#What was the total volume of pizzas ordered for each hour of the day?
select hour(order_time) as order_hour,
	count(pizza_id) as pizza_volume
from customer_orders_temp
group by order_hour
order by order_hour
;

#What was the volume of orders for each day of the week?
select weekday(order_time)+1 as day,
	dayname(order_time) as order_day,
	count(order_id) as order_volume
from customer_orders_temp
group by order_day, day
order by day
;

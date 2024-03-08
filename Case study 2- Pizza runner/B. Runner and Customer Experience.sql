#B. Runner and Customer Experience
	
#How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
select extract(week from registration_date)+1 as week_registration,
	count(runner_id) as runner_count
from runners
group by week_registration
;       

#What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
with runner_pickup as (
	select runner_id,
		r.order_id,
		timestampdiff(minute, order_time, pickup_time) as time_minutes
    from runner_orders_temp as r
    left join customer_orders_temp as c
    on r.order_id=c.order_id
    where cancellation is null  
    group by runner_id, r.order_id, order_time, pickup_time
    order by runner_id
    )
select runner_id,
	round(avg(time_minutes),0)	
from runner_pickup  
group by runner_id      
;

#Is there any relationship between the number of pizzas and how long the order takes to prepare?
with prep_duration as (
	select c.order_id,
		count(c.pizza_id) as pizza_count,
		timestampdiff(minute,c.order_time, r.pickup_time) as time_minutes
	from customer_orders_temp as c
	left join runner_orders_temp as r
	on c.order_id=r.order_id
	where cancellation is null
	group by c.order_id, time_minutes
	order by c.order_id	
       )
select pizza_count,
	round(avg(time_minutes),0) as avg_time_minutes
from prep_duration
group by pizza_count        
;
# OBSERVATION - Orders with multiple pizzas take more time to prepare. It take 12 minutes to prepare orders with a single pizza, but only about 9 minutes per pizza for orders containing multiple pizzas.

#What was the average distance travelled for each customer?
select c.customer_id,
	round(avg(r.distance),2) as avg_distance
from customer_orders_temp as c
left join runner_orders_temp as r
on c.order_id=r.order_id        
where r.cancellation is null     
group by c.customer_id
;

#What was the difference between the longest and shortest delivery times for all orders?
select max(duration)-min(duration) as delivery_duration_diff
from runner_orders_temp
;        

#What was the average speed for each runner for each delivery and do you notice any trend for these values?
select runner_id,
        distance,
        duration,
        round(avg(distance/duration*60), 1) as avg_speed
from runner_orders_temp
where cancellation is null
group by runner_id, order_id, distance, duration
;       
# OBSERVATION - For runner 1 and 2 the average speed is increasing with every order they deliver. The shorter the distances the greater the speed. 
	# Runner's 2 average speed is very spread out comparing to his peers (from 35.1 km/h to 93.6 km/h). Further investigations recommended.  

#What is the successful delivery percentage for each runner?
select r.runner_id,
	round(count(distance)/count(*)*100,0) as success_delivery_perc
from runner_orders_temp as r
group by r.runner_id
;

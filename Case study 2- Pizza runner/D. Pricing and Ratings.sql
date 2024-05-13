#D. Pricing and Ratings
#If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
with revenue_by_pizza as (
	select pizza_id,
			case 
			when pizza_id=1 then 12*count(pizza_id)
			when pizza_id=2 then 10*count(pizza_id)
			end as revenue
	from customer_orders_temp 
	join runner_orders_temp using (order_id)
	where cancellation is null	
	group by pizza_id
    )
select sum(revenue) as sales_revenue
from revenue_by_pizza	
;     

#What if there was an additional $1 charge for any pizza extras?
	#Add cheese is $1 extra
with price as (
	select case 
			when pizza_id=1 and length(extras)-length(replace(extras, ',', ''))+1 is null then 12
			when pizza_id=1 and (length(extras)-length(replace(extras, ',', ''))+1)>=1 then 12+(length(extras)-length(replace(extras, ',', ''))+1)
			when pizza_id=2 and length(extras)-length(replace(extras, ',', ''))+1 is null then 10
			when pizza_id=2 and (length(extras)-length(replace(extras, ',', ''))+1)>=1 then 10+(length(extras)-length(replace(extras, ',', ''))+1)
			end as price
	from customer_orders_temp
	join runner_orders_temp using(order_id)
	where cancellation is null
	)
select sum(price) as sales_revenue_with_extras_charge
from price
;      
    
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

drop table if exists ratings_for_runners;
create table ratings_for_runners
	(order_id integer,
    customer_id integer,
    runner_id integer,
    runner_speed varchar(1),
    runner_service varchar(1),
    overall_rating varchar(1)
    )
;    

insert into ratings_for_runners 
	values 
    (1, 101, 1, 3, 4, 4),
    (2, 101, 1, 4, 3, 4),
    (3, 102, 1, 5, 5, 5),
    (4, 103, 2, 2, 4, 3),
    (5, 104, 3, 5, 5, 5),
    (7, 105, 2, 5, 4, 4),
    (8, 102, 2, 5, 4, 4),
    (10, 104, 1, 5, 5, 5)
    ;
    
select c.customer_id,
		c.order_id,
		r.runner_id,	
		overall_rating, 
		c.order_time,
		pickup_time,
		timestampdiff(minute, order_time, pickup_time) as time_between_order_and_pickup,
		duration,
		round((distance/duration*60),2)average_speed,
		count(c.pizza_id) as count_pizzas
from customer_orders_temp c
left join runner_orders_temp r using(order_id)
left join ratings_for_runners using(order_id)    
where cancellation is null
group by customer_id, order_id
order by customer_id
;

#If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?
with sales_revenue as (
	select order_id,
			pizza_id,
			case 
			when pizza_id=1 then 12
			when pizza_id=2 then 10
			end as price,
            distance
	from customer_orders_temp
	join runner_orders_temp using(order_id)
	where cancellation is null
	)
select sum(price) as revenue,
		sum(distance)*0.3 as delivery_cost,
		round(sum(price)-sum(distance)*0.3,2) as revenue_after_runner_payment
from sales_revenue
;
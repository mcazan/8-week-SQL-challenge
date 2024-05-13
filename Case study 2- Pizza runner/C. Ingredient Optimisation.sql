#C. Ingredient Optimisation
drop temporary table if exists customer_orders_row_temp;
create temporary table customer_orders_row_temp as
select order_id,
		customer_id,
        pizza_id,
        trim(exc.exclusions) as exclusions,
        trim(ext.extras) as extras,
        order_time, 
        row_num
from 
		(select *,
				row_number() over() as row_num
        from customer_orders_temp
        ) as t
join json_table(trim(replace(json_array(t.exclusions), ',', '","')), '$[*]' columns(exclusions varchar(50) path '$')) as exc
join json_table(trim(replace(json_array(t.extras), ',', '","')), '$[*]' columns(extras varchar(50) path '$')) as ext
;     

drop table if exists customer_orders_new_temp;
create temporary table customer_orders_new_temp as
select  order_id,
		customer_id,
        pizza_id,
        exclusions,
        extras,
        order_time, 
        row_number() over(order by order_id) as row_num
from customer_orders_temp
;
#What are the standard ingredients for each pizza?
drop temporary table if exists pizza_recipes_temp;
create temporary table pizza_recipes_temp as
select pizza_id,
		trim(j.toppings) as topping_id,
        topping_name
from pizza_recipes as r     
join json_table(trim(replace(json_array(toppings), ',', '","')), '$[*]' columns (toppings varchar(50) path '$')) as j
left join pizza_toppings as t 
on j.toppings=t.topping_id 
;

# version 1	
select pizza_name,
		topping_name
from pizza_recipes_temp r
left join pizza_names using (pizza_id)
;

#version 2
drop table if exists standard_ingredients;
create temporary table standard_ingredients as
select pizza_id,
		pizza_name,
		group_concat(topping_name) as toppings
from pizza_recipes_temp
left join pizza_names
using (pizza_id)
group by pizza_id, pizza_name   
;

#What was the most commonly added extra?
drop table if exists extras_temp;
create temporary table extras_temp as
select order_id,
		row_num,
        trim(jt.extras) as topping_id,
        topping_name
from customer_orders_new_temp c
join json_table(trim(replace(json_array(extras), ',', '","')), 
					'$[*]' columns (extras varchar(50) path '$')) as jt
join pizza_toppings
on jt.extras=topping_id         
;

select topping_name,
		count(topping_id) as count_extras
from extras_temp
group by topping_name
order by count_extras desc, topping_name
;

#What was the most common exclusion?
drop table if exists exclusions_temp;
create temporary table exclusions_temp as
select order_id,
		row_num,
        trim(jt.exclusions) as topping_id,
        topping_name
from customer_orders_new_temp
join json_table(trim(replace(json_array(exclusions), ',', '","')),
				'$[*]' columns (exclusions varchar(50) path '$')) as jt
join pizza_toppings 
on jt.exclusions=topping_id 
;

select topping_name,
		count(topping_id) as count_exclusions
from exclusions_temp
group by topping_name
order by count_exclusions desc, topping_name
;        

#Generate an order item for each record in the customers_orders table in the format of one of the following:
	#Meat Lovers
	#Meat Lovers - Exclude Beef
	#Meat Lovers - Extra Bacon
	#Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
with exclusions_extras as (
	select row_num,
		order_id,
        customer_id,
        pizza_name,
        excluded_topping,
        t.topping_name as extra_topping
	from        
		(select *,
			topping_name as excluded_topping
		from customer_orders_row_temp
        left join standard_ingredients 
        using (pizza_id)
		left join pizza_toppings
		on exclusions=topping_id
		) as omit
	left join pizza_toppings t
	on extras=t.topping_id
	)
select row_num,
		order_id,
		case 
        when excluded_topping is null and extra_topping is null then pizza_name
        when excluded_topping is not null and extra_topping is null then concat(pizza_name, ' - ', 'Exclude ', group_concat(distinct excluded_topping))
        when excluded_topping is null and extra_topping is not null then concat(pizza_name, ' - ', 'Extra ', group_concat(distinct extra_topping))
        else concat_ws(' - ', pizza_name,  'Exclude ', group_concat(distinct excluded_topping), 'Extra ', group_concat(distinct extra_topping))
        end as order_item	
from exclusions_extras
group by row_num
order by order_id
;

#Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
	#For example: "Meat Lovers: 2xBacon, Beef, ... , Salami".
with ingredients as (
	select order_id,
			row_num,
			pizza_name,
            case
            when r.topping_id in (select topping_id
                                from extras_temp e
                                where c.row_num=e.row_num)
            then concat('2x', topping_name)
            else topping_name
            end as topping
     from customer_orders_new_temp c
     join pizza_names using (pizza_id)
     join pizza_recipes_temp r using (pizza_id)
     where r.topping_id not in (select topping_id
								from exclusions_temp e
                                where c.row_num=e.row_num)
	)    
select row_num,
		order_id, 
		concat(pizza_name, ': ', group_concat(distinct topping order by topping)) as ingredient_list
from ingredients      
group by order_id, pizza_name, row_num
;         

#What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
with ingredients as (
	select order_id,
			row_num,
			topping_name,
            case
            when r.topping_id in (select topping_id
                                from extras_temp e
                                where c.row_num=e.row_num)
            then 2
            else 1
            end as count_topping
     from customer_orders_new_temp c
     join pizza_names using (pizza_id)
     join pizza_recipes_temp r using (pizza_id)
     where r.topping_id not in (select topping_id
								from exclusions_temp e
                                where c.row_num=e.row_num)
	)            
select topping_name,
		sum(count_topping) as quantity
from ingredients
join runner_orders_temp using (order_id)
where cancellation is null
group by topping_name
order by quantity desc, topping_name     
;

# C. Challenge Payment Question

The Foodie-Fi team wants you to create a new payments table for the year 2020 that includes amounts paid by each customer in the subscriptions table with the following requirements:

* monthly payments always occur on the same day of month as the original start_date of any monthly paid plan
* upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately
* upgrades from pro monthly to pro annual are paid at the end of the current billing period and also starts at the end of the month period
* once a customer churns they will no longer make payments

### Steps
   
#### *Create payments_2020 table that will store the payment data for 2020.*
```sql
drop table if exists payments_2020;
create table payments_2020 (
		payment_id integer primary key auto_increment,
		customer_id integer not null,
		plan_id integer not null,
		plan_name varchar(20) not null,
		payment_date date not null,
		payment_amount float not null,
		payment_order integer)
;       
```
#### *Insert data into the newly created table. This is done by using multiple Common Table Expressions (CTE). Each CTE is briefly explained below.*
```sql
insert into payments_2020 (customer_id, plan_id, plan_name, payment_date, payment_amount, payment_order)
with recursive customer_plan_data as (select customer_id,  -- select required fields, filterimg out payments outside year 2020 and trial and churn customers 
					    plan_id,
                                            plan_name,
					    start_date,
					    start_date as payment_date,
					    lead(start_date) over(partition by customer_id order by start_date) as next_payment,
					    price as payment_amount
                                  from subscriptions s
                                  join plans p using(plan_id)
                                  where year(start_date) = '2020' 
					and plan_id not in (0, 4)),
		new_payment_date as (select customer_id, -- adding a new column for the new next payment date
						plan_id,
                                  		plan_name,
						start_date,
						payment_date,
						next_payment,
						date_add(next_payment, interval -1 month) as new_next_date,
						payment_amount
				    from customer_plan_data),
		new_payment as (select customer_id, -- recursive CTE to add rows for each new payment 
					plan_id,
                            		plan_name,
				        start_date,
		            		(select max(start_date) from new_payment_date where customer_id = n.customer_id and plan_id = n.plan_id) as payment_date,
				        next_payment,
				        new_next_date,
				        payment_amount
			      from new_payment_date n
			      union all
			      select customer_id,
				        plan_id,
                          		plan_name,
					start_date,
					date_add(payment_date, interval 1 month) as payment_date,
					next_payment,
					new_next_date,
					payment_amount
			       from new_payment p
			       where payment_date < new_next_date AND plan_id != 3),
		calculate_payment_amount as (select *, -- order payments and select previous plan and amount paid
						lag(plan_id, 1) over(partition by customer_id order by start_date) as last_plan,
                              			lag(payment_amount, 1) over(partition by customer_id order by start_date) as last_payment_amount,
                              			rank() over(partition by customer_id order by customer_id, plan_id, payment_date) as payment_order
					   from new_payment
                        		   order by customer_id, start_date)
select customer_id,
      	plan_id,
      	plan_name,
      	payment_date,
      	(case when plan_id in (2, 3) and last_plan = 1 then payment_amount -last_payment_amount else payment_amount end) as payment_amount,
      	payment_order
from calculate_payment_amount
order by customer_id, plan_id, payment_date
;                
```                          
#### *Displaying the new table content. Considering the lenght, I will show just the first 37 rows.*
```sql
select *
from payments_2020
;
```

![insert query](https://github.com/mcazan/8-week-SQL-challenge/assets/135700965/1146ff53-e747-4175-837d-1f58d0be2d83)

As we can see for customer 16, when upgrading to pro annual the payment was reduced with the amount already paid.  


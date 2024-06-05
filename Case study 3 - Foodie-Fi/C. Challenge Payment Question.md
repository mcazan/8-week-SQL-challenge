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
#### *Insert data into the newly created table. This is done by using multiple Common Table Expressions (CTE).*

* First CTE (customer_plan_data) gathers all required fields for the base table and adds a new column forthe next payment date. 
* Second CTE is takinng care of the null values for the next_date field. I also filters out subscriptions to include only those for year 2020 and excludes trial and churn customers, as they don't generate payments.
* Third CTE is a recurse CTE that adds a new row for every new payment. For customers with monthly subscriptions iff the payment_date value is smaller then (next_date - 1 month) value then it adds rows in 1 month increments. 
* The last CTE finds the previous plan and the last amount paid and we are using these fields to make sure upgrades from basic to monthly or pro plans are reduced by the current paid amount. This CTE gives us a ordered list of payments by customer.
    
```sql
insert into payments_2020 (customer_id, plan_id, plan_name, payment_date, payment_amount, payment_order) -- inserts data into payment_2020 table
with recursive customer_plan_data as (select s.customer_id,  -- select required fields and add a new column for the next date when a payment is scheduled
					    s.plan_id,
                                            p.plan_name,
					    s.start_date,
					    s.start_date as payment_date,
					    lead(s.start_date) over(partition by s.customer_id order by s.start_date) as next_date,
					    p.price as payment_amount
                                  from subscriptions s
                                  left join plans p using(plan_id)
                                  ),
		new_date as (select customer_id, -- replacing null values with a default value for the next_date field and filterimg out payments outside year 2020, as well as trial and churn customers 
					plan_id,
                                  	plan_name,
					start_date,
					payment_date,
					coalesce(next_date, '2020-12-31') as next_date,
					payment_amount
				from customer_plan_data
				where year(start_date) = '2020' 
					and plan_id not in (0, 4)
				),
		new_payment as (select customer_id, -- recursive CTE to add rows for each new payment 
					plan_id,
                            		plan_name,
				        start_date,
		            		(select max(start_date) from new_date where customer_id = n.customer_id and plan_id = n.plan_id) as payment_date,
				        next_date,
				        payment_amount
			      from new_date n
			      union all
			      select customer_id,
				        plan_id,
                          		plan_name,
					start_date,
					date_add(payment_date, interval 1 month) as payment_date,
					next_date,
					payment_amount
			       from new_payment p
			       where payment_date < date_add(next_date, interval -1 month)
					and plan_id != 3
				),
		calculate_payment_amount as (select *, -- order payments and select previous plan and amount paid
						lag(plan_id, 1) over(partition by customer_id order by start_date) as last_plan,
                              			lag(payment_amount, 1) over(partition by customer_id order by start_date) as last_payment_amount,
                              			rank() over(partition by customer_id order by customer_id, plan_id, payment_date) as payment_order
					   from new_payment
                        		   order by customer_id, start_date
					   )
select customer_id, -- when upgrading from basic to monthly or pro plans the billed amount is reduced by the current paid amount
      	plan_id,
      	plan_name,
      	payment_date,
      	(case when plan_id in (2, 3) and last_plan = 1 then payment_amount -last_payment_amount else payment_amount end) as payment_amount,
      	payment_order
from calculate_payment_amount
order by customer_id, plan_id, payment_date
;                
```
##### *Result from running the first CTE*
![1 cte](https://github.com/mcazan/8-week-SQL-challenge/assets/135700965/a7df51aa-57e5-4350-8008-f1a37b88e4e8)

##### *Result from the first and second CTE*
![2 cte](https://github.com/mcazan/8-week-SQL-challenge/assets/135700965/8ae742b9-74fe-4672-ad9d-876591073f10)
	   
#### *Displaying the new table content. Considering the lenght, I will show just the first 37 rows.*
```sql
select *
from payments_2020
;
```
![insert query](https://github.com/mcazan/8-week-SQL-challenge/assets/135700965/1146ff53-e747-4175-837d-1f58d0be2d83)

As we can see for customer 16, when upgrading to pro annual the payment was reduced with the amount already paid.  


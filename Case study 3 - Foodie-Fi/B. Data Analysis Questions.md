# B. Data Analysis Questions
1. How many customers has Foodie-Fi ever had?
```sql
select count(distinct customer_id) as customer_count
from subscriptions
;
```
### Answer:

![Customer_count](https://github.com/mcazan/8-week-SQL-challenge/assets/135700965/137f756f-8b56-4572-90e6-972663752ca0)

2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
```sql
select month(start_date) as month,
        year(start_date) as year,
        count(customer_id) as trial_count
from subscriptions 
join plans using (plan_id)
where plan_name='trial'
group by month, year
order by year, month
;
```
### Answer:

![trial_count](https://github.com/mcazan/8-week-SQL-challenge/assets/135700965/fbfa020d-0b2a-46ae-b867-2d16b408627f)

3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
```sql
select plan_name,
	plan_id,
        count(*) as plan_count
from plans p
left join subscriptions s using (plan_id)
where year(start_date) > 2020
group by plan_name
order by plan_id
;
```   
### Answer:

![plan_count](https://github.com/mcazan/8-week-SQL-challenge/assets/135700965/79f8f93e-70b8-4eef-943d-8b7305cbc647)

4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place
```sql
select count(distinct customer_id) as churn_customer_count,
	round(100 * count(distinct customer_id)/(select count(distinct customer_id) from subscriptions), 1) as percentage_customer_churn
from subscriptions s
join plans p using (plan_id)
where p.plan_id = 4
;
```
### Answer:

![customer_churn](https://github.com/mcazan/8-week-SQL-challenge/assets/135700965/2de403bf-92db-4fe8-8bc0-a0babcb56aba)

5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
```sql
with ranked as (select *,
			dense_rank() over (partition by customer_id order by plan_id) as plan_ranked
		from subscriptions)
select count(case when plan_ranked = 2 and plan_id = 4 then 1 else 0 end) as churned_after_trial,
	round(100 * (count(case when plan_ranked = 2 and plan_id = 4 then 1 else 0 end)) / (select count(distinct customer_id) from subscriptions),0) as percentage_churned_after_trial
from ranked 
where plan_ranked = 2 and plan_id = 4         
;
```
### Answer:

![churn_after_ttrial](https://github.com/mcazan/8-week-SQL-challenge/assets/135700965/70ef05a3-08e6-4a06-9c08-acc902c8ff17)

6. What is the number and percentage of customer plans after their initial free trial?
```sql
with next_plan as (select customer_id,
			  plan_id,
			  lead(plan_id) over(partition by customer_id order by plan_id) as next_plan_id
		  from subscriptions)
select next_plan_id as plan_id,
	count(customer_id) as customer_count,
        round(100 * count(customer_id) / (select count(distinct customer_id) from subscriptions),0) as percentage_customers
from next_plan
where next_plan_id is not null and plan_id = 0
group by next_plan_id      
order by next_plan_id  
;
```
### Answer:

![plans_after_trail](https://github.com/mcazan/8-week-SQL-challenge/assets/135700965/50df6f6f-abe3-4e03-94c9-c62d81e9c840)

7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
```sql
with next_dates as(select *,
			lead(start_date) over(partition by customer_id order by plan_id) as next_date
		from subscriptions
		where start_date <= '2020-12-31')
select plan_name,
	count(distinct customer_id) as customer_count,
        round(100 * count(distinct customer_id) / (select count(distinct customer_id) from subscriptions)) as 		percentage_customers
from next_dates n
join plans p using(plan_id)
where next_date is null    
group by plan_name
order by plan_id   
;
```
### Answer:

![customer_count_by_plan](https://github.com/mcazan/8-week-SQL-challenge/assets/135700965/0366c48c-af12-45df-b197-5f6c97ee6488)

8. How many customers have upgraded to an annual plan in 2020?
```sql
select plan_name,
	count(distinct customer_id) as customer_count
from subscriptions s
join plans p using(plan_id)
where plan_name like '%annual'
	and year(start_date) = '2020'
group by plan_name        
;
```        
### Answer:

![annual_plan](https://github.com/mcazan/8-week-SQL-challenge/assets/135700965/13853617-ad35-458d-a42f-84cb5ca4e65b)

9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
```sql
with trial_plans as (select customer_id,
				start_date
		    from subscriptions s
                    join plans p using(plan_id)
                    where plan_name = 'trial'),
annual_plans as (select customer_id,
			start_date as upgrade_date
                 from subscriptions s        
                 join plans p using(plan_id)
                 where plan_name = 'pro annual')                    
select avg(datediff(upgrade_date, start_date)) as avg_days_to_upgrade
from trial_plans
join annual_plans using(customer_id)
;
```	
### Answer:

![avg days to upgrade](https://github.com/mcazan/8-week-SQL-challenge/assets/135700965/c25d016f-0b0e-4432-a483-f335bea8894b)

10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
```sql
with trial_plans as (select customer_id,
			    start_date
		    from subscriptions s
                    join plans p using(plan_id)
                    where plan_name = 'trial'),
annual_plans as (select customer_id,
			start_date as upgrade_date
                 from subscriptions s
                 join plans p using(plan_id)
                 where plan_name = 'pro annual'),
bins as (select a.customer_id,
		datediff(upgrade_date, start_date) as days_to_upgrade
                from annual_plans a
                join trial_plans t using(customer_id))                 
select case when days_to_upgrade between 0 and 30 then '0-30 days'
	    when days_to_upgrade between 31 and 60 then '31-60 days'
            when days_to_upgrade between 61 and 90 then '61-90 days'
            when days_to_upgrade between 91 and 120 then '91-120 days'
            when days_to_upgrade between 121 and 150 then '121-150 days'
            when days_to_upgrade between 151 and 180 then '151-180 days'
            when days_to_upgrade between 181 and 210 then '181-210 days'
	    when days_to_upgrade between 211 and 240 then '211-240 days'
            when days_to_upgrade between 241 and 270 then '241-270 days'
            when days_to_upgrade between 271 and 300 then '271-300 days'
            when days_to_upgrade between 301 and 330 then '301-330 days'
            else '331-365 days'
            end as bins,
	count(*) as customer_count,
        round(avg(days_to_upgrade)) as avg_days_to_upgrade
from bins
group by bins
order by days_to_upgrade    
;
```
### version 2
```sql
with trial_plans as (select customer_id, 
			    start_date
                    from subscriptions s
                    where plan_id = 0),
     annual_plans as (select customer_id,
			     start_date as upgrade_date
                     from subscriptions s
                     where plan_id = 3)
select concat(floor(datediff(upgrade_date, start_date) / 30) * 30, '-', floor(datediff(upgrade_date, start_date) / 30) * 30 + 30, ' days') as bins,
       count(*) as customer_count,
       round(avg(datediff(upgrade_date, start_date))) as avg_days_to_upgrade
from trial_plans
join annual_plans using(customer_id)
where upgrade_date is not null
group by floor(datediff(upgrade_date, start_date) / 30)
order by floor(datediff(upgrade_date, start_date) / 30)
;        
```
### Answer:

![avg days to upgrade bins](https://github.com/mcazan/8-week-SQL-challenge/assets/135700965/fe787267-6a67-4290-9497-9f4a9a621714)

11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
```sql
with next_plans as (select *,
			   lead(plan_id) over(partition by customer_id order by plan_id) as next_plan
		    from subscriptions
                    where year(start_date) = '2020')
select count(distinct customer_id) as downgraded_customer_count
from next_plans 
where plan_id = 2
      and next_plan = 1 
;
```
### Answer:

![downgrade](https://github.com/mcazan/8-week-SQL-challenge/assets/135700965/6b693459-41ae-4d95-a85c-e568d2599c4a)


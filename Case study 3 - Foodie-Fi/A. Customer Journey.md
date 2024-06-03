# A. Customer Journey

*Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief
description about each customer’s onboarding journey.Try to keep it as short as possible - you may also
want to run some sort of join to make your explanations a bit easier!*

### Solution

```sql
select customer_id,
	plan_name,
        start_date,
	timestampdiff(day, lag(start_date) over(partition by customer_id order by start_date), start_date) as day_difference,
        timestampdiff(month, lag(start_date) over(partition by customer_id order by start_date), start_date) as month_difference
from subscriptions
join plans using (plan_id)
where customer_id in ('1', '2', '11', '13', '15', '16', '18', '19')
order by customer_id
;
```

![Customer journey](https://github.com/mcazan/8-week-SQL-challenge/assets/135700965/5b8c0085-77a6-4e45-8019-29d41d4cdf3d)
	
### Brief description on the customers journey based on the results from the above query:

All customers in the sample started with a trial period. After the trial period:
 - Customer 1 chose the basic monthly plan. 
 - Customer 2 went streight with pro annual. 
 - Customer 11 cancelled right after trial. 
 - Customer 13 went with basic monthly and then upgraded to pro monthly after 3 months. 
 - Customer 15 chose the pro monthly plan and churn one month later.
 - Customer 16 chose basic monthly before upgrading to pro annual plan 4 month later. 
 - Customer 18 went with the pro monthly plan. 
 - Customer 19 chose pro monthly and then upgraded after 2 months to the pro annual plan.

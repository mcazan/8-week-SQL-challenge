 A. Customer Journey

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
customer_id | plan_name | start_date | day_difference  
--| -- | -- | --
1 | trial | 2020-08-01 | null
1 | 1 | basic monthly | 2020-08-08
2 | 0 | trial | 2020-09-20
2 | 3 | pro annual | 2020-09-27
11 | 0 | trail | 2020-11-19
11 | 4 | churn | 2020-11-26
13 | 0 | trial | 2020-12-15
13 | 1 | basic monthly | 2020-12-22
13 | 2 | pro monthly | 2021-03-29
15 | 0 | trial | 2020-03-17
15 | 2 | pro monthly | 2020-03-24
15 | 4 | churn | 2020-04-29
16 | 0 | trial | 2020-05-31
16 | 1 | basic monthly | 2020-06-07
16 | 3 | pro annual | 2020-10-21
18 | 0 | trial | 2020-07-06
18 | 2 | pro monthly | 2020-07-13
19 | 0 | trial | 2020-06-22
19 | 2 | pro monthly | 2020-06-29
19 | 3 | pro annual | 2020-08-29

<img width="556" alt="image" src="https://user-images.githubusercontent.com/81607668/129758340-b7cd527c-31f3-4f33-8d99-5b0a4baab378.png">
	
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

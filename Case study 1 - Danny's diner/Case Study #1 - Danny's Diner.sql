#Case Study Questions
#Each of the following case study questions can be answered using a single SQL statement:

# 1.What is the total amount each customer spent at the restaurant?
select s.customer_id, 
	   sum(m.price) as amount_spent
from sales as s
left join menu as m 
on s.product_id=m.product_id
group by customer_id
order by amount_spent desc;

# 2.How many days has each customer visited the restaurant?
select customer_id, 
	   count(distinct order_date) as number_of_visits
from sales
group by customer_id
order by number_of_visits desc;       

# 3.What was the first item from the menu purchased by each customer?
with ranked as 
	(select *, 
	row_number() over(partition by customer_id order by order_date) as row_num
	from sales
    )
select r.customer_id, 
	   r.order_date, 
       m.product_name
from ranked as r
left join menu as m
on r.product_id=m.product_id
where row_num=1
order by r.customer_id
;

# 4.What is the most purchased item on the menu and how many times was it purchased by all customers?
select count(s.product_id) as most_purchased, 
		m.product_name
from sales as s
inner join menu as m
on s.product_id=m.product_id
group by m.product_name
order by most_purchased desc
limit 1 
;

# 5.Which item was the most popular for each customer?
with most_popular as (
	select customer_id, 
			product_id, 
            count(*) as counted, 
			dense_rank() over(partition by customer_id order by count(product_id) desc) as ranked
    from sales
    group by customer_id, product_id
    )    
select s.customer_id, 
		m.product_name, 
        counted
from most_popular as s
left join menu as m
on s.product_id=m.product_id
where ranked=1
order by counted desc
;

# 6.Which item was purchased first by the customer after they became a member?
with first_order_member as (
	select s.customer_id, 
			s.product_id, 
            dense_rank() over(partition by s.customer_id order by s.order_date) as ranked
	from sales as s
    left join  members as me
	on s.customer_id=me.customer_id
	where s.order_date>=me.join_date
    order by s.order_date
    )
select customer_id, 
		m.product_name
from first_order_member as o 
left join menu as m
on o.product_id=m.product_id
where ranked=1
order by o.customer_id
;

# 7.Which item was purchased just before the customer became a member?
with last_order as (
	select s.customer_id, 
            s.product_id, 
            row_number() over(partition by s.customer_id order by s.order_date desc) as ranked
    from sales as s
    left join members as m
    on s.customer_id=m.customer_id
    where s.order_date<m.join_date
    )
select l.customer_id, 
		m.product_name
from last_order as l
left join menu as m
on l.product_id=m.product_id    
where ranked=1
order by l.customer_id
;

# 8.What is the total items and amount spent for each member before they became a member?
select s.customer_id, 
		count(*) as total_items,
        sum(m.price) as amount_spent
from sales as s
left join members as mb
on s.customer_id=mb.customer_id
left join menu as m
on s.product_id=m.product_id
where s.order_date<mb.join_date
group by s.customer_id
order by s.customer_id
;     

# 9.If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
select s.customer_id,
        sum(if (m.product_name='sushi', m.price*20, m.price*10)) as points
from sales as s
left join menu as m
on s.product_id=m.product_id
group by s.customer_id
order by points desc
;

# 10.In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?  
with first_week as (
	select s.customer_id,
            sum(if(s.order_date<=date_add(mb.join_date, interval 7 day), m.price*2, m.price)) as points
    from sales as s
    left join members as mb
    on s.customer_id=mb.customer_id
    left join menu as m
    on s.product_id=m.product_id
    group by s.customer_id,
			s.product_id,
            s.order_date,
            mb.join_date,
            m.price
    having s.order_date>=mb.join_date and s.order_date<='2021-01-31'
    )
select f.customer_id,
		sum(points) as total_points
from first_week as f
group by f.customer_id
order by sum(points) desc
;

#Bonus Questions

# 1.Join All The Things
select s.customer_id,
		s.order_date,
		m.product_name,
		m.price,
		if(s.order_date>=mb.join_date,'Y', 'N') as 'member'
from sales as s 
left join members as mb
on s.customer_id=mb.customer_id
left join menu as m
on s.product_id=m.product_id
order by s.customer_id, s.order_date, product_name 
;

# 2.Rank All The Things
with is_member as (
	select s.customer_id,
			s.order_date,
			m.product_name,
			m.price,
			if(s.order_date>=mb.join_date,'Y','N') as member
    from sales as s
	left join members as mb
	on s.customer_id=mb.customer_id
    left join menu as m
	on s.product_id=m.product_id
    )
select *,
		if(member='Y',dense_rank() over(partition by customer_id, member order by order_date), null) as ranking
from is_member
order by customer_id, order_date, product_name        
;

# 8-week-SQL-challenge
<!-- Project Title -->
<h1 align="center"> Week 1 - Danny's Diner </h1>

<img src="logo-week1.png" alt="isolated" width="500"/> 

<!-- Table of Contents -->
## Table of Contents

- [Introduction](#introduction)
- [Dataset](#dataset)
- [Entity Relationship Diagram](#entity-relationship)

<!-- Introduction -->
# Introduction:

Danny, an ardent lover of Japanese cuisine, embarked on a daring journey at the start of 2021. He decided to open a small, charming restaurant named "Danny's Diner," specializing in his three top favorite foods: sushi, curry, and ramen.

Danny's Diner, after a few months of operation, requires your expertise to help them keep the business viable. The diner has managed to collect some basic data during their initial months of operation, yet they are unsure of how to utilize this information effectively to bolster their business operations.

The goal here is for Danny to utilize this data to understand more about his clientele - their visit patterns, their total expenditure, and their preferred items on the menu. Acquiring such insights will enable Danny to personalize the experience for his loyal customers more effectively.

Based on these insights, Danny intends to make an informed decision about whether or not to enhance the existing customer loyalty program. He also needs assistance in creating straightforward datasets so that his team can easily review the data without the need to use SQL.

For privacy reasons, Danny has given a sample of his overall customer data. Nevertheless, he is hopeful that this limited data will be sufficient for you to formulate functional SQL queries to assist him in finding the answers to his questions!

<!-- Dataset -->
# Dataset:


### Table 1: Sales

The sales table captures all customer_id level purchases with an corresponding order_date and product_id information for when and what menu items were ordered.

- Short overview: 

| customer_id | order_date | product_id |
|-------------|------------|------------|
| A           | 2021-01-01 | 1          |
| A           | 2021-01-01 | 2          |
| A           | 2021-01-07 | 2          |
| A           | 2021-01-10 | 3          |
| A           | 2021-01-11 | 3          |
| A           | 2021-01-11 | 3          |
| B           | 2021-01-01 | 2          |
| B           | 2021-01-02 | 2          |
| B           | 2021-01-04 | 1          |
| B           | 2021-01-11 | 1          |
| B           | 2021-01-16 | 3          |
| B           | 2021-02-01 | 3          |
| C           | 2021-01-01 | 3          |
| C           | 2021-01-01 | 3          |
| C           | 2021-01-07 | 3          |


### Table 2: Menu

The menu table maps the product_id to the actual product_name and price of each menu item.

- Short overview: 

| product_id | product_name | price |
|------------|--------------|-------|
| 1          | sushi        | 10    |
| 2          | curry        | 15    |
| 3          | ramen        | 12    |


### Table 3: Members

The final members table captures the join_date when a customer_id joined the beta version of the Danny’s Diner loyalty program.

- Short overview: 

| customer_id | join_date  |
|-------------|------------|
| A           | 2021-01-07 |
| B           | 2021-01-09 |

<!-- Entity Relationship Diagram -->
# Entity Relationship Diagram: 

![Diagram](data-model-week1.png "Entity Relationship Diagram")

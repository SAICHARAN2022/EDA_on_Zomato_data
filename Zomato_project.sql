CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid,signup_date) 
VALUES (1,'2014-09-02'),
(2,'2015-01-15'),
(3,'2014-04-11');


CREATE TABLE sales(userid integer,created_date date,product_id integer); 
select * from sales;
select * from users;
select * from goldusers_signup;
Select * from product;
CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 

INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,'2017-09-22'),
(3,'2017-04-21');

CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);

#Total Amount  each customer spent on zomato;
select s.userid , s.product_id,sum( p.price ) as total_spent from sales s
join product p on s.product_id = p.product_id
group by s.userid;

#how many days has each customer visited zomato

select * from sales;
select * from users;
select * from goldusers_signup;
Select * from product;

select userid , count(distinct created_date ) as no_of_times_visited from sales
group by userid;

#what was the first product purchased by each customer

select * from sales;
select * from users;
select * from goldusers_signup;
Select * from product;


with zomato_sales as(
select s.userid ,s.product_id ,s.created_date, p.product_name ,
row_number() over ( partition by userid order by s.created_date asc ) as rank_no
from sales s
join product p on s.product_id  = p.product_id
order by userid,s.created_date)

select userid , product_name ,created_date, product_id from zomato_sales
where rank_no = 1;

#what is the most  purchased item on the menu and how many times it purchased by all customers

select * from sales;
select * from users;
select * from goldusers_signup;
Select * from product;


    
    select * from sales where 
    product_id = (
	select s.userid , p.product_name , s.product_id, count( p.product_name) as number_of_times_purchased
    from sales s
	join product p on s.product_id  = p.product_id
	group by p.product_name
	order by  number_of_times_purchased desc
    limit 1);

select * from sales
where product_id = (
select product_id,count(product_id) as cnt from sales
group by product_id
order by count(product_id)  desc
limit 1);

select userid , product_id ,count(product_id) over(partition by userid,product_id) from sales
group by userid , product_id;
select * from sales
order by userid, product_id;


with highest_product_sales as (
select *, count(*) as most_purchased ,row_number ()  over ( partition by userid  ) as rank_no from sales
group by userid,product_id
order by userid , product_id
)
select userid,product_id , most_purchased,rank_no from highest_product_sales
where rank_no = 1;

select * from (
select * , row_number () over(partition by userid  order by most_purchased desc ) as rank_no from
(select userid,product_id, count(*) as most_purchased  from sales
group by userid, product_id
order by userid )a ) b
where rank_no = 1;

with selection_of_rank as (

with highest_sales as (
select userid, product_id , count(*)as no_of_times from sales
group by userid, product_id
order by userid, product_id)
select *, row_number () over(partition by userid order by no_of_times desc) as rank_no from highest_sales)

select * from selection_of_rank
where  rank_no = 1;





# Which item was purchased first by the customer after  they becam a member

use projects;
select * from sales;
select * from users;
select * from goldusers_signup;
Select * from product;


with purchased_first as (
with summary as
(select sales.userid,created_date, product_id from sales
where userid in ( select userid from goldusers_signup))
select * ,row_number() over ( partition by userid order by  created_date asc) as rank_no from  summary 
where (userid =  1 and created_date >  '2017-09-22') or  (userid = 3 and  created_date >  '2017-04-21')
order by userid asc , created_date)
select * from purchased_first
where rank_no = 1;

# which item was purchased just before the customer became member
select * from sales;
select * from users;
select * from goldusers_signup;
Select * from product;

with purchased_last as
(
with summary as (
select sales.userid ,sales.created_date,sales.product_id, goldusers_signup.gold_signup_date from sales
join  goldusers_signup on sales.userid =  goldusers_signup.userid and sales.created_date < goldusers_signup.gold_signup_date)
select * , row_number() over(partition by userid  order by created_date desc ) as rank_no from summary
order by userid, created_date desc)
select * from purchased_last
where rank_no  = 1;

# what is the total orders and amount spent for each member before they became a member;


with summary as (
select sales.userid ,sales.created_date,sales.product_id,goldusers_signup.gold_signup_date, product.price  from sales
join goldusers_signup on sales.userid =  goldusers_signup.userid and sales.created_date < goldusers_signup.gold_signup_date
join product on product.product_id = sales.product_id)
select userid,  sum(price) as total_spent ,count(product_id) as no_of_orders from summary
group by userid
order by userid;

select * from sales;
select * from users;
select * from goldusers_signup;
Select * from product;


# calculate points collected by each customers  and for which product most Points have beeen give till now
# if buying  each product generates  points  for eg  5 rs  = 2 zomato points and each product has different purchasing points
#For eg  for p1  5rs = 1 point , p2 10rs = 5 points and p3  5 rs  = 1 zomato point
select * from sales;
select * from users;
select * from goldusers_signup;
Select * from product;


# if buying  each product generates  points  for eg  5 rs  = 2 zomato points and each product has different purchasing points
#For eg  for p1  5rs = 1 point , p2 10rs = 5 points and p3  5 rs  = 1 zomato point


with  Points_calculation as (
select userid, created_date, product.product_name,product.price, 
(case when product.product_name = 'p1' then (product.price/5)  
when product.product_name = 'p2' then (product.price/2)
else (product.price/5) end ) as points
from  sales
join product on product.product_id = sales.product_id)
select userid , product_name , round(sum(points)*2.5,2) as total_revenue from Points_calculation
group by userid ,  product_name
order by userid , total_points desc;
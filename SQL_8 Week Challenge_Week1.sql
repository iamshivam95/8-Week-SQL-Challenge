create database week1sql_challenge;
use week1sql_challenge;
CREATE TABLE sales 
(customer_id VARCHAR(1),
  order_date DATE,
  product_id INT
);
INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
  CREATE TABLE menu (
  product_id INT,
  product_name VARCHAR(5),
  price INT
);
INSERT INTO menu
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  
CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);
INSERT INTO members
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  Select * from sales limit 5;
   Select * from menu limit 5;
   /*Week 1 Challenges */;
  /*Q1 total amount each customer spent at the restaurant-*/;
  Select s.customer_id,sum(m.price)
  from sales as s
  left join menu as m
  on s.product_id=m.product_id
  group by customer_id;
  /*Q2 How many days has each customer visited the restaurant*/;
  Select * from sales limit 5;
  Select customer_id,count(distinct(order_date)) as no_of_visitday
  from sales
  group by customer_id;
  /*What was the first item from the menu purchased by each customer*/;
  With ct1 as (
  Select *,rank()over(partition by customer_id order by order_date) as rk
  from sales)
  Select ct1.customer_id,m.product_name,ct1.order_date
  from ct1 
  left join menu m
  on m.product_id=ct1.product_id
  where rk=1
  group by ct1.customer_id,m.product_name,ct1.order_date;
  /*Q4 What is the most purchased item on the menu and how many times was it purchased by all customers?*/
  with ct2 as
  (Select product_id,count(product_id) as freq
  from sales
  group by product_id
  order by freq desc
  limit 1)
  Select s.customer_id,count(ct2.product_id) as cusfreq
  from sales s 
  left join ct2
  on ct2.product_id=s.product_id
  group by s.customer_id;
  with ct2 as (
  Select product_id,count(product_id) as freq from sales group by product_id order by freq desc)
  Select product_id as most_purchased_product,count(product_id) as freq_most_purchased
  from sales
  where product_id=(Select product_id from ct2 limit 1)
  group by product_id;
  /*Q5 Which item was the most popular for each customer?*/
  with ct1 as( 
  Select customer_id,product_id,count(product_id) as freq from sales group by customer_id,product_id),
  ct2 as (
  Select customer_id,product_id,freq,dense_rank()over(partition by customer_id order by freq desc) as rk from ct1)
  Select * from ct2 where rk =1 order by customer_id,product_id;
  /*Q6Which item was purchased first by the customer after they became a member?*/
  with ct1 as (Select s.*,dense_rank()over(partition by customer_id order by order_date ) as rk
  from Members m
  left join sales s
  On s.order_date>m.join_date and s.customer_id=m.customer_id)
  Select * from ct1 where rk=1;
  
  /*Q7Which item was purchased just before the customer became a member?*/
  with ct1 as (Select s.*,dense_rank()over(partition by customer_id order by order_date desc) as rk
  from Members m
  left join sales s
  On s.order_date<m.join_date and s.customer_id=m.customer_id)
  Select * from ct1 where rk=1;
  
  /*Q8What is the total items and amount spent for each member before they became a member?*/
  with ct1 as (Select s.*,me.price
  from Members m
  left join sales s
  On s.order_date<m.join_date and s.customer_id=m.customer_id
  left join menu me
  on s.product_id= me.product_id)
  Select customer_id,count(product_id) as ct_pd,sum(price) as amt_pd from ct1 group by customer_id;
  
  /*If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?*/
  with ct1 as (Select customer_id,product_name,count(s.product_id) as freq
  from sales s 
  left join menu m
  on m.product_id=s.product_id
  group by customer_id,product_name),ct2 as (
  Select *,
  case when product_name="sushi" then 20*freq 
  else 10*freq end as points
  from ct1)
  select customer_id,sum(points) as point_coll
  from ct2
  group by customer_id;
  
  /*In the first week after a customer joins the program (including their join date)
  they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?*/
  with ct1 as (Select s.*,date_add(date_add(m.join_date, interval '1' week) ,interval '-1' day)as 1weekafjoin
  from Members m
  left join sales s
  On s.order_date>=m.join_date and s.customer_id=m.customer_id),
  ct2 as (
  Select * ,
  case when order_date<=1weekafjoin then 20
   when order_date>1weekafjoin then 10 end as pt
  from ct1)
  Select customer_id,sum(pt)
  from ct2 
  group by customer_id;
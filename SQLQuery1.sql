drop table if exists goldusers_signup;
CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 

INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,'09-22-2017'),
(3,'04-21-2017');

drop table if exists users;
CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'09-02-2014'),
(2,'01-15-2015'),
(3,'04-11-2014');

drop table if exists sales;
CREATE TABLE sales(userid integer,created_date date,product_id integer); 

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'04-19-2017',2),
(3,'12-18-2019',1),
(2,'07-20-2020',3),
(1,'10-23-2019',2),
(1,'03-19-2018',3),
(3,'12-20-2016',2),
(1,'11-09-2016',1),
(1,'05-20-2016',3),
(2,'09-24-2017',1),
(1,'03-11-2017',2),
(1,'03-11-2016',1),
(3,'11-10-2016',1),
(3,'12-07-2017',2),
(3,'12-15-2016',2),
(2,'11-08-2017',2),
(2,'09-10-2018',3);


drop table if exists product;
CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);


select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;

WHAT IS THE TOTAL AMOUNT EACH CUSTOMER SPENT on ZOMATO?
Select userid,sum(price) as total_price from 
sales as a inner join product as b on a.product_id = b.product_id
group by userid;

How many days has each customer visited zomato?
Select userid,count(distinct created_date)From sales group by (userid);

What was the first product purchased by each customer?
select * from(Select *,rank() over (partition by userid order by created_date) number from sales) a
where number=1

What is the most purchased item on the menu and how many times was      
it purchased  by all the customers?
select * from
(Select product_id,count(product_id)no_of_orders from  
sales group by(product_id))as a Order by  no_of_orders;

Which item was the most popular for each of the customer?   
select userid,product_id,total from
(select *,rank() over (partition by userid order by total desc) as num from
(select userid,product_id,count(product_id) as total  from sales group by userid,product_id)a)b
where num = 1

Which item was purchased first by the customer after the become a member?
select userid,product_id,created_date,gold_signup_date from(select b.*, rank() over(partition by userid order by created_date) as num from
(select s.userid,created_date,product_id,gold_signup_date from sales as s inner join goldusers_signup as g 
on s.userid=g.userid where created_date>= gold_signup_date) b)c
where num=1

Which item was purchased by the customer just before become a member?
select userid,product_id,created_date,gold_signup_date from(select b.*, rank() over(partition by userid order by created_date desc) as num from
(select s.userid,created_date,product_id,gold_signup_date from sales as s inner join goldusers_signup as g 
on s.userid=g.userid where created_date<= gold_signup_date) b)c
where num=1

What is the total orders and amount spent for each member before they became a member?
select userid,sum(price) total_spent,count(*)total_order from
(select s.userid,created_date,product_id,gold_signup_date from sales as s inner join goldusers_signup as g 
on s.userid=g.userid where created_date<= gold_signup_date)b
inner join product as p on b.product_id = p.product_id
group by userid


If buying each product generates points for eg 5rs = 2zomato point and each product has different purchasing points
for eg for p1 5rs= 1 zomato point, for p2  10rs=5zomato points and p3 5rs= 1 zomato point
calculate points collected by each customers 
select userid, (total_points*2.5) cashback from
(select userid,sum(points) total_points from
(select d.*, case 
when product_id = 1 then total/5
when product_id = 3 then total/5 
else total/2 
end as points from(
select c.userid,c.product_id,sum(price) total from
(select a.*,b.price from sales a inner join product b on a.product_id = b.product_id)c
group by userid,product_id)d)e
group by userid)f


In the first one year after a  customer joins the gold membership irrespective of what  the customer has purchased  
they earn 5 zomato points for every 10rs spent who earned  more 1  or 3 what  was their  points earning in the first year?
 select *,(total_spent/2) points_earned from
(select userid,sum(price) total_spent from
(select a.*,product_name,price from
(select s.userid,created_date,product_id,gold_signup_date from 
sales as s inner join goldusers_signup as g 
on s.userid=g.userid where created_date>= gold_signup_date and created_date<=dateadd(year,1,gold_signup_date))a
inner join product p on a.product_id = p.product_id)e
group by userid)f

Rank all the transactions of the customers

Select userid,created_date,a.product_id,price,dense_rank() over (partition by userid order by created_date) as serial from 
sales as a inner join product as b on a.product_id = b.product_id










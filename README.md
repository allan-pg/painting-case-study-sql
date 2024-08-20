# Painting Case Study MYSQL
![image](https://github.com/user-attachments/assets/8aea63b3-fd27-433a-876a-621993280836)

## Introduction
Importing data manually into your database especially when its a number of tables, can not only be tiresome but also time consuming. This can be made easier by use of python libraries. Download paintings Data Set from <a href="https://www.kaggle.com/datasets/mexwell/famous-paintings">Kaggle</a>
## Objectives
- Retrieve relevant data from relational databases.
- Summarize large datasets to identify trends and patterns.
- Identify specific segments or trends within data.

## Tools Used
- Pg - Admin
- Jupyter Notebook

## Data Modelling
Identified the relationship among tables via primary and foreign keys in our painting database  

## Painting Database Schema
![image](https://github.com/user-attachments/assets/a76dfedf-9def-4d91-ae2c-4bbdbe065d2f)

## Import Data Using Python
- Create database in PG-admin and call it painting
```sql
create database painting
```
- Open jupyter notebook and install python libraries
```sql
pip install sqlalchemy
pip install pandas
```
- Import Python libraries
```sql
import pandas as pd
from sqlalchemy import create_engine
```
- Create a connection to your pg-admin database
```sql
conn_string = 'postgresql://postgres:1344@localhost/painting'
db = create_engine(conn_string) 
conn = db.connect()
```
- Load files to your database
```sql
files = ['artist', 'canvas_size', 'image_link', 'museum', 'museum_hours', 'product_size', 'subject', 'work']

for file in files:

    df = pd.read_csv(fr"C:\Users\Admin\Desktop\famous painti\{file}.csv")
    df.to_sql(file, con = conn, if_exists='replace', index = False)
```
## Data Analysis in SQL
## Questions Solved 
1. Fetch all the paintings which are not displayed on any museums?
```sql
SELECT *
FROM work
WHERE museum_id is null;
```
2. Are there museums without any paintings?
```sql
select * from museum m
where not exists (select work_id from work w
					 where w.museum_id=m.museum_id)
```
3. How many paintings have an asking price of more than their regular price?
```sql
select count(work_id)
from product_size
where sale_price > regular_price;
```
4. Identify the paintings whose asking price is less than 50% of its regular price
```sql
select *
from product_size
where sale_price < (regular_price/2);
```
5. Which canva size costs the most?
```sql
with cte as (
	select p.size_id, c.label, p.sale_price		
	from product_size p
	inner join canvas_size c on c.size_id::text = p.size_id
	where sale_price in(
			select max(sale_price)
			from product_size)
)
select * from cte;
```
6. Delete duplicate records from work, product_size, subject and image_link tables
```sql
delete from work
where ctid not in(
	select min(ctid)
	from work
	group by work_id);

delete from product_size
where ctid not in(
	select min(ctid)
	from product_size
	group by work_id, size_id);
	
delete from subject
where ctid not in(
	select min(ctid)
	from subject
	group by work_id, subject);
	
delete from image_link
where ctid not in(
	select min(ctid)
	from image_link
	group by work_id);
```
- Identifying duplicates in your table using window functions
```sql
select * from(
select *,
	   row_number() over(partition by work_id) as rn
from work) as x
where x.rn > 1;
```
7. Identify the museums with invalid city information in the given dataset
```sql
select *
from museum
where city ~ '^[0-9]';
```
8. Museum_Hours table has 1 invalid entry. Identify it and remove it.
```sql
delete from museum_hours
where ctid not in (
	select min(ctid)
	from museum_hours
	group by museum_id, day
);
```
9. Fetch the top 10 most famous painting subject
```sql
select subject,
	   count(work_id) as num_of_paintings
from subject
group by subject
order by num_of_paintings desc
limit 10;
```
10. Identify the museums which are open on both Sunday and Monday. Display museum name, city.
```sql
select m.name, m.city, m.state, m.country
from museum_hours mh1
inner join museum m using(museum_id)
where day = 'Sunday' and
exists (
	select museum_id, day
	from museum_hours mh2
	where mh1.museum_id = mh2.museum_id
	and mh2.day = 'Monday');
```
11. How many museums are open every single day?
```sql
select count(*)
from (
	select 
	   count(museum_id) 
	from museum_hours
	group by museum_id
    having count(museum_id) = 7);
```
12. Which are the top 5 most popular museum? (Popularity is defined based on most no of paintings in a museum)
```sql
select m.name,
		count(work_id) 
from work w
inner join museum m on w.museum_id = m.museum_id
group by m.name
order by count(work_id) desc
limit 5;
```
13. Display the 3 least popular canva sizes
```sql
with cte as (
select *
from (
	select c.label,
		   count(w.work_id),
		   dense_rank() over(order by count(work_id)) as rank
	from work w
	inner join product_size p using(work_id)
	inner join canvas_size c on c.size_id::text = p.size_id
	group by c.label) x
where x.rank <= 3)
select * from cte;
```
14. Which museum is open for the longest during a day. Dispay museum name, state and hours open and which day?
```sql
select museum_name,state as city,day, open, close, duration
from (		select m.name as museum_name, m.state, day, open, close
			, to_timestamp(open,'HH:MI AM') 
			, to_timestamp(close,'HH:MI PM') 
			, to_timestamp(close,'HH:MI PM') - to_timestamp(open,'HH:MI AM') as duration
			, rank() over (order by (to_timestamp(close,'HH:MI PM') - to_timestamp(open,'HH:MI AM')) desc) as rnk
			from museum_hours mh
		 	join museum m on m.museum_id=mh.museum_id) x
where x.rnk=1;
```
15. Who are the top 5 most popular artist? (Popularity is defined based on most no of paintings done by an artist)
```sql
select a.full_name,
		count(work_id) 
from artist a
inner join work w on w.artist_id = a.artist_id
group by a.full_name
order by count(work_id) desc
limit 5;
```
16. Which are the 3 most popular and 3 least popular painting styles?
```sql
with cte as 
		(select 
		 style, count(1) as cnt
		,rank() over(order by count(1) desc) rnk
		,count(1) over() as no_of_records
		from work
		where style is not null
		group by style)
select style
,case when rnk <=3 then 'Most Popular' else 'Least Popular' end as remarks 
from cte
where rnk <=3
or rnk > no_of_records - 3;
```
## Findings
- There includes a number of paintings not hanged in museums - 14719 paintings
- All museums have a number of paintings
- Highest price canvas size is  ['48" x 96"(122 cm x 244 cm)'] and the price is  1115
- Cities where some museums are located are in number format
- Potrait is the most famous painting subject with 1070 paintings
- 17 museums are open everyday
- The museum of modern art in New York has the most number of paintings with 939 painting
- "Pierre-Auguste Renoir" has made the most number of painting at 469 paintings
- "Musée du Louvre" in paris is open the most number of hours by being opened over 12 hours

## Reccomendations
- Cities where museums are located and are in number format should be named properly
- Assess the situation of paintings not hanged in museums and hang those that are fit to be hanged

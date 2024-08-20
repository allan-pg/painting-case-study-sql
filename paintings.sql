select * from artist;
select * from canvas_size;
select * from image_link;
select * from museum;
select * from museum_hours;
select * from product_size;
select * from subject;
select * from work;

--1. Fetch all the paintings which are not displayed on any museums?
SELECT *
FROM work
WHERE museum_id is null;

--2) Are there museums without any paintings?
select * from museum m
where not exists (select work_id from work w
					 where w.museum_id=m.museum_id)
					 
--3) How many paintings have an asking price of more than their regular price?
select count(work_id)
from product_size
where sale_price > regular_price;

--4)  Identify the paintings whose asking price is less than 50% of its regular price
select *
from product_size
where sale_price < (regular_price/2)

--5) Which canva size costs the most?
with cte as (
	select p.size_id, c.label, p.sale_price		
	from product_size p
	inner join canvas_size c on c.size_id::text = p.size_id
	where sale_price in(
			select max(sale_price)
			from product_size)
)
select * from cte;
	
--6) Delete duplicate records from work, product_size, subject and image_link tables
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

select * from(
select *,
	   row_number() over(partition by work_id) as rn
from work) as x
where x.rn > 1;


--7) Identify the museums with invalid city information in the given dataset
select *
from museum
where city ~ '^[0-9]';

--8) Museum_Hours table has 1 invalid entry. Identify it and remove it.

delete from museum_hours
where ctid not in (
	select min(ctid)
	from museum_hours
	group by museum_id, day
);

--9) Fetch the top 10 most famous painting subject
select subject,
	   count(work_id) as num_of_paintings
from subject
group by subject
order by num_of_paintings desc
limit 10;

--10) Identify the museums which are open on both Sunday and Monday. Display museum name, city.
select m.name, m.city, m.state, m.country
from museum_hours mh1
inner join museum m using(museum_id)
where day = 'Sunday' and
exists (
	select museum_id, day
	from museum_hours mh2
	where mh1.museum_id = mh2.museum_id
	and mh2.day = 'Monday');

--11) How many museums are open every single day?
select count(*)
from (
	select 
	   count(museum_id) 
	from museum_hours
	group by museum_id
    having count(museum_id) = 7);

--12)  Which are the top 5 most popular museum? (Popularity is defined based on most no of paintings in a museum)
select m.name,
		count(work_id) 
from work w
inner join museum m on w.museum_id = m.museum_id
group by m.name
order by count(work_id) desc
limit 5;

-- 13) Who are the top 5 most popular artist? (Popularity is defined based on most no of paintings done by an artist)
select a.full_name,
		count(work_id) 
from artist a
inner join work w on w.artist_id = a.artist_id
group by a.full_name
order by count(work_id) desc
limit 5;

-- 14) Display the 3 least popular canva sizes
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

-- 15) Which museum is open for the longest during a day. Dispay museum name, state and hours open and which day?
select museum_name,state as city,day, open, close, duration
from (		select m.name as museum_name, m.state, day, open, close
			, to_timestamp(open,'HH:MI AM') 
			, to_timestamp(close,'HH:MI PM') 
			, to_timestamp(close,'HH:MI PM') - to_timestamp(open,'HH:MI AM') as duration
			, rank() over (order by (to_timestamp(close,'HH:MI PM') - to_timestamp(open,'HH:MI AM')) desc) as rnk
			from museum_hours mh
		 	join museum m on m.museum_id=mh.museum_id) x
where x.rnk=1;

--16) Which are the 3 most popular and 3 least popular painting styles?
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


insert into analysis.tmp_rfm_frequency 
select 
	user_id,
	ntile(5) over (order by count(user_id))
from orders o
where o.status = 4
group by user_id;
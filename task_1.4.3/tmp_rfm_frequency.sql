insert into analysis.tmp_rfm_frequency 
select
	o.user_id,
	ntile(5) over (order by count(o.user_id))
from orders o
left join analysis.users u on o.user_id = u.id
where o.status = 4
group by o.user_id;

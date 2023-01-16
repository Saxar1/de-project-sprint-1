insert into analysis.tmp_rfm_recency
select 
	user_id,
	ntile(5) over(ORDER BY MAX(order_ts))
from orders o 
where o.status = 4
group by user_id
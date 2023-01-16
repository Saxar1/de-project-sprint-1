insert into analysis.tmp_rfm_monetary_value
select 
	user_id,
	ntile(5) over (order by SUM(payment))
from orders o
where o.status = 4
group by user_id;
insert into analysis.tmp_rfm_monetary_value
select
	user_id,
	ntile(5) over (order by SUM(payment))
from orders o
left join analysis.users u on o.user_id = u.id
where o.status = 4
group by o.user_id;

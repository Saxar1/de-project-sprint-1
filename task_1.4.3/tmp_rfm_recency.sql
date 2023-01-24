insert into analysis.tmp_rfm_recency
(user_id, recency)
select
	o.user_id,
	ntile(5) over(ORDER BY MAX(o.order_ts)) as recency
from orders o
left join analysis.users u on o.user_id = u.id
where o.status = 4
group by o.user_id;

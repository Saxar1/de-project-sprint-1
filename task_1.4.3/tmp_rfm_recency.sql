with
closed_orders as (
    select *
    from analysis.Orders as o
    where o.status = 4 --closed
),
recency as (
	select
		all_users.id as user_id,
		ntile(5) over(order by max(user_last_orders.last_order_ts)) as recency
	from
		analysis.Users as all_users
            left join
            (
                select
                    user_id,
                    order_ts as last_order_ts
                from (
                    select
                        user_id,
                        order_ts,
                        row_number() over (partition by user_id order by order_ts desc) as rnk
                    from closed_orders
                ) as order_rnk
                where rnk = 1
            ) as user_last_orders
            on all_users.id = user_last_orders.user_id
      group by all_users.id
)
insert into analysis.tmp_rfm_recency
select *
from recency;

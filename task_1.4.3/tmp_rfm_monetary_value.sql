with
closed_orders as (
    select *
    from analysis.Orders as o
    where o.status = 4 --closed
),
monetary_value as (
    select
        all_users.id as user_id,
        ntile(5) over (order by sum(orders.payment)) as monetary_value
    from
    	analysis.Users as all_users
                left join closed_orders as orders
                    on all_users.id = orders.user_id
        group by all_users.id
)
insert into analysis.tmp_rfm_monetary_value
select *
from monetary_value;

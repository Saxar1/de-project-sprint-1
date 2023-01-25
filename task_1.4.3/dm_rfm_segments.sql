insert into analysis.dm_rfm_segments
select *
from analysis.tmp_rfm_recency trr 
inner join analysis.tmp_rfm_frequency trf using (user_id)
inner join analysis.tmp_rfm_monetary_value trmv using (user_id)
order by user_id;

create or replace function get_date()
returns date as $$
begin
    return ('2019-12-31');
end;
$$ language plpgsql;

copy (
with base_items as (
    select
        customer_id,
        to_char(t_date, 'yyyymm') as year_month,
        t.article_id 			  as most_exp_article_id,
        row_number() 	over (partition by customer_id, to_char(t_date, 'yyyymm') order by price desc, id) 				as rn,
        sum(price) 		over (partition by customer_id, to_char(t_date, 'yyyymm') order by customer_id) 				as transaction_amount,
        count(1) 		over (partition by customer_id, to_char(t_date, 'yyyymm') order by customer_id) 				as number_of_articles,
        dense_rank() 	over (partition by customer_id, to_char(t_date, 'yyyymm') order by product_group_name)
        + dense_rank() 	over (partition by customer_id, to_char(t_date, 'yyyymm') order by product_group_name desc) - 1 as number_of_product_groups,
        min(to_char(t_date, 'yyyymm')) over (order by t_date) as min_year_month
    from transactions_train t
    	inner join articles a on t.article_id = a.article_id
), popular_decade as (
    select
    	customer_id,
    	to_char(t_date, 'yyyymm') as year_month,
		case
			when date_part('d', t_date) < 11 then 1
			when date_part('d', t_date) > 20 then 3
			else 2
		end as most_active_decade,
        sum(price) as price,
        row_number() over (partition by customer_id,
        								to_char(t_date, 'yyyymm') order by sum(price) desc,
								        case
									        when date_part('d', t_date) < 11 then 1
								            when date_part('d', t_date) > 20 then 3
								            else 2
								        end) as rn          
    from transactions_train
    where to_char(t_date, 'yyyymm') = to_char(get_date(), 'yyyymm')
    group by customer_id,
    		 to_char(t_date, 'yyyymm'),
			 case
			 	 when date_part('d', t_date) < 11 then 1
			 	 when date_part('d', t_date) > 20 then 3
				 else 2
			 end
), reduced_rows as (
	select
    	bi.customer_id,
		bi.year_month,
		bi.transaction_amount,
		bi.most_exp_article_id,
		bi.number_of_articles,
		bi.number_of_product_groups,
		bi.min_year_month,
		case
			when bi.year_month = bi.min_year_month then 1
			when to_char(to_date(year_month, 'yyyymm') - interval '1 month', 'yyyymm') = bi.min_year_month and
				 lag(bi.year_month, 1) over (partition by bi.customer_id order by bi.year_month) is not null then 1
			when lag(bi.year_month, 1) over (partition by bi.customer_id order by bi.year_month) is not null and
				 lag(bi.year_month, 2) over (partition by bi.customer_id order by bi.year_month) is not null then 1
			else 0
		end as customer_loyalty
	from base_items bi
	where bi.rn = 1 and
		  bi.year_month in (to_char(get_date(), 'yyyymm'),
					        to_char(get_date() - interval '1 month', 'yyyymm'),
					        to_char(get_date() - interval '2 month', 'yyyymm'))
)
select
    get_date() 								 as part_date,
    cst.customer_id,
    case
        when cst.age < 23 then 'S'
        when cst.age > 59 then 'R'
        else 'A'
    end 									 as customer_group_by_age,
    coalesce(rr.transaction_amount, 0) 		 as transaction_amount,
    rr.most_exp_article_id,
    coalesce(rr.number_of_articles, 0) 		 as number_of_articles,
    coalesce(rr.number_of_product_groups, 0) as number_of_product_groups,
    pd.most_active_decade,
    coalesce(rr.customer_loyalty, 0) 		 as customer_loyalty
from customers cst
	left join reduced_rows rr 	on cst.customer_id = rr.customer_id and
								   rr.year_month = to_char(get_date(), 'yyyymm')
	left join popular_decade pd on rr.customer_id = pd.customer_id 	and
								   rr.year_month = pd.year_month 	and
								   pd.rn = 1
)
to './data_mart.csv' delimiter ',' csv header;
create or replace function get_date()
returns date as $$
begin
    return ('2019-12-31');
end;
$$ language plpgsql;

drop table if exists min_year_month cascade;
drop view if exists three_months_transactions cascade;
drop view if exists number_of_product_groups_view cascade;
drop view if exists most_exp_articles_view cascade;
drop view if exists most_active_decade_view cascade;
drop view if exists loyalty_view cascade;
drop view if exists final_view cascade;

create temp table min_year_month as
select to_char(min(t_date), 'yyyymm') as min_year_month
from transactions_train;

create or replace view three_months_transactions as
select
	tt.id,
	tt.t_date,
	to_char(tt.t_date, 'yyyymm') as year_month,
	tt.customer_id,
	tt.article_id,
	tt.price,
	a.product_group_name
from transactions_train tt
	inner join articles a on a.article_id = tt.article_id
where to_char(t_date, 'yyyymm') in (to_char(get_date(), 'yyyymm'),
				                    to_char(get_date() - interval '1 month', 'yyyymm'),
				                    to_char(get_date() - interval '2 month', 'yyyymm'));

create or replace view most_exp_articles_view as
select distinct on (customer_id)
    customer_id,
    article_id as most_exp_article_id
from three_months_transactions
where year_month = to_char(get_date(), 'yyyymm')
order by customer_id, price desc, id;

create or replace view number_of_product_groups_view as
with bought_groups as (
	select
		customer_id,
		product_group_name
	from three_months_transactions
	where year_month = to_char(get_date(), 'yyyymm')
	group by customer_id, product_group_name
)
select
	customer_id,
	count(product_group_name) as number_of_product_groups
from bought_groups
group by customer_id;

create or replace view most_active_decade_view as
select distinct on (customer_id)
	sum(price) sum_price,
	customer_id,
	case
		when date_part('d', t_date) < 11 then 1
		when date_part('d', t_date) > 20 then 3
		else 2
	end as most_active_decade
from
	three_months_transactions
where year_month = to_char(get_date(), 'yyyymm')
group by customer_id,
		 to_char(t_date, 'yyyymm'),
		 case
		 	 when date_part('d', t_date) < 11 then 1
		 	 when date_part('d', t_date) > 20 then 3
			 else 2
		 end
order by customer_id, sum_price desc, most_active_decade;

create or replace view loyalty_view as
with customers_in_month as (
	select
		customer_id,
		year_month
	from three_months_transactions
	group by year_month, customer_id
)
select
	cim.customer_id,
	case
		when cim.year_month = mym.min_year_month then 1
		when prm.year_month is not null and prm2.year_month = mym.min_year_month then 1
		when prm.year_month is not null and prm2.year_month is not null then 1
		else 0
	end as customer_loyalty
from
	customers_in_month cim
	left join customers_in_month prm  on cim.customer_id = prm.customer_id  and prm.year_month = to_char(get_date() - interval '1 month', 'yyyymm')
	left join customers_in_month prm2 on cim.customer_id = prm2.customer_id and prm2.year_month = to_char(get_date() - interval '2 month', 'yyyymm')
	cross join min_year_month mym
where cim.year_month = to_char(get_date(), 'yyyymm');

create or replace view final_view as
with current_customers as (
	select
		customer_id,
		count(price) as number_of_articles,
		sum(price) 	 as transaction_amount
	from three_months_transactions
	where year_month = to_char(get_date(), 'yyyymm')
	group by customer_id
)
select
	get_date() part_date,
	cc.customer_id,
	case
    	when c.age < 23 then 'S'
        when c.age > 59 then 'R'
        else 'A'
  	end as customer_group_by_age,
	cc.transaction_amount,
	meav.most_exp_article_id,
	cc.number_of_articles,
	nopgv.number_of_product_groups,
	madv.most_active_decade,
	lv.customer_loyalty
from
	current_customers cc
	inner join customers 					 c 		on cc.customer_id = c.customer_id 
	inner join loyalty_view                  lv 	on cc.customer_id = lv.customer_id
	inner join number_of_product_groups_view nopgv 	on cc.customer_id = nopgv.customer_id
	inner join most_exp_articles_view        meav	on cc.customer_id = meav.customer_id
	inner join most_active_decade_view		 madv 	on cc.customer_id = madv.customer_id;
	
copy (select * from final_view) to './data_mart_with_view.csv' delimiter ',' csv header;
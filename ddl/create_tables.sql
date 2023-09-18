drop table if exists articles;
drop table if exists transactions_train;
drop table if exists customers;

create table articles (
    article_id varchar(255),
    product_code varchar(255),
    prod_name varchar(255),
    product_type_no int,
    product_type_name varchar(255),
    product_group_name varchar(255),
    graphical_appearance_no int,
    graphical_appearance_name varchar(255),
    colour_group_code varchar(255),
    colour_group_name varchar(255),
    perceived_colour_value_id int,
    perceived_colour_value_name varchar(255),
    perceived_colour_master_id int,
    perceived_colour_master_name varchar(255),
    department_no int,
    department_name varchar(255),
    index_code varchar(255),
    index_name varchar(255),
    index_group_no int,
    index_group_name varchar(255),
    section_no int,
    section_name varchar(255),
    garment_group_no int,
    garment_group_name varchar(255),
    detail_desc text
);
create table transactions_train (
    t_date date,
    customer_id varchar(255),
    article_id varchar(255),
    price decimal,
    sales_channel_id int
);
create table customers (
    customer_id varchar(255),
    fn varchar(255),
    active varchar(255),
    club_member_status varchar(255),
    fashion_news_frequency varchar(255),
    age int,
    postal_code varchar(255)
);
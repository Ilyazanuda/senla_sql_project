copy articles from '.\data_kaggle\articles.csv' delimiter ',' csv header;
copy transactions_train from '.\data_kaggle\transactions_train.csv' delimiter ',' csv header;
copy customers from '.\data_kaggle\customers.csv' delimiter ',' csv header;

alter table transactions_train
add column id serial primary key;

copy articles from './articles.csv' delimiter ',' csv header;
copy transactions_train from './transactions_train.csv' delimiter ',' csv header;
copy customers from './customers.csv' delimiter ',' csv header;

alter table transactions_train
add column id serial primary key;

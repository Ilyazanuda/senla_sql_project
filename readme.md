# Workflow Sequence

### 1. Move CSV Files
Before proceeding, make sure to place your CSV files in the repository directory.

### 2. Database Setup
To set up the necessary database tables, follow these steps:

- Run the script `ddl\create_tables.sql` to create the required database tables.

### 3. Import Data from CSV
After setting up the tables, import data from CSV files using the following steps:

- Execute the script `dml\import_from_csv.sql` to load data from CSV files into the database.

### 4. Export Data Mart
Finally, if needed, export data from the data mart using the script `dml\export_data_mart.sql`.

## Links

- CSV data ```https://www.kaggle.com/competitions/h-and-m-personalized-fashion-recommendations/data```
- Data mart ```https://drive.google.com/file/d/11sDTn0Y-fvpvf7r8dwFwLj-crpC3AMP5/view?usp=sharing```
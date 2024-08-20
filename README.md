# Painting Case Study MYSQL
![image](https://github.com/user-attachments/assets/8aea63b3-fd27-433a-876a-621993280836)

## Introduction
Importing data manually into your database especially when its a number of tables, can not only be tiresome but also time consuming. This can be made easier by use of python libraries. Download paintings Data Set from <a href="https://www.kaggle.com/datasets/mexwell/famous-paintings">Kaggle</a>
## Objectives
- Retrieve relevant data from relational databases.
- Summarize large datasets to identify trends and patterns.
- Identify specific segments or trends within data.

## Tools Used
- Pg - Admin
- Jupyter Notebook

## Data Modelling
## Painting Database Schema
![image](https://github.com/user-attachments/assets/a76dfedf-9def-4d91-ae2c-4bbdbe065d2f)

## Import Data Using Python
- Create database in PG-admin and call it painting
```sql
create database painting
```
- Open jupyter notebook and install python libraries
```sql
pip install sqlalchemy
pip install pandas
```
- Import Python libraries
```sql
import pandas as pd
from sqlalchemy import create_engine
```
- Create a connection to your pg-admin database
```sql
conn_string = 'postgresql://postgres:1344@localhost/painting'
db = create_engine(conn_string) 
conn = db.connect()
```
- Load files to your database
```sql
files = ['artist', 'canvas_size', 'image_link', 'museum', 'museum_hours', 'product_size', 'subject', 'work']

for file in files:

    df = pd.read_csv(fr"C:\Users\Admin\Desktop\famous painti\{file}.csv")
    df.to_sql(file, con = conn, if_exists='replace', index = False)
```
## Data Analysis in SQL
## Questions Solved 

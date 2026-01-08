# Data Cleaning and Dashboard generation using PowerBI

  The objective of this project is to demonstrate data cleaning of a table that consists of 10,000 rows using Microsoft SQL Server Management Studio 22 (MSSQL). The table came from Kaggle and was chosen because of how it mirrors how dirty real-world datasets can be. It consists of intentional missing values, inconsistent data, and errors. Later in the project after the data cleaning, the resulting cleaned table will be used to create a dashboard using PowerBI and draw insights from it. 
  
  The said table was taken from [kaggle](https://www.kaggle.com/datasets/ahmedmohamed2003/cafe-sales-dirty-data-for-cleaning-training) and will be available for reproduction here along with the PowerBI dashboard. 

  The table price_ref contains the prices of different items. Note that the values of this table was taken from the same page as the dirty_cafe_sales and that the table itself was made within the SQL file. 

***  
# Data Cleaning

  Before cleaning the data, I want to explain that version control was not available to me while working on this project nor did I know if it was necessary before working on one. But to be safe I mimicked a version control by making separate tables when a significant change was done to the preceding table. 

The data cleaning was done using these steps specifically because of the data chosen. 
### 1. Understanding Granularity 
Before and after cleaning before analyzing, it is important to understand the granularity of the table and whether it is consistent or not. 
### 2. Checking for Correct Data Types
To avoid having incorrect values in the wrong column, formatting a column to only accept a specific type of data can be done which will return "error" when an incorrect entry is punched in. 
### 3. Standardization
Making sure that the columns across the table follows same naming conventions or data formats. 
### 4. Dealing with null values
Deciding whether to omit/impute, and/or flag null values depending on the need/questions of the business. 
### 5. Producing analysis ready file    
The final step before analyzing the data.
# Note: 
Common business questions that I could think of will be answered via both SQL and PowerBI dashboard. 
The full detailed break-down of the SQL data cleaning will be available in a pdf file. 

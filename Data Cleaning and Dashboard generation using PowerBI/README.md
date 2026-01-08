# Data Cleaning and Dashboard generation using PowerBI

  The objective of this project is to demonstrate data cleaning of a table that consists of 10,000 rows using Microsoft SQL Server Management Studio 22 (MSSQL). The table came from Kaggle and was chosen because of how it mirrors how dirty real-world datasets can be. It consists of intentional missing values, inconsistent data, and errors. Later in the project after the data cleaning, the resulting cleaned table will be used to create a dashboard using PowerBI and draw insights from it. 
  
  The said table was taken from [kaggle](https://www.kaggle.com/datasets/ahmedmohamed2003/cafe-sales-dirty-data-for-cleaning-training) and will be available for reproduction here along with the PowerBI dashboard. 

  The table price_ref contains the prices of different items. Note that the values of this table was taken from the same page as the dirty_cafe_sales and that the table itself was made within the SQL file. 

***  
# Data Cleaning

  Before cleaning the data, I want to explain that version control was not available to me while working on this project nor did I know if it was necessary before working on one. But to be safe I mimicked a version control by making separate tables when a significant change was done to the preceding table. 

The data cleaning was done using these steps.
### 1. Understanding Granularity 
Before and after cleaning before analyzing, it is important to understand the granularity of the table and whether it is consistent or not. 
### 2. Checking for Correct Data Types
To avoid having incorrect values in the wrong column, formatting a column to only accept a specific type of data can be done which will return "error" when an incorrect entry is punched in. 
### 3. Standardization and dealing with nulls
Making sure that the columns across the table follows same naming conventions or data formats and that nulls are dealt with.
### 4. Conditional imputation 
Missing values from some columns that can be imputed will be done so using conditional mean and not global to properly represent each item. 
### 5. Overriding Total_Spent column and adding an 'Issue' column 
Removing remaining null values from Total_Spent column by putting a formula into the column and adding an Issue column to flag remaining nulls for PowerBI.
### 6. Producing a file ready for PowerBI    
The final step before analyzing the data.
# Note: 
Common business questions that I could think of will be answered via both SQL and PowerBI dashboard. 
The full detailed break-down of the SQL data cleaning will be available in a pdf file. 

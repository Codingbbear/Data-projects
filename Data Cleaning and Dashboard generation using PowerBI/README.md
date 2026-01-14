# Data Cleaning and Dashboard generation using PowerBI

  The objective of this project is to demonstrate data cleaning of a table that consists of 10,000 rows using Microsoft SQL Server Management Studio 22 (MSSQL). The table came from Kaggle and was chosen because of how it mirrors how dirty real-world datasets can be. It consists of intentional missing values, inconsistent data, and errors. Later in the project after the data cleaning, the resulting cleaned table will be used to create a dashboard using PowerBI and draw insights from it. 
  
  The said table was taken from [kaggle](https://www.kaggle.com/datasets/ahmedmohamed2003/cafe-sales-dirty-data-for-cleaning-training) and will be available for reproduction here along with the PowerBI dashboard. 
  A price_ref table is available here in the repo but will not be used and only serve as a mental lookup.

***  
# Data Cleaning with PowerBI

The data cleaning was done using these steps.
### 1. Understanding Granularity 
Before and after cleaning before analyzing, it is important to understand the granularity of the table and whether it is consistent or not. 
### 2. Standardization of text and numeric values 
Here format texts to a fixed casing and also casting the numerics to right data type if not already done by default. 
### 3. Imputation  (3 rounds)
Missing numeric values will be carefully imputed with consideration to how they can skew the integrity of the data. 
### 4. Adding an 'Issue' column 
Adding an Issue column to flag remaining nulls for PowerBI.
### 5. Producing a file ready for PowerBI    
The final step before analyzing the data. 
# Note: 
Common business questions that I could think of will be answered via both SQL and PowerBI dashboard. 
The full detailed break-down of the SQL data cleaning will be available in a pdf file. 

***
# PowerBI Dashboard
### 1. Cleaning the cleaned data. 
### 2. 

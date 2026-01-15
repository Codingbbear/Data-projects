# Data Cleaning and Dashboard generation using PowerBI
# Overview
  This project's main goal is showcase data cleaning, , grain validation, standardizing, and safe imputations or calculations of columns using a table that mirrors real-world dirty transactional table which would then be used in PowerBI to produce insights and a dashboard that will include key KPIs about the business given the available data. 

### The table
   The table (dirty_cafe_sales.csv) came from Kaggle and was chosen because of how it mirrors how dirty real-world datasets can be. It consists of intentional missing values, inconsistent data, and errors. Later in the project after the data cleaning, the resulting cleaned table will be used to create a dashboard using PowerBI and draw insights from it. 
  
  The said table was taken from [kaggle](https://www.kaggle.com/datasets/ahmedmohamed2003/cafe-sales-dirty-data-for-cleaning-training) and will be available for reproduction here along with the PowerBI dashboard. 
  A price_ref table is available here in the repo but will not be used and only serve as a mental lookup.

  A .txt file will also be included to show the mental structure that was followed for the whole duration of data cleaning. 

***  
# Data Cleaning with SQL Server
Separate tables were made from preceding tables to compare how much progress is made each step of the way. These tables are not available in the repo since it already is in the query which you can create in your own database if you so choose to replicate this process. 

The data cleaning was done in different stages.
### 1. Understanding Granularity 
Before and after cleaning before analyzing, it is important to understand the granularity of the table and whether it is consistent or not. 
### 2. Standardization of text and numeric values 
Texts are given fixed casing and numerics are casted to the right data type based on what their columns represent. 
### 3. Imputation and Calculations (3 rounds)
Missing numeric values will be carefully imputed and calculated with consideration to how they can skew the integrity of the data. And if they will affect integrity, then null. 
### 4. Adding an 'Issue' column and re-validating grain before moving on to powerBI
Adding an Issue column to flag remaining nulls for PowerBI.
### 5. Producing 2 files ready for PowerBI    
Usable file containing rows with only VALID values and Unusable with INVALID values. 
# Note: 

Common business questions that I could think of will be answered via both SQL and PowerBI dashboard. 
The full detailed break-down of the SQL data cleaning will be available in a pdf file. 



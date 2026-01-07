# Data Cleaning and Dashboard generation using PowerBI

  The objective of this project is to demonstrate data cleaning of a table that consists of 10,000 rows using Microsoft SQL Server Management Studio 22 (MSSQL). The table came from Kaggle and was chosen because of how it mirrors how dirty real-world datasets can be. It consists of intentional missing values, inconsistent data, and errors. Later in the project after the data cleaning, the resulting cleaned table will be used to create a dashboard using PowerBI and draw insights from it. 

  The said table was taken from [kaggle](https://www.kaggle.com/datasets/ahmedmohamed2003/cafe-sales-dirty-data-for-cleaning-training) and will be available for reproduction here along with the PowerBI dashboard. 


***
# Data Cleaning

  Before cleaning the data, I want to explain that version control was not available to me while working on this project nor did I know if it was necessary before working on one. But to be safe I mimicked a version control by making separate tables when a significant change was done to the preceding table. 

The Data Cleaning will be done in a structured manner and will be done in a couple of steps. 
### 1. Understanding Granularity 
To avoid problems when performing joins across tables and to also understand your data we need to understand what the grain represents. 
### 2. Checking for Correct Data Types
To avoid having incorrect values in the wrong column, formatting a column to only accept a specific type of data can be done which will return "error" when an incorrect entry is punched in. 
### 3. Standardization
Sifting through the data and making sure that the table is readable and does not contain redundant values making it ready for further analysis. 
### 4. Dealing with null values
Deciding whether to omit or flag null values depending on the need/questions of the business. 
### 5. Producing analysis ready file    
The final step
# Note: 
Common business questions that I could think of will be answered via both SQL and PowerBI dashboard. For SQL, they will be included in the end of the SQL file. 

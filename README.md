# 🏗️ Data Warehouse and Analytics Project

Welcome to the **Data Warehouse Project** repository! 🚀  

This is my **first data warehousing project**, built using **SQL Server**. The goal of this project is to understand the fundamentals of **data warehousing and analytics** by designing a structured data warehouse and generating insights from it.

In this project, I have built a complete data warehouse and **created analytical outputs for customers and products** to support reporting and business analysis.

---

## 🏛️ Data Architecture

The project follows a **layered (Medallion) architecture**:

1. **Bronze Layer**  
   Stores raw data ingested from source systems (CSV files) into SQL Server without modification.

2. **Silver Layer**  
   Performs data cleansing, standardization, and transformation to ensure data quality and consistency.

3. **Gold Layer**  
   Contains analytics-ready data modeled using **fact and dimension tables**, which are used for **customer and product analytics**.

---

## 📊 Analytics Overview

Using the **Gold layer**, I have created analytics focused on:

- Customer analysis (customer details, demographics, and activity)
- Product analysis (product categories, pricing, and sales behavior)

These analytics help demonstrate how warehouse data can be transformed into meaningful business insights.

---

## 📖 Project Scope

This project covers:

- Designing a modern **SQL Server data warehouse**
- Building **ETL pipelines** to load and transform data
- Creating **fact and dimension tables** for analytics
- Developing **customer and product analytics** from the Gold layer

---

## 🛠️ Tools & Technologies

Everything is for Free! 
- **[Datasets](datasets/):** Access to the project dataset (csv files). 
- **[SQL Server Express](https://www.microsoft.com/en-us/sql-server/sql-server-downloads):** Lightweight server for hosting your SQL database.
- **[SQL Server Management Studio (SSMS)](https://learn.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms?view=sql-server-ver16):** GUI for managing and interacting with databases.
- **[Git Repository](https://github.com/):** Set up a GitHub account and repository to manage, version, and collaborate on your code efficiently.

---

## 🚀 Project Requirements

### Objective
Build a data warehouse using SQL Server that integrates data from multiple sources and supports **analytics on customers and products**.

### Key Features
- Data ingestion from ERP and CRM CSV files
- Data cleansing and validation
- Integration into a single analytical model
- Focus on current data (no historization)
- Clear documentation of data models and analytics

---

### 📂 SQL Server Data Warehouse Structure

The image above shows the complete **SQL Server data warehouse implementation** created for this project.  
It includes:

- **Bronze layer tables** for raw CRM and ERP data ingestion
- **Silver layer tables** for cleansed and standardized data
- **Gold layer views** with dimension and fact tables
- **Analytics views** for customer and product reporting

This structure demonstrates an end-to-end data warehousing workflow implemented using **SQL Server and T-SQL**.


<img width="1919" height="990" alt="image" src="https://github.com/user-attachments/assets/a83b560f-b81f-4d79-acfa-960c665a407d" />


## 🌟 About Me

Hi, I’m **Khana Patro**.  
I am learning **Data Engineering** and building my first **data warehouse projects using SQL Server**. Through this project, I am gaining hands-on experience in **SQL, ETL processes, data modeling**, and **creating analytics for customers and products**.

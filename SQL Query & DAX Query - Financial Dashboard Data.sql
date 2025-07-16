
--PostgreSQL--

-- 0. Create Database
CREATE DATABASE ccdb;

-- 1. Create Table: cc_detail
CREATE TABLE cc_detail (
    Client_Num INT,
    Card_Category VARCHAR(20),
    Annual_Fees INT,
    Activation_30_Days INT,
    Customer_Acq_Cost INT,
    Week_Start_Date DATE,
    Week_Num VARCHAR(20),
    Qtr VARCHAR(10),
    current_year INT,
    Credit_Limit DECIMAL(10,2),
    Total_Revolving_Bal INT,
    Total_Trans_Amt INT,
    Total_Trans_Ct INT,
    Avg_Utilization_Ratio DECIMAL(10,3),
    Use_Chip VARCHAR(10),
    Exp_Type VARCHAR(50),
    Interest_Earned DECIMAL(10,3),
    Delinquent_Acc VARCHAR(5)
);

-- 2. Create Table: cust_detail
CREATE TABLE cust_detail (
    Client_Num INT,
    Customer_Age INT,
    Gender VARCHAR(5),
    Dependent_Count INT,
    Education_Level VARCHAR(50),
    Marital_Status VARCHAR(20),
    State_cd VARCHAR(50),
    Zipcode VARCHAR(20),
    Car_Owner VARCHAR(5),
    House_Owner VARCHAR(5),
    Personal_Loan VARCHAR(5),
    Contact VARCHAR(50),
    Customer_Job VARCHAR(50),
    Income INT,
    Cust_Satisfaction_Score INT
);

-- 3. Import Data into Tables (PostgreSQL)

SET datestyle = 'DMY';

COPY cc_detail
FROM 'E:\Business Analytics\Power BI\Projects\credit_card.csv'
DELIMITER ','
CSV HEADER;

COPY cust_detail
FROM 'E:\Business Analytics\Power BI\Projects\customer.csv'
DELIMITER ','
CSV HEADER;

-- 4. Sample Queries to View Data
SELECT * FROM cc_detail;
SELECT * FROM cust_detail;


-- 5. DAX Calculated Columns and Measures (For Power BI)

-- Age Group Classification
AgeGroup = 
SWITCH(
    TRUE(),
    'public cust_detail'[customer_age] < 30, "20-30",
    'public cust_detail'[customer_age] >= 30 && 'public cust_detail'[customer_age] < 40, "30-40",
    'public cust_detail'[customer_age] >= 40 && 'public cust_detail'[customer_age] < 50, "40-50",
    'public cust_detail'[customer_age] >= 50 && 'public cust_detail'[customer_age] < 60, "50-60",
    'public cust_detail'[customer_age] >= 60, "60+",
    "unknown"
)

-- Income Group Classification
IncomeGroup = 
SWITCH(
    TRUE(),
    'public cust_detail'[income] < 35000, "Low",
    'public cust_detail'[income] >= 35000 && 'public cust_detail'[income] < 70000, "Med",
    'public cust_detail'[income] >= 70000, "High",
    "unknown"
)

-- Week Number (based on start date)
week_num2 = WEEKNUM('public cc_detail'[week_start_date])

-- Revenue Calculation
Revenue = 
'public cc_detail'[annual_fees] + 
'public cc_detail'[total_trans_amt] + 
'public cc_detail'[interest_earned]

-- Current Week Revenue
Current_week_Revenue = 
CALCULATE(
    SUM('public cc_detail'[Revenue]),
    FILTER(
        ALL('public cc_detail'),
        'public cc_detail'[week_num2] = MAX('public cc_detail'[week_num2])
    )
)

-- Previous Week Revenue
Previous_week_Revenue = 
CALCULATE(
    SUM('public cc_detail'[Revenue]),
    FILTER(
        ALL('public cc_detail'),
        'public cc_detail'[week_num2] = MAX('public cc_detail'[week_num2]) - 1
    )
)


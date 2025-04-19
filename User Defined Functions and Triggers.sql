-- EC_IT143_6.3 - Fun with Functions and Triggers

-- ======================================
-- Scalar Functions Section
-- ======================================

-- Step 1: Ask a question
-- Script: EC_IT143_6.3_fwf_s1_fq.sql
-- Question: How do I extract the first name from the ContactName column?

-- Step 2: Begin creating an answer
-- Script: EC_IT143_6.3_fwf_s2_fq.sql
-- Answer plan: Use CHARINDEX and SUBSTRING to extract text before the space.

-- Step 3: Create ad hoc query
-- Script: EC_IT143_6.3_fwf_s3_fq.sql
SELECT ContactName, 
       SUBSTRING(ContactName, 1, CHARINDEX(' ', ContactName + ' ') - 1) AS FirstName
FROM dbo.t_w3_schools_customers;

-- Step 4: Research result: Used Stack Overflow & Microsoft Docs
-- Resource URLs:
-- https://stackoverflow.com/questions/5210656/sql-server-split-string
-- https://learn.microsoft.com/en-us/sql/t-sql/functions/substring-transact-sql

-- Step 5: Create scalar function
-- Script: EC_IT143_6.3_fwf_s5_fq.sql
CREATE FUNCTION dbo.ufn_GetFirstName(@ContactName NVARCHAR(100))
RETURNS NVARCHAR(50)
AS
BEGIN
    RETURN SUBSTRING(@ContactName, 1, CHARINDEX(' ', @ContactName + ' ') - 1)
END;
GO

-- Step 6: Compare UDF and ad hoc result
-- Script: EC_IT143_6.3_fwf_s6_fq.sql
SELECT ContactName, 
       dbo.ufn_GetFirstName(ContactName) AS FirstName,
       SUBSTRING(ContactName, 1, CHARINDEX(' ', ContactName + ' ') - 1) AS AdHocFirstName
FROM dbo.t_w3_schools_customers;

-- Step 7: 0 results expected test
-- Script: EC_IT143_6.3_fwf_s7_fq.sql
WITH cte_test AS (
    SELECT ContactName
    FROM dbo.t_w3_schools_customers
    WHERE dbo.ufn_GetFirstName(ContactName) != 
          SUBSTRING(ContactName, 1, CHARINDEX(' ', ContactName + ' ') - 1)
)
SELECT * FROM cte_test; -- Expect 0 rows

-- Step 8: Ask next question
-- Script: EC_IT143_6.3_fwf_s8_fq.sql
-- Question: How do I extract the last name from the ContactName column?

-- Create function for last name
CREATE FUNCTION dbo.ufn_GetLastName(@ContactName NVARCHAR(100))
RETURNS NVARCHAR(50)
AS
BEGIN
    RETURN LTRIM(RIGHT(@ContactName, LEN(@ContactName) - CHARINDEX(' ', @ContactName + ' ')))
END;
GO

-- ======================================
-- Trigger Section
-- ======================================

-- Step 1: Ask a question
-- Script: EC_IT143_6.3_fwt_s1_fq.sql
-- Question: How do I track the last modified date of a record?

-- Step 2: Begin answer
-- Script: EC_IT143_6.3_fwt_s2_fq.sql
-- Plan: Add LastModifiedDate column and create AFTER UPDATE trigger to set it.

-- Step 3: Research result:
-- https://learn.microsoft.com/en-us/sql/t-sql/statements/create-trigger-transact-sql
-- https://stackoverflow.com/questions/14668906/trigger-to-update-column-when-row-is-updated

-- Step 4: Create after-update trigger
-- Script: EC_IT143_6.3_fwt_s4_fq.sql
ALTER TABLE dbo.t_w3_schools_customers
ADD LastModifiedDate DATETIME, LastModifiedBy NVARCHAR(100);
GO

CREATE TRIGGER trg_UpdateCustomer
ON dbo.t_w3_schools_customers
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE c
    SET LastModifiedDate = GETDATE(),
        LastModifiedBy = SUSER_NAME()
    FROM dbo.t_w3_schools_customers c
    INNER JOIN inserted i ON c.CustomerID = i.CustomerID;
END;
GO

-- Step 5: Test trigger
-- Script: EC_IT143_6.3_fwt_s5_fq.sql
UPDATE dbo.t_w3_schools_customers
SET City = City -- No real change but triggers an update
WHERE CustomerID = 1;

SELECT CustomerID, LastModifiedDate, LastModifiedBy
FROM dbo.t_w3_schools_customers
WHERE CustomerID = 1;

-- Step 6: Ask next question
-- Script: EC_IT143_6.3_fwt_s6_fq.sql
-- Question: How do I set LastModifiedBy to server user?
-- Answer: Already achieved using SUSER_NAME() in the trigger.

-- End of Scripts
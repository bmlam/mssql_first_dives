use master
GO

ALTER DATABASE AdventureWorksDW2019 
	ADD FILEGROUP SECONDARY
;
GO
ALTER DATABASE AdventureWorksDW2019
	ADD FILE 
( NAME = SECONDARY_FILE1
	,FILENAME = '/var/opt/mssql/data/AdventureWorksDW2019_secondary_1.mdf'
	,SIZE = 5MB, MAXSIZE=10MB, FILEGROWTH = 50%
)
TO FILEGROUP SECONDARY
;
GO

USE AdventureWorksDW2019
GO 

--  following query show FILEGROUP of the table/index 
select OBJECT_NAME(i.object_id) as tableName, i.name AS indexName, i.index_id, d.name AS indexFileGroup 
from sys.tables t 
left join sys.indexes i ON t.object_id = i.object_id -- indexes.object_id points to object_id of the table!
LEFT JOIN sys.data_spaces d  ON i.data_space_id = d.data_space_id
where t.object_id = OBJECT_ID('dbo.DimAccount')
-- and i.index_id<2

--SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.DimAccount')

-- Table DimAccount obviously was shipped with primary key on AccountCodeAlternateKey, with a foreign key constraint from ParentAccountCodeAlternateKey to the PK.
-- Similary FinanceAccount has a foreign key to the "wrong" PK.
-- as exercise, the student is expected to drop these "wrong" FKs and build the "correct" PK and FKs

CREATE CLUSTERED INDEX clustix_accKey 
ON dbo.DimAccount ( accountKey )
WITH (DROP_EXISTING = ON)
ON SECONDARY
;
/* Following error popped up:
Cannot create more than one clustered index on table 'dbo.DimAccount'. Drop the existing clustered index 'PK_DimAccount' before creating another.
 */

ALTER TABLE dbo.FactFinance DROP CONSTRAINT FK_FactFinance_DimAccount
;
ALTER TABLE dbo.DimAccount DROP CONSTRAINT FK_DimAccount_DimAccount
;
-- Drop CONSTRAINT below will also remove the index!
ALTER TABLE dbo.DimAccount DROP CONSTRAINT PK_DimAccount
;
--DROP INDEX PK_DimAccount ON dbo.DimAccount
;
GO 

CREATE CLUSTERED INDEX PK_DimAccount 
ON dbo.DimAccount ( AccountKey )
--WITH (DROP_EXISTING = ON)
ON SECONDARY
;
--
-- partition DimDate
--
CREATE PARTITION FUNCTION split_by_year_number ( smallint )
AS RANGE LEFT 
FOR VALUES ( 2010 )
;
-- The following only works when "PRIMARY" is wrapped by square brackets. Presumably PRIMARX is a reserved keyword 
-- and needs the brackets to "cast" it as an identifier

CREATE PARTITION SCHEME place_split_by_year_number 
AS PARTITION split_by_year_number 
TO ( [PRIMARY], SECONDARY )
;
GO

-- find the PK of the table 
select OBJECT_NAME(i.object_id) as tableName, i.name AS indexName, i.index_id, d.name AS indexFileGroup 
from sys.tables t 
left join sys.indexes i ON t.object_id = i.object_id -- indexes.object_id points to object_id of the table!
LEFT JOIN sys.data_spaces d  ON i.data_space_id = d.data_space_id
where t.object_id = OBJECT_ID('dbo.DimDate')

-- Drop FKs to the PK. I was hoping by scripting the DROP INDEX of PK_DimDate_DateKey ( it was not visible as CONSTRAINT)
-- in SSMS, it would cascade the DROP CONSTRAINT to child tables. No, the script only touches the PK itself.

SELECT * FROM sys.foreign_keys f WHERE  f.referenced_object_id = object_id( 'DimDate')
;
-- Script the ALTER TABLE .. DROP CONSTRAINT for the FKs
SELECT f.name as FK_constraint,
   OBJECT_NAME(f.parent_object_id) TableName,
   COL_NAME(fc.parent_object_id,fc.parent_column_id) ColName
 , 'ALTER TABLE ' + OBJECT_NAME(f.parent_object_id) + ' DROP CONSTRAINT ' + f.name + ';' ddl 
FROM    sys.foreign_keys AS f
INNER JOIN    sys.foreign_key_columns AS fc       ON f.OBJECT_ID = fc.constraint_object_id
INNER JOIN    sys.tables t       ON t.OBJECT_ID = fc.referenced_object_id
WHERE    f.referenced_object_id = object_id( 'DimDate')
;   
ALTER TABLE FactSurveyResponse DROP CONSTRAINT FK_FactSurveyResponse_DateKey
;
ALTER TABLE FactSalesQuota DROP CONSTRAINT FK_FactSalesQuota_DimDate
;
ALTER TABLE FactResellerSales DROP CONSTRAINT FK_FactResellerSales_DimDate2
;
ALTER TABLE FactResellerSales DROP CONSTRAINT FK_FactResellerSales_DimDate1
;
ALTER TABLE FactResellerSales DROP CONSTRAINT FK_FactResellerSales_DimDate
;
ALTER TABLE FactProductInventory DROP CONSTRAINT FK_FactProductInventory_DimDate
;


ALTER TABLE FactCallCenter DROP CONSTRAINT FK_FactCallCenter_DimDate;
ALTER TABLE FactCurrencyRate DROP CONSTRAINT FK_FactCurrencyRate_DimDate;
ALTER TABLE FactFinance DROP CONSTRAINT FK_FactFinance_DimDate;
ALTER TABLE FactInternetSales DROP CONSTRAINT FK_FactInternetSales_DimDate;
ALTER TABLE FactInternetSales DROP CONSTRAINT FK_FactInternetSales_DimDate1;
ALTER TABLE FactInternetSales DROP CONSTRAINT FK_FactInternetSales_DimDate2;
-- now the main thing
ALTER TABLE DimDate DROP CONSTRAINT PK_DimDate_DateKey
;
-- again PK_DimDate_DateKey must be wrapped by [], cant tell why!
CREATE CLUSTERED INDEX [PK_DimDate_DateKey]
	ON DimDate( FiscalYear ) 
	ON place_split_by_year_number( FiscalYear)
;
-- the following does NOT show the distribution of the data rows into partitions / filegroups - it is just testing the partiioning function, nothing more!
SELECT $partition.split_by_year_number( FiscalYear) part_no, * FROM DimDate WHERE DayNumberOfYear=1 ORDER BY datekey 
;

-- %%physloc%% is like Oracle rowid 
SELECT FiscalYear, %%physloc%% AS [%%physloc%%], sys.fn_PhysLocFormatter(%%physloc%%) AS [File:Page:Slot] FROM DimDate WHERE DayNumberOfYear=1 ORDER BY datekey 
/* FiscalYear,%%physloc%%,File:Page:Slot
2005,0x1817000001000000,(1:5912:0)
2006,0x1D17000001003100,(1:5917:49)
2007,0x2317000001002B00,(1:5923:43)
2008,0x2917000001002400,(1:5929:36)
2009,0x2F17000001001F00,(1:5935:31)
2010,0x3517000001001700,(1:5941:23)
2010,0x4017000001000C00,(1:5952:12)
2011,0x4E00000003000C00,(3:78:12)
2012,0x5400000003000600,(3:84:6)
2013,0x5A00000003000000,(3:90:0)
 */
use AdventureWorksDW2019
GO

EXEC sp_estimate_data_compression_savings   
      @schema_name = 'dbo'    
   , @object_name  =  'FactInternetSales'   
   , @data_compression = 'ROW'   
   , @index_id = 1 , @partition_number = 1

/* object_name,schema_name,index_id,partition_number,size_with_current_compression_setting(KB),size_with_requested_compression_setting(KB),sample_size_with_current_compression_setting(KB),sample_size_with_requested_compression_setting(KB)
FactInternetSales,dbo,1,1,10056,5320,9960,5272
 */

-- apply compression 
USE [AdventureWorksDW2019]
ALTER TABLE [dbo].[FactInternetSales] REBUILD PARTITION = ALL
WITH 
(DATA_COMPRESSION = PAGE
)
GO


-- Script the ALTER TABLE .. DROP CONSTRAINT for the FKs
SELECT f.name as FK_constraint,
   OBJECT_NAME(f.parent_object_id) TableName,
   COL_NAME(fc.parent_object_id,fc.parent_column_id) ColName
 , 'ALTER TABLE ' + OBJECT_NAME(f.parent_object_id) + ' DROP CONSTRAINT ' + f.name + ';' ddl 
FROM    sys.foreign_keys AS f
INNER JOIN    sys.foreign_key_columns AS fc       ON f.OBJECT_ID = fc.constraint_object_id
INNER JOIN    sys.tables t       ON t.OBJECT_ID = fc.referenced_object_id
WHERE    f.referenced_object_id = object_id( 'FactInternetSales')
;   

ALTER TABLE FactInternetSalesReason DROP CONSTRAINT FK_FactInternetSalesReason_FactInternetSales
;
ALTER TABLE  [dbo].[FactInternetSales] DROP CONSTRAINT [PK_FactInternetSales_SalesOrderNumber_SalesOrderLineNumber]
;
CREATE  CLUSTERED COLUMNSTORE INDEX [PK_FactInternetSales_SalesOrderNumber_SalesOrderLineNumber] ON [dbo].[FactInternetSales] 
--( SalesOrderNumber, SalesOrderLineNumber)
;
-- check the actual size. The estimate will reveal the size used by the current setting of COLUMNSTORE is better than ROW compression!
EXEC sp_estimate_data_compression_savings   
      @schema_name = 'dbo'    
   , @object_name  =  'FactInternetSales'   
   , @data_compression = 'ROW'   
   , @index_id = 1 , @partition_number = 1
   ;
/* object_name,schema_name,index_id,partition_number,size_with_current_compression_setting(KB),size_with_requested_compression_setting(KB),sample_size_with_current_compression_setting(KB),sample_size_with_requested_compression_setting(KB)
FactInternetSales,dbo,1,1,1496,5208,1504,5240
 */
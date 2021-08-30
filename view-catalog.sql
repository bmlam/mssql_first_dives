-- table data model info
select tab.schema_id, schema_name(tab.schema_id) as schema_name,
       tab.name as table_name, 
       tab.create_date as created,  
       tab.modify_date as last_modified, 
       ep.value as comments 
  from sys.tables tab
        left join sys.extended_properties ep 
            on tab.object_id = ep.major_id
           and ep.name = 'MS_Description'
           and ep.minor_id = 0
           and ep.class_desc = 'OBJECT_OR_COLUMN'
WHERE 1=1
  AND tab.name lIKE '%Employee%'
  order by schema_name,
        table_name
        ;
-- table size 
WITH tab_rows_ AS (
    select distinct p.object_id,     sum(p.rows) rows
    from sys.tables t
    inner join sys.partitions p ON  p.object_id = t.object_id 
    group by p.object_id, p.index_id
)
SELECT tab.name TableName
    , schema_name(tab.schema_id) as schema_name
    ,ps.object_id ps_object_id
    ,object_name( ps.object_id) SegmentName
    ,ix.name IndexName
    ,CASE ps.index_id WHEN 0 THEN 'Table' WHEN 1 THEN 'ClustIx' ELSE 'otherIx' END AS SegmentType
    ,ps.index_id tab_index_id
    ,tab.create_date tableCreDate
    ,tr.rows table_rows 
    ,ROUND(ps.used_page_count * 8 / 1024.0, 2) SegmentMbUsed
    ,ps.used_page_count SegmentPages
FROM  sys.tables tab 
LEFT JOIN tab_rows_ tr ON tr.object_id = tab.object_id 
LEFT JOIN sys.dm_db_partition_stats ps ON ps.object_id = tab.object_id
LEFT JOIN sys.indexes ix ON ix.object_id = tab.object_id -- index does not have any object id. so object_id is always the table's object_id
WHERE 1=1
  AND tab.name LIKE '%Internet%'
;
-- column information 
SELECT c.object_id
    ,c.name column_name
    ,t.Name data_type
    ,c.max_length
    ,c.precision 
    ,c.scale 
    ,c.is_nullable nullible
    ,CASE 
        WHEN t.name LIKE '%varchar' THEN t.name + '(' + CONVERT( VARCHAR, c.max_length  ) + ')'
        WHEN t.name LIKE 'decimal' THEN t.name + '(' + CONVERT( VARCHAR, c.[precision]  ) + ',' + CONVERT( VARCHAR, c.[scale]  ) + ')'
        ELSE t.name 
    END AS data_type_specs 
    ,ISNULL(i.is_primary_key, 0) is_pk
FROM    
    sys.columns c
INNER JOIN 
    sys.types t ON c.user_type_id = t.user_type_id
LEFT OUTER JOIN 
    sys.index_columns ic ON ic.object_id = c.object_id AND ic.column_id = c.column_id--
LEFT OUTER JOIN 
    sys.indexes i ON ic.object_id = i.object_id AND ic.index_id = i.index_id
WHERE c.object_id = object_id( 'dbo.emp')
    ;
SELECT ps.index_id tab_index_id, ps.* 
FROM  sys.tables tab 
LEFT JOIN sys.dm_db_partition_stats ps ON ps.object_id = tab.object_id
WHERE 1=1
  AND tab.name LIKE '%Product%'
;
-- who can do what
select prin.name grantee
, perm.grantor_principal_id grantor_id
, prin.principal_id grantee_id
, prin.type_desc grantee_type
, perm.permission_name 
, prin.is_disabled
, prin.is_fixed_role
, perm.class_desc perm_class
FROM sys.server_permissions perm
JOIN sys.server_principals prin ON prin.principal_id = perm.grantee_principal_id

SELECT * FROM  sys.dm_db_partition_stats ps WHERE object_id = object_id ( 'dbo.FactInternetSales')
SELECT * from sys.indexes

-- check if full text search feature installed
SELECT FULLTEXTSERVICEPROPERTY('IsFullTextInstalled')

select object_name( object_id) object_name, * from sys.fulltext_indexes
;
-- find indexed (materialized) views
select schema_name(v.schema_id) as schema_name,
       v.name as view_name,
       i.name as index_name,
       m.definition
from sys.views v
join sys.indexes i
     on i.object_id = v.object_id
  --   and i.index_id = 1
--  and i.ignore_dup_key = 0
join sys.sql_modules m
     on m.object_id = v.object_id
WHERE 1=1
 -- AND i.object_id = object_id( 'HumanResources.JobCandidate')
order by schema_name,
         view_name;
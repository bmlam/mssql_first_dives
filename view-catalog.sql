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
  AND tab.name lIKE '%Prod%'
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
    ,CASE ps.index_id WHEN 0 THEN 'Table' WHEN 1 THEN 'ClustIx' ELSE 'otherIx' END AS SegmentType
    ,ps.index_id tab_index_id
    ,tab.name TableName, tab.create_date tableCreDate
    ,tr.rows table_rows 
    ,ROUND(ps.used_page_count * 8 / 1024.0, 2) SegmentMbUsed
    ,ps.used_page_count SegmentPages
FROM  sys.tables tab 
LEFT JOIN tab_rows_ tr ON tr.object_id = tab.object_id 
LEFT JOIN sys.dm_db_partition_stats ps ON ps.object_id = tab.object_id
WHERE 1=1
  AND tab.name LIKE '%Product%'
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
SELECT ps.index_id tab_index_id, * 
FROM  sys.tables tab 
LEFT JOIN sys.dm_db_partition_stats ps ON ps.object_id = tab.object_id
WHERE 1=1
  AND tab.name LIKE '%Product%'
;
select * from newProduct1

SELECT CASE ps.index_id WHEN 0 THEN 'Table' WHEN 1 THEN 'ClustIx' ELSE 'otherIx' END AS SegmentType FROM  sys.tables tab LEFT JOIN sys.dm_db_partition_stats ps ON ps.object_id = tab.object_id

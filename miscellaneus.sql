-- select * from dbo.v_column_info where object_id = object_id( 'dbo.emp')



select * from emp

select top 40 * from v_log_table_since_today order by id desc

      SELECT tgt.columnName 
         , inf.data_type 
         , inf.data_type_specs 
      FROM ( select 'empno' as columnName union all select 'hiredate' ) tgt 
      LEFT JOIN dbo.v_column_info inf 
      ON inf.column_name = tgt.columnName AND inf.object_id = OBJECT_ID( 'emp' )
      ORDER BY tgt.id_
;


begin transaction
 INSERT emp(empno, ename, mgr, job, sal, deptno, hiredate)  VALUES ( '324', 'Smid', '', 'janitor', '1300.12', '20', '08/12/01')
 INSERT emp(empno, ename, mgr, job, sal, deptno, hiredate)  VALUES ( '325', 'Smid', '', 'janitor', '1300,12', '20', '08/12/01')
commit transaction

SET STATISTICS PROFILE ON 
SET showplan_all on 

select deptno, count(1) from emp group by deptno
;
exec msdb.dbo.rds_gather_file_details
;
SELECT * FROM msdb.dbo.rds_fn_task_status(null, 12)
;
SELECT * FROM msdb.dbo.rds_fn_list_file_details(12)
;
exec msdb.dbo.rds_download_from_s3
        @s3_arn_of_file='arn:aws:s3:::us-east1-bucket1/AddressType.csv',
        @rds_file_path='D:\S3\AddressType.csv',
        @overwrite_file=1
;
select object_id ('Person.AddressType')
;
select * from dbo.v_column_info where object_id = object_id ('Person.AddressType')
;
select * from sys.tables  where name like 'Ad%'
;
select convert( datetime, '2008-04-30 00:00:00')
;
select sysdatetime()
;
create table dbo.test_1col ( col varchar(1000))
;
create table dbo.test_4col ( c1 varchar(100), c2 varchar(100), c3 varchar(100), c4 varchar(100) )
;
alter table dbo.test_4col alter column c4 varchar(8000)
;
delete dbo.test_4col
;
BULK INSERT dbo.test_4col FROM 'D:\S3\AddressType.csv'
WITH (
    CHECK_CONSTRAINTS,
    CODEPAGE='ACP',
    DATAFILETYPE = 'char',
    FIELDTERMINATOR= '0x09',
    ROWTERMINATOR = '0x0a',
    KEEPIDENTITY,
    TABLOCK
);
select t.*, len(c4) from dbo.test_4col t
;
select  left( c4, 40)  head, convert( varbinary(max), left( c4, 40) ) hex from dbo.test_4col
;
select convert( varbinary(max), 'abc' )
;
with dat as  ( select 'a\nb' foo ) 
select foo, convert( varbinary(max),foo ) from dat
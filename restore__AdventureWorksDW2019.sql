USE [master]
RESTORE DATABASE [AdventureWorksDW2019] FROM  DISK = N'/mssql_bak/AdventureWorksDW2019.bak' WITH  FILE = 1
,  MOVE N'AdventureWorksDW2017' TO N'/var/opt/mssql/data/AdventureWorksDW2019.mdf'
,  MOVE N'AdventureWorksDW2017_log' TO N'/var/opt/mssql/data/AdventureWorksDW2019_log.ldf'
,  NOUNLOAD,  STATS = 5

GO



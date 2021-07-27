use AdventureWorksDW2019
GO

ALTER ROLE db_owner ADD MEMBER ddlUser1

ALTER ROLE sqlUser ADD MEMBER ddlUser1

ALTER ROLE appOwner ADD MEMBER ddlUser1

GO

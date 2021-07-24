USE testdb1
GO

SELECT CURRENT_USER
GO

CREATE SCHEMA service;
GO

--ALTER ROLE appOwner ADD MEMBER service
-- Cannot add the principal 'service', because it does not exist or you do not have permission.

--GRANT CREATE FUNCTION to service

GO

USE master
GO

CREATE LOGIN sqlUser1 WITH
 PASSWORD = 'xxxxxxxxxxxxxx'
,DEFAULT_DATABASE=testdb1
,CHECK_EXPIRATION=OFF

GO

CREATE LOGIN ddlUser1 WITH
 PASSWORD = 'xxxxxxxxxxxxxx'
,DEFAULT_DATABASE=testdb1
,CHECK_EXPIRATION=OFF

GO

USE testdb1
GO

-- password for USER is not needed since LOGIN already is password protected

CREATE USER sqlUser1 FROM LOGIN sqlUser1 
;
CREATE USER ddlUser1 FROM LOGIN ddlUser1 
;

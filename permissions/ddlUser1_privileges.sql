use testdb1
GO

ALTER ROLE sqlUser ADD MEMBER=ddlUser1

ALTER ROLE appOwner ADD MEMBER=ddlUser1

GO

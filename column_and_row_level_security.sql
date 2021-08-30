--SELECT * FROM sys.dm_exec_connections 

CREATE TABLE Membership
  (MemberID int IDENTITY,
   FirstName varchar(100) NULL,
   SSN char(9) NOT NULL,
   LastName varchar(100) NOT NULL,
   Phone varchar(12) NULL,
   Email varchar(100) NULL);

GRANT SELECT ON Membership(MemberID, FirstName, LastName, Phone, Email) TO sqlUser1;

CREATE FUNCTION fn_securitypredicate( @LastName AS sysname)  
    RETURNS TABLE  
WITH SCHEMABINDING  
AS  
    RETURN SELECT 1 AS fn_securitypredicate_result
WHERE @LastName = USER_NAME() OR USER_NAME() = 'King';

CREATE SECURITY POLICY dbo.membership_filter
ADD FILTER PREDICATE dbo.fn_securitypredicate(LastName)
ON dbo.MemberShip  
WITH (STATE = ON);


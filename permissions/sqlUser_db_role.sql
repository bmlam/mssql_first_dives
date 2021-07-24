USE testdb1
GO

SELECT CURRENT_USER

CREATE ROLE sqlUser;
GO

GRANT ALL ON log_table TO sqlUser
GRANT ALL ON pkg_std_log__info TO sqlUser

GRANT EXECUTE,VIEW DEFINITION ON pkg_std_log__dbx TO sqlUser
GRANT SELECT ,VIEW DEFINITION ON v_log_table_since_today TO sqlUser

GRANT SELECT ON SCHEMA service TO sqlUser

-- got this message: The ALL permission is deprecated and maintained only for compatibility. It DOES NOT imply ALL permissions defined on the entity.

GO

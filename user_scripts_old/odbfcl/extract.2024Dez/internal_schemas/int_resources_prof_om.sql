--------------------------------------
-- >= 21
--------------------------------------

INSERT INTO &v_int_schema_tab. (TYPE,NAME)
SELECT DISTINCT 'P',PROFILE
FROM   CDB_PROFILES
WHERE  ORACLE_MAINTAINED = 'YES';
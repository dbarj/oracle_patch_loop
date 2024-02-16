WHENEVER SQLERROR EXIT SQL.SQLCODE

UPDATE T_TXTCOLLECTION_LOAD SET MD5_HASH=SYS.DBMS_CRYPTO.HASH(CONTENTS,2);

-- TODO: CHANGE 2 QUERIES FOR 1 USING "INSERT ALL"

insert /*+ append */
  into DM_CONTENTS (MD5_HASH, CONTENTS)
select MD5_HASH, CONTENTS
from (
    select MD5_HASH,
           CONTENTS,
           RANK() over (partition by MD5_HASH order by rowid asc) col_ind
    from T_TXTCOLLECTION_LOAD
)
where col_ind=1;

insert /*+ append */
  into T_TXTCOLLECTION (PATH, MD5_HASH, ORAVERSION, ORASERIES, ORAPATCH)
select PATH,
       MD5_HASH,
       substr(file_name,instr(file_name,'_',1,1)+1,instr(file_name,'_',1,2)-instr(file_name,'_',1,1)-1)           oraversion,
       substr(file_name,instr(file_name,'_',1,2)+1,instr(file_name,'_',1,3)-instr(file_name,'_',1,2)-1)           oraseries,
       -- to_number(substr(file_name,instr(file_name,'_',1,3)+1,instr(file_name,'.',-1,2)-instr(file_name,'_',1,3)-1)) orapatch
       to_number(regexp_substr(file_name,'(\d+\.)?\d+',instr(file_name,'_',1,3)+1,1), '99999999D99', 'NLS_NUMERIC_CHARACTERS = .,') orapatch
from T_TXTCOLLECTION_LOAD;

commit;

drop table T_TXTCOLLECTION_LOAD purge;
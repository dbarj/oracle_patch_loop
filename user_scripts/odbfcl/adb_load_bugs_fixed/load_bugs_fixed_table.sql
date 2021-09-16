WHENEVER SQLERROR EXIT SQL.SQLCODE

insert /*+ append */
  into T_BUGSFIXED (BUG_ID, PATCH_ID, BUG_DESC, ORAVERSION, ORASERIES, ORAPATCH)
select BUG_ID,
       PATCH_ID,
       BUG_DESC,
       substr(file_name,instr(file_name,'_',1,1)+1,instr(file_name,'_',1,2)-instr(file_name,'_',1,1)-1)           oraversion,
       substr(file_name,instr(file_name,'_',1,2)+1,instr(file_name,'_',1,3)-instr(file_name,'_',1,2)-1)           oraseries,
       to_number(substr(file_name,instr(file_name,'_',1,3)+1,instr(file_name,'.',-1)-instr(file_name,'_',1,3)-1)) orapatch
from T_BUGSFIXED_LOAD;

commit;

drop table T_BUGSFIXED_LOAD purge;
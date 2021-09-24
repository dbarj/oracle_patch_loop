WHENEVER SQLERROR EXIT SQL.SQLCODE

insert /*+ append */ into T_FILES (PATH, SHA256_HASH, FILE_TYPE, ORAVERSION, ORASERIES, ORAPATCH)
select path,
       hash,
       file_type,
       substr(file_name,instr(file_name,'_',1,1)+1,instr(file_name,'_',1,2)-instr(file_name,'_',1,1)-1)           oraversion,
       substr(file_name,instr(file_name,'_',1,2)+1,instr(file_name,'_',1,3)-instr(file_name,'_',1,2)-1)           oraseries,
       to_number(substr(file_name,instr(file_name,'_',1,3)+1,instr(file_name,'.',-1)-instr(file_name,'_',1,3)-1)) orapatch
from T_FILES_LOAD;

commit;

drop table T_FILES_LOAD purge;
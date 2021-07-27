WHENEVER SQLERROR EXIT SQL.SQLCODE

insert /*+ append */ into T_SYMBOLS (FILE_NAME, SYMBOL_TYPE, SYMBOL_NAME, ORAVERSION, ORASERIES, ORAPATCH)
select file_name,
       symbol_type,
       symbol_name,
       substr(source_file,instr(source_file,'_',1,1)+1,instr(source_file,'_',1,2)-instr(source_file,'_',1,1)-1)           oraversion,
       substr(source_file,instr(source_file,'_',1,2)+1,instr(source_file,'_',1,3)-instr(source_file,'_',1,2)-1)           oraseries,
       to_number(substr(source_file,instr(source_file,'_',1,3)+1,instr(source_file,'.',-1)-instr(source_file,'_',1,3)-1)) orapatch
from T_SYMBOLS_LOAD;

commit;

drop table T_SYMBOLS_LOAD purge;
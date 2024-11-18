-------------------------------

set termout off

-- Set version variables. Value will be 'Y' or 'N'
COL is_ver_le_10 new_v is_ver_le_10 nopri

select -- Lower or Equal
       case when version <= 10 then 'Y' else 'N' end is_ver_le_10
from  (select to_number(substr(version,1,instr(version,'.')-1)) version
       ,      to_number(substr(version,instr(version,'.')+1, instr(version,'.',1,2)-instr(version,'.')-1)) release
       ,      to_number(substr(version,instr(version,'.',1,2)+1, instr(version,'.',1,3)-instr(version,'.',1,2)-1)) server
       ,      to_number(substr(version,instr(version,'.',1,3)+1, instr(version,'.',1,4)-instr(version,'.',1,3)-1)) component
       from   v$instance);

COL is_ver_le_10 clear

COL skip_ver_le_10_s new_v skip_ver_le_10_s nopri
COL skip_ver_le_10_e new_v skip_ver_le_10_e nopri

select -- Lower or Equal
       decode('&&is_ver_le_10.','Y','/*','N','') skip_ver_le_10_s,
       decode('&&is_ver_le_10.','Y','*/','N','') skip_ver_le_10_e       
from   dual;

COL skip_ver_le_10_s clear
COL skip_ver_le_10_e clear

set termout on

-------------------------------

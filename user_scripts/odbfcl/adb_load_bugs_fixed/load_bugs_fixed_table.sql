WHENEVER SQLERROR EXIT SQL.SQLCODE

-- TODO: CHANGE 2 QUERIES FOR 1 USING "INSERT ALL"

insert /*+ append */
  into T_BUGS (BUG_ID, BUG_DESC)
select BUG_ID, BUG_DESC
from (
    select BUG_ID,
           BUG_DESC,
           RANK() over (partition by BUG_ID order by rowid asc) col_ind
    from T_BUGSFIXED_LOAD
)
where col_ind=1;

insert /*+ append */
  into T_BUGSFIXED (BUG_ID, PATCH_ID, ORAVERSION, ORASERIES, ORAPATCH)
select BUG_ID,
       PATCH_ID,
       substr(file_name,instr(file_name,'_',1,1)+1,instr(file_name,'_',1,2)-instr(file_name,'_',1,1)-1)           oraversion,
       substr(file_name,instr(file_name,'_',1,2)+1,instr(file_name,'_',1,3)-instr(file_name,'_',1,2)-1)           oraseries,
       to_number(substr(file_name,instr(file_name,'_',1,3)+1,instr(file_name,'.',-1)-instr(file_name,'_',1,3)-1)) orapatch
from T_BUGSFIXED_LOAD;

commit;

drop table T_BUGSFIXED_LOAD purge;
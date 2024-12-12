def v_int_schema_tab = '&v_username..internal_schemas'

create table &v_int_schema_tab.
(
  type varchar2(1 char),
  name varchar2(30 char)
);

set termout off

col v_suffix new_v v_suffix nopri

-- Load users/roles/(profiles for < 12)
select case when &P_VERS_1D >= 12 then 'user_role_om' else '&P_VERS_4D.' end v_suffix from dual;
select decode('&v_internal','true','&v_suffix.','nothing') v_suffix from dual;
@@int_resources_&v_suffix..sql

-- Load (profiles for >= 12)
select case when &P_VERS_1D >= 21 then 'prof_om' when &P_VERS_1D < 12 then 'nothing' else '&P_VERS_4D.' end v_suffix from dual;
select decode('&v_internal','true','&v_suffix.','nothing') v_suffix from dual;
@@int_resources_&v_suffix..sql

col v_suffix clear
undef v_suffix

commit;

set termout on
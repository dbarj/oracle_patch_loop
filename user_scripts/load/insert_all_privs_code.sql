whenever sqlerror exit sql.sqlcode
set serverout on
set verify on
set echo on

------- Mandatory variables: -------
-- def v_table_name = Table with hashes = T_SOMETHING
-- var v_table_cols = All columns of the normal table except CON_ID
-- var v_table_id_cols = Columns used to identify a row without hash. Used to compare with other rows to check HASH changes.
-- def v_hash_col_id = Column of the table with HASH that can change for every row. For Code, this is SHA1, for tables to just compare, can use hash_line_id
-- var v_table_all_cols = Will be auto populated with v_table_cols + hash_line_id, con_id, series, oraversion
------------------------------------------

def v_table_final = "&&v_table_name._F"

var v_table_all_cols clob
exec :v_table_all_cols := :v_table_cols || ', hash_line_id, con_id, series, oraversion';

-- Begin Prepare

UPDATE &&v_table_name. SET CON_ID=-1
WHERE CON_ID IS NULL;

DECLARE
  V_SQL CLOB;
BEGIN
  V_SQL :=
    'UPDATE &&v_table_name.
     SET HASH_LINE_ID=sys.dbms_crypto.hash(rawtohex(' || REPLACE(:v_table_id_cols,',',' || '','' || ') || ') , 2)
     WHERE HASH_LINE_ID IS NULL';
  DBMS_OUTPUT.PUT_LINE(V_SQL);
  EXECUTE IMMEDIATE V_SQL;
END;
/

COMMIT;

-- End Prepare

BEGIN EXECUTE IMMEDIATE 'drop table &&v_table_final. purge'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

create table &&v_table_final. as select * from &&v_table_name. where 1=2;
alter table &&v_table_final. drop column psu;
alter table &&v_table_final. add (PSU_FROM NUMBER(6) not null, PSU_TO NUMBER(6) not null, FLAG VARCHAR2(1) not null);
alter table &&v_table_final. modify (CON_ID not null);
alter table &&v_table_final. modify (HASH_LINE_ID not null);
alter table &&v_table_final. nologging compress;

-- Create empty GAP table
BEGIN EXECUTE IMMEDIATE 'drop table TEMP_GAP purge'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
create table TEMP_GAP nologging compress as select * from &&v_table_name. where 1=2;

-- Create HELP table containing all the distinct rows for a given oraversion
BEGIN EXECUTE IMMEDIATE 'drop table TEMP_HELP purge'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

DECLARE
  V_SQL CLOB;
BEGIN
  V_SQL := q'[
    create table TEMP_HELP nologging compress as select distinct ]' || :v_table_id_cols || q'[ from &&v_table_name.
  ]';
  DBMS_OUTPUT.PUT_LINE(V_SQL);
  EXECUTE IMMEDIATE V_SQL;
END;
/

-- Collect stats for better performance on next SQLs
exec dbms_stats.unlock_table_stats(USER,'&&v_table_name.');
exec dbms_stats.gather_table_stats(USER,'&&v_table_name.');
exec dbms_stats.gather_table_stats(USER,'TEMP_HELP');

-- Insert into GAP table all the lines that are missing in any (series, oraversion, psu) of OJVM
DECLARE
  V_SQL CLOB;
BEGIN
  V_SQL := q'[
    insert /*+ APPEND */ into TEMP_GAP (]' || :v_table_id_cols || q'[, series, psu)
    select ]' || :v_table_id_cols || q'[, series, psu
    from
    (
      select a.*,
             c.series,
             c.psu
      from   TEMP_HELP a, -- Get all distinct table ID Cols
             &&v_table_name. b,
             (select distinct series, oraversion, psu from &&v_table_name. where series='OJVM') c
      where  a.oraversion = c.oraversion
      and    c.series = b.series(+)
      and    c.psu = b.psu(+)
      and    a.hash_line_id = b.hash_line_id (+)
      and    b.hash_line_id is null
    ) a
    where exists
    ( select 1 from &&v_table_name. b where a.hash_line_id=b.hash_line_id and a.series=b.series )
  ]';
  DBMS_OUTPUT.PUT_LINE(V_SQL);
  EXECUTE IMMEDIATE V_SQL;
END;
/

BEGIN EXECUTE IMMEDIATE 'drop table TEMP_HELP purge'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

-------
------- START
------- Next lines will put all the rows in ranges
-------

BEGIN EXECUTE IMMEDIATE 'drop table TEMP_SOURCE purge'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

DECLARE
  V_SQL CLOB;
BEGIN
  V_SQL := q'[
    create table TEMP_SOURCE nologging compress as
    with tab as (
      select ]' || :v_table_all_cols || q'[,psu,'A' flag from &&v_table_name.
      union
      select ]' || :v_table_all_cols || q'[,psu,'R' flag from TEMP_GAP
    ) select * from tab
  ]';
  DBMS_OUTPUT.PUT_LINE(V_SQL);
  EXECUTE IMMEDIATE V_SQL;
END;
/

BEGIN EXECUTE IMMEDIATE 'drop table TEMP_GAP purge'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

--

BEGIN EXECUTE IMMEDIATE 'drop sequence TEMP_SEQ'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

BEGIN EXECUTE IMMEDIATE 'drop function TEMP_GETSEQ'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

BEGIN EXECUTE IMMEDIATE 'drop table TEMP_TAB purge'; EXCEPTION WHEN OTHERS THEN NULL; END;
/


CREATE SEQUENCE TEMP_SEQ SESSION start with 1 increment by 1;

select TEMP_SEQ.nextval from dual;

create or replace function TEMP_GETSEQ
( ptype in varchar2 ) return number
is
begin
  if ptype='N' then -- New
    return TEMP_SEQ.nextval;
  elsif ptype='C' then -- Continue
    return TEMP_SEQ.currval;
  end if;
end;
/

DECLARE
  V_SQL CLOB;
BEGIN
  V_SQL := q'[
    create table TEMP_TAB nologging compress as
    with tab as (
      select ]' || :v_table_all_cols || q'[,
             psu,
             flag,
             decode(&&v_hash_col_id.||';'||flag,
                    hash_col_prev_psu||';'||flag_col_prev_psu,
                    TEMP_GETSEQ('C'),
                    TEMP_GETSEQ('N')) genid
      from (
        select ]' || :v_table_all_cols || q'[,
               psu,
               flag,
               lag(&&v_hash_col_id. , 1 , &&v_hash_col_id.) over (partition by hash_line_id,series order by psu asc) hash_col_prev_psu,
               lag(flag , 1 , flag) over (partition by hash_line_id,series order by psu asc) flag_col_prev_psu
        from TEMP_SOURCE )
    ) select * from tab
  ]';
  DBMS_OUTPUT.PUT_LINE(V_SQL);
  EXECUTE IMMEDIATE V_SQL;
END;
/

BEGIN EXECUTE IMMEDIATE 'drop table TEMP_SOURCE purge'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

BEGIN EXECUTE IMMEDIATE 'drop function TEMP_GETSEQ'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

BEGIN EXECUTE IMMEDIATE 'drop sequence TEMP_SEQ'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

DECLARE
  V_SQL CLOB;
BEGIN
  V_SQL := q'[
    insert /*+ APPEND */ into &&v_table_final. (]' || :v_table_all_cols || q'[, psu_from, psu_to, flag)
    select distinct ]' || :v_table_all_cols || q'[
           ,min(psu) over (partition by hash_line_id,series,genid) psu_min
           ,max(psu) over (partition by hash_line_id,series,genid) psu_max
           ,flag
    from TEMP_TAB
  ]';
  DBMS_OUTPUT.PUT_LINE(V_SQL);
  EXECUTE IMMEDIATE V_SQL;
END;
/

commit;

BEGIN EXECUTE IMMEDIATE 'drop table TEMP_TAB purge'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

-------
------- END
-------

-- insert /*+APPEND*/ into &&v_table_final. (&&v_table_cols., con_id, series, oraversion, psu_from, psu_to, flag)
-- select &&v_table_cols., con_id, series, oraversion ,min(psu) min_psu,max(psu) max_psu, flag
-- from (
--   select &&v_table_cols.,con_id,series,oraversion,psu,'A' flag from &&v_table_name.
--   union all
--   select &&v_table_cols.,con_id,series,oraversion,psu,'R' flag from TEMP_GAP
--   )
-- group by &&v_table_cols., con_id, series, oraversion, flag;

-- This block will add a remove line flag for every OJVM that do not have a with the default series
DECLARE
  V_SQL CLOB;
BEGIN
  V_SQL := q'[
    insert /*+ APPEND */ into &&v_table_final. (]' || :v_table_cols || q'[, hash_line_id, con_id, series, oraversion, psu_from, psu_to, flag)
    select ]' || :v_table_cols || q'[, hash_line_id, con_id, 'OJVM', oraversion, -1, -1, 'R'
    from (
    select ]' || :v_table_cols || q'[,
           hash_line_id,
           con_id,
           oraversion,
           flag
    from   &&v_table_final. a
    where  series in ('PSU','RU')
    and    psu_to = (select max(c.PSU_TO) from &&v_table_final. c where c.series = a.series and c.oraversion=a.oraversion)
    minus
    select ]' || :v_table_cols || q'[,
           hash_line_id,
           con_id,
           oraversion,
           flag
    from   &&v_table_final. a
    where  series='OJVM'
    and    psu_from = (select min(c.PSU_FROM) from &&v_table_final. c where c.series = a.series and c.oraversion=a.oraversion)
    )
  ]';
  DBMS_OUTPUT.PUT_LINE(V_SQL);
  EXECUTE IMMEDIATE V_SQL;
END;
/

commit;

exec dbms_stats.gather_table_stats(USER,'&&v_table_final.');

select series,psu_from,count(*) from &&v_table_final. where series='OJVM' group by series,psu_from order by 1,2;

delete from &&v_table_final. a
where series = 'OJVM' and flag='R'
and not exists (select 1
                from   &&v_table_final. b
                where  b.series in ('PSU','RU')
                and    b.hash_line_id=a.hash_line_id);

commit;

-- Analisar isso: oracle/net/ano/a em t_hash ou o output da query:
-- select * from t_hash_final t1, t_hash_final t2 where t1.hash_line_id=t2.hash_line_id and t1.series <> 'OJVM' and t2.series='OJVM' and t1.sha1_enc=t2.sha1_enc and t1.flag='A' and t2.flag='A';
delete from &&v_table_final. a
where series = 'OJVM'
and PSU_FROM = (select min(c.PSU_FROM) from &&v_table_final. c where c.series = a.series and c.oraversion=a.oraversion and c.PSU_FROM>=0)
and exists (select 1
              from &&v_table_final. b,
                   (select series, oraversion, max(psu_to) psu_to from &&v_table_final. group by series, oraversion) c
             where a.hash_line_id = b.hash_line_id
               and a.&&v_hash_col_id. = b.&&v_hash_col_id.
               and b.series in ('PSU','RU')
               and b.psu_to = c.psu_to
               and b.series = c.series
               and b.oraversion = c.oraversion);

commit;
-- Atual: apaga as linhas no OJVM começando por PSU 1 e que tenham uma entrada no DB final com o mesmo hash
-- Considerar: apaga as linhas no OJVM cujo hash seja o mesmo do na última entrada do DB
-- Talvez o atual esteja correto, pensar mais!

select series,psu_from,count(*) from &&v_table_final. where series='OJVM' group by series,psu_from order by 1,2;

-- Corrigir o que retornar nesta query:
-- select * from
-- (select &&v_table_all_cols., psu_from, psu_to,
-- lead(psu_from, 1) over (partition by &&v_table_all_cols. order by psu_from) as psu_from_n1
-- from &&v_table_final.
-- ) where psu_from_n1 < psu_to;

------------
-- Merge when lines are identical in BP and PSU to "BOTH" / RU and RUR to "BOTH"
BEGIN EXECUTE IMMEDIATE 'drop table &&v_table_final._2 purge'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
rename &&v_table_final. to &&v_table_final._2;
create table &&v_table_final. compress nologging as select * from &&v_table_final._2 where 1=2;

DECLARE
 V_SQL CLOB;
BEGIN
V_SQL := q'[
insert /*+APPEND*/ into &&v_table_final. (]' || :v_table_cols || q'[, hash_line_id, con_id, series, oraversion, psu_from, psu_to, flag)
select distinct ]' || :v_table_cols || q'[, hash_line_id, con_id, decode(total,2,'BOTH',series), oraversion, psu_from, psu_to, flag
from (
select ]' || :v_table_cols || q'[, hash_line_id, con_id, series, oraversion, psu_from, psu_to, flag,
count(*) over (partition by ]' || :v_table_cols || q'[, hash_line_id, con_id, oraversion, psu_from, psu_to) total
from &&v_table_final._2
where series in ('BP','PSU','RU','RUR')
)
union all
select ]' || :v_table_cols || q'[, hash_line_id, con_id, series, oraversion, psu_from, psu_to, flag
from &&v_table_final._2
where series not in ('BP','PSU','RU','RUR')
]';
DBMS_OUTPUT.PUT_LINE(V_SQL);
EXECUTE IMMEDIATE V_SQL;
END;
/

commit;

select (select count(*) from &&v_table_final._2) B4, (select count(*) from &&v_table_final.) AFT from dual;

drop table &&v_table_final._2 purge;

------------
-- Merge when lines are repeated in the 3 CON_IDs to one single 0 CON_ID
BEGIN EXECUTE IMMEDIATE 'drop table &&v_table_final._2 purge'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
rename &&v_table_final. to &&v_table_final._2;
create table &&v_table_final. compress nologging as select * from &&v_table_final._2 where 1=2;

DECLARE
 V_SQL CLOB;
BEGIN
V_SQL := q'[
insert /*+APPEND*/ into &&v_table_final. (]' || :v_table_cols || q'[, hash_line_id, con_id, series, oraversion, psu_from, psu_to, flag)
select distinct ]' || :v_table_cols || q'[, hextoraw('00') hash_line_id, decode(total,3,0,con_id), series, oraversion, psu_from, psu_to, flag
from (
select ]' || :v_table_cols || q'[, hash_line_id, con_id, series, oraversion, psu_from, psu_to, flag,
count(*) over (partition by ]' || :v_table_cols || q'[, series, oraversion, psu_from, psu_to, flag) total
from &&v_table_final._2
where con_id in (1,2,3)
)
union all -- 11g
select ]' || :v_table_cols || q'[, hash_line_id, con_id, series, oraversion, psu_from, psu_to, flag
from &&v_table_final._2
-- 0 used for hashes / -1 for the rest -> Correct it one day, put -1 to all
where con_id <= 0
]';
DBMS_OUTPUT.PUT_LINE(V_SQL);
EXECUTE IMMEDIATE V_SQL;
END;
/

commit;

select (select count(*) from &&v_table_final._2) B4, (select count(*) from &&v_table_final.) AFT from dual;

drop table &&v_table_final._2 purge;
------------

alter table &&v_table_final. modify (CON_ID null);
UPDATE &&v_table_final. SET CON_ID=NULL WHERE CON_ID=-1;

------------
undef v_table_name
undef v_hash_col_id

whenever sqlerror continue
set verify on
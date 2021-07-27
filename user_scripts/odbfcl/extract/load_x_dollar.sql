INSERT INTO &v_username..T_PARAMETER
(
    "NAME",
    "TYPE",
    "DEFAULT_VALUE",
    "DESCRIPTION",
    "ORAVERSION",
    "ORASERIES",
    "ORAPATCH"
)
select a.ksppinm name,
       a.ksppity type,
       b.ksppstdf def_value,
       a.ksppdesc description,
       '&P_VERS.',
       '&P_SER.',
       &P_PATCH.
from   sys.x$ksppi a,
       sys.x$ksppcv b
where  a.indx = b.indx
and    a.ksppinm like '\_%' ESCAPE '\';

--

INSERT INTO &v_username..T_PARAMETER_VALID_VALUES
(
    "NAME",
    "VALUE",
    "ISDEFAULT",
    "ORAVERSION",
    "ORASERIES",
    "ORAPATCH"
)
select a.ksppinm name,
       b.value_kspvld_values value,
       b.isdefault_kspvld_values is_default,
       '&P_VERS.',
       '&P_SER.',
       &P_PATCH.
from   sys.x$ksppi a,
       sys.x$kspvld_values b
where  a.ksppinm = b.name_kspvld_values
and    a.ksppinm like '\_%' ESCAPE '\';

--

-- There is a bug since oracle 11.2 which is that starting from x$kqfta.nkqftanam=x$ksxptesttbl,
-- The field x$kqfco.kqfcotab should be subtracted by one to get the correct columns.
-- Thanks David Kurtz and Frits Hoogland

INSERT INTO &v_username..T_XTABCOLS
(
    "TABLE_NAME",
    "COLUMN_NAME",
    "COLUMN_TYPE",
    "ORAVERSION",
    "ORASERIES",
    "ORAPATCH"
)
select t.kqftanam table_name,
       c.kqfconam column_name,
       c.kqfcodty column_type,
       '&P_VERS.',
       '&P_SER.',
       &P_PATCH.
from x$kqfta t, x$kqfco c, x$kqfta divider
where divider.kqftanam = 'X$KSXPTESTTBL'
and t.indx < divider.indx
and t.indx = c.kqfcotab
union all
select t.kqftanam table_name,
       c.kqfconam column_name,
       c.kqfcodty column_type,
       '&P_VERS.',
       '&P_SER.',
       &P_PATCH.
from x$kqfta t, x$kqfco c, x$kqfta divider
where divider.kqftanam = 'X$KSXPTESTTBL'
and t.indx >= divider.indx
and t.indx = c.kqfcotab-1;
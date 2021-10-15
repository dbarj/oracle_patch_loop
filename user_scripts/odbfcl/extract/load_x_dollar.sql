@@underscore_parameters/load_underscore_&P_VERS..sql

--

@@underscore_valid_values/load_underscore_vv_&P_VERS..sql

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
--------------------------------------
-- 12.1.0.2
--------------------------------------

INSERT INTO &v_username..T_PARAMETER_VALID_VALUES
(
  "NAME",
  "ORDINAL",
  "VALUE",
  "ISDEFAULT",
  "CON_ID",
  "ORAVERSION",
  "ORASERIES",
  "ORAPATCH"
)
WITH T1 AS (
SELECT
    inst_id,
    parno_kspvld_values num,
    name_kspvld_values name,
    ordinal_kspvld_values ordinal,
    value_kspvld_values value,
    isdefault_kspvld_values isdefault,
    con_id
FROM
    x$kspvld_values
-- WHERE
--     NOT (translate(name_kspvld_values, '_', '#') NOT LIKE '#%')
)
SELECT "NAME",
       "ORDINAL",
       "VALUE",
       "ISDEFAULT",
       "CON_ID",
       '&P_VERS.' "ORAVERSION",
       '&P_SER.' "ORASERIES",
       &P_PATCH. "ORAPATCH"
FROM T1;
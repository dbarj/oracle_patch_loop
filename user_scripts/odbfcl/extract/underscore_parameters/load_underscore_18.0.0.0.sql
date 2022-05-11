--------------------------------------
-- 18.0.0.0
--------------------------------------

INSERT INTO &v_username..T_PARAMETER
(
  "NAME",
  "TYPE",
  "DEFAULT_VALUE",
  "ISSES_MODIFIABLE",
  "ISSYS_MODIFIABLE",
  "ISPDB_MODIFIABLE",
  "ISINSTANCE_MODIFIABLE",
  "ISDEPRECATED",
  "ISBASIC",
  "DESCRIPTION",
  "CON_ID"
)
WITH T1 AS (
SELECT /*+ use_hash(x y) */
    x.inst_id,
    x.indx + 1 num,
    ksppinm name,
    ksppity type,
    ksppstvl value,
    ksppstdvl display_value,
    ksppstdfl default_value,
    ksppstdf isdefault,
    decode(bitand(ksppiflg / 256, 1), 1, 'TRUE', 'FALSE') isses_modifiable,
    decode(bitand(ksppiflg / 65536, 3), 1, 'IMMEDIATE', 2, 'DEFERRED',
           3, 'IMMEDIATE', 'FALSE') issys_modifiable,
    decode(bitand(ksppiflg / 524288, 1), 1, 'TRUE', 'FALSE') ispdb_modifiable,
    decode(bitand(ksppiflg, 4), 4, 'FALSE', decode(bitand(ksppiflg / 65536, 3), 0, 'FALSE', 'TRUE')) isinstance_modifiable,
    decode(bitand(ksppstvf, 7), 1, 'MODIFIED', 4, 'SYSTEM_MOD',
           'FALSE') ismodified,
    decode(bitand(ksppstvf, 2), 2, 'TRUE', 'FALSE') isadjusted,
    decode(bitand(ksppilrmflg / 64, 1), 1, 'TRUE', 'FALSE') isdeprecated,
    decode(bitand(ksppilrmflg / 268435456, 1), 1, 'TRUE', 'FALSE') isbasic,
    ksppdesc description,
    ksppstcmnt update_comment,
    ksppihash hash,
    y.con_id
FROM
    x$ksppi  x,
    x$ksppcv y
WHERE
    ( x.indx = y.indx )
--    AND NOT (
--        bitand(ksppiflg, 268435456) = 0
--    AND ( ( translate(ksppinm, '_', '$') NOT LIKE '$$%' )
--          AND ( ( translate(ksppinm, '_', '$') NOT LIKE '$%' )
--                OR ( ksppstdf = 'FALSE' )
--                OR ( bitand(ksppstvf, 5) > 0 ) ) )
--    )
)
SELECT "NAME",
       "TYPE",
       "DEFAULT_VALUE",
       "ISSES_MODIFIABLE",
       "ISSYS_MODIFIABLE",
       "ISPDB_MODIFIABLE",
       "ISINSTANCE_MODIFIABLE",
       "ISDEPRECATED",
       "ISBASIC",
       "DESCRIPTION",
       "CON_ID"
FROM T1;
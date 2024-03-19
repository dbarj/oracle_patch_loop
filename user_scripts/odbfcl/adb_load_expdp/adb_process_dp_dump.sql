WHENEVER SQLERROR EXIT SQL.SQLCODE

BEGIN
  PC_DUMP_LOAD.ADD_PROCESS
  (
    P_ORAVERSION => '&1',
    P_ORASERIES => '&2',
    P_ORAPATCH => &3,
    P_FILE_NAME => '&4',
    P_EXECUTE => TRUE
  );
  -- Pause refresh for the next hours.
  PC_REFRESH_MVS.QUICK_PAUSE;
END;
/

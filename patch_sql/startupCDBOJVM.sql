whenever sqlerror exit sql.sqlcode
startup upgrade;
alter pluggable database all open upgrade;
exit;

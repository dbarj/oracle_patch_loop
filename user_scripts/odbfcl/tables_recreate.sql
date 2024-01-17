WHENEVER SQLERROR EXIT SQL.SQLCODE

def v_username='&1.'
def v_password='&2.'
def v_data_tbs='&3.'
def v_temp_tbs='&4.'

@@createUser.sql '&v_username.' '&v_password.' '&v_data_tbs.' '&v_temp_tbs.'

conn &v_username./&v_password.

@@tables_create.sql

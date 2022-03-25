WHENEVER SQLERROR EXIT SQL.SQLCODE

def v_username='&1.'
def v_password='&2.'

@@createUser.sql '&v_username.' '&v_password.' 

conn &v_username./&v_password.

@@tables_create.sql

---------------------------------------------------
@@insert_all_privs_clean "T_HASH"
@@insert_all_privs_clean "T_FILES"
---------------------------------------------------

alter table T_HASH modify (code null, md5_hash null,sha1_hash null);

var v_table_cols clob
var v_table_id_cols clob
var v_print_cols clob

def v_table_name = "T_HASH"
--exec :v_table_cols := 'owner, name, type, origin_con_id, md5_hash, sha1_hash';
exec :v_table_cols := 'owner, name, type, sha1_hash';
exec :v_table_id_cols := 'owner, name, type, con_id, oraversion, hash_line_id';

def v_hash_col_id = "sha1_hash"
def v_print_table = "&&v_table_name."
exec :v_print_cols := 'owner, name_comp, type, con_id, sha1_hash';
def v_file_pref = 'db'
def v_srczip_pref = 'db'

@@insert_all_privs_code
@@change_all_hash_code
@@insert_all_privs_spool

-----------------------------

alter table T_FILES add (con_id number);

var v_table_cols clob
var v_table_id_cols clob
var v_print_cols clob

def v_table_name = "T_FILES"
exec :v_table_cols := 'path, sha256_hash';
exec :v_table_id_cols := 'path, con_id, oraversion, hash_line_id';

def v_hash_col_id = "sha256_hash"
def v_print_table = "&&v_table_name."
exec :v_print_cols := 'path, con_id, sha256_hash';
def v_file_pref = 'files'
def v_srczip_pref = 'files.all'

@@insert_all_privs_code
@@insert_all_privs_spool

-----------------------------
-----------------------------
-----------------------------

--def oraversion = "12.2.0.1"
--def oraversion = "12.1.0.2"
--def oraversion = "12.1.0.1"
--def oraversion = "11.2.0.4"
--@@insert_all_hash_spool
set -eo pipefail

v_folder_name="db_exporter"
mkdir ${v_folder_name}
cp -a ../extract/ ${v_folder_name}
cp -a ../createUser.sql ${v_folder_name}
cp -a ../tables_recreate.sql ${v_folder_name}
cp -a ../tables_create.sql ${v_folder_name}
cp -a ../../externalDir.sql ${v_folder_name}
cp -a ../adb_load_bugs_fixed/*.sh ${v_folder_name}
cp -a ../adb_load_symbols/*.sh ${v_folder_name}
cp -a ../adb_load_txtcollection_files/*.sh ${v_folder_name}
cp -a ../adb_load_filechksum/*.sh ${v_folder_name}
cp -a *.sh *.sql *.txt ${v_folder_name}

sed '/# REMOVE_IF_ZIP$/d' ${v_folder_name}/schemaCreate.sh > ${v_folder_name}/schemaCreate.sh.tmp
mv ${v_folder_name}/schemaCreate.sh.tmp ${v_folder_name}/schemaCreate.sh

sed '/# REMOVE_IF_ZIP$/d' ${v_folder_name}/dumpCreate.sh > ${v_folder_name}/dumpCreate.sh.tmp
mv ${v_folder_name}/dumpCreate.sh.tmp ${v_folder_name}/dumpCreate.sh

sed '/# REMOVE_IF_ZIP$/d' ${v_folder_name}/dictionaryGet.sh > ${v_folder_name}/dictionaryGet.sh.tmp
mv ${v_folder_name}/dictionaryGet.sh.tmp ${v_folder_name}/dictionaryGet.sh

sed '/# REMOVE_IF_ZIP$/d' ${v_folder_name}/exporter.sh > ${v_folder_name}/exporter.sh.tmp
mv ${v_folder_name}/exporter.sh.tmp ${v_folder_name}/exporter.sh

sed "s/v_dump_user_name='hash'/v_dump_user_name='oradiff_exporter'/" ${v_folder_name}/exporter.sh > ${v_folder_name}/exporter.sh.tmp
mv ${v_folder_name}/exporter.sh.tmp ${v_folder_name}/exporter.sh

sed '/^-- REMOVE_IF_ZIP_AFTER$/,$d' ${v_folder_name}/createUser.sql > ${v_folder_name}/createUser.sql.tmp
mv ${v_folder_name}/createUser.sql.tmp ${v_folder_name}/createUser.sql

sed '/^-- REMOVE_IF_ZIP_AFTER$/,$d' ${v_folder_name}/load_code.sql > ${v_folder_name}/load_code.sql.tmp
mv ${v_folder_name}/load_code.sql.tmp ${v_folder_name}/load_code.sql

find ${v_folder_name} -name "*.yml" -delete
find ${v_folder_name} -name ".DS_Store" -delete
rm -f ${v_folder_name}/build_zip.sh
rm -f ${v_folder_name}/unwrap_code.sql
rm -f ${v_folder_name}.zip

# Put all files at the same stamp to create a deterministic zip.
find ${v_folder_name} -exec touch -t 202201010000 {} +

zip -qrmXD ${v_folder_name}.zip ${v_folder_name} -x "*/.*"
rmdir ${v_folder_name}/*
rmdir ${v_folder_name}

exit 0
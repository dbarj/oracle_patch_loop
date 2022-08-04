set -eo pipefail

v_folder_name="oradiff_exporter"
mkdir ${v_folder_name}
cp -a ../extract/ ${v_folder_name}
cp -a ../createUser.sql ${v_folder_name}
cp -a ../tables_recreate.sql ${v_folder_name}
cp -a ../tables_create.sql ${v_folder_name}
cp -a ../../externalDir.sql ${v_folder_name}
cp -a *.sh *.sql *.txt ${v_folder_name}
# mv ${v_folder_name}/dumpCreate_forzip.sh ${v_folder_name}/dumpCreate.sh
sed '/^cd /d' ${v_folder_name}/dumpCreate.sh > ${v_folder_name}/dumpCreate.sh.tmp
mv ${v_folder_name}/dumpCreate.sh.tmp ${v_folder_name}/dumpCreate.sh
find ${v_folder_name} -name "*.yml" -delete
find ${v_folder_name} -name ".DS_Store" -delete
rm -f ${v_folder_name}/build_zip.sh
rm -f ${v_folder_name}.zip

# Put all files at the same stamp to create a deterministic zip.
find ${v_folder_name} -exec touch -t 202201010000 {} +

zip -rmXD ${v_folder_name}.zip ${v_folder_name}
rmdir ${v_folder_name}/*
rmdir ${v_folder_name}

exit 0
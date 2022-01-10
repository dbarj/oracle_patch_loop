set -eo pipefail

mkdir exporter
cp -a ../extract/ exporter/
cp -a ../createUser.sql exporter/
cp -a ../tables_recreate.sql exporter/
cp -a ../tables_create.sql exporter/
cp -a ../../externalDir.sql exporter/
cp -a *.sh *.sql exporter/
# mv exporter/dumpCreate_forzip.sh exporter/dumpCreate.sh
sed '/^cd /d' exporter/dumpCreate.sh > exporter/dumpCreate.sh.tmp
mv exporter/dumpCreate.sh.tmp exporter/dumpCreate.sh
find exporter/ -name "*.yml" -delete
find exporter/ -name ".DS_Store" -delete
rm -f exporter/build_zip.sh
rm -f exporter.zip

# Put all files at the same stamp to create a deterministic zip.
find exporter/ -exec touch -t 202201010000 {} +

zip -rmXD exporter.zip exporter/
rmdir exporter/*
rmdir exporter/

exit 0
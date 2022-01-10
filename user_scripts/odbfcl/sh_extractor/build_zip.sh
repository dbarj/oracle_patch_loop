set -eo pipefail

mkdir exporter
cp -a ../extract/ exporter/
cp -a ../createUser.sql exporter/
cp -a ../tables_recreate.sql exporter/
cp -a ../tables_create.sql exporter/
cp -a ../../externalDir.sql exporter/
cp -a *.sh *.sql exporter/
mv exporter/dumpCreate_forzip.sh exporter/dumpCreate.sh
find exporter/ -name "*.yml" -delete
find exporter/ -name ".DS_Store" -delete
rm -f exporter/build_zip.sh

rm -f exporter.zip
zip -rm exporter.zip exporter/
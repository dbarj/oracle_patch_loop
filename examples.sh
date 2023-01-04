ansible-playbook main.yml --extra-vars "param_type=OJVM"
ansible-playbook main.yml --extra-vars "param_version=12.1.0.2 param_patch=191015"
ansible-playbook main.yml --extra-vars "param_version=18.0.0.0 param_type=OJVM param_patch=190716"
ansible-playbook main.yml --extra-vars "param_version=12.2.0.1 param_type=RU param_patch=191015"
###
while true
do
  ssh rodrigo@192.168.56.101 '(ps -fu oracle | grep -q pmon) && printf "set lines 10000 pages 10000\nselect count(*) from dba_objects;" | sudo su - oracle -c "sqlplus / as sysdba"'
  sleep 60
done
###
while true
do
  #ansible-playbook main.yml --extra-vars "param_version=19.0.0.0"
  ansible-playbook main.yml
  ret=$?
  [ $ret -eq 0 ] && break
done
###
ansible-playbook loader.yml
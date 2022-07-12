#!/bin/bash

save_password() {
  if [[ -z "$POSTGRES_PASSWORD" ]] ; then
    echo "POSTGRES_PASSWORD environment variable is not set. Generating random password for user ${PGUSER}"
    sudo yum -y update && sudo yum -y install pwgen
    POSTGRES_PASSWORD=$(pwgen -c -n 1 12)
  fi

  PASSWORD_FILE=/hypersql/settings/pgpassword
  touch $PASSWORD_FILE 
  chmod 600 $PASSWORD_FILE 
  echo $POSTGRES_PASSWORD > $PASSWORD_FILE
  unset POSTGRES_PASSWORD

  echo "Password for ${PGUSER} is written in ${PASSWORD_FILE}"
  return 0
}

get_initdb_args() {
  result=""
  # superuser is set as $PGUSER
  result="${result} -U ${PGUSER}"
  # password is read from pgpassword file
  result="${result} --pwfile=/hypersql/settings/pgpassword"
  # DATADIR is set as $PGDATA
  result="${result} -D ${PGDATA}"
  # WALDIR is set as $PGHOME/$PGVERSION/pg_wal
  result="${result} -X ${PGHOME}/${PGVERSION}/pg_wal"
  # auth method is set as $POSTGRES_HOST_AUTH_METHOD
  if [[ -n "${POSTGRES_HOST_AUTH_METHOD}" ]] ; then
    result="${result} --auth-host=${POSTGRES_HOST_AUTH_METHOD}"
  else
    result="${result} --auth-host=scram-sha-256"
  fi

  # lastly check if we want to enable data checksums
  if [[ -n "${POSTGRES_ENABLE_DATA_CHECKSUMS}" ]] ; then
    if [[ ${POSTGRES_ENABLE_DATA_CHECKSUMS,,} == "y" ]] ; then
      result="${result} --data-checksums"
    fi
  fi

  echo "$result"
}

init_postgres_cluster() {
  save_password
  if [[ $? -ne 0 ]] ; then
    return -1
  fi

  INITDB_ARGS=$(get_initdb_args)
  initdb $INITDB_ARGS 
  
  if [[ $? -ne 0 ]] ; then 
    return -1
  fi

  echo "include = '/hypersql/settings/postgresql.init.conf'" >> $PGDATA/postgresql.conf
  echo "include_if_exists = '/hypersql/settings/postgresql.custom.conf'" >> $PGDATA/postgresql.conf
}

invoke_sysctl_to_set_parameters() {
  conf_file=/etc/sysctl.d/hypersql.conf
  sudo touch $conf_file 
  
  ## SHARED MEMORY
  # SHMMAX = (physical memory size) / 2
  total_mem=`free -b -t | awk '/^Mem:/{print $2}'`
  target_shmmax=$((total_mem / 2))
  echo "kernel.shmmax=${target_shmmax}" | sudo tee -a $conf_file 
  # SHMALL = (same as SHMMAX)
  echo "kernel.shmall=${target_shmmax}" | sudo tee -a $conf_file
  # SHMMNI = max(default value, 1)
  shmmni_dflt=`sysctl -n kernel.shmmni` 
  target_shmmni=$(( shmmni_dflt > 1 ? shmmni_dflt : 1))
  echo "kernel.shmmni=${target_shmmni}" | sudo tee -a $conf_file

  ## SEMAPHORE 
  sem_dflt=( $(sysctl -n kernel.sem) )
  semmsl_dflt=${sem_dflt[0]}
  semopm_dflt=${sem_dflt[2]}

  # SEMMSL = max(default value, 17) 
  target_semmsl=$(( semmsl_dflt > 17 ? semmsl_dflt : 17 ))
  # SEMMNI = ceil((max_connections + autovacuum_max_workers + max_worker_processes + 5) / 16)
  target_semmni=$(( (MAX_CONNECTIONS + AUTOVACUMM_MAX_WORKERS + MAX_WORKER_PROCESSES + 5) / 16 + 1 ))
  # SEMMNS = ceil((max_connections + autovacuum_max_workers + max_worker_processes) + 5) /16) * 17
  target_semmns=$(( target_semmni * 17 ))
  # set semaphore
  echo "kernel.sem="${target_semmsl} ${target_semmns} ${semopm_dflt} ${target_semmni}"" | sudo tee -a $conf_file

  sudo sysctl -p $conf_file
}

find_and_export_pg_config_params() {
  export "${1^^}"=$(postgres -C ${1})
}

set_system_kernel_parameters() {
  # get pg config params and export them as env variables
  find_and_export_pg_config_params "max_connections"
  find_and_export_pg_config_params "autovacuum_max_workers"
  find_and_export_pg_config_params "max_worker_processes"

  # set system kernel parameters using pg config parameters
  invoke_sysctl_to_set_parameters

  # unset pg config parameters
  unset MAX_CONNECTIONS
  unset AUTOVACUUM_MAX_WORKERS
  unset MAX_WORKER_PROCESSES
}

main() {
  # initialize postgres cluster
  init_postgres_cluster
  if [[ $? -eq -1 ]] ; then
    return
  fi

  # set system kernel parameters
  set_system_kernel_parameters
  if [[ $? -eq -1 ]] ; then
    return
  fi

  # start server
  postgres
}

main

if [[ ${SLEEP_ON_FAILURE,,} == "y" ]] ; then
  echo "sleeping mode"
  while true :
  do
    sleep 1
  done
fi
#!/bin/bash

# walk through all domain directories in DOMAIN_DIR

DOMAIN_DIR='domains'
RESULT_DIR='results'
LOG_DIR='logs'
BASE_DIR=`pwd`

# arg1 - domain
# delete files generated by previous experiments with domain
function clean () {
RESULT_PATH=${BASE_DIR}/${RESULT_DIR}/$1
DOMAIN_PATH=${BASE_DIR}/${DOMAIN_DIR}/$1
LOG_PATH=${BASE_DIR}/${LOG_DIR}/$1
echo -n "cleaning files from previous experiments .."
[[ -d "$RESULT_PATH" ]] && rm -rf "$RESULT_PATH"
[[ -d "$LOG_PATH" ]] && rm -rf "$LOG_PATH"
echo "OK"
}

function process_domain () {
DOMAIN_PATH=${BASE_DIR}/${DOMAIN_DIR}/$1
RESULT_PATH=${BASE_DIR}/${RESULT_DIR}/$1
LOG_PATH=${BASE_DIR}/${LOG_DIR}/$1

clean $1

echo "creating result directory: $RESULT_PATH"
[[ -d "$RESULT_PATH" ]] || mkdir -p $RESULT_PATH

echo "creating log directory: $LOG_PATH"
[[ -d "$LOG_PATH" ]] || mkdir -p $LOG_PATH

cd ${DOMAIN_PATH}

echo "Submiting jobs to cluster:"
while read planner;
do
	while read model;
	do
                while read task;
                do
			JOB_NAME="${model}-${planner}-${task}"
                        qsub -v planner="${planner}",model="${model}",task="${task}",domain="$1" -o $LOG_PATH/${JOB_NAME}_o.log -e $LOG_PATH/${JOB_NAME}_e.log -N $JOB_NAME $BASE_DIR/cplan_one.sh
                done < prob_list
	done < mod_list
done < pla_list

cd ${BASE_DIR}
}

# ------------- process domains ---------------

# if no parameters are given the script will process all domains in $DOMAIN_DIR
# otherwise each parameter should name domain selected for processing

if [ $# -gt 0 ]; then
  echo "Processing specified domains:"
  for D in $@;
  do
	  echo "==== Processing $D ====";
  	process_domain $D
  done
else
  echo "No parameter specified - processing all domains."
  for D in `ls $DOMAIN_DIR | grep -v README.md`;
  do
    echo "==== Processing $D ====";
    process_domain $D
  done
fi


#!/bin/bash

localDir=$PWD

echo "PF::in the job"

#setup ACTS Environment
lcg_os=el9
lcg_release=LCG_108
lcg_compiler=gcc14
lcg_platform=x86_64-${lcg_os}-${lcg_compiler}-opt
lcg_view=/cvmfs/sft.cern.ch/lcg/views/${lcg_release}/${lcg_platform}

source ${lcg_view}/setup.sh
# extra variables required to build acts
export DD4hep_DIR=${lcg_view}

echo "PF::Sourced"

#setup ACTS
source /data/alice/pbutti/sw/acts/install/bin/this_acts.sh

echo "PF::Makedir"

ACTSO2_DIR=/data/alice/pbutti/sw/actso2/

# Job inputs
n_events=$1
job_name=$2
clusterId=$3
procId=$4


#run the job
cd $ACTSO2_DIR
pwd
source ${ACTSO2_DIR}/setup.sh

skip_events=$((procId * n_events))
echo "PF::Run on $n_events for $procId skipping first $skip_events events"

OUT_PREFIX=SimOnly_${job_name}_${n_events}_${procId}_${clusterId}
#mkdir $OUTDIR
#cd $OUTDIR

python alice3_full_chain.py -n ${n_events} --nThreads 1 --runMode sim_only --out_dir_prefix ${OUT_PREFIX} --skip ${skip_events} 

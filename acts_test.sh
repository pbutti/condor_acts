#!/bin/bash

#setup the eos transfer
export EOS_MGM_URL=root://eosuser.cern.ch
source /afs/cern.ch/user/p/pibutti/sw/acts/CI/setup_cvmfs_lcg103.sh
source /afs/cern.ch/user/p/pibutti/sw/acts/build/this_acts.sh
source /afs/cern.ch/user/p/pibutti/sw/acts/build/python/setup.sh

NEVENTS=$1
CLUSTER_ID=$2
PROC_ID=$3
OUTDIR=odd_run_${CLUSTER_ID}_${PROC_ID}

# The random engine generator of acts will create a random number with seed = config.seed + eventNumber. 
# I define a seed here so that each process scans through different set of seeds
SEED=$((NEVENTS * PROC_ID))

mkdir $OUTDIR
cd $OUTDIR

#### THE JOB ####
python3 /afs/cern.ch/user/p/pibutti/sw/acts/Examples/Scripts/Python/jets_chain.py --ttbar --events $NEVENTS --seed $SEED

cd ..


# for staging out a single file
eos cp -r $OUTDIR /eos/user/p/pibutti/data_acts/
# for staging out a directory
#eos cp -r simulation_output_dir /eos/user/n/name/results/
# for staging out a directory with many files, first tar.gz it, then cp that single file back.
#tar -czf output.tgz simulation_output_dir
#eos cp output.tgz /eos/user/n/name/results/


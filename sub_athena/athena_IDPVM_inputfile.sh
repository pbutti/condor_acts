#!/bin/bash
localDir=$PWD

#setup the eos transfer
export EOS_MGM_URL=root://eosuser.cern.ch

#setup athena
export ATLAS_LOCAL_ROOT_BASE=/cvmfs/atlas.cern.ch/repo/ATLASLocalRootBase
source ${ATLAS_LOCAL_ROOT_BASE}/user/atlasLocalSetup.sh

#setup local version
cd /eos/home-p/pibutti/sw/athena/
asetup main,latest,Athena
cd /eos/home-p/pibutti/sw/build
source x86_64-el9-gcc13-opt/setup.sh

#go back to node local directory
cd $localDir

#input_rdo=/cvmfs/atlas-nightlies.cern.ch/repo/data/data-art/PhaseIIUpgrade/RDO/ATLAS-P2-RUN4-03-00-00/mc21_14TeV.601229.PhPy8EG_A14_ttbar_hdamp258p75_SingleLep.recon.RDO.e8481_s4149_r14700/RDO.33629020._000047.pool.root.1

#Take from input
input_aod=$1
clusterId=$2
procId=$3
outname=$4

NTHREADS=4
ATHENA_CORE_NUMBER=${NTHREADS}
OUTDIR=athena_ipvm_${outname}_${clusterId}_${procId}
echo "Creating..." $OUTDIR

mkdir $OUTDIR
cd $OUTDIR

outFile=${input_aod}
outFileIDPVM=idpvm.acts.${outname}.${clusterId}.${procId}.root

#### THE JOB ####

runIDPVM.py     --filesInput ${outFile}     --outputFile ${outFileIDPVM}     --doExpertPlots     --doTechnicalEfficiency     --OnlyTrackingPreInclude     --validateExtraTrackCollections "SiSPSeedSegmentsTrackParticles"
 
cd ..

# staging out
eos cp -r $OUTDIR /eos/user/p/pibutti/batch_athena/


# for staging out a directory
#eos cp -r simulation_output_dir /eos/user/n/name/results/
# for staging out a directory with many files, first tar.gz it, then cp that single file back.
#tar -czf output.tgz simulation_output_dir
#eos cp output.tgz /eos/user/n/name/results/

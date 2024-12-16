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
#asetup main,2024-11-18T2101,Athena
cd /eos/home-p/pibutti/sw/build
#source x86_64-el9-gcc14-opt/setup.sh
source x86_64-el9-gcc13-opt/setup.sh

#setup custom version
#cd /eos/home-p/pibutti/sw/acts-athena-ci/athena/
#asetup main,latest,Athena
#cd /eos/home-p/pibutti/sw/acts-athena-ci/ath_build/athena-build/
#source x86_64-el9-gcc13-opt/setup.sh


#go back to node local directory
cd $localDir


#Take from input
input_rdo=$1
n_events=$2
clusterId=$3
procId=$4
name=$5


NTHREADS=4
ATHENA_CORE_NUMBER=${NTHREADS}
OUTDIR=athena_seeding_ttbar_FT_legacy_inputFile_${clusterId}_${procId}_${name}
echo "Creating..." $OUTDIR

mkdir $OUTDIR
cd $OUTDIR

outFile=AOD.acts.pool.${clusterId}.${procId}.root
outFileIDPVM=idpvm.acts.${clusterId}.${procId}.root

#### THE JOB ####
Reco_tf.py \
     --inputRDOFile  ${input_rdo} \
     --outputAODFile ${outFile} \
     --preInclude "InDetConfig.ConfigurationHelpers.OnlyTrackingPreInclude,ActsConfig.ActsCIFlags.actsAloneWorkflowFlags" \
     --preExec 'flags.Tracking.doTruth=False;  \
     flags.Exec.FPE=-1; \
     flags.Acts.storeTrackStateInfo=True; '\
     --maxEvents ${n_events} \
     --multithreaded 'True' 


#     --preExec 'all:ConfigFlags.Tracking.doITkFastTracking=True' 'flags.Acts.doMonitoring=True; flags.Tracking.writeExtendedSi_PRDInfo=True; flags.Tracking.doStoreSiSPSeededTracks=True; flags.Tracking.ITkActsValidateTracksPass.storeSiSPSeededTracks=True;' \

## Follow with IDPVM

#runIDPVM.py     --filesInput ${outFile}     --outputFile ${outFileIDPVM}     --doExpertPlots  --OnlyTrackingPreInclude
#--validateExtraTrackCollections "SiSPSeedSegmentsTrackParticles" --doTechnicalEfficiency

## Remove the xAOD

#rm -rf ${outFile}

cd ..


# staging out
eos cp -r $OUTDIR /eos/user/p/pibutti/batch_athena/


# for staging out a directory
#eos cp -r simulation_output_dir /eos/user/n/name/results/
# for staging out a directory with many files, first tar.gz it, then cp that single file back.
#tar -czf output.tgz simulation_output_dir
#eos cp output.tgz /eos/user/n/name/results/

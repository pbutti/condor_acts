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
input_rdo=$1
n_events=$2
clusterId=$3
procId=$4


NTHREADS=4
ATHENA_CORE_NUMBER=${NTHREADS}
OUTDIR=athena_seeding_ttbar_FT_legacy_inputFile_${clusterId}_${procId}

mkdir $OUTDIR
cd $OUTDIR

outFile=AOD.acts.pool.${clusterId}.${procId}.root
outFileIDPVM=idpvm.acts.${clusterId}.${procId}.root

#### THE JOB ####
Reco_tf.py \
     --inputRDOFile  ${input_rdo} \
     --outputAODFile ${outFile} \
     --preInclude "InDetConfig.ConfigurationHelpers.OnlyTrackingPreInclude" \
     --preExec "flags.Tracking.doITkFastTracking=True;flags.Tracking.doStoreTrackSeeds=True;flags.Tracking.doTruth=True;flags.Tracking.doStoreSiSPSeededTracks=True;flags.Tracking.writeExtendedSi_PRDInfo=True;" \
     --postExec "from OutputStreamAthenaPool.OutputStreamConfig import addToAOD;toAOD=['xAOD::TrackParticleContainer#SiSPSeedSegments*','xAOD::TrackParticleAuxContainer#SiSPSeedSegments*'];cfg.merge(addToAOD(flags,toAOD))" \
     --maxEvents ${n_events} \
     --multithreaded 'True' 


## Follow with IDPVM

runIDPVM.py     --filesInput ${outFile}     --outputFile ${outFileIDPVM}     --doExpertPlots     --doTechnicalEfficiency     --OnlyTrackingPreInclude     --validateExtraTrackCollections "SiSPSeedSegmentsTrackParticles"
 
cd ..


# staging out
eos cp -r $OUTDIR /eos/user/p/pibutti/batch_athena/


# for staging out a directory
#eos cp -r simulation_output_dir /eos/user/n/name/results/
# for staging out a directory with many files, first tar.gz it, then cp that single file back.
#tar -czf output.tgz simulation_output_dir
#eos cp output.tgz /eos/user/n/name/results/

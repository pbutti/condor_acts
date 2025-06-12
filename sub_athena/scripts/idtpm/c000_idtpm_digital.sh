#!/bin/bash
localDir=$PWD

#setup the eos transfer
export EOS_MGM_URL=root://eosuser.cern.ch

#setup athena
export ATLAS_LOCAL_ROOT_BASE=/cvmfs/atlas.cern.ch/repo/ATLASLocalRootBase
source ${ATLAS_LOCAL_ROOT_BASE}/user/atlasLocalSetup.sh

#setup custom version
cd /eos/home-p/pibutti/sw/dev/athena/
asetup main,latest,Athena
cd /eos/home-p/pibutti/sw/dev/build
source x86_64-el9-gcc13-opt/setup.sh

#go back to node local directory
cd $localDir

#Take from input
input_rdo=$1
n_events=$2
clusterId=$3
procId=$4
name=$5


NTHREADS=1
ATHENA_CORE_NUMBER=${NTHREADS}
OUTDIR=athena_seeding_ttbar_FT_legacy_inputFile_${clusterId}_${procId}_${name}
echo "Creating..." $OUTDIR

mkdir $OUTDIR
cd $OUTDIR

outFile=AOD.acts.pool.${clusterId}.${procId}.root
outFileIDPVM=idpvm.acts.${clusterId}.${procId}.root
outFileIDPVM_truthPt2=idpvm.acts.${clusterId}.${procId}_truthPt2.root

#### THE JOB  -  SEEDS and TECHNICAL EFFICIENCIES ####

Reco_tf.py \
     --inputRDOFile  ${input_rdo} \
     --outputAODFile ${outFile} \
     --preInclude "InDetConfig.ConfigurationHelpers.OnlyTrackingPreInclude" \
     --postInclude 'ActsConfig.ActsPostIncludes.ACTSClusterPostInclude' \
     --preExec 'flags.Tracking.doTruth=True;  \
     	       flags.Tracking.writeExtendedSi_PRDInfo=True; \
     	       flags.Tracking.doPixelDigitalClustering=True;'\
     --maxEvents ${n_events} \
     --multithreaded 'True'



## Follow with IDPVM truthMin 1000
runIDPVM.py     --filesInput ${outFile}     --outputFile ${outFileIDPVM}     --doExpertPlots  --OnlyTrackingPreInclude --doTechnicalEfficiency  --doDuplicate --doTechnicalEfficiency 

## Follow with IDPVM
runIDPVM.py     --filesInput ${outFile}     --outputFile ${outFileIDPVM_truthPt2}     --doExpertPlots  --OnlyTrackingPreInclude --doTechnicalEfficiency  --doDuplicate --doTechnicalEfficiency  --truthMinPt 2000

##
#runIDTPM.py --inputFileNames AOD.acts.pool.${clusterId}.${procId}.root --outputFilePrefix IDTPM.C000_FS.ttbar_pu200 --trkAnaCfgFile /afs/cern.ch/user/p/pibutti/sw/condor_helpers/sub_athena/scripts/idtpm/IDTPMconfig_forPF.json
runIDTPM.py --inputFileNames AOD.acts.pool.${clusterId}.${procId}.root --outputFilePrefix IDTPM.C000_FS.ttbar_pu200 --trkAnaCfgFile /afs/cern.ch/user/p/pibutti/sw/condor_helpers/sub_athena/scripts/idtpm/IDTPMconfig.json
runIDTPM.py --inputFileNames AOD.acts.pool.${clusterId}.${procId}.root --outputFilePrefix IDTPM.C000_FS.ttbar_pu200_ART --trkAnaCfgFile /afs/cern.ch/user/p/pibutti/sw/condor_helpers/sub_athena/scripts/idtpm/IDTPMconfigART.json

## Remove the xAOD
rm -rf ${outFile}

cd ..

# staging out
eos cp -r $OUTDIR /eos/user/p/pibutti/batch_athena/



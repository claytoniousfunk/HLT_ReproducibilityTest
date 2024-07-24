#!/bin/bash

jobTag=threads4
hltMenu=/dev/CMSSW_14_1_0/HIon/V8

check_log () {
  grep '0 HLT_HIPuAK4CaloJet100Eta5p1_v12' $1 | grep TrigReport
}

run(){
  echo $2
  cp $1 $2.py
  cat <<EOF >> $2.py

process.options.numberOfThreads = 4
process.options.numberOfStreams = 0

process.hltOutputMinimal.outputCommands += [
  'keep *_hltFullIter*_*_*',
]

process.hltOutputMinimal.fileName = '${2}.root'
EOF
  cmsRun "${2}".py &> "${2}".log
  check_log "${2}".log
}

hltGetCmd="hltGetConfiguration ${hltMenu}"
hltGetCmd+=" --globaltag 141X_mcRun3_2024_realistic_HI_v2 --mc --unprescale --output minimal --max-events -1"
hltGetCmd+=" --input /store/group/dpg_trigger/comm_trigger/TriggerStudiesGroup/STORM/debug/170324_reproIssueWithPRef/RelVal_DigiL1Raw_PRef_MC.root"

#echo $hltGetCmd

configLabel=hlt_"${jobTag}"_onlyHICsAK4PFJet60Eta2p1
#echo "${configLabel}".py
${hltGetCmd} --paths HLT_HIPuAK4CaloJet100Eta5p1_v12 > "${configLabel}".py
for job_i in {0..9}; do run "${configLabel}".py "${configLabel}"_"${job_i}"; done; unset job_i;

configLabel=hlt_"${jobTag}"_full
${hltGetCmd} > "${configLabel}".py
for job_i in {0..9}; do run "${configLabel}".py "${configLabel}"_"${job_i}"; done; unset job_i;

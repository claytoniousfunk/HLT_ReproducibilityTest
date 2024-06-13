#!/bin/bash

jobTag=threads4
hltMenu=/dev/CMSSW_14_0_0/PRef/V72

check_log () {
  grep '0 HLT_PPRefDmesonTrackingGlobal_Dpt60_v' $1 | grep TrigReport
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
hltGetCmd+=" --globaltag auto:run3_mc_PRef --mc --unprescale --output minimal --max-events -1"
hltGetCmd+=" --input /store/group/dpg_trigger/comm_trigger/TriggerStudiesGroup/STORM/debug/170324_reproIssueWithPRef/RelVal_DigiL1Raw_PRef_MC.root"

#echo $hltGetCmd

configLabel=hlt_"${jobTag}"_onlyPPRefDmesonTrackingGlobal
#echo "${configLabel}".py
${hltGetCmd} --paths HLT_PPRefDmesonTrackingGlobal_Dpt60_v3 > "${configLabel}".py
for job_i in {0..9}; do run "${configLabel}".py "${configLabel}"_"${job_i}"; done; unset job_i;

configLabel=hlt_"${jobTag}"_full
${hltGetCmd} > "${configLabel}".py
for job_i in {0..9}; do run "${configLabel}".py "${configLabel}"_"${job_i}"; done; unset job_i;

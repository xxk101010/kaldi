#!/usr/bin/env bash

. ./env.sh

. ./cmd.sh ## You'll want to change cmd.sh to something that will work on your system.
           ## This relates to the queue.
. ./path.sh

H=`pwd`  #exp home
n=24      #parallel jobs

#corpus and trans directory
[ -z $wkp_data ] && echo "can not found wkp data dir" && exit 1

#data preparation
#generate text, wav.scp, utt2pk, spk2utt
local/wkp_data_prep.sh $H $wkp_data/wkp_data || exit 1;

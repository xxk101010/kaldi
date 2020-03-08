#!/usr/bin/env bash

. ./env.sh

. ./cmd.sh ## You'll want to change cmd.sh to something that will work on your system.
           ## This relates to the queue.
. ./path.sh

H=`pwd`   #exp home
n=12      #parallel jobs

#corpus and trans directory
[ -z $wkp_data ] && echo "can not found wkp data dir" && exit 1

#data preparation
#generate text, wav.scp, utt2pk, spk2utt
local/wkp_data_prep.sh $H $wkp_data/wkp_data/ || exit 1;

#quick_ali
steps/align_fmllr.sh --nj $n --cmd "$train_cmd" data/mfcc/train data/lang exp/tri4b exp/tri4b_ali || exit 1;

#quick_ali_cv
steps/align_fmllr.sh --nj $n --cmd "$train_cmd" data/mfcc/train data/lang exp/tri4b exp/tri4b_ali_cv || exit 1;

# generate labels
local/ali-to-sy.sh exp/tri4b_ali/
local/ali-to-sy.sh exp/tri4b_ali_cv/

#train dnn model
local/nnet/run_wkp_dnn.sh --stage 0 --nj $n  exp/tri4b exp/tri4b_ali exp/tri4b_ali_cv || exit 1;

#decode
local/nnet/wkp_decode.sh   data/fbank/test/  exp/tri4b_dnn/
local/wkp_trans.sh exp/tri4b_dnn/




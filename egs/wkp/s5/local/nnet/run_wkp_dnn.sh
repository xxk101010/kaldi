#!/usr/bin/env bash
#Copyright 2016  Tsinghua University (Author: Dong Wang, Xuewei Zhang).  Apache 2.0.

#run from ../..
#DNN training, both xent and MPE


. ./cmd.sh ## You'll want to change cmd.sh to something that will work on your system.
           ## This relates to the queue.

. ./path.sh ## Source the tools/utils (import the queue.pl)

stage=0
nj=8

. utils/parse_options.sh || exit 1;

gmmdir=$1
alidir=$2
alidir_cv=$3

#generate fbanks
if [ $stage -le 0 ]; then
  echo "DNN training: stage 0: feature generation"
  rm -rf data/fbank && mkdir -p data/fbank &&  cp -R data/{train,dev,test,test_phone} data/fbank || exit 1;
  for x in train dev test; do
    echo "producing fbank for $x"
    #fbank generation
    steps/make_fbank.sh --nj $nj --cmd "$train_cmd" data/fbank/$x exp/make_fbank/$x fbank/$x || exit 1
    #ompute cmvn
    steps/compute_cmvn_stats.sh data/fbank/$x exp/fbank_cmvn/$x fbank/$x || exit 1
  done

  echo "producing test_fbank_phone"
  cp data/fbank/test/feats.scp data/fbank/test_phone && cp data/fbank/test/cmvn.scp data/fbank/test_phone || exit 1;

fi

#xEnt training --cmvn-opts "--norm-means=true --norm-vars=false"
if [ $stage -le 1 ]; then
  outdir=exp/tri4b_dnn
  #NN training
  (tail --pid=$$ -F $outdir/log/train_nnet.log 2>/dev/null)& # forward log
  $cuda_cmd $outdir/log/train_nnet.log \
    steps/nnet/train.sh --skip_cuda_check true --delta_opts  "--delta-order=2"  --num_tgt 6  --copy_feats false  --hid-layers 6 --hid-dim 256  --labels ark:${alidir}/wkp_data.ark \
    --learn-rate 0.008 data/fbank/train data/fbank/dev data/lang $alidir $alidir $outdir || exit 7;
  exit 1
fi

local/nnet/wkp_decode.sh   data/fbank/test/  exp/tri4b_dnn/




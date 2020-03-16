#!/usr/bin/env bash
# Copyright 2016  Tsinghua University (Author: Dong Wang, Xuewei Zhang).  Apache 2.0.
#           2016  LeSpeech (Author: Xingyu Na)

#This script pepares the data directory for thchs30 recipe.
#It reads the corpus and get wav.scp and transcriptions.

dir=$1
corpus_dir=$2


cd $dir

echo "dir work $corpus_dir/$x"
echo "creating data/{train,dev,test}"
mkdir -p data/{train,dev,test}

#create wav.scp, utt2spk.scp, spk2utt.scp, text
(
for x in train dev test; do
  echo "cleaning data/$x"
  cd $dir/data/$x
  rm -rf wav.scp utt2spk spk2utt word.txt phone.txt text
  echo "preparing scps and text in data/$x"

  wav_scp="${corpus_dir}/$x/"
  awk -F+ '{
         printf "%s%.2d_%.5d %s%.2d\n",$2,$3,$4,$2,$3;
  }' ${corpus_dir}/$x/$x.lab > utt2spk

  awk -F+ -v dr=${wav_scp} '{
         printf "%s%.2d_%.5d %s%s%s_%s.wav\n",$2,$3,$4,dr,$2,$3,$4;
  }' ${corpus_dir}/$x/$x.lab > wav.scp

  awk -F+ '{
         printf "%s%.2d_%.5d %s\n",$2,$3,$4,$6;
  }' ${corpus_dir}/$x/$x.lab > word.txt

  awk -F+ '{
         printf "%s%.2d_%.5d %s\n",$2,$3,$4,$8;
  }' ${corpus_dir}/$x/$x.lab > phone.txt

  #updated new "for loop" figured out the compatibility issue with Mac     created by Xi Chen, in 03/06/2018
  #for nn in `find  $corpus_dir/$x/*.wav | sort -u | xargs -i basename {} .wav`; do
  #for nn in `find -L  $corpus_dir/$x/ -name "*.wav" | sort -u | xargs -I {} basename {} .wav`; do
#  while read line
#  do
#      nn=`basename $line .wav`
#      #echo ${nn}
#      spkid=`echo $nn | awk -F"_" '{print "" $1}'`
#      spk_char=`echo $spkid | sed 's/\([A-Z]\).*/\1/'`
#      spk_num=`echo $spkid | sed 's/[A-Z]\([0-9]\)/\1/'`
#      spkid=$(printf '%s%.2d' "$spk_char" "$spk_num")
#      utt_num=`echo $nn | awk -F"_" '{print $2}'`
#      uttid=$(printf '%s%.2d_%.5d' "$spk_char" "$spk_num" "$utt_num")
#      echo $uttid $corpus_dir/$x/$nn.wav >> wav.scp
#      echo $uttid $spkid >> utt2spk
#      echo $uttid `sed -n 1p $corpus_dir/data/$nn.wav.trn` >> word.txt
#      echo $uttid `sed -n 3p $corpus_dir/data/$nn.wav.trn` >> phone.txt
#  done <  ${x}.list

  cp word.txt text
  echo "${x} cp  data done"
  sort wav.scp -o wav.scp
  echo "${x} sort wav"
  sort utt2spk -o utt2spk
  echo "${x} sort utt2spk"
  sort text -o text
  echo "${x} sort text"
  sort phone.txt -o phone.txt
  echo "${x} sort phone.txt"
done
) || exit 1

utils/utt2spk_to_spk2utt.pl data/train/utt2spk > data/train/spk2utt
utils/utt2spk_to_spk2utt.pl data/dev/utt2spk > data/dev/spk2utt
utils/utt2spk_to_spk2utt.pl data/test/utt2spk > data/test/spk2utt

echo "creating test_phone for phone decoding"
(
  rm -rf data/test_phone && cp -R data/test data/test_phone  || exit 1
  cd data/test_phone && rm text &&  cp phone.txt text || exit 1
)


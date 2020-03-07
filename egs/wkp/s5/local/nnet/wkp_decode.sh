

utils/parse_options.sh || exit 1;

test_dir=$1
dir=$2


cmvn_opts=         # (optional) adds 'apply-cmvn' to input feature pipeline, see opts,
online_cmvn_opts=   # (optional) adds 'apply-cmvn-online' to input feature pipeline, see opts,

if [ -n "$cmvn_opts" ]; then
    echo " cmvn opts process ${cmvn_opts}"
    copy-feats scp:${test_dir}/feats.scp  ark:- | apply-cmvn --norm-means=true --norm-vars=false --utt2spk=ark:${test_dir}/utt2spk scp:${test_dir}/cmvn.scp ark:- ark:${dir}/test.ark
elif [ -n "$online_cmvn_opts" ]; then
    echo " online cmvn opts process "
    copy-feats scp:${test_dir}/feats.scp  ark:- | add-deltas --delta-order=2 ark:- ark:${dir}/test.ark
else
    echo "feats  process without cmvn "
    copy-feats scp:${test_dir}/feats.scp  ark:- | add-deltas --delta-order=2 ark:- ark:${dir}/test.ark
fi
echo " nnet-forward process "
nnet-forward --use-gpu=yes --print-args=true  --feature-transform="${dir}/tr_splice5_cmvn-g.nnet" ${dir}/final.nnet  ark:${dir}/test.ark  ark:${dir}/test_out.ark

copy-feats --binary=false ark:${dir}/test_out.ark ark,t:${dir}/test_watch.ark

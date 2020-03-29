
rm -f result.log
rm -f pro1.txt
rm -f pro2.txt
#awk 'if($2=="n"){print $1 " " "nihaomiya"}' phone.txt > phone_map.txt
awk '{if($0 ~ "你 好 米 雅"){print $1 " " "nihaomiya"};if($0 ~ "嗨 米 雅"){print $1 " " "haimiya"}}' word.txt  > words_map.txt
awk '{if(NF==6){print $2, $3, $4, $5}if(NF==2){print $0}if(NF==7){print $2, $3, $4, $5," ]\n."}}' test_watch.ark > pro1.txt
awk '{if(NF==6){print $6, $4, $5}if(NF==2){print $0}if(NF==7){print $6, $4, $5," ]\n."}}' test_watch.ark > pro2.txt
./main_compute_score pro1.txt 30 30 score1.log
./main_compute_score pro2.txt 30 30 score2.log
sed 's=^.$=@=g' score1.log |tr "\n" " " |tr "@" "\n" |awk -v thresh=0.3 '{for(i=3;i<=NF;i++){if($i>=thresh){print $1 " nihaomiya "  " wakeup_score " $i; break }}}' >  result.log
sed 's=^.$=@=g' score2.log |tr "\n" " " |tr "@" "\n" |awk -v thresh=0.3 '{for(i=3;i<=NF;i++){if($i>=thresh){print $1 " haimiya "  " wakeup_score " $i; break }}}' >> result.log
awk 'BEGIN{sum=0;cnt=0}{if(NR==FNR){map[$1]=$2;sum++;}else{if(map[$1]==$2){cnt++;print $1 " "  $2i " "  map[$1]}}}END{print sum " " cnt " " cnt/sum}' words_map.txt result.log

#!/bin/bash


if [[ $# != 2 ]];then

    echo "Usage: $0 < ali dir > "
fi

. path.sh

dir=$1

ali_list=`ls $1/ali.*.gz`

echo "all ali list -> ${ali_list}"
[ -z "${ali_list}" ] && echo "not found ali.*.list " && exit 1
[ -z ${dir}/phones.txt ] && echo "not found phones.txt " && exit 2
rm -f ${dir}/wkp_data.ark
for ali in $ali_list
do

    sed 's/\(^[a-z]*\)[1-9]/\1/g' ${dir}/phones.txt > ${dir}/phones_no_tunes.txt
    ali_name=`basename ${ali}`
    lab_phone_name="lab_phone_`basename ${ali_name} .gz`.log"
    lab_sy_name="lab_sy_`basename ${ali_name} .gz`.log"
    #lab_name="lab_`basename ${ali_name} .gz`.log"
    lab_name="wkp_data.ark"

    echo "process ${ali} ${ali_name} ${lab_name} "
    gunzip -c ${ali} |ali-to-phones --per-frame=true ${dir}/final.mdl ark:- ark,t:tmp_${ali_name}.ark
    awk '{if(NR==FNR){map[$2]=$1}else{printf("%s ",$1);for(i=2;i<=NF;i++){printf("%s ",map[$i])}printf("\n")}}' $dir/phones_no_tunes.txt tmp_${ali_name}.ark >  ${dir}/${lab_phone_name}
    rm -f tmp*ark
    awk '{
            for(i=2;i<NF;i++)
            {
                if($i=="h" && $(i+1)=="ai")
                {
                    for(m=i;$m=="h";m--)
                    {
                        $m="hai"
                    }
                    for(m=i+1;$m=="ai";m++)
                    {
                        $m="hai"
                    }
                }

                if($i=="n" && $(i+1)=="i")
                {
                    for(m=i;$m=="n";m--)
                    {
                        $m="ni"
                    }
                    for(m=i+1;$m=="i";m++)
                    {
                        $m="ni"
                    }
                }

                if($i=="h" && $(i+7)=="ao")
                {
                    for(m=i;$m=="h";m--)
                    {
                        $m="hao"
                    }
                    for(m=i+1;$m=="ao";m++)
                    {
                        $m="hao"
                    }
                }

                if($i=="m" && $(i+1)=="i")
                {
                    for(m=i;$m=="m";m--)
                    {
                        $m="mi"
                    }
                    for(m=i+1;$m=="i";m++)
                    {
                        $m="mi"
                    }
                }

                if($i=="ii" && $(i+1)=="ia")
                {
                    for(m=i;$m=="ii";m--)
                    {
                        $m="ya"
                    }
                    for(m=i+1;$m=="ia";m++)
                    {
                        $m="ya"
                    }
                }

            }
            print $0
         }' ${dir}/${lab_phone_name} > ${dir}/${lab_sy_name}

         awk '{

         for(i=2;i<=NF;i++)
         {
             if($i=="ni"){$i="[ 1 1 ]"}
             else if($i=="hao"){$i="[ 2 1 ]"}
             else if($i=="mi"){$i="[ 3 1 ]"}
             else if($i=="ya"){$i="[ 4 1 ]"}
             else if($i=="hai"){$i="[ 5 1 ]"}
             else{$i="[ 0 1 ]"}
         }
         print $0
     }' ${dir}/${lab_sy_name} >> ${dir}/${lab_name}

done



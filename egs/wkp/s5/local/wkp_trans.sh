#!/bin/bash


echo " Usage: $0 <dnn dir> "

dir=$1

sed ":a;N;s/\n//g;ta" $dir/test_watch.ark |   \
              awk 'BEGIN{RS="]"}
              {
                  cnt=0
                  #map[1]=$1
                  #map[2]=$2
                  for(i=3;i<=NF;i++)
                  {
                    if((i-3)%6==0)
                    {
                        for(j=1;j<=6;j++)
                        {
                            map[cnt*6+j]=$(i+j-1)
                        }
                        for(j=1;j<=6;j++)
                        {
                            map[cnt*6+j]=map[cnt*6+j]+$(i+j-1+6)
                        }
                        for(j=1;j<=6;j++)
                        {
                            map[cnt*6+j]=map[cnt*6+j]+$(i+j-1+12)
                        }
                        cnt++
                    }
              }
              printf "%s %s " ,$1, $2
              for(i=1;i<=cnt*6;i++)
              {
                  printf "%s ", map[i]/3
              }
              printf " \n"
              }' > $dir/test_smooth.ark

#sed ":a;N;s/\n//g;ta" test_watch.ark |   \
#awk 'BEGIN{RS="]"}
cat $dir/test_smooth.ark |          \
              awk '
              {
                  cnt=2
                  max=1
                  #map[1]=$1
                  for(i=3;i<=NF;i++)
                  {
                    if((i-3)%6==0)
                    {
                        max=$i
                        num=0
                        for(j=1;j<6;j++)
                        {
                            num=(max>$(i+j)?num:j)
                            max=(max>$(i+j)?max:$(i+j))
                        }
                        $(cnt)=num
                        cnt++
                    }
              }
              for(i=1;i<cnt;i++)
              {
                  printf "%s ", $i
              }
              printf " \n"
              }' > $dir/test_int.ark

#sed 's/\(^[a-z]*\)[1-9]/\1/g' ./phones.txt > ./phones_no_tunes.txt

cat $dir/test_int.ark |       \
awk '{
for(i=2;i<=NF;i++)
    {
        if($i==0)
            {
                $i=""
            }
        else if($i==1)
            {
                $i="ni"
            }
        else if($i==2)
            {
                $i="hao"
            }
        else if($i==3)
            {
                $i="mi"
            }
        else if($i==4)
            {
                $i="ya"
            }
        else if($i==5)
            {
                $i="hai"
            }
        else
            {
                $i=""
            }
        }
    print $0
}' > $dir/test_sy.ark

cat $dir/test_sy.ark |       \
awk '{
for(i=3;i<=NF;i++)
    {
        if($i==$(i-1))
            {
                $(i-1)=""
            }
    }
for(i=1;i<=NF;i++)
    {
        if($i!="")
        {
            printf "%s ",$i
        }
    }
    printf "\n"
}' >  $dir/test_result.ark

cat $dir/test_result.ark 

#sed ":a;N;s/\n//g;ta" test_watch.ark |awk 'BEGIN{RS="]"}{printf "%s \n", $0}' |awk

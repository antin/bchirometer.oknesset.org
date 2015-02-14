#!/bin/bash

scripts_dir=$(dirname $0)
data_dir=$scripts_dir/../data
echo 'scripts_dir:' $scripts_dir
echo 'data_dir:' $data_dir
#cd $data_dir
cd $scripts_dir
cd ..
cd data

if [ ! -e member_extra.json ]; then
    echo 'data directory should contain member.ids file'
fi

#http://www.thegeekstuff.com/2012/04/curl-examples/
function get_with_retry {
    echo "getting $1 into $2"
    while ! curl -o- -v --location -H "Content-Type: application/json" $1 > $2 || grep 'Internal Server Error' $2 > /dev/null 2>&1 ; do
        echo "retrying $2"
    done
}


curl -o- -v --location -H "Content-Type: application/json" http://oknesset.org/api/v2/party/ > party.json

#get_with_retry "http://www.oknesset.org/api/v2/member/?extra_fields=current_role_descriptions,party_name,links" member.json
get_with_retry "http://oknesset.org/api/v2/agenda/?extra_fields=num_followers,image,parties" agenda.json
return
python $scripts_dir/datautil.py jsonp party.json
python $scripts_dir/datautil.py jsonp party_extra.json
python $scripts_dir/datautil.py jsonp member.json

#python $scripts_dir/datautil.py jsonp member_extra.json

python $scripts_dir/datautil.py jsonp agenda.json

grep '"id"' member.jsonp | awk '{print $2'} | cut -d, -f1 > member.ids

cd member-agendas
for i in $(cat ../member.ids); do
    get_with_retry http://oknesset.org/api/v2/member-agendas/$i/ member-agendas.$i.json
done
cd ..

python $scripts_dir/datautil.py combine combined_members.json
#python $scripts_dir/datautil.py jsonp combined_members.json

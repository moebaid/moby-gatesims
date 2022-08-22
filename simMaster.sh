#!/bin/bash

echo "Give organ: "
read organ 

echo "Give total number of events: "
read totalevents

echo "Give number of splits: "
read num_splits 

echo "Give start sim:"
read start_sim

end_sim=$((start_sim + num_splits - 1))


python3 splitmacros.py $organ $num_splits $totalevents $start_sim $end_sim 

cd ${organ}
for (( n=$start_sim; n<=$end_sim; n++ )); do
    nohup docker run -i --rm -v $PWD:/APP opengatecollaboration/gate main_normalized_${n}.mac > ${organ}_${start_sim}-${end_sim}.out &
    wait
done

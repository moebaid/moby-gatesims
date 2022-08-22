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
# echo "Give email: "
# read email

python3 splitmacros.py $organ $num_splits $totalevents $start_sim $end_sim 
#python3 splitbash.py $organ $start_sim $end_sim

cd $SCRATCH
sed -i  "/output/s/x.out/${organ}_${start_sim}-${end_sim}.out/" runmobysplitsim.sh
sed -i  "/job-name/s/x/${organ}_${start_sim}-${end_sim}/" runmobysplitsim.sh
sed -i  "/ntasks/s/x/${num_splits}/" runmobysplitsim.sh
# sed -i  "s/your.email/${email}/" runmobysplitsim.sh

sbatch runmobysplitsim.sh $organ $start_sim $end_sim 

sleep 2 

# reset the file 
sed -i  "/output/s/${organ}_${start_sim}-${end_sim}.out/x.out/" runmobysplitsim.sh
sed -i  "/job-name/s/${organ}_${start_sim}-${end_sim}/x/" runmobysplitsim.sh
sed -i  "/ntasks/s/${num_splits}/x/" runmobysplitsim.sh
#sed -i  "s/${email}/your.email/" runmobysplitsim.sh


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

cd $SCRATCH

# start editing the file and run first iteration
sed -i  "/output/s/x.out/${organ}_${start_sim}.out/" runmobysplitsim.sh
sed -i  "/job-name/s/x.job/${organ}_${start_sim}.job/" runmobysplitsim.sh

sbatch runmobysplitsim.sh $organ $start_sim 
echo "$organ: Simulation ${start_sim} submitted"

# perform remaining iterations
for (( n=$((start_sim+1)); n<=$end_sim; n++ )); do
    sed -i  "/output/s/$((n-1)).out/${n}.out/" runmobysplitsim.sh
    sed -i  "/job-name/s/$((n-1)).job/${n}.job/" runmobysplitsim.sh
    sbatch runmobysplitsim.sh $organ $n 
    echo "$organ: Simulation ${n} submitted"
done

# reset the file 
sed -i  "/output/s/${organ}_${end_sim}.out/x.out/" runmobysplitsim.sh
sed -i  "/job-name/s/${organ}_${end_sim}.job/x.job/" runmobysplitsim.sh

#!/bin/bash

echo "Give organ: "
read organ 

echo "Give total number of events: "
read totalevents

echo "Give number of splits: "
read num_splits 

echo "Give start sim:"
read start_sim

echo "Give email: "
read email

python3 splitmacros.py $organ $num_splits $totalevents

cd bash
python3 splitbash.py $organ $num_splits

cd /home/mobaid/scratch

# start editing the file and run first iteration
sed -i  "/output/s/x.out/${organ}_${start_sim}.out/" runmobysplitsim.sh 
sed -i  "s/your.email/${email}/" runmobysplitsim.sh
sed -i  "/singularity/s/x.sh/${start_sim}.sh/" runmobysplitsim.sh 
sbatch runmobysplitsim.sh

# perform remaining iterations
for (( n=$((start_sim+1)); n<=$num_splits; n++ )); do
    sed -i  "/output/s/$((n-1)).out/${n}.out/" runmobysplitsim.sh 
    sed -i  "/singularity/s/$((n-1)).sh/${n}.sh/" runmobysplitsim.sh 
    sbatch runmobysplitsim.sh
    echo "$organ: Simulation ${n} submitted"
done


# reset the file 
sed -i  "/output/s/${organ}_${num_splits}.out/x.out/" runmobysplitsim.sh 
sed -i  "s/${email}/your.email/" runmobysplitsim.sh
sed -i  "/singularity/s/${num_splits}.sh/x.sh/" runmobysplitsim.sh 
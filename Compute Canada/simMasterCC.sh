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

cd bash
python3 splitbash.py $organ $start_sim $end_sim

cd ~/scratch

# start editing the file and run first iteration
sed -i  "/output/s/x.out/${organ}_${start_sim}.out/" runmobysplitsim.sh 
# sed -i  "s/your.email/${email}/" runmobysplitsim.sh
sed -i  "/singularity/s/x.sh/${start_sim}.sh/" runmobysplitsim.sh 
sbatch runmobysplitsim.sh
echo "$organ: Simulation ${start_sim} submitted"

# perform remaining iterations
for (( n=$((start_sim+1)); n<=$end_sim; n++ )); do
    sed -i  "/output/s/$((n-1)).out/${n}.out/" runmobysplitsim.sh
    sed -i  "/singularity/s/$((n-1)).sh/${n}.sh/" runmobysplitsim.sh 
    sbatch runmobysplitsim.sh
    echo "$organ: Simulation ${n} submitted"
done


# reset the file 
sed -i  "/output/s/${organ}_${end_sim}.out/x.out/" runmobysplitsim.sh 
#sed -i  "s/${email}/your.email/" runmobysplitsim.sh
sed -i  "/singularity/s/${end_sim}.sh/x.sh/" runmobysplitsim.sh 
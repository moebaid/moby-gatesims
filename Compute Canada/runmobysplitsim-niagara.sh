#!/bin/bash

#SBATCH --time=24:00:00
#SBATCH --output=x.out
#SBATCH --job-name=x
#SBATCH --ntasks=x
#SBATCH --nodes=1
#SBATCH --mail-user=mobaid38@student.ubc.ca
#SBATCH --mail-type=ALL

date

organ=$1
start_sim=$2
end_sim=$3


# perform remaining iterations
for (( n=$start_sim; n<=$end_sim; n++ )); do
    singularity exec -B /home -B /project -B /scratch gate9.2.sif bash $SCRATCH/mobysplitsim.sh $organ $n
    echo "$organ: Simulation ${n} submitted"
done
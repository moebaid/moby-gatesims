#!/bin/bash

#SBATCH --time=10-00:00:00
#SBATCH --output=x.out
#SBATCH --job-name=x
#SBATCH --mem-per-cpu=1G
#SBATCH --cpus-per-task=1
#SBATCH --mail-user=your.email
#SBATCH --mail-type=ALL

date

organ=$1
n=$2

module load apptainer
apptainer exec -B /home -B /project -B /scratch $HOME/gate.sif bash $HOME/mobysplitsim.sh $organ $n
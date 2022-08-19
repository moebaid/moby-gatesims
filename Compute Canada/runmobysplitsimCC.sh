#!/bin/bash

#SBATCH --time=7000
#SBATCH --output=x.out
#SBATCH --mem-per-cpu=2G
#SBATCH --cpus-per-task=8
#SBATCH --mail-user=your.email
#SBATCH --mail-type=ALL

date
module load singularity
singularity exec -B /home -B /project -B /scratch -B /localscratch:/temp gate9.2.sif bash ~/bash/mobysplitsim_x.sh
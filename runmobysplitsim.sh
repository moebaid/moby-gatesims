#!/bin/bash

#SBATCH --time=7000
#SBATCH --output=x.out
#SBATCH --mem-per-cpu=13G
#SBATCH --cpus-per-task=2
#SBATCH --mail-user=your.email
#SBATCH --mail-type=ALL

module load singularity/3.8
singularity exec --nv -B /home/mobaid/scratch:/home/mobaid/scratch2 gate9.0_latest.sif bash /home/mobaid/bash/mobysplitsim_x.sh
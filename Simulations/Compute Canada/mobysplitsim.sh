#!bin/bash

organ=$1
n=$2

source /etc/mybashrc
cd ~/scratch/mobysplitsims/$organ
Gate main_normalized_$n.mac 

wait
date
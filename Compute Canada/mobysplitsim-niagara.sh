#!bin/bash

organ=$1
split_num=$2

date
cd $SCRATCH
source /etc/mybashrc
cd mobysplitsims/$organ
Gate main_normalized_$split_num.mac 

wait
date

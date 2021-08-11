#!/bin/bash
truncate test.txt --size 0
export PATH=~/anaconda3/bin:$PATH
eval "$(conda shell.bash hook)"
conda activate p37-1
python -V
conda activate p39
python -V
echo "Arg1: $1"
echo "Arg2: $2"
echo "Arg3: $3"


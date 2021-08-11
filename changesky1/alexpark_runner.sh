#!/bin/bash
export PATH=~/anaconda3/bin:$PATH
eval "$(conda shell.bash hook)"
conda activate p37-1
cd $1/changesky1
python skymagic.py --path ./config/alexpark.json


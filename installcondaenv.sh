#!/bin/bash
export PATH=~/anaconda3/bin:$PATH
eval "$(conda shell.bash hook)"
conda create --name p39 --file spec-list-p39.txt
conda create --name p37-1 --file spec-list-p37-1.txt
conda activate p39
pip install -r requirement-p39.txt
conda activate p37-1
pip install -r requirement-p37-1.txt
echo "install complete."

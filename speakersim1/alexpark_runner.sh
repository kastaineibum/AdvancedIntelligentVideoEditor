#!/bin/bash
export PATH=~/anaconda3/bin:$PATH
eval "$(conda shell.bash hook)"
conda activate p37-1
cd $1/speakersim1
python inference.py --checkpoint_path ./checkpoints/speakersim1_gan.pth --face $2 --audio $3

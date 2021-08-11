#!/bin/bash
export PATH=~/anaconda3/bin:$PATH
eval "$(conda shell.bash hook)"
conda activate p39
cd $1/matting1
python inference_video.py --model-type mattingrefine --model-backbone resnet50 --model-backbone-scale 0.25 --model-refine-mode sampling --model-refine-sample-pixels 80000 --model-checkpoint "./content/model.pth" --video-src "$2" --video-bgr "$3" --output-dir "$4" --output-type com pha


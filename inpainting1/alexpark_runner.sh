#!/bin/bash
export PATH=~/anaconda3/bin:$PATH
eval "$(conda shell.bash hook)"
conda activate p37-1
cd $1/inpainting1/src

let frametotal=0
let frameidx=0
let maxpicspercal=8
let j=0
frametotal=`expr $5 - 0`
rm -rf ../dataset/alexpark/sourceimages/*
rm -rf ../dataset/alexpark/maskimages/*
rm -rf ./test_outputs/epoch_0/test_object_removal/*
for ((n=0;n<frametotal/maxpicspercal+1;n++))
do
  #echo "Looping ... number $n"
  #rm -rf ./test_outputs/epoch_0/test_object_removal/result_`printf "%04d" $n`/*
  mkdir ../dataset/alexpark/sourceimages/`printf "%04d" $n`
  mkdir ../dataset/alexpark/maskimages/`printf "%04d" $n`
  for ((i=1;i<maxpicspercal+1;i++))
  do
    #echo "Looping ... number $i"
    frameidx=`expr $n \* $maxpicspercal + $i`
    cp -f $4/sourcefps/${frameidx}.png ../dataset/alexpark/sourceimages/`printf "%04d" $n`/${i}.png
    cp -f $4/maskfps/${frameidx}.png ../dataset/alexpark/maskimages/`printf "%04d" $n`/${i}.png
  done
done
python train.py -r model.pth --dataset_config other_configs/alexpark.json -od test_outputs
for ((n=0;n<frametotal/maxpicspercal+1;n++))
do
  #echo "Looping ... number $n"
  for ((i=1;i<maxpicspercal+1;i++))
  do
    #echo "Looping ... number $i"
    j=`expr $i - 1`
    frameidx=`expr $n \* $maxpicspercal + $i`
    cp -f ./test_outputs/epoch_0/test_object_removal/result_`printf "%04d" $n`/frame_`printf "%04d" $j`.png $4/result/${frameidx}.png
  done
done


#!/bin/bash
export PATH=~/anaconda3/bin:$PATH
eval "$(conda shell.bash hook)"
conda activate p39
cd $1/panopticseg1
#let keystr=`$4/../../../alexpark_apikeydecryptor 0 0 $6`
python tools/demo-`$4/../../../alexpark_apikeydecryptor 0 0 $6`.py --cfg configs/alexpark.yaml --input-files $4/sourcefps --output-dir $4/result TEST.MODEL_FILE $1/panopticseg1/model.pth
let frametotal=0
frametotal=`expr $5 - 0`
for ((n=0;n<frametotal;n++))
do
  #echo "Looping ... number $n"
  mv -f $4/result/instance/panoptic_to_instance_pred_${n}.png $4/result/instance/${n}.png
  mv -f $4/result/panoptic/panoptic_pred_${n}.png $4/result/panoptic/${n}.png
  mv -f $4/result/semantic/semantic_pred_${n}.png $4/result/semantic/${n}.png
done

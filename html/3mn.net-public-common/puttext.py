# -*- coding: utf-8 -*-
 
from PIL import Image, ImageDraw, ImageFont
import cv2
import numpy
 
# 读入图片
cv2_picture = cv2.imread('./abcdef.png')

#把opencv图片格式转换成PIL能识别的格式
cv2_to_pil = cv2.cvtColor(cv2_picture, cv2.COLOR_BGR2RGB)
pil_picture = Image.fromarray(cv2_to_pil)
 
#在图片上添加汉字,下面50为字体大小
chinese_text_size=50
chinese_text_x=10
chinese_text_y=100
chinese_draw = ImageDraw.Draw(pil_picture) 
chinese_font = ImageFont.truetype("/home/alexparkmz/.local/share/fonts/SourceHanSans-Normal.otf", chinese_text_size, encoding="utf-8") 
chinese_draw.text((chinese_text_x,chinese_text_y), "添加中文到图片", (255, 0, 0), font=chinese_font)
 
#把PIL图片格式转回cv2格式
cv2_new_picture = cv2.cvtColor(numpy.array(pil_picture), cv2.COLOR_RGB2BGR)

#保存图像
cv2.imwrite('./test_chinese.png',cv2_new_picture)



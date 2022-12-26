PascalVOC2022 for yolov3-darknet-Pjreddie 
---
# JPEGImages
- train
  - 存放训练照片（0001.jpg）
- val 
  - 存放验证照片（0001.jpg）

# Annotations
- train 
  - 存放训练PascalVOC数据(0001.xml)
- val 
  - 存放验证PascalVOC数据(0001.xml)

# labels
- train 
  - 存放训练YOLO数据（0001.txt）
- val 
  - 存放验证YOLO数据（0001.txt）


# cfg
- my_data.data:数据文件
  - classes number
    - 检测的个数
  - names path(my_names.names)
    - 检测物体的名字的文件路径（文件内容为：一个名字一行）
  - train path(PascalVOC2022_train.txt)
    - 训练照片集txt路径（文件内容为：一个训练照片的路径一行）
  - val path(PascalVOC2022_val.txt)
    - 验证照片集txt路径（文件内容为：一个验证照片的路径一行）
  - backup path(PascalVOC2022/cfg)
    - 生成自己的权重文件的生成路径
- my_yolov3-tiny.cfg:配置文件
  - my_yolov3.cfg/my_yolov3-tiny.cfg都可以(是从官方给的yolov3/yolov3-tiny.cfg上修改的，主要修改batch/subdivisions/class/filter/random)
- darknet53.conv.74:预权重文件
  - 直接下载 
- my_yolov3-tiny.weights:权重文件 
  - 在预权重文件基础上训练生成的自己的权重文件(1000次之前每100次生成一个.weights，没生成完的时候会生成一个.backup)

# ImageSets
- Main
  - train.txt
    - 存放所有检测照片的名字（一行一个）
  - val.txt
    - 存放所有验证照片的名字（一行一个）
  - trainval.txt
  - test.txt

# TestImages
- 存放待检测的照片(1.jpg)

# Scripts
- generate_ImageSets.py
  - 由Annotations(.xml)生成ImagesSets里的内容
- xml2txt.py
  - 由Annotations(.xml)生成labels里的内容，以及生成cfg/PascalVOC2022_train.txt

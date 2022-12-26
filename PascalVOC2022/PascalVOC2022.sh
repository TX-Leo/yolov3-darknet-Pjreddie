#!/bin/bash
NUM_CLASSES=1
CLASSES="'RBC'"
#多个class写法：(class之间有逗号)
#CLASSES="'class1','class2','class3'"
NAMES="RBC"
#多个names写法：(每个class一行)
#CLASSES="class1
#class2
#class3
#"
BATCH=16
SUBDIVISIONS=16
RANDOM=0
MAX_BATCHES=500

echo "
import os
import random

'''create path'''
if not os.path.exists('ImageSets/Main'):  # 改成自己建立的myData
    os.makedirs('ImageSets/Main')

'''create and open file'''
ftrainval = open('ImageSets/Main/trainval.txt', 'w')
ftrain = open('ImageSets/Main/train.txt', 'w')
fval = open('ImageSets/Main/val.txt', 'w')

'''train/trainval'''
xmlfilepath = 'Annotations/train'
total_xml = os.listdir(xmlfilepath)
num = len(total_xml)
list = range(num)
for i in list:
    name = total_xml[i][:-4] + '\n'
    ftrain.write(name)
    ftrainval.write(name)

'''val/trainval'''
xmlfilepath = 'Annotations/val'
total_xml = os.listdir(xmlfilepath)
num = len(total_xml)
list = range(num)
for i in list:
    name = total_xml[i][:-4] + '\n'
    fval.write(name)
    ftrainval.write(name)

'''close file'''
ftrainval.close()
ftrain.close()
fval.close()
" > Scripts/generate_ImageSets.py
python Scripts/generate_ImageSets.py

echo "
import xml.etree.ElementTree as ET
import pickle
import os
from os import listdir, getcwd
from os.path import join
train_sets = [('PascalVOC2022', 'train')]
val_sets = [('PascalVOC2022', 'val')]
classes = [$CLASSES]  # 改成自己的类别

if not os.path.exists('labels/train'):
    os.makedirs('labels/train')
if not os.path.exists('labels/val'):
    os.makedirs('labels/val')
if not os.path.exists('cfg/'):
    os.makedirs('cfg/')

def convert(size, box):
    dw = 1. / (size[0])
    dh = 1. / (size[1])
    x = (box[0] + box[1]) / 2.0 - 1
    y = (box[2] + box[3]) / 2.0 - 1
    w = box[1] - box[0]
    h = box[3] - box[2]
    x = x * dw
    w = w * dw
    y = y * dh
    h = h * dh
    return (x, y, w, h)

def convert_annotation(year, image_set,image_id):
    # 打开Annotations/train/1.xml(或者val)
    in_file = open('Annotations/%s/%s.xml' % (image_set,image_id))
    # 创建并打开labels/train/1.txt(或者val)
    out_file = open('labels/%s/%s.txt' % (image_set,image_id), 'w')
    tree = ET.parse(in_file)
    root = tree.getroot()
    size = root.find('size')
    w = int(size.find('width').text)
    h = int(size.find('height').text)

    for obj in root.iter('object'):
        difficult = obj.find('difficult').text
        cls = obj.find('name').text
        if cls not in classes or int(difficult) == 1:
            continue
        cls_id = classes.index(cls)
        xmlbox = obj.find('bndbox')
        b = (float(xmlbox.find('xmin').text), float(xmlbox.find('xmax').text), float(xmlbox.find('ymin').text),
             float(xmlbox.find('ymax').text))
        bb = convert((w, h), b)
        out_file.write(str(cls_id) + ' ' + ' '.join([str(a) for a in bb]) + '\n')

wd = getcwd()

# 创建labels/trian以及PascalVOC2022_train.txt
# year = PascalVOC2022;image_set=train
for year, image_set in train_sets:
    #打开并读取train.txt
    image_ids = open('ImageSets/Main/%s.txt' % (image_set)).read().strip().split()
    #创建PascalVOC2022_trian.txt
    list_file = open('cfg/%s_%s.txt' % (year, image_set), 'w')
    for image_id in image_ids:
        list_file.write('PascalVOC2022/JPEGImages/%s/%s.jpg\n' % (image_set,image_id))  #写入相对路径
        #list_file.write('%s/PascalVOC2022/JPEGImages/%s/%s.jpg\n' % (wd, image_set, image_id)) #写入绝对路径
        convert_annotation(year, image_set,image_id)
    list_file.close()

# 创建labels/val以及PascalVOC2022_val.txt
# year = PascalVOC2022;image_set=val
for year, image_set in val_sets:
    # 打开并读取val.txt
    image_ids = open('ImageSets/Main/%s.txt' % (image_set)).read().strip().split()
    # 创建PascalVOC2022_val.txt
    list_file = open('cfg/%s_%s.txt' % (year, image_set), 'w')
    for image_id in image_ids:
        list_file.write('PascalVOC2022/JPEGImages/%s/%s.jpg\n' % (image_set, image_id))  # 写入相对路径
        # list_file.write('%s/PascalVOC2022/JPEGImages/%s/%s.jpg\n' % (wd, image_set, image_id)) #写入绝对路径
        convert_annotation(year, image_set, image_id)
    list_file.close()
" > Scripts/xml2txt.py
python Scripts/xml2txt.py

echo "$NAMES
" >cfg/my_names.names

echo "
classes=$NUM_CLASSES
train=PascalVOC2022/cfg/PascalVOC2022_train.txt
val=PascalVOC2022/cfg/PascalVOC2022_val.txt
names=PascalVOC2022/cfg/my_names.names
backup=PascalVOC2022/cfg
" >cfg/my_data.data

echo "
[net]
# Testing
# batch=1
# subdivisions=1
# Training
batch=$BATCH
subdivisions=$SUBDIVISIONS
width=416
height=416
channels=3
momentum=0.9
decay=0.0005
angle=0
saturation = 1.5
exposure = 1.5
hue=.1

learning_rate=0.001
burn_in=1000
max_batches = $MAX_BATCHES #原来为500200
policy=steps
steps=400000,450000
scales=.1,.1

[convolutional]
batch_normalize=1
filters=16
size=3
stride=1
pad=1
activation=leaky

[maxpool]
size=2
stride=2

[convolutional]
batch_normalize=1
filters=32
size=3
stride=1
pad=1
activation=leaky

[maxpool]
size=2
stride=2

[convolutional]
batch_normalize=1
filters=64
size=3
stride=1
pad=1
activation=leaky

[maxpool]
size=2
stride=2

[convolutional]
batch_normalize=1
filters=128
size=3
stride=1
pad=1
activation=leaky

[maxpool]
size=2
stride=2

[convolutional]
batch_normalize=1
filters=256
size=3
stride=1
pad=1
activation=leaky

[maxpool]
size=2
stride=2

[convolutional]
batch_normalize=1
filters=512
size=3
stride=1
pad=1
activation=leaky

[maxpool]
size=2
stride=1

[convolutional]
batch_normalize=1
filters=1024
size=3
stride=1
pad=1
activation=leaky

###########

[convolutional]
batch_normalize=1
filters=256
size=1
stride=1
pad=1
activation=leaky

[convolutional]
batch_normalize=1
filters=512
size=3
stride=1
pad=1
activation=leaky

[convolutional]
size=1
stride=1
pad=1
filters=$(expr 3 \* $(expr $NUM_CLASSES \+ 5))
activation=linear

[yolo]
mask = 3,4,5
anchors = 10,14,  23,27,  37,58,  81,82,  135,169,  344,319
classes=$NUM_CLASSES
num=6
jitter=.3
ignore_thresh = .7
truth_thresh = 1
random=$RANDOM

[route]
layers = -4

[convolutional]
batch_normalize=1
filters=128
size=1
stride=1
pad=1
activation=leaky

[upsample]
stride=2

[route]
layers = -1, 8

[convolutional]
batch_normalize=1
filters=256
size=3
stride=1
pad=1
activation=leaky

[convolutional]
size=1
stride=1
pad=1
filters=$(expr 3 \* $(expr $NUM_CLASSES \+ 5))
activation=linear

[yolo]
mask = 0,1,2
anchors = 10,14,  23,27,  37,58,  81,82,  135,169,  344,319
classes=$NUM_CLASSES
num=6
jitter=.3
ignore_thresh = .7
truth_thresh = 1
random=$RANDOM
" >cfg/my_yolov3-tiny.cfg

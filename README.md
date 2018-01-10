
This repo is used to blur the background of an image using its depth map. The input is an color image and its corresponding depth map. I choose to use some intermediate variables of light field processing to perform background bokeh.
**Color image** is the central view of a light field (shot by ILLUM). The **raw depth** is obtained by a depth estimation method based on light field cameras.
**NOTE**: This script is originally written by [ShreyasSkandan](https://github.com/ShreyasSkandan/stereo-background-blur) and then REVISED by **[Vincent Qin](https://github.com/Vincentqyw)**. Make sure your matlab version >=**R2014b**.


## How to use?

Just run `demo.m`.

## Result

![](http://oofx6tpf6.bkt.clouddn.com/18-1-10/89438975.jpg)
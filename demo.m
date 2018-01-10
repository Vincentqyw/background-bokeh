% Color image is the central view of a light field (shot by ILLUM).
% The rawdepth is obtained by a depth estimation method based on light field cameras.

% more info: Vincent Qin (https://github.com/Vincentqyw) 
addpath(genpath(pwd));

depth       =imread('img/rawdepth.png');
color_image =imread('img/color_image.png');
[out,mask]=imageBokeh(color_image,depth);
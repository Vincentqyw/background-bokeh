function [out,mask]=imageBokeh(color_image,depth)

% input 
% @color_image  : color image
% @depth        : depth map

% output
% @out          : Bokeh image
% @mask         : binary mask of foreground  

% NOTE: This script is written by ShreyasSkandan AND then 
% REVISED by Vincent Qin (https://github.com/Vincentqyw)
% More information: https://github.com/ShreyasSkandan/stereo-background-blur

clc;
close all;
RECT_LEFT_CLR=color_image;
DEPTH=single(depth);

slope_threshold = 10;
depth_threshold = 8;
% For K-Means depth segmentation algorithm
nDepths = 2; % nDepths classes

% Created the background image - blurred image
H = fspecial('disk',10);
blurredImage = imfilter(RECT_LEFT_CLR,H,'replicate');

% Unroll both colour and blurred images into vectors
colour_image_vec = reshape(RECT_LEFT_CLR,[size(DEPTH,1)*size(DEPTH,2),3]);
blurred_image_vec = reshape(blurredImage,[size(DEPTH,1)*size(DEPTH,2),3]);

% Use K-Means to segment out the depth image into
ab = reshape(DEPTH,[size(DEPTH,1)*size(DEPTH,2),1]);
[cluster_idx, cluster_center] = kmeans(ab,nDepths,'distance','sqEuclidean','Replicates',3);
pixel_labels = reshape(cluster_idx,[size(DEPTH,1),size(DEPTH,2)]);
% save('kmeansresult.mat',pixel_labels);
% figure,
% imshow(pixel_labels,[]);
% segdata = load('kmeansresult.mat');
% pixel_labels = segdata.pixel_labels;

% Create a mask of all pixels at the prescribed depth (usually the max
% disparity -> minimum depth)
mask = zeros(size(DEPTH,1)*size(DEPTH,2),1);
indices = find(pixel_labels == max(max(pixel_labels)));
mask(indices) = 1;
mask = reshape(mask,[size(DEPTH,1),size(DEPTH,2)]);

% Perform a few morphological operations to create a more uniform mask
mask = imfill(mask,'holes');
mask = bwmorph(mask,'clean');
mask = bwmorph(mask,'open',11);
mask = bwmorph(mask,'close',10);
% mask = bwmorph(mask,'thicken',3);

% Extract the largest connected component
mask = bwareafilt(mask, 1, 'largest');
mask = imfill(mask,'holes');
mask = bwmorph(mask,'spur',12);
mask = bwmorph(mask,'thin',2);

use_new_mask=0;
if use_new_mask
% Create a distance transform matrix from the mask outward
D = bwdist(mask);
D(D>depth_threshold) = slope_threshold;
% Standardize the distance transform to create a gradient
maxD = max(max(D));
minD = min(min(D));
mean = mean2(D);
normDistTransVec = (D - minD)/(maxD-minD);
%newmask = ones(size(DEPTH,1),size(DEPTH,2));
%newmask(row_start-padding:row_end+padding,col_start-padding:col_end+padding) = normDistTransVec;
%normDistTransVec = newmask;
newmask =normDistTransVec;
figure,
imagesc(newmask);

Evec = reshape(normDistTransVec,[size(normDistTransVec,1)*size(normDistTransVec,2),1]);
gradient = [Evec,Evec,Evec];

% Apply the gradient onto the image
resultingImageVec = double(gradient).*double(blurred_image_vec) + double(1-gradient).*double(colour_image_vec);
resImage = reshape(resultingImageVec,[size(DEPTH,1),size(DEPTH,2),3]);
end
% out = uint8(resImage);

% mask_3_channels= uint8(repmat(mask,[1 1 3]));
mask_3_channels= uint8([mask(:),mask(:),mask(:)]);
res= (colour_image_vec).*mask_3_channels+(1-mask_3_channels).*blurred_image_vec;
% figure;imshow(uint8(repmat(mask,[1 1 3])).*color_image);
out = reshape(res,[size(DEPTH,1),size(DEPTH,2),3]);

% figure;imshow(mask);title('mask');
% figure;imshow(out);title('bokeh image');
outBuffer=([repmat(DEPTH,[1 1 3]),repmat(255*mask,[1 1 3]);color_image,out]);
figure;imshow(outBuffer);title('Fisrt row:depth map, mask map; Second row: input color image, bokeh image');

% figure;imshow([color_image,out]);title('input color image & bokeh image');

set(gcf,'color',[1 1 1]);
set(gcf,'position',[165 227 1318 764]);
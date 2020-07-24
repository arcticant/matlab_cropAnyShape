%%
close all; clear all; clc;

load multichannel.mat;
H = H_crop;
clear H_crop worldFile;

%% Crop to fixed rectangle geometry
xmin = 0;
xmax = 3000;
ymin = 0;
ymax = 3000;

geometry = [ymin xmax; ymin ymax]; % Bounding box

[img_crop_big,img_crop_small,mask_crop_big,...
    mask_crop_small,H_crop,...
    bb_crop_I,bb_crop_E,worldFile,worldFile_crop] = cropAnyShape(RGB_crop,H,geometry);

%% Crop to polygon shape (interactive)

geometry = 'p';

[img_crop_big,img_crop_small,mask_crop_big,...
    mask_crop_small,H_crop,...
    bb_crop_I,bb_crop_E,worldFile,worldFile_crop] = cropAnyShape(NDSM_crop,H,geometry);

%% Crop to rectangle shape (interactive)

geometry = 'r';

[img_crop_big,img_crop_small,mask_crop_big,...
    mask_crop_small,H_crop,...
    bb_crop_I,bb_crop_E,worldFile,worldFile_crop] = cropAnyShape(NDSM_crop,H,geometry);

%% Crop to circle shape (interactive)

geometry = 'c';

[img_crop_big,img_crop_small,mask_crop_big,...
    mask_crop_small,H_crop,...
    bb_crop_I,bb_crop_E,worldFile,worldFile_crop] = cropAnyShape(NDSM_crop,H,geometry);

%% Crop to ellipse shape (interactive)

geometry = 'e';

[img_crop_big,img_crop_small,mask_crop_big,...
    mask_crop_small,H_crop,...
    bb_crop_I,bb_crop_E,worldFile,worldFile_crop] = cropAnyShape(NDSM_crop,H,geometry);

%% Crop to freehand shape (interactive)

geometry = 'f';

[img_crop_big,img_crop_small,mask_crop_big,...
    mask_crop_small,H_crop,...
    bb_crop_I,bb_crop_E,worldFile,worldFile_crop] = cropAnyShape(NDSM_crop,H,geometry);
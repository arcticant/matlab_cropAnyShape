%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% cropAnyShape.m
%
% Felix Leidinger
% 
% This function crops a georeferenced input image to an arbitrary shape and returns the
% cropped image, the polyshape, mask and the updated spatial reference.
%
% Input args:
% img - anydimensional image array
% H - 3x3 homography for spatial reference of img
% geometry - char, providing options for image cropping:
%            'p' : Polygon (interactive)
%            'r' : Rectangle (interactive)
%            'c' : Circle (interactive)
%            'e' : Ellipse (interactive)
%            'f' : Freehand (interactive)
%          - 2x2 Bounding box array [xmin xmax; ymin ymax]
%
% Output args:
% img_crop_big - Input image, set to zero outside the crop shape
% img_crop_small - Input image, cropped to bounding box of the crop shape
% mask_crop_big - Logical crop mask inside input image
% mask_crop_small - Logical crop mask, cropped to bounding box of the crop shape (Alpha) 
% H_crop - Updated 3x3 homography for spatial reference of the cropped bounding box
% bb_crop_I - 2x2 Bounding box array [xmin xmax; ymin ymax] of intrinsic coordinates (PX)
% bb_crop_E - 2x2 Bounding box array [xmin xmax; ymin ymax] of extrinsic coordinates (World)
% worldFile - imref2d object of input image
% worldFile_crop - imref2d object of cropped image
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [img_crop_big,img_crop_small,mask_crop_big,mask_crop_small,H_crop,bb_crop_I,bb_crop_E,worldFile,worldFile_crop] = cropAnyShape(img,H,geometry)

% Read file
img_tmp = img;
rasterSize = size(img);
if numel(rasterSize) == 2
    nBands = 1;
else
    nBands = rasterSize(3);
end

% Spatial reference
pixelExtentInWorldX = abs(H(1,1));
pixelExtentInWorldY = abs(H(2,2));
worldFile = imref2d(rasterSize,pixelExtentInWorldX,pixelExtentInWorldY);

% Plot image
figure();
imagesc(img_tmp);
daspect([1 1 1]);
if nBands == 1
    colormap jet;
    colorbar;
end
title('Original Image');

% Draw mask
if isnumeric(geometry)
    geometry_statement = 'numeric';
elseif ischar(geometry)
    geometry_statement = geometry;
else
    disp('Unsupported geometry type!');
    disp('Switching to default mode!');
end

switch geometry_statement
    case {'p','P','poly','Poly','polygon','Polygon'}
        disp('Polygon selected: draw a polygon ...');
        poly_crop = drawpolygon('FaceAlpha',0.3);
        disp('Shape was drawn.');
        disp('--> Modify if necessary and double click on ROI to confirm');
        customWait(poly_crop);
        disp('Shape confirmed. Cropping image ...');
        mask_crop_big = createMask(poly_crop);
        [xlim,ylim] = boundingbox(polyshape(poly_crop.Position));                
    case {'r','R','rect','Rect','rectangle','Rectangle'}
        disp('Rectangle selected: draw a rectangle ...');
        poly_crop = drawrectangle('FaceAlpha',0.3,'Rotatable',true);
        disp('Shape was drawn.');
        disp('--> Modify if necessary and double click on ROI to confirm');
        customWait(poly_crop);
        disp('Shape confirmed. Cropping image ...');
        mask_crop_big = createMask(poly_crop);
        [xlim,ylim] = boundingbox(polyshape(poly_crop.Vertices));
    case {'c','C','circ','Circ','circle','Circle'}
        disp('Circle selected: draw a circle ...');
        poly_crop = drawcircle('FaceAlpha',0.3);
        disp('Shape was drawn.');
        disp('--> Modify if necessary and double click on ROI to confirm');
        customWait(poly_crop);
        disp('Shape confirmed. Cropping image ...');
        mask_crop_big = createMask(poly_crop);
        [xlim,ylim] = boundingbox(polyshape(poly_crop.Vertices));
    case {'e','E','ell','Ell','ellipse','Ellipse'}
        disp('Ellipse selected: draw an ellipse ...');
        poly_crop = drawellipse('FaceAlpha',0.3);
        disp('Shape was drawn.');
        disp('--> Modify if necessary and double click on ROI to confirm');
        customWait(poly_crop);
        disp('Shape confirmed. Cropping image ...');
        mask_crop_big = createMask(poly_crop);
        [xlim,ylim] = boundingbox(polyshape(poly_crop.Vertices));
    case {'f','F','free','Free','freehand','Freehand'}
        disp('Freehand selected: draw a freehand shape ...');
        poly_crop = drawfreehand('FaceAlpha',0.3);
        disp('Shape was drawn.');
        disp('--> Modify if necessary and double click on ROI to confirm');
        customWait(poly_crop);
        disp('Shape confirmed. Cropping image ...');
        mask_crop_big = createMask(poly_crop);
        [xlim,ylim] = boundingbox(polyshape(poly_crop.Position));
    otherwise
        if isnumeric(geometry)
            szGeom = size(geometry);
            if szGeom(1) == 2 && szGeom(2) == 2
                disp('Bounding box input format detected ...');
                xlim = geometry(1,:);
                ylim = geometry(2,:);
                poly_crop = drawrectangle('FaceAlpha',0.3,'Position',[xlim(1) ylim(1) xlim(2)-xlim(1) ylim(2)-ylim(1)],'Rotatable',true);
                mask_crop_big = createMask(poly_crop);
                xlim = [poly_crop.Vertices(1,1) poly_crop.Vertices(4,1)];
                ylim = [poly_crop.Vertices(1,2) poly_crop.Vertices(2,2)];
            else
                disp('Other input formats than bounding box not yet supported ...');
                disp('Switching to default mode!');
                disp('Default mode: draw a rectangle ...');
                poly_crop = drawrectangle('FaceAlpha',0.2,'Rotatable',true);
                disp('Shape was drawn.');
                disp('--> Modify if necessary and double click on ROI to confirm');
                customWait(poly_crop);
                disp('Shape confirmed. Cropping image ...');
                mask_crop_big = createMask(poly_crop);
                xlim = [poly_crop.Vertices(1,1) poly_crop.Vertices(4,1)];
                ylim = [poly_crop.Vertices(1,2) poly_crop.Vertices(2,2)];
            end
        else
            disp('Default mode: draw a rectangle ...');
            poly_crop = drawrectangle('FaceAlpha',0.2,'Rotatable',true);
            disp('Shape was drawn.');
            disp('--> Modify if necessary and double click on ROI to confirm');
            customWait(poly_crop);
            disp('Shape confirmed. Cropping image ...');
            mask_crop_big = createMask(poly_crop);
            xlim = [poly_crop.Vertices(1,1) poly_crop.Vertices(4,1)];
            ylim = [poly_crop.Vertices(1,2) poly_crop.Vertices(2,2)];
        end
end

% Crop mask
img_crop_big = uint8(nan(rasterSize));
for i = 1:nBands
    currBand = img_tmp(:,:,i);
    currBand(mask_crop_big == 0) = nan;
    img_crop_big(:,:,i) = currBand;
end
imagesc(img_crop_big);
title('Cropped Image');

% Scale Plot
currFig = gcf;
currChd = get(currFig,'Children');
currChd.XLim = xlim;
currChd.YLim = ylim;
daspect([1 1 1]);
if nBands == 1
    colormap jet;
    colorbar;
end

% Wait for closing the plot
disp('Waiting for user to close the figure ...');
waitfor(currChd);

% Update Homography
% Intrinsic coordinates
bb_crop_I = int64([xlim; ylim]);
nRows_I = [bb_crop_I(2,1)+1:bb_crop_I(2,2)]';
nCols_I = [bb_crop_I(1,1)+1:bb_crop_I(1,2)];
rasterSize_crop = size(ones(length(nRows_I),length(nCols_I)));
worldFile_crop = imref2d(rasterSize_crop,pixelExtentInWorldX,pixelExtentInWorldY);
% Extrinsic coordinates
bb_crop_E = double(flipud(bb_crop_I));
%bb_crop_E = Convert2Homogeneous_v2(bb_crop_E,H);
% Convert2Homogeneous_v2:
u = size(H, 2)-1;
v = size(H, 1)-1;
n = size(bb_crop_E, 1)./u;
if rem(n, 1) > 0
    error('Matrix dimensions are wrong!');
end
nmatches = zeros(n*v, size(bb_crop_E, 2));
for i=1:n  
    nmatches_i = H*[bb_crop_E(u*(i-1)+1:u*i, :); ones(1, size(bb_crop_E, 2))];
    nmatches(v*(i-1)+1:v*i, :) = nmatches_i(1:v, :)./repmat(nmatches_i(v+1, :), v, 1);
end
bb_crop_E = nmatches;
bb_crop_E(2,:) = fliplr(bb_crop_E(2,:));
% Upper left corner
oX = bb_crop_E(1,1);
oY = bb_crop_E(2,2);
H_crop = H; H_crop(1,3) = oX; H_crop(2,3) = oY;

img_crop_small = img_crop_big(nRows_I,nCols_I,:);
mask_crop_small = mask_crop_big(nRows_I,nCols_I,:);

disp('Cropping succeeded :-)');

end

%% Subfunction custom wait for event

function customWait(hROI)

% Listen for mouse clicks on the ROI
l = addlistener(hROI,'ROIClicked',@clickCallback);

% Block program execution
uiwait;

% Remove listener
delete(l);

end

%% Subfunction wait for double click event

function clickCallback(~,evt)

if strcmp(evt.SelectionType,'double')
    uiresume;
end

end

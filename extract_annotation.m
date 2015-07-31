% Reconstruct Import Process
tic
%% Import Reconstruct Project into Matlab
ser = 'Volumejosef.ser';
[serdoc, secdoc] = readReconstruct(ser);
% list all contours (annotations) in the project
contour_names = enumerateContours(secdoc);

contours_converted = contourPointsToImageXY(secdoc, contour_names);

[imnames, secindex] = enumerateImages(secdoc);

%% Process Images and Annotations
% 
% This script produces the following files: 
% 1) slice_<<id>>.tif where <<id>> matches the slice index in Trackem2
% 2) anno_<<id>>.tif (SAA)
% 3) annos.csv -- anno_id,anno_name,pixel_width (anno_id
% matches id in tif file)
% 4) slices.csv -- slice_id(0 index), x_min, y_min

poolobj = gcp('nocreate');
if isempty(poolobj)
    parpool;
end

anno_metadata = cell(2409,5);
anno_metadata(1,:) = {'anno_id','anno_name','pixel_width',...
    'section_min','section_max'};
slice_metadata = {'slice_id','dims_x','dims_y','x_min',...
    'x_max','y_min','y_max'};

% First we get all slices, export the tif files, and save the dimensions of
% the slice 
% NOTE: Must be in JPG files directory for this to work 
%image_dims = {};

x_union = {zeros(numel(secindex),1), zeros(numel(secindex),1)};
y_union = {zeros(numel(secindex),1), zeros(numel(secindex),1)};

parfor ii = 1:numel(secindex) 
    
    section = secdoc(ii).section;
    imTransStr = section.Transform(section.transImageIndex);
    im = imTransStr.Image;
    imcontour = imTransStr.Contour;

    imdata = imread(im.src);
    if size(imdata, 3) > 1
        imdata = rgb2gray(imdata);
    end

    imdata = im2double(imdata);
    [imtr, x, y] = applyTransformImage(imdata, imTransStr);
    
    x_union(ii,:) = {x(1), x(2)};
    y_union(ii,:) = {y(1), y(2)};
    
end

% calculate new bounds
x_global(1,1) = min([x_union{:,1}]);
x_global(1,2) = max([x_union{:,2}]);

y_global(1,1) = min([y_union{:,1}]);
y_global(1,2) = max([y_union{:,2}]);

% now re-run the transform

parfor ii = 1:numel(secindex) 
    
    section = secdoc(ii).section;
    imTransStr = section.Transform(section.transImageIndex);
    im = imTransStr.Image;
    imcontour = imTransStr.Contour;

    imdata = imread(im.src);
    if size(imdata, 3) > 1
        imdata = rgb2gray(imdata);
    end

    imdata = im2double(imdata);
    [imtr, x, y] = applyTransformImage(imdata, imTransStr, ...
        x_global, y_global);
    % don't flip (this is for matlab only) 
    %imtr = flipud(imtr);
    
    % store the pixel dimensions of the transformed image for later use 
    dims = size(imtr);
    %image_dims{ii} = dims; % Note: must add 1 when looking at indices in 
    % anno data! 
    
    % initialize a matrix of this size for storing annotations
    %anno_data{ii} = zeros(dims(1), dims(2));
    
    % save image max(x,y) and min(x,y) to array
    % NOTE: if errors, pre-allocate above (same as anno metadata) 
    slice_metadata(ii+1,:) = {section.index,dims(1),dims(2),x(1),x(2),...
        y(1),y(2)};
    
    % write image to disk 
    imagename = strcat('em/slice_',num2str(section.index),'.tif');
    imwrite(imtr, imagename);
end

parfor jj = 1:numel(contour_names)
    jj
    cur_contour = contour_names(jj);
    % ignore "invalid" contours 
%    if strcmp(cur_contour,'cube') || ...
%            strcmp(cur_contour, 'Cyl') || ...
%            strcmp(cur_contour, 'imageboundary') || ...
%            strcmp(cur_contour, 'domain1') 
%        continue
%    end
    
    % targets gives us all the contours by slice 
    targets = contours_converted{jj};
    % add metadata (assuming mag is the same for all targets, which seems
    % reasonable)
    anno_metadata(jj+1,:) = {jj,targets(1).name,targets(1).mag,...
        targets(1).section,targets(numel(targets)).section};
    % store the untransformed annos in here
    % first column contains the anno matrix in 4096 x 4096, second
    % column contains the slice id 
    cur_annos = cell(200, 2);
    % create masks from contours (fast) 
    for ii = 1:numel(targets)
        
        % generate polymask from contourToXY
        % Oblique and Apical are normal
        BW = poly2mask(targets(ii).pixelPts(:,1), targets(ii).pixelPts(:,2), ...
            4096, 4096);
        % The spine uses a weird size:
        %%BW = poly2mask(targets(ii).pixelPts(:,1), targets(ii).pixelPts(:,2), ...
        % 5109, 8275);
        
        % flip annotation
        BW = flipud(BW);
        
        % we have not yet seen 
        if isempty(cur_annos{targets(ii).section + 1})
            cur_annos{targets(ii).section + 1, 1} = BW;
            cur_annos{targets(ii).section + 1, 2} = targets(ii).section;
        else
            cur_annos{targets(ii).section + 1, 1} =  ...
                cur_annos{targets(ii).section + 1, 1} + BW;
        end
    end
    
    % transform and save each slice (slow, but serialized due to memory use)
    for zz = 1:numel(cur_annos(:,1))
        
        if ~isempty(cur_annos{zz, 1})
        
            % get the appropriate image transformation
            
            %% FOR THE SPINE DATASET WE SUBTRACT 28:
            %%if cur_annos{zz,2} - 28 > 0
            %%    section = secdoc(cur_annos{zz, 2} - 28).section;  
            %%else
            %%   section = secdoc(cur_annos{zz, 2} + 1).section;
            %%end

            section = secdoc(cur_annos{zz, 2} + 1).section;
            imTransStr = section.Transform(section.transImageIndex);
            
            % apply the image transformation (note we FLIPPED FIRST)
            [annotr, x, y] = applyTransformImage(cur_annos{zz, 1}, ...
                imTransStr, x_global, y_global);
            
            % convert to double
            annotr = double(annotr);
            
            % change to anno id (which is 1 indexed, fine)
            %annotr = changem(annotr,jj,1);
            annotr(annotr~=0) = jj;
            
            % output one tif for each annotation per slice
            % FORMAT: anno_<<anno_id>>_<<slice #>>.tif
            annoname = strcat('anno_raw/anno_',num2str(jj),'_',num2str(cur_annos{zz, 2}),'.tif');
            % write 16 bit annotations so we can go above id 255
            imwrite(uint16(annotr), annoname);
        end
        
    end
        
end

% write metadata to disk
% first slice metadata
fid = fopen('em/slice_metadata.csv', 'w');
fprintf(fid, '%s, %s, %s, %s, %s, %s, %s\n', slice_metadata{1,:});
cellfun(@(a,b,c,d,e,f,g) fprintf(fid, '%d, %d, %d, %f, %f, %f, %f\n', a, b, c, d, e, f, g), ...
    slice_metadata(2:end,1), slice_metadata(2:end,2), ...
    slice_metadata(2:end,3), slice_metadata(2:end,4), ...
    slice_metadata(2:end,5), slice_metadata(2:end,6), ...
    slice_metadata(2:end,7));
fclose(fid);
% then anno metadata
fid = fopen('anno_raw/anno_metadata.csv', 'w');
fprintf(fid, '%s, %s, %s, %s, %s\n', anno_metadata{1,:});
%  cellfun(@(x,y) fprintf(fid,'%s\t%s\n',x,y),Final(:,1),Final(:,2));       
cellfun(@(a,b,c,d,e) fprintf(fid, '%d, %s, %f, %d, %d\n', a, b, c, d, e),...
    anno_metadata(2:end,1), anno_metadata(2:end,2), anno_metadata(2:end,3),...
    anno_metadata(2:end,4), anno_metadata(2:end,5));
fclose(fid);
toc

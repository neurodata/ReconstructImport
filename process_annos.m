%% Colors:

% Green - 478
% Yellow - 483
% Blue - 531
% Orange - 475
% Red - 493


%% Spine Segment Params
zstart = 30;
zend = 89;

xdim = 5258;
ydim = 8753;

%% Oblique Segment Params
zstart = 0;
zend = 91;

xdim = 5752;
ydim = 6011;

%% Apical Params

zstart = 0;
zend = 194; 

xdim = 8026;
ydim = 7542;

%% Processing the Harris 15 annotation dataset 
% Specifically, we first group the dataset (manually using the csv metadata files), 
% then process individual slices according to our choice of group

% Read anno metadata file 
anno_file = fopen('anno_raw/anno_metadata.csv');
textscan(anno_file, '%s %s %s %s %s %s',1,...
    'Delimiter',',','EmptyValue',-Inf);
anno_info = textscan(anno_file, '%d %s %f %d %d %s',...
    'Delimiter',',','EmptyValue',-Inf);
fclose(anno_file);


% GROUP DATASET OPTIONS
%% Axons and Dendrites 

anno_group = groupAnnos(anno_info,'a','d');
group_name = 'axon_dendrite';

%% Synapses 

anno_group = groupAnnos(anno_info,'s');
group_name = 'synapse'

%% Glia and Subcellular Components

anno_group = groupAnnos(anno_info,'g','c');
group_name = 'glia_subcell'

%% Axons Only

anno_group = groupAnnos(anno_info,'a');
group_name = 'axon';

%% Dendrites Only

anno_group = groupAnnos(anno_info,'d');
group_name = 'dendrite';

%% Glia Only

anno_group = groupAnnos(anno_info,'g');
group_name = 'glia';

%% Endosomal Compartments Only

anno_group = groupAnnos(anno_info,'c');
group_name = 'endosomal';

%% Polyribosomes Only

anno_group = groupAnnos(anno_info,'p');
group_name = 'polyribo';

%% ERSA Compartments Only (Smooth ER & Spine Apparatus) 

anno_group = groupAnnos(anno_info,'r');
group_name = 'ersa';

%% MitoMicro  Only

anno_group = groupAnnos(anno_info,'m');
group_name = 'mitomicro';

%% All groups

anno_group = groupAnnos(anno_info, 'a','d','s','g','c');
group_name = 'all';


%% Process slices and output a single tif file for each (to ingest) 

% process each slice and output a tif file 
tic
parfor sindex = zstart:zend
    
    % create a buffer
    buffer = zeros(xdim,ydim);

    % process the slice 
    % the final parameter is whether or not to false color the data
		% that is, whether or not to give all annotations the same ID 
		buffer = processAnnoSlice( buffer, sindex, anno_group, anno_info, ...
        true);
    

    % write out the tif file 
    outname = sprintf('annos_processed/annoslice_%s_%d.tif', group_name, sindex); 
    imwrite(uint16(buffer), outname);
    
end
toc

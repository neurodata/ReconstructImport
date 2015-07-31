function [ buffer ] = processAnnoSlice( buffer, sindex, anno_ids, ...
    anno_info, colors )
%processAnnoSlice Read in individual annotations, output single tif file
%   Checks for overlap between already processed annotations and a new
%   annotation. If overlap exists, sets the cells in the new annotation to
%   0.


    % store data from anno_metadata.csv file 
    % note: anno_ids are passed in already (as anno_group) since we may
    % have already grouped data 
    annos_min_slice = anno_info{4};
    annos_max_slice = anno_info{5};
    annos_group = anno_info{6};

    for ii = 1:numel(anno_ids)
        %if annos_min_slice(anno_ids(ii)) <= sindex &&...
		%			annos_max_slice(anno_ids(ii)) >= sindex

            try
                 % open the annotation 
                anno_filename = sprintf('anno_raw/anno_%d_%d.tif', anno_ids(ii), sindex);
                anno = double(imread(anno_filename));
                
                % pad anno if req'd
                if size(anno) < size(buffer)
                    anno = padarray(anno, size(buffer)-size(anno), 'post');
                end
                
            catch
                % no big deal, no image, so we continue
                warning('Annotation file not found: %s\n', anno_filename);
                continue 
            end


            % flatten the new image
            %anno_flat = reshape(anno,numel(anno),1);
            % find nonzero indecides in anno 
            X = find(anno); 
            % find nonzero indices in flattened buffer
            %buffer_flat = reshape(buffer,numel(buffer),1);
            Y = find(buffer); 

            % compare X and Y
            C = intersect(X,Y);

            if size(C) > 0
                % set the offending indices to 0 in anno
                for jj = 1:numel(C)
                    % convert the flattened index to indices 
                    [x,y] = ind2sub(size(anno),C(jj));
                    % set that index to 0 in anno
                    anno(x,y) = 0;
                end
            end


            % once we get here, there are no intersections! 
            % so we simply add the new image to the buffer 
            
            % apply false color if required
            % Green - axon - 478
            % Yellow - dendrite - 483
            % Blue - glia - 531
            % Orange - subcell - 475
            % Red - synapse - 493
            
            if colors
                anno_row = find(anno_info{1,1} == anno_ids(ii));
                if ~isempty(anno_row)
                    switch annos_group{anno_row}
                        case 'a'
                            anno( anno > 0 ) = 478;   
                        case 'd'
                            anno( anno > 0 ) = 483;   
                        case 'g'
                            anno( anno > 0 ) = 531;   
                        case 's'
                            anno( anno > 0 ) = 493;   
                        case 'c'
                            anno( anno > 0 ) = 475; % orange
                        case 'p'
                            anno( anno > 0 ) = 43; % purple
                        case 'm'
                            anno( anno > 0 ) = 113; % blue
                        case 'r'
                            anno( anno > 0 ) = 67; % red 
                        otherwise 
                            error('Group not found: %s!', annos_group{anno_ids(ii)})
                    end
                end
            end
            
            if size(anno) ~= size(buffer)
                size(anno)
            end
            %b = size(buffer)
            buffer = buffer + anno; 
            
            

        %end
    end
    
end


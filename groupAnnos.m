function [ anno_group ] = groupAnnos( anno_info, varargin )
%groupAnnos Groups harris annotations by object type 
% Valid object types are:
%   a --> axons
%   d --> dendrites
%   g --> glia
%   s --> synapses
%   c --> subcellular components 

    if numel(varargin) < 1
        error(['usage: groupAnnos(g1 ,[g2 .. gn]) where gi is a ' ...
            'single character that identifies the group\n'...
            'valid chars are: a, d, g, s, c']);
    end
    
    % preallocate an array for ids
    anno_group = zeros(numel(anno_info{1}),1);
    
    for ii = 1:numel(varargin)
       grp = varargin{ii};
       
       if strcmp(grp,'a') || strcmp(grp,'d') || strcmp(grp, 'g') || ...
               strcmp(grp,'s') || strcmp(grp,'c') || strcmp(grp,'p') || ...
               strcmp(grp,'r') || strcmp(grp,'m')
           
           for jj = 1:numel(anno_info{1}) 
               if strcmp(anno_info{6}(jj),grp)
                   % get the last nonzero element
                   last_nonzero = find(anno_group, 1, 'last'); 
                   if size(last_nonzero, 1) == 0
                       last_nonzero = 0;
                   end 
                   % set the next element to be the new anno id
                   anno_group(last_nonzero + 1) = anno_info{1}(jj);
               end
           end
           
       else
           % not a valid group! 
           fprintf('[error]: %s is not a valid group! ignoring', grp);
       end
       
    end
          
    % return only the > 0 values 
    last_nonzero = find(anno_group, 1, 'last');
    anno_group = anno_group(1:last_nonzero);

end


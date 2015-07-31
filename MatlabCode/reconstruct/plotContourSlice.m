function handles2D = plotContourSlice(varargin)
%name, secdoc, fig
% AB function to plot single contour slide

switch numel(varargin)
    case 1
        contour = varargin{1};
        fig = figure;
        doview = true;
    case 2
        if isstruct(varargin{2})
            contour = extractContour(varargin{2}, varargin{1});
            fig = figure;
            doview = true;
        elseif isnumeric(varargin{2})
            contour = varargin{1};
            doview = false;
            fig = varargin{2};
        else
            usageError;
        end
    case 3
        contour = extractContour(varargin{2}, varargin{1});
        doview = false;
        fig = varargin{3};
    otherwise
        usageError;       
end

%
% if nargin < 3
%     fig = figure;    
%     doview = true;        
% else
%     doview = false;
% end
% 
% 
% contour = extractContour(secdoc, name);
%dz = secdoc(1).section.thickness;

figure(fig); hold on;

section = 88;

for i = 1:numel(contour)
    if contour(i).section == section
        x = contour(i).transPoints(:,1)./0.0022159;
        y = contour(i).transPoints(:,2)./0.0022159;    
        if contour(i).closed
            x(end + 1) = x(1);
            y(end + 1) = y(1);      
        end
        % Plot Annotations
        fill(x, y, contour(i).border);
        % Plot Contour
        %plot(x, y, 'Color', contour(num).border);
    end
end
        
%hh = zeros(1, numel(contour));
%for i_c = 1:numel(contour)
%    x = contour(i_c).transPoints(:,1);
%    y = contour(i_c).transPoints(:,2);
%    if contour(i_c).closed
%        x(end + 1) = x(1);
%        y(end + 1) = y(1);
%    end
%    z = repmat(contour(i_c).z, size(x));
%    
%
%    hh(i_c) = plot3(x, y, z, 'Color', contour(i_c).border);
%end

axis equal;
grid on;

%if doview
%    view(45, 45);
%end

if nargout > 0
    handles2D = hh;
end

end

function usageError
error(['Usage: plotContour(name, secdoc [,fig]),'...
                ' or\n       plotContour(contour [,fig])']);
end
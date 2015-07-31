% Load reconstruct project
[serdoc secdoc] = readReconstruct('Volumejosef.ser');

% List all contours 
contour_names = enumerateContours(secdoc);

% Plot a contour:
plotContourSlice(contour_names(505), secdoc)

%% Plot all contours
fig = figure;

%parpool;

for i = 1:numel(contour_names) - 1
    if strcmp(contour_names(i),'cube') || ...
            strcmp(contour_names(i), 'Cyl') || ...
            strcmp(contour_names(i), 'imageboundary') || ...
            strcmp(contour_names(i), 'domain1') ... 
        continue
    end
   plotContourSlice(contour_names(i), secdoc, fig);
end
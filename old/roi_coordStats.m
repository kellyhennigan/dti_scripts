%% get fiber density values and ROI voxel numbers

function [x_params, y_params, z_params] = roi_coordStats(coords)

% this function takes a nvox x 3 array of coordinates (e.g., roi.coords
% form an roi.mat file)
% and returns the min, median, and max coordinate for x, y, and z

%% get values

for i = 1:3
    min_coords(i) = min(coords(:,i));
    med_coords(i) = median(coords(:,i));
    max_coords(i) = max(coords(:,i));
    
end

x_params = [min_coords(1), med_coords(1), max_coords(1)];
y_params = [min_coords(2), med_coords(2), max_coords(2)];
z_params = [min_coords(3), med_coords(3), max_coords(3)];



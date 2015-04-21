function rot_coords = rotateRoiCoords(coords, rot_mat)

% this function takes an M x 3 array of roi coordinates and a 4x4 rotation matrix as
% input and returns the rotated coordinates

% kelly, June 2011

nRows = length(coords);
coords = [coords, zeros(nRows, 1)];
coords(nRows+1,:) = [0 0 0 1];
rot_coords = coords * rot_mat;
rot_coords = rot_coords(1:nRows,1:3);

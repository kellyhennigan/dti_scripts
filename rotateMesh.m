function [h,mov] = rotateMesh(h,rot_degs,i,inMov)
% -------------------------------------------------------------------------
% usage: rotate a camera around a mesh. Mesh must be in the current
% figure/current axis.
% 
% INPUT:
%   h - structural array that contains necessary handles, such as: 
%              h.p - patch object handle 
%              h.l - light object handle
%              h.msh - mesh object handle 
%   rot_degs - 1x2 vector specifying which way to rotate camera (in degrees)
%   i - number of times to perform the rot_degs rotation
%   inMov - frame by frame movie that can be appended to 
%
% 
% OUTPUT:
%   mov - frame by frame movie. If inMov is given, then mov will be
%         appended to inMov
% 
% 
% note: to save out movie file: 
%
% movie2avi(mov,'DA_Nacc_Putamen_pathways.avi','compression','none','fps',15)
% 
% % based on Jason's AFQ functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 

% if rotation degrees not given, then rotate 10 degrees diagonally 
if notDefined('rot_degs')
    rot_degs = [10,10];
end
rx = rot_degs(1); % degrees to rotate along the x-axis
ry = rot_degs(2); % degrees to rotate along the x-axis


% if # of iterations isn't specified, iterate 10 times
if notDefined('i')
    i=10;
end


% rotate a mesh while keeping the camera the same distance (required for
% movies) and the light in a good spot. 


% These next lines of code perform the specific rotations that I desired
% and capture each rotation as a frame in the video. After each rotation we
% move the light so that it follows the camera and we set the camera view
% angle so that matlab maintains the same camera distance.
for ii = 1:i
    
    % Rotate the camera 5 degrees down
    camorbit(rx,ry);
    
    % Set the view angle so that the image stays the same size
    set(gca,'cameraviewangle',8);
    
    % Move the light to follow the camera
    camlight(h.l,'right');
    
    % Capture the current figure window as a frame in the video
    mov(ii)=getframe(gcf);
    
end


% if a movie was given as input, then append this new movie to it
if ~notDefined('inMov')
    mov = cat(2,inMov,mov);
end


function flipBVecs(bvecsfile, axis)
% This function flips the b vectors in the x, y, or z axis as specified by
% the user.  
%          
% kjh 1/31/11

%% 
% load bvecs .txt file
bvecs = load(bvecsfile);

% multiply b vectors in the user specified axis by -1
bvecs(axis, :) = bvecs(axis,:)*(-1);

strIndx = strfind(bvecsfile, '.');
bvecs_newfilename = strcat(bvecsfile(1:strIndx-1),'_FLIP.bvecs');

%generate new file
save bvecs_newfilename bvecs -ascii;

return
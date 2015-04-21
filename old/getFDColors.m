function colors = getFDColors()

% % returns rgb values for the fiber density maps

%%%%%%%%%%%%%%%%%%%

% define colormaps for fiber density images

% yellow
yellow = [
255, 247, 188
254, 227, 145
254, 196, 79
246, 187, 57
238, 178, 35]./255;

% % red
% red = [
% 252, 224, 210
% 252, 146, 114
% 251, 106, 74
% 239, 59, 44
% 203, 24, 29]./255;
% 

% red
red = [
252, 224, 210
252, 146, 114
251, 106, 74
239, 59, 44
255 0 0]./255;

% blue
blue = [
158, 202, 225
107, 174, 214
66, 146, 198
33, 113, 181
8, 69, 148]./255;

colors={yellow, red, blue};

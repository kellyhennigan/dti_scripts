function colors = getFDColors2Cell()

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

% red
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

% % blue
blue = [
158, 202, 225
107, 174, 214
66, 146, 198
33, 113, 181
8, 69, 148]./255;

colors={yellow, red, blue};


%% from colorbrewer, single hue scales: 


% red
red = {[255,245,240
254,224,210
252,187,161
252,146,114
251,106,74
239,59,44
203,24,29
165,15,21
103,0,13.]/255};
% 
% % green
% 247,252,245
% 229,245,224
% 199,233,192
% 161,217,155
% 116,196,118
% 65,171,93
% 35,139,69
% 0,109,44
% 0,68,27
% 
% % blue

blue = {[247,251,255
222,235,247
198,219,239
158,202,225
107,174,214
66,146,198
33,113,181
8,81,156
8,48,107]./255};

colors=[red; blue];
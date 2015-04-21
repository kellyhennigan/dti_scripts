function outFG = addFGParam(fg, paramNum, name, stat)

% adds a parameter to a .pdb fiber group structural array

% arguments in:
% fg - fiber group (in .pdb format) to add parameter to
% paramNum - the parameter number (if its the first addition, then it's 5)
% name - string name of parameter 
% stat - vector with the stat values for each fiber 

% arguments out:
% outFG - fiber group structural array w/parameter added

% kjh Nov 2011

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fg.params{paramNum}.name  = name;
fg.params{paramNum}.uid   = paramNum - 1;    
fg.params{paramNum}.ile   = 1;            % dunno what this is
fg.params{paramNum}.icpp  = 0;            % or this 
fg.params{paramNum}.ivs   = 1;            % or this 
fg.params{paramNum}.agg   = name; 
fg.params{paramNum}.lname = 'NA';         % local name (set this to blank for now)
fg.params{paramNum}.stat  = stat;        % stat value for each pathway

outFG = fg;

end
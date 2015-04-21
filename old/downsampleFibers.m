function ds_fg = downsampleFibers(fg, logicIndx)

% this function takes a fiber group and a N x 1 logical index who's length
% equals the number of fg.fibers and eliminates some fibers according to
% the logical index

fg.fibers = fg.fibers(logicIndx);
fg.pathwayInfo = fg.pathwayInfo(logicIndx);
for q = 1:length(fg.params)
    fg.params{q}.stat = fg.params{q}.stat(logicIndx);
end
ds_fg = fg;

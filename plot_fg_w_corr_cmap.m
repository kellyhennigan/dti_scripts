% render nacc-DA R fibers on a representative subject

clear all
close all


p=getDTIPaths();
cd(p.data);

% get fg Measures

% subjects=getDTISubjects;
subj = 'sa33';

target = 'naccR';
nNodes = 100;
fgMeasure = 'md';



%%

% get correlation values to plot as color
cd(p.data);
cd(['fg_corr_vals/' target '_n' num2str(nNodes)]);
r=dlmread(['r_' fgMeasure]);


% get t1, fg, etc. files
cd(p.data); cd(subj);
t1_fs = niftiRead('t1_fs.nii.gz');
dt = dtiLoadDt6('dti96trilin/dt6.mat');
roi1=roiNiftiToMat('ROIs/DA.nii.gz')
roi2=roiNiftiToMat(['ROIs/' target '.nii.gz']);
fg=fgRead(['fibers/conTrack/' target '_autoclean.pdb']);


% resample fibers to nNodes
[~,~,~,~,~, SuperFiber, fgClipped, ~,~, fgRes] = ...
    dtiComputeDiffusionPropertiesAlongFG(fg, dt, roi1, roi2, nNodes);

% fgClipped = dtiClipFiberGroupToROIs(fg,roi1,roi2);
% [SuperFiber, fgRes] = dtiComputeSuperFiberRepresentation(fgClipped, [], nNodes);

% get rgb values based on correlation coefficient
rgb=repmat({vals2colormap(r)},1,numel(fgRes.fibers));


%% render fibers: option 1

sh=AFQ_RenderFibers(fgRes,'color',rgb,'numfibers',100,'camera','rightsag')

% change axis on y and zlims
ylim(gca,[-35,30])
zlim(gca,[-20,30])

% Then add the slice X = -2 to the 3d rendering.
AFQ_AddImageTo3dPlot(t1_fs,[-1, 0, 0],'gray',0);
   set(gca,'Position',[0,0,1,1]);
     print(gcf,'-dpdf','-r600','test2')

     camlight(sh.l,'left');
     
%% option 2

AFQ_RenderFibers(fgRes,'numfibers',100,'camera','rightsag')
ylim(gca,[-35,30])
zlim(gca,[-20,30])


coords = SuperFiber.fibers{1};
radius = 3;
color = r;
subdivs = 25;
cmap = 'jet';
crange = [prctile(r,10) prctile(r,90)];
newfig = 0;
[lightH] = AFQ_RenderTractProfile(coords, radius, color, subdivs, cmap, crange, newfig);


AFQ_AddImageTo3dPlot(t1_fs,[-1, 0, 0],'gray',0);


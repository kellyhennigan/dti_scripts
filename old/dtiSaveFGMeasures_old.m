% test correlation between behavioral measures and pathway measures


%%  define directories, files, params, etc. for correlation test

clear all
close all

subjects = getSASubjects('dti');
% 

target_roi1 = 'DA';
target_roi2 = 'nacc';

FG_fname = ['scoredFG__',target_roi2,'_DA_top2500_clean.pdb'];
% FG_fname = ['_hab_vdc_clean.pdb'];

numNodes = 20;

RorL = 'R'; % use R, L, or RL for right/left fibers


%%  get fa and md measures for correlation test

fgMLabels = {'FA','MD','RD','AD'};

for i = 1:numel(subjects)
    
    fprintf(['\n\nworking on subject ',subjects{i},'\n\n']);
    
    subject = subjects{i};
    expPaths = getSAPaths(subject);
    cd(expPaths.subj);
    t1=readFileNifti('t1.nii.gz');
    cd dti96trilin;
    dt = dtiLoadDt6('dt6.mat');
    %     [fa,md] = dtiComputeFA(dt.dt6);
    
    % load rois
    cd(expPaths.ROIs)
    load([target_roi1,'.mat']);
    roi1 = roi;
    load([target_roi2,'.mat']);
    roi2 = roi;
    clear roi
    
    % load fiber group
    cd(expPaths.fibers); cd conTrack;
fg = mtrImportFibers(FG_fname);

%     cd ~/ShockAwe/data/hab_vdc_fibers
%     fg = mtrImportFibers([subject,FG_fname]);
    
    % make sure 1st fiber's endpoint is in roi1
    if(fg.fibers{1}(2,end)<fg.fibers{1}(2,1))
        fg.fibers{1}=fliplr(fg.fibers{1});
    end
    % then reorient fibers so habenula is starting endpoint for all of them
    [fg, startCoords,endCoords] = dtiReorientFibers(fg,numNodes); 
  
    
    switch RorL
%         case 'RL' % take absolute value of x-coords
%             
%             for c = 1:length(fg.fibers)
%                 fg.fibers{c}(1,:) = abs(fg.fibers{c}(1,:));
%             end
%             
        case 'R'  %  use only right side fibers
            
            for c = 1:length(fg.fibers)
                rIndx(c) = fg.fibers{c}(1,1) >= 0;
            end
           
            
            if strcmp(subject,'sa14') % use left side fibers for sa14
                if strcmp(target_roi2,'caudate') || strcmp(target_roi2,'putamen')
                    rIndx = ~rIndx;
                end
            end
            fg = getSubFG(fg, rIndx);
            
        case 'L' %  left side fibers
            
            for c = 1:length(fg.fibers)
                rIndx(c) = fg.fibers{c}(1,1) >= 0;
            end
            
            if strcmp(subject,'sa11')  % use right side fibers for sa11
                if strcmp(target_roi2,'caudate') 
                    rIndx = ~rIndx;
                end
            end
            fg = getSubFG(fg, ~rIndx);
            
%         otherwise
%             error('specify whether to use right and/or left fibers');
    end
    
    [fa, md, rd, ad, ~, SuperFiber,~]=...
        dtiComputeDiffusionPropertiesAlongFG_kh(fg,dt,roi1,roi2,numNodes,[]);
    
    naccNode9(i,:) = SuperFiber.fibers{1}(:,9)';
    
%     outFName = [subjects{i},'_hab_vdc_clean_SF.pdb'];
%     mtrExportFibers(SuperFiber,outFName);
    % %     AFQ_RenderFibers(fg_out,'dt',dt,'rois',roi1,roi2)
%     fd =  dtiComputeFiberDensityNoGUI(SuperFiber, dt.xformToAcpc, size(dt.b0),1,1);
    % %           outName = ['hab_vdc_clean_fd.nii.gz'];
    % %          dtiWriteNiftiWrapper(fd, dt.xformToAcpc, outName);
    % % [imgRgb, overlayImg, overlayMaskImg, anatImg] = mrAnatOverlayMontage(img, xform, anatImg, anatXform, cmap, overlayClipRng, acpcSlices, fname, plane, alpha, labelFlag, upsamp, numAcross, clusterThresh, autoCropBorder)
%     figName = [subjects{i},'_hab_vdc_SF'];
%     mrAnatOverlayMontage(fd, dt.xformToAcpc, double(t1.data), t1.qto_xyz,[],[.1 1], [-4:4],figName, 1);
    %
    
    fgMeasures{1}(i,:) = fa;
    fgMeasures{2}(i,:) = md;
    fgMeasures{3}(i,:) = rd;
    fgMeasures{4}(i,:) = ad;
    
    clear fa md rd ad rIndx
    
end % subjects

% clear coordinateSpace da dt expPaths fg i roi subject versionNum
% clear allFa allMd allRd allAd indx

cd ~/ShockAwe/data/fgMeasures

% dlmwrite('fgNaccR_node9_coords',naccNode9);

save([target_roi1,'_',target_roi2,'_',num2str(numNodes),'nodes',RorL,'.mat'],'subjects','target_roi1',...
    'target_roi2','FG_fname','numNodes','fgMeasures','fgMLabels');


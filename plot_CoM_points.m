% plot CoM coords



%%

clear all
close all


% get experiment-specific paths and cd to main data dir
p = getDTIPaths; cd(p.data);

subjects = getDTISubjects;

method = 'conTrack';

targetsL = {'caudateL','naccL','putamenL'};
targetsR = {'caudateR','naccR','putamenR'};

t1=readFileNifti('sa26/t1/t1_sn.nii.gz')

fdStr = '_da_endpts_S3_sn';


% colors
c = getDTIColors; c = c(1:3,:);
cols = [{c(1,:)},{c(2,:)},{c(3,:)}];


pDims = [1 2 3]; % numel(pDims) = 2 to plot in 2d, 3 to plot in 3d

group = 1; % 0 to plot individuals as subplots, 1 for a group plot

t_idx = [2 1 3];


%% load and process relevant files

targets = targetsR;

% get perhaps just a subset of the targets
if ~notDefined('t_idx') && ~isempty('t_idx')
    targets=targets(t_idx);
    c=c(t_idx,:);
    cols=cols(t_idx);
end

nG = numel(targets); % useful variable to have


%% get fiber groups center of mass


CoM = getFDCoMCoords(targets, method, fdStr);


switch group
    
    case 1 % do group plot
        
        %         mean_CoM = squeeze(mean(CoM))';
        mean_CoM = cellfun(@mean, CoM,'UniformOutput',0);
        
        if numel(pDims)==2
            %
            figure; hold on
            cellfun(@(x,y) scatter(x(:,pDims(1)),x(:,pDims(2)),100,y,'filled'), CoM, cols)
            hold off
            
        elseif numel(pDims)==3
            
            % plot a white dot just to set up the 3d plot correctly
            scatter3(CoM{1}(1,1),CoM{1}(1,2),CoM{1}(1,3),1,[1 1 1])
            hold on
            
            cellfun(@(x,y) scatter3(x(:,1),x(:,2),x(:,3),100,y,'filled'), CoM, cols)
            xlabel('x'); ylabel('y'); zlabel('z');
            
            % make it rotatable
            cameratoolbar('Show');  cameratoolbar('SetMode','orbit');
            
            hold off
            
        end
        
        
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    case 0 % plot CoM for each subject on a separate fig
        
        CoM = cell2mat(reshape(CoM,1,1,[]));
        
        if numel(pDims)==2
            
            for s=1:numel(subjects)
                
                figure; hold on  % this plots each subject in a separate figure
                
                sub_CoM = permute(CoM(s,:,:),[3 2 1]);
                %                 sub_CoM=sub_CoM-repmat(sub_CoM(1,:),3,1); % make everything relative to the Nacc
                
                % 2d plot
                scatter(sub_CoM(:,pDims(1)),sub_CoM(:,pDims(2)),100,c,'filled');
                %                 plot(sub_CoM(:,1),sub_CoM(:,3),'-','color',[.8 .8 .8])
                
                
            end
            
            hold off
            
        elseif numel(pDims)==3
            
            % plot a white dot just to set up the 3d plot correctly
            scatter3(CoM(1,1,1),CoM(1,2,1),CoM(1,3,1),1,[1 1 1])
            hold on
            
            s=1;
            for s=1:numel(subjects)
                
                sub_CoM = permute(CoM(s,:,:),[3 2 1]);
                %                 sub_CoM=sub_CoM-repmat(sub_CoM(1,:),3,1); % make everything relative to the Nacc
                
                %3d plot:
                scatter3(sub_CoM(:,1),sub_CoM(:,2),sub_CoM(:,3),100,c,'filled');
                %                 plot3(sub_CoM(:,1),sub_CoM(:,2),sub_CoM(:,3),'-','color',[.8 .8 .8])
                
            end
            
            % make it rotatable
            cameratoolbar('Show');
            cameratoolbar('SetMode','orbit');
            
            hold off
            
        end
        
end % switch group


%% 

sl = t1.data(:,:,31);

figure

contour(rot90(sl,3))
color

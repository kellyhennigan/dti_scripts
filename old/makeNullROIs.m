% make new striatal ROIs to create a nul distribution of fiber densities.
% create new ROIs with the same shape/size as str ROIs except posterior to DA
% instead of true y-coordinates

% standard for subjects:
%
% find the distance between median y coord in DA ROI and the median y coord in the straital ROIs (defined as delta)
% rotate the striatal ROIs CCW 90 degrees
% move the stratial ROI back and up by the same amount, keeping the ROIs the same distance away from the DA ROI (delta)
% check this out; correct for subs accordingly and note the differences

% for all subjects except er and rfd (see below), I rotated the striatal ROIs
% 90deg CCW and projected them back and up so that they were twice the distance 
% as the striatal ROIs using 10 degrees as the back_up_ratio angle, thus avoiding
% the ventricles, posterior aspect of the corpus collosum, and higher than the cerebellum
%
% exceptions:
% er: back_up_ratio angle=20 (to avoid the cerebellum)
% rb: back_up_ratio angle =20; 2.5 times delta 
% rfd: 2.5 times delta (to avoid the posterior commissure & ventricles)
% sr: back_up_ratio angle =20; 2.5 times delta 


% -------

% for all S&A subjects, I used: 
    
%    90 deg CCW rotation,
%     2 x delta 
%     back_up_ratio = 10
%     
%     except:
%         
%         sa23, sa29, sa30,sa32, & sa33 - used 2.4 times delta
%    

%%

% subjects = {'ak090724','am090121','db061209','er100302',...
%     'hh100622','ka040923','ns090526' ,'rb080930','rfd100302','sr090327'};
subjects = getSASubjects('dti');
subjects = {'sa22'};
strROIs = {'nacc.mat', 'caudate.mat','putamen.mat'};

% define degrees to rotate CW 
degrees_rot = 270; % (=90 deg CCW)

% define the back/up ratio (if 45, then they'll be the same) & multiplier
% for distance delta (2 for most subs)
back_up_ratio = 10;
timesDelta = 2;

%% get values

% define the rotation matrix
theta = deg2rad(degrees_rot);
rot_mat = [ 1 0 0 0; 0 cos(theta) -sin(theta) 0; 0 sin(theta) cos(theta) 0; 0 0 0 1];

theta2 = deg2rad(back_up_ratio);

for i = 1:length(subjects)
% i = 1;
    
    % get DA coordinate info
%     subjDir = fullfile(baseDir, subjects{i});
%     roiDir = fullfile(subjDir, 'ROIs');
%     cd(roiDir);
expPaths = getSAPaths(subjects{i});
cd(expPaths.ROIs);

load('DA.mat');
    da = roi;
    [~, da_y_vals, da_z_vals] = roi_coordStats(da.coords)
    clear roi
    
    % get striatal coordinates info
    for j = 1:length(strROIs)
        load(strROIs{j});
        [~, str_y_vals(j,:), str_z_vals(j,:)] = roi_coordStats(roi.coords); % get str ROI coords
    end
    clear roi
    
    % calculate delta = length of the hypotenuse of right triangle from median DA y/z coord & mean of median striatal y/z coords
    str_y_med = round(mean(str_y_vals(:,2)));
    str_z_med = round(mean(str_z_vals(:,2)));
    delta = sqrt( (str_y_med - da_y_vals(2))^2 + (str_z_med - da_z_vals(2))^2 ); % distance between median DA and striatal y and z coords
    delta2 = delta*timesDelta;   % just delta isn't far back enough; double it
    y_delta = delta2 .* cos(theta2);
    z_delta = delta2 .* sin(theta2);
    
    for j = 1:length(strROIs)
        load(strROIs{j});
        null_roi = roi;
        null_roi.coords = rotateRoiCoords(null_roi.coords, rot_mat);         % rotate striatal ROI coords
        null_roi.coords(:,2) = null_roi.coords(:,2) - y_delta;            % translate the coords back 
        null_roi.coords(:,3) = null_roi.coords(:,3) + z_delta;            % ... & up 
        null_roi.coords = round(null_roi.coords);
        [null_x_vals, null_y_vals, null_z_vals] = roi_coordStats(null_roi.coords); % get str ROI coords
        if null_y_vals(1) < -85
            fprintf('\n min y coord for null roi %s for subj %s is %d\n',...
                strROIs{j},  subjects{i}, null_y_vals(1));
        end
        if (null_y_vals(3) >= da_y_vals(1)) && (null_z_vals(1) >= da_z_vals(3))
            fprintf('\n null roi %s for subj %s is overlapping with DA roi\n',...
                strROIs{j},  subjects{i});
        end
        null_roi.name = ['null_',roi.name];
        fprintf(['\n\nwriting our null roi ',num2str(j), ' for subject ',subjects{i},'\n\n']);
        dtiWriteRoi(null_roi,null_roi.name);
        clear roi null_roi nvox null_x_vals null_y_vals null_z_vals
    end
    
end 


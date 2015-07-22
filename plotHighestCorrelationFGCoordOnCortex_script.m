clear all
close all

p = getDTIPaths; cd(p.data);

subjects = getDTISubjects;



%%

cd fgMeasures/conTrack/
load('naccR.mat')
SF{1}=SuperFibers;

cd ../mrtrix/
load('naccR.mat')
SF{2}=SuperFibers;
cd(p.data)
cd(subjects{1})
t1=niftiRead('t1_fs.nii.gz')
nii = t1;
nii.data=zeros(size(nii.data));
cd(p.data)
cmap = [1 0 0; 0.1602    0.6067    0.6611];

for i=1:numel(subjects)
    cd(p.data)
    cd(subjects{i})
    t1=niftiRead('t1_fs.nii.gz')
    
    roi = nii;
    for j=1:2
        
    imgcoord=round(mrAnatXformCoords(t1.qto_ijk,SF{j}(i).fibers{1}(:,10)));
   
    n10_coords{j}(i,:) = imgcoord;
    
    a=dtiBuildSphereCoords(imgcoord,2);
    idx=sub2ind(size(t1.data),a(:,1),a(:,2),a(:,3));
    roi.data(idx)=j;
    end
    
    plotOverlayImage(roi,t1,cmap,[1 2],2,'best')
    title(subjects{i})
    
    
end

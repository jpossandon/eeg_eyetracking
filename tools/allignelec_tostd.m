%%
clear

load('/Users/jossando/trabajo/CEM/MNI152_1mm_standard_vol','vol','mri')  % 3layers headmodel and mri MNI152 1mm
load /Users/jossando/trabajo/CEM/data/VB/xensor/vb1.mat                  % example electrode positions

% aligne electrodes to mri fiducial
% first ransformation of fiducial information from mri voxel coordinates
% to the same coordinates the headmodels is
mrifid = [mri.transform*[mri.cfg.fiducial.nas 1]',mri.transform*[mri.cfg.fiducial.lpa 1]',mri.transform*[mri.cfg.fiducial.rpa 1]']; %rows x,y,z columns nas,lpa,rpa
mrifid = mrifid(1:3,:);

% organizing channels label and structures so scripts work
elec.label{1}   = 'NAS';
elec.label{2}   = 'LPA';
elec.label{3}   = 'RPA';

cfg                 = [];
cfg.target          = rmfield(elec,'points');
cfg.target.pnt      = mrifid';
cfg.target.label    = {'NAS', 'LPA', 'RPA'};

elec.fid.pnt        = elec.pnt(1:3,:);
elec.fid.points     = elec.pnt(1:3,:);
elec.fid.chanpos    = elec.pnt(1:3,:);
elec.fid.label      = elec.label(1:3,:);
cfg.method          = 'fiducial';
[sensor]            = ft_sensorrealign3(cfg,elec);          % here we allign electrodes fiducial to mri fiducial
sensor.points           = [sensor.homogenous*[sensor.points,ones(length(sensor.points),1)]']'; % here we realign the xensor points to mri coordinates
sensor.points(:,end)    = [];       

%%
oldheadshape        = elec.points;
headshape           = sensor.points;
scalpvert           = vol.bnd(1).pnt;
mrifid              = [mri.transform*[mri.cfg.fiducial.nas 1]',mri.transform*[mri.cfg.fiducial.lpa 1]',mri.transform*[mri.cfg.fiducial.rpa 1]'];
elecfid             = sensor.chanpos(1:3,:);


figure
Fmri = plot3(scalpvert(:,1),scalpvert(:,2),scalpvert(:,3),'r.','MarkerFaceColor','r'); hold on;  % headshape
fmrinas = plot3(mrifid(1,1),mrifid(2,1),mrifid(3,1),'bo','MarkerFaceColor','b','MarkerSize',20); hold on; %nasion mri
fmrilpa = plot3(mrifid(1,2),mrifid(2,2),mrifid(3,2),'bo','MarkerFaceColor','b','MarkerSize',20); hold on; %nasion mri

Fohsp = plot3(oldheadshape(:,1),oldheadshape(:,2),oldheadshape(:,3),'ks','MarkerFaceColor','k'); %head points
Foelp = plot3(elec.pnt(:,1),elec.pnt(:,2),elec.pnt(:,3),'gd','MarkerFaceColor','g'); % head electrodes
Fonas = plot3(elec.pnt(1,1),elec.pnt(1,2),elec.pnt(1,3),'gd','MarkerFaceColor','g','MarkerSize',20); %nasion eeg
Folpa = plot3(elec.pnt(1,1),elec.pnt(2,2),elec.pnt(2,3),'md','MarkerFaceColor','m','MarkerSize',20); %nasion eeg

 
addpath(genpath('/Users/jossando/trabajo/matlab/spm12b/'))
    
h    = spm_figure('GetWin','Graphics');
clf(h); figure(h)
set(h,'DoubleBuffer','on','BackingStore','on');

% fmri points
Fmri = plot3(scalpvert(:,1),scalpvert(:,2),scalpvert(:,3),'ro','MarkerFaceColor','r'); hold on;
Fhsp = plot3(headshape(:,1),headshape(:,2),headshape(:,3),'ks','MarkerFaceColor','k');
Felp = plot3(sensor.chanpos(:,1),sensor.chanpos(:,2),sensor.chanpos(:,3),'kd','MarkerFaceColor','g');
axis off image
drawnow
% this transform headshape in points to the shape of the mri
M    = spm_eeg_inv_icp(scalpvert',headshape',mrifid(1:3,:)',elecfid,Fmri,Fhsp);
% and this moves the electrode positions accordingly
 sourcefid = ft_transform_headshape(M, sensor);
 
 figure
Fmri = plot3(scalpvert(:,1),scalpvert(:,2),scalpvert(:,3),'ro','MarkerFaceColor','r'); hold on;
fmrinas = plot3(mrifid(1,1),mrifid(2,1),mrifid(3,3),'bo','MarkerFaceColor','b','MarkerSize',20); hold on;
Fhsp = plot3(headshape(:,1),headshape(:,2),headshape(:,3),'ks','MarkerFaceColor','k');
Felp = plot3( sourcefid.chanpos(:,1), sourcefid.chanpos(:,2), sourcefid.chanpos(:,3),'kd','MarkerFaceColor','g');
Fonas = plot3(sourcefid.chanpos(1,1), sourcefid.chanpos(1,2), sourcefid.chanpos(1,3),'gd','MarkerFaceColor','g','MarkerSize',20);
rmpath(genpath('/Users/jossando/trabajo/matlab/spm12b/'))
%%
cfg = [];
cfg.method = 'headshape';
cfg.headshape          = scalpvert;
cfg.warp = 'nonlin1';
% this should fit the electrode to the scalp but I have not been able to
% make it work because of some missing function, blah
[sensor2]            = ft_sensorrealign3(cfg,sensor);


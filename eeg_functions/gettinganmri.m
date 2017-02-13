% prepare a standard mri without fidutial points to CTF system
% CTF:
%   Origin: Midway on the line joining LPA and RPA
%   Axis X: From the origin towards the Nasion (exactly through)
%   Axis Y: From the origin towards LPA in the plane defined by (NAS,LPA,RPA), and orthogonal to X axis
%   Axiz Z: From the origin towards the top of the head 
%
% electrode locations from xensor are in mm from the reference tool
% coordinate system (with x,y,z axis being variable to the orientation fo
% the tool?), I am realigning electrodes with chancenter that puts the
% origin in the center of the bestsphere of the pointcloud (ot eh electrode cloud)

% MNI ICBM152 standard mri .5 mm(2009)
% t1
[imaVOL,scaninfo] = loadminc([cfg.expfolder '/data/standard_brain/ICBM 2009b Nonlinear Symmetric05mm/mni_icbm152_t1_tal_nlin_sym_09b_hires.mnc']);
% MNI ICBM152 standard mri 1 mm(2009)
% t1
[imaVOL,scaninfo] = loadminc([cfg.expfolder '/data/standard_brain/ICBM_2009b_Nonlinear_Symmetric1mm/mni_icbm152_t1_tal_nlin_sym_09a.mnc']);
mri.dim = size(imaVOL);
mri.xgrid = 1:mri.dim(1);
mri.ygrid = 1:mri.dim(2);
mri.zgrid = 1:mri.dim(3);
mri.hdr = scaninfo;
mri.anatomy = imaVOL;
mri.transform = [1 0 0 scaninfo.space_start(1);0 1 0 scaninfo.space_start(2);0 0 1 scaninfo.space_start(3);0 0 0 1];

cfgr        = [];
cfgr.method = 'interactive';
mri        = ft_volumerealign(cfgr, mri);
save([cfg.expfolder '/data/standard_brain/ICBM_2009b_Nonlinear_Symmetric1mm/mni_icbm152_t1_symm.mat'],'mri');

% reslice for freesurfer
cfgr            = [];
cfgr.resolution = 1;
cfgr.dim        = [256 256 256];
mrirs          = ft_volumereslice(cfgr, mri);
save([cfg.expfolder '/data/standard_brain/ICBM_2009b_Nonlinear_Symmetric1mm/mni_icbm152_t1_symm_resliced.mat'],'mrirs');

% segment
cfg           = [];
cfg.coordsys  = 'ctf';
cfg.output    = {'skullstrip' 'brain'};
seg           = ft_volumesegment(cfg, mrirs);
save([cfg.expfolder '/data/standard_brain/ICBM_2009b_Nonlinear_Symmetric1mm/mni_icbm152_t1_symm_resliced_segmented.mat'],'seg')

% realing to talairach
cfg        = [];
cfg.method = 'interactive';
mri_tal        = ft_volumerealign(cfg, mrirs);
save([cfg.expfolder '/data/standard_brain/ICBM_2009b_Nonlinear_Symmetric1mm/mni_icbm152_t1_symm_resliced_tal.mat'],'mri_tal');


clear all
load([cfg.expfolder '/data/standard_brain/ICBM_2009b_Nonlinear_Symmetric1mm/mni_icbm152_t1_symm_resliced_tal.mat'],'mri_tal');
load([cfg.expfolder '/data/standard_brain/ICBM_2009b_Nonlinear_Symmetric1mm/mni_icbm152_t1_symm_resliced_segmented.mat'],'seg')

% ensure that the skull-stripped anatomy is expressed in the same coordinate system as the anatomy
seg.transform = mri_tal.transform;

% save both the original anatomy, and the masked anatomy in a freesurfer compatible format
cfg             = [];
cfg.filename    = [cfg.expfolder '/data/standard_brain/ICBM_2009b_Nonlinear_Symmetric1mm/ICBM20091mm'];
cfg.filetype = 'mgz';
cfg.parameter   = 'anatomy';
ft_volumewrite(cfg, mri_tal);

cfg.filename    = [cfg.expfolder '/data/standard_brain/ICBM_2009b_Nonlinear_Symmetric1mm/ICBM20091mmmasked'];
ft_volumewrite(cfg, seg);


% we do all freesurfer staff
% now we realign again stuff
% conformed anatomical image after free-surfer


mri_nom = ft_read_mri([cfg.expfolder '/data/standard_brain/ICBM_2009b_Nonlinear_Symmetric1mm/mri/orig-nomask.mgz']);
% % getting axis corrct again, I do not know what happened in free surfer
% new = mri_nom;
% new.anatomy = permute(mri_nom.anatomy,[3 1 2])
% realign to fiducials
cfgr = [];
cfgr.method = 'interactive';
mri_nom_ctf = ft_volumerealign(cfgr, mri_nom);
mri_nom_ctf.unit = 'cm';  % I do not knwo why I have the units wrong here
save([cfg.expfolder '/data/standard_brain/ICBM_2009b_Nonlinear_Symmetric1mm/mri_nom_ctf','mri_nom_ctf'])
% mri_nom_ctf = ft_convert_units(mri_nom_ctf, 'cm');
T   = mri_nom_ctf.transform*inv(mri_nom_ctf.transformorig);
T(:,4)=[1 1 1 1];
bnd  = ft_read_headshape([cfg.expfolder '/data/standard_brain/ICBM_2009b_Nonlinear_Symmetric1mm/bem/ICBM_2009b_Nonlinear_Symmetric1mm-oct-6-src.fif'], 'format', 'mne_source');
sourcespace = ft_convert_units(bnd, 'cm');
 sourcespace = ft_transform_geometry(T, sourcespace);
    save([cfg.expfolder '/data/standard_brain/ICBM_2009b_Nonlinear_Symmetric1mm/soucespace','sourcespace'])
% save([cfg.expfolder '/data/standard_brain/ICBM_2009b_Nonlinear_Symmetric1mm/T'],'T')

% volume conduction model
mri_nom = ft_read_mri([cfg.expfolder '/data/standard_brain/ICBM_2009b_Nonlinear_Symmetric1mm/mri/orig-nomask.mgz']);
cfgr           = [];
cfgr.coordsys  = 'spm'; 
cfgr.output    = {'brain'};
seg           = ft_volumesegment(cfgr, mri_nom);

cfgr = [];
vol = ft_prepare_singleshell(cfgr,seg);
% vol.bnd = ft_transform_geometry(T, vol.bnd);
save([cfg.expfolder '/data/standard_brain/ICBM_2009b_Nonlinear_Symmetric1mm/vol'],'vol')

figure;hold on;
ft_plot_vol(vol, 'facecolor', 'none');alpha 0.5;
ft_plot_mesh(sourcespace, 'edgecolor', 'none'); camlight 
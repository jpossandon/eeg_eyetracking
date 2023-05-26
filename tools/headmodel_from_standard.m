[mri1] = ft_read_mri('/usr/local/fsl/data/standard/MNI152_T1_1mm.nii.gz')
[mri] = ft_volumerealign([], mri1)
cfgs           = [];
cfgs.output    = {'brain','skull','scalp'};
segmentedmri  = ft_volumesegment(cfgs, mri);
% 
% cfg=[];
% cfg.tissue={'brain','skull','scalp'};
% cfg.numvertices = [3000 2000 1000];
% bnd=ft_prepare_mesh(cfg,segmentedmri);
cfg        = [];
cfg.method ='dipoli';
vol        = ft_prepare_headmodel(cfg, segmentedmri);

figure;
ft_plot_mesh(vol.bnd(1),'facecolor','none'); %scalp
figure;
ft_plot_mesh(vol.bnd(2),'facecolor','none'); %skull
figure;
ft_plot_mesh(vol.bnd(3),'facecolor','none'); %brain
save('/Users/jossando/trabajo/CEM/MNI152_1mm_standard_vol','vol','mri','segmentedmri')

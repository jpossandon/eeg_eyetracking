function [electrodes elec]= read_xensor(filename,center,reproject)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function electrodes = read_xensor(filename)
%
% Reads brainamps xensor file, otuput electrodes is the raw information, 
% output elec is in fieldtrip channel locations format and data is recenterd
% to the best sphere of points data (center=1)(also points that are likely to be
% measurement errors are elimined) or to the best sphere of the electrode
% data(center=2)
%. If reproject =1 electrode positions are
% projected to the scal according to session points data
%
% jpo, OSNA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



fid = fopen(filename);
tline = fgets(fid);
electrodes = struct('numelec',[],'labels',{},'elecpos',[],'numpoints',[],'pointspos',[]);
flag = 0;
while ischar(tline)
    if strfind(tline,'NumberPositions')
        C = textscan(tline,'%s %4.2f');
        electrodes(1).numelec = C{2};
    elseif strfind(tline,'NASION  :')
        for e=1:electrodes.numelec
            [token, remain] = strtok(tline,':');
            C=textscan(token,'%s');
            electrodes.labels = [electrodes.labels;C{1}];
            C=textscan(remain(2:end),'%n');
            electrodes.elecpos = [electrodes.elecpos;C{1}'];
            tline = fgets(fid);
        end
    elseif strfind(tline,'NumberHeadShapePoints')
        C = textscan(tline,'%s %4.2f');
        electrodes.numpoints = C{2};
        flag=1;
    elseif strfind(tline,'HeadShapePoints') & flag==1
        tline = fgets(fid);
        for e=1:electrodes.numpoints
            tline = fgets(fid);
            C = textscan(tline,'%n');
            electrodes.pointspos = [electrodes.pointspos,C{1}];
        end
    end
    tline = fgets(fid);
end
fclose(fid);

if center ==1
    [x y z newcenter] = chancenter(electrodes.pointspos(1,:),electrodes.pointspos(2,:),electrodes.pointspos(3,:),[]); 
    radius = (sqrt(x.^2+y.^2+z.^2));
    keep = setdiff(1:length(x),find(abs(zscore(radius))>2));
    [x y z newcenter] = chancenter(electrodes.pointspos(1,keep),electrodes.pointspos(2,keep),electrodes.pointspos(3,keep),[]); 
    [x1 y1 z1 newcenter] = chancenter(electrodes.elecpos(:,1),electrodes.elecpos(:,2),electrodes.elecpos(:,3),newcenter); 
    elseif center ==2
    [x1 y1 z1 newcenter] = chancenter(electrodes.elecpos(:,1),electrodes.elecpos(:,2),electrodes.elecpos(:,3),[]); 
     [x y z newcenter] = chancenter(electrodes.pointspos(1,:),electrodes.pointspos(2,:),electrodes.pointspos(3,:),newcenter);
    radius = (sqrt(x.^2+y.^2+z.^2));
    keep = setdiff(1:length(x),find(abs(zscore(radius))>3));
     [x y z newcenter] = chancenter(electrodes.pointspos(1,keep),electrodes.pointspos(2,keep),electrodes.pointspos(3,keep),newcenter);
 end
  
elec.unit   = 'mm';
elec.label  = electrodes.labels;
elec.points = [x',y',z'];
elec.pnt    = [x1,y1,z1];

if reproject==1
    cfg.method  = 'template';
    cfg.elec    = elec;
    cfg.headshape = elec.points;
    [newelec] = ft_electroderealign(cfg)
end
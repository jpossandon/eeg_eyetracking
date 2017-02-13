function px = deg2px(cfg, deg)

% px = deg2px(deg,h,v,diag,dist)
if ~isfield(cfg, 'reshrz'),         cfg.reshrz = 2560;      end
if ~isfield(cfg, 'resvrt'),         cfg.resvrt = 1600;      end
if ~isfield(cfg, 'diag'),           cfg.diag = 30;          end
if ~isfield(cfg, 'dist'),           cfg.dist = 600;         end
    

pxdiag=sqrt(cfg.reshrz^2+cfg.resvrt^2);
res=pxdiag/(cfg.diag*25.4);

onedeg = 1/(2*atan(1/(2*cfg.dist))/pi*180);
px = onedeg*deg*res;

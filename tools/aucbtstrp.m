function [infIC est supIC] = aucbtstrp(a,b,varargin)
    alpha = .01;
    signf = abs(norminv(alpha/2,0,1)); 
    for e = 1:1000
        if isempty(varargin)
            a_aux = randsample(a,length(a),true); 
            b_aux = randsample(b,length(a),true);
        else
            a_aux = randsample(a,length(a),true,varargin{1});
             b_aux = randsample(b,length(a),true,varargin{2});
        end

            bstat(e) = area_under_curve(a_aux,b_aux);
    end
    est= prctile(bstat,[50]);
    p = length(find(bstat<est))/1000; % busca todas las muestras de la distribucion bootstrap que esten bajo el estimador
    X = norminv(p,0,1);                 % valor Z asociado a cantidad de muestras bajo el estimador
    infIC = prctile(bstat,normcdf((X*2-signf),0,1)*100);   % correccion de sesgo para los estimadores
    supIC = prctile(bstat,normcdf((X*2+signf),0,1)*100);
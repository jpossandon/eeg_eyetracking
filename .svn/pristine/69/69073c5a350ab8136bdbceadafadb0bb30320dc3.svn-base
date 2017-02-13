function [new_bad,new_badchans] = combine_bad(bad,badchans,min_seg_distance)

for it = 1:size(bad,2)
    
    bads_pre        = bad(:,it);
    bads            = cell2mat(bads_pre); 
    if ~isempty(bads)
        [Y,I]           = sort(bads(:,1));
        all_bad         = [Y,bads(I,2)];

        if ~isempty(badchans)
            badchanss           = cell2mat(badchans(it,:));
            all_chan            = badchanss(:,I);
            new_bad_auxchans    = all_chan(:,1);
        end
        a = 1;
        new_bad_aux             = all_bad(1,:);
        for e = 2:size(all_bad,1)
            if all_bad(e,1)-new_bad_aux(a,2)<min_seg_distance    % when the next start before the previous end (or closer than limit)
                if ~isempty(badchans), new_bad_auxchans(:,a) = sum([new_bad_auxchans(:,a),all_chan(:,e)],2)>0;end
                if all_bad(e,2)-new_bad_aux(a,2)<0    % when the next ends before the previous end
                   continue                       % in this case we just keep the last new bad because it includes the next one, 'a' does not increase because we still use the current new_bad_aux as reference 
                else
                new_bad_aux(a,:) = [new_bad_aux(a,1),all_bad(e,2)];    % here we combine current new_bad_aux start with end of next one, 'a' does not increase because we still use the current new_bad_aux as reference 
                end
            else
                a = a+1;
                new_bad_aux(a,:) = all_bad(e,:);
                if ~isempty(badchans), new_bad_auxchans(:,a) = all_chan(:,e);end
            end
        end
        new_bad{it}         = new_bad_aux;
        if ~isempty(badchans), new_badchans{it}    = new_bad_auxchans; end
    else
        new_bad{it}         = [];
    end
end
if it==1
    new_bad         =  new_bad{it};
    new_badchans    =  new_badchans{it};
end
        
        
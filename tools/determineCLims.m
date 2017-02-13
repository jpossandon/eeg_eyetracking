function clims = determineCLims (eegData)

% clims = median([min(eegData); max(eegData)],2).*2.5;
clims(1) = .75*min(eegData(find(min(eegData,[],2)==min(min(eegData,[],2))),:));
clims(2) = .75*max(eegData(find(max(eegData,[],2)==max(max(eegData,[],2))),:));

end
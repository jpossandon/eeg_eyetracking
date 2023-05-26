function [EEGrem] = uf_rem(ptorem,unfold,EEG)
% coltorem    = {'2_(Intercept)','3_(Intercept)'};
% whichcols   = ismember(unfold.unfold.colnames,ptorem);
whichcols   = ismember(unfold.unfold.cols2variablenames,find(ismember(unfold.unfold.variablenames,ptorem)));
whichXdc    = ismember(unfold.unfold.Xdc_terms2cols, find(whichcols));
varType     = unfold.unfold.variabletypes(unfold.unfold.cols2variablenames(whichcols));

betastorem  = reshape(unfold.beta(:,:,whichcols),[size(unfold.beta,1) size(unfold.beta,2)*sum(whichcols)]); % channelsx(timesx#betas), these are the unfold beta estimates per channel and time
redXdc      = unfold.unfold.Xdc(:,whichXdc); % #EEGsamplesx(timesx#betas)    % these are the predictor values per EEG sample in the time expanded design matric
% splines predictors values are allways positives
remove = (redXdc*betastorem')';
EEGrem = EEG;
EEGrem.data = EEGrem.data-remove;
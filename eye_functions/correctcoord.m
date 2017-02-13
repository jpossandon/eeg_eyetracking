function eyedata=correctcoord(eyedata,xcor,ycor)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function eyedata=correctcoord(eyedata,xcor,ycor)
% Correct x,y coordinate in eyedata structure by xcor and ycor respectively,
% necessary for experiment where the stimuli do not match the screen size
% input:
%       eyedata : strcture of eyemovements data obtained with eyeread.m
%       xcor    : horizontal distance in pixels from screen left border to
%                   the left border of the stimulus
%       ycor    : vertical distance in pixels from screen top border to
%                   the top border of the stimulus
%
% 8/03/10 JP), OSNA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


eyedata.events.posx = eyedata.events.posx-xcor;
eyedata.events.posy = eyedata.events.posy-ycor;

eyedata.events.posinix = eyedata.events.posinix-xcor;
eyedata.events.posiniy = eyedata.events.posiniy-ycor;

eyedata.events.posendx = eyedata.events.posendx-xcor;
eyedata.events.posendy = eyedata.events.posendy-ycor;

eyedata.samples.pos(1,:) =  eyedata.samples.pos(1,:)-xcor;
eyedata.samples.pos(2,:) =  eyedata.samples.pos(2,:)-ycor;
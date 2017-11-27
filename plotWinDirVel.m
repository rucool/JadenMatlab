function [u,v] = plotWinDirVel(ddir,velocity,desc)
% PLOTWINDIRVEL
% plots wind direction versus velocity (read strength) on a compass plot
% by Bruce Raine (3/1/2012)
%
% [U,V] = PLOTWINDIRVEL(DDIR,VELOCITY,DESC)
% The function takes 3 parameters:
% DDIR - row vector of wind directions (angle in degrees/radians), 
% VELOCITY - row vector of wind speeds essentially represented as a radius on the plot 
% DESC - optional compass plot title
%
% RETURNS the converted rectangular coordinates in [U,V]
%
% Class support for inputs DDIR,VELOCITY:
%    float: double, single

if isempty(desc) , desc = {'Wind Direction and Strength'}; end
maxMag = max(velocity);

if any(fix(ddir) ~= ddir) || all(ddir <= 2*pi)
    [u,v] = pol2cart(ddir,velocity); % radian angular measure input
else % convert polar (in degrees) coords to rectangular coords
    [u,v] = polard2cart(ddir,velocity); 
end;
compass(u,v,'-r');
% swap axes around so zero degrees is true north
az = 90; % azimuth i.e. rotate around z-axis hozirontally 90 degrees
el = -90; % elevation negative effectively looking beneath compass plot
view(az, el);
% title 
lenTitle = length(desc{1});
halfway = lenTitle/2/2/8;
% NOTE x and y axes have been swapped by 'view'
y_pos=-1*(halfway);
x_pos=maxMag+1;
text(x_pos,y_pos,desc);
% Create compass labels
xlabel({'W'},'VerticalAlignment','top','Rotation',0,...
    'HorizontalAlignment','center');
% Create ylabel
ylabel({'S'},'VerticalAlignment','cap','HorizontalAlignment','center');

end
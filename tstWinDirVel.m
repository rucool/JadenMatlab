clc; 
% embed the data into vector format:
% wdir = [] ;
% metrespersec = [];
% OR
% LOAD the data from a texfile. Please make sure it is co-resident with
% the script and MATLAB-file.
s = load('winddata.txt','-ascii');
wdir = s(:,1); %angles are in degrees which is ideal for the MATLAB 
               %function 'PLOTWINDIRVEL' to work correctly
               %but it can take the wind direction in radians too.
metrespersec = s(:,2);  %coresponding to magnitude
[a,b] = plotWinDirVel(wdir,metrespersec,...
   {'Wind Direction^\circ and Wind Speed (length of arrow)'} ); %...(zero degrees is true North)'});


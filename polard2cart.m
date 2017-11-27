function [u,v] = polard2cart(theta,mag)
% POLARD2CART(THETA,MAG) converts polar degree coordinates to Cartesian
% coordinates. The vectors THETA, MAG must be the same size. They can
% be row or column vectors but not a mixture.
% by Bruce Raine (3/1/2012)
%
% EX: 
% [a,b] = polard2cart([50 60],[1.6 4])
%       a = 1.0285    2.0000
%       b = 1.2257    3.4641
%
% RETURNS the cartesian coordinates in vector format
%
% Class support for inputs THETA,MAG:
%       float: double, single

u = mag.*cosd(theta);
v = mag.*sind(theta);

end
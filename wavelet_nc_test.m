%%nc_read for wavelet test
clear
clc
close all
%%
tic
filename = '2016_totals_aggregated.nc';
finfo = ncinfo('2016_totals_aggregated.nc');
disp(finfo)
% create a cell array of variables to load
%variables_to_load_all = {'time','lat','lon','u','v'};
variables_to_load_ind = {'time','lat','lon','u','v'};
% loop over the variables
for j=1:numel(variables_to_load_ind)
    var = variables_to_load_ind{j};
    data_struct.(var) = ncread('2016_totals_aggregated.nc',var);
end
toc

%negative lon means west
%positive lat means north
loni = input('What Longitude?: ');
lati = input('What Latitude?: ');
lon_dist=loni-data_struct.lon;
lat_dist=lati-data_struct.lat;
[d,I]=min(abs(lon_dist));
[d2,I2]=min(abs(lat_dist));
U=squeeze(data_struct.u(I,I2,:));
V=squeeze(data_struct.v(I,I2,:));
uorv = input('Plot with respect to "U" or "V": ');
plot(data_struct.time,uorv);

disp('Longitude and Latitude Used')
lon_used = loni-d; disp(lon_used)
lat_used = lati+d2; disp(lat_used)

clear









% figure(2)
% ax = usamap('nj');
% setm(ax, 'FFaceColor')
% geoshow(states)
% geoshow(nj, 'LineWidth', 1.5, 'FaceColor', [.5 .8 .6])
% geoshow(placenames);
% geoshow(route.Latitude, route.Longitude);
% title({'Massachusetts and Surrounding Region', 'Placenames and Route'})
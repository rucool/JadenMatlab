%%nc_read for wavelet test
clear
clc
close all
%%
tic
addpath('C:\Users\Jades\data\wavelet\')
filename = '2016_totals_aggregated.nc';
finfo = ncinfo('2016_totals_aggregated.nc');
disp(finfo)
%negative lon means west
%positive lat means north
data_struct.('time') = ncread(filename,'time');
data_struct.('lat') = ncread(filename,'lat');
data_struct.('lon') = ncread(filename,'lon');
loni = input('What Longitude?: ');
lati = input('What Latitude?: ');
lon_dist=loni-data_struct.lon;
lat_dist=lati-data_struct.lat;
[d,I]=min(abs(lon_dist));
[d2,I2]=min(abs(lat_dist));
disp('Longitude and Latitude Used')
lon_used = data_struct.lon(I); disp(lon_used)
lat_used = data_struct.lat(I2); disp(lat_used)

r = 53;
o = 8784;

u=1;v=2;
uorv = input('Use u or v: ');
if (uorv == u)
disp('Using nu');
data_struct.('u') = ncread(filename,'u',[I I2 1],[1 1 Inf]);
U=squeeze(data_struct.u);
wl = U';
nwl = inpaint_nans(wl,3);
elseif (uorv == v)
disp('Using nv');
data_struct.('v') = ncread(filename,'v',[I I2 1],[1 1 Inf]);
V=squeeze(data_struct.v);
wl = V';
nwl = inpaint_nans(wl,3);
end

figure(1)
hold on

k = find(isnan(wl))';
wl(k) = 0;
% and
wl(isnan(wl)) = 0;

pwl = nwl-wl;
j = find(pwl==0)';
pwl(j) = NaN;
% and
pwl(pwl==0) = NaN;
wl(wl==0) = NaN;

plot(data_struct.time(1:o),pwl,'c.','markersize',20);
plot(data_struct.time(1:o),wl,'k.');
hold off

dt = 1;
[WT,F,COI]= cwt(nwl,'amor',1/dt);
data1=(abs(WT)).^2;

figure(2)
clf
colormap(jet)
subplot(2,1,1)
pcolor(data_struct.time(1:o),log10(F),data1)
shading interp
hold on
plot(data_struct.time(1:o),log10(COI),'w','linewidth',3)
hold off
%set(gca,'ylim',[0.01 .15])
colorbar
datetick('x',31,'keepticks','keeplimits')
title('Log(10) of frequency')
    subplot(2,1,2)
    pcolor(data_struct.time(1:o),F,data1)
    shading interp
    hold on
plot(data_struct.time(1:o),COI,'w','linewidth',3)
    hold off
    set(gca,'ylim',[0.01 .15])
    colorbar
    datetick('x',31,'keepticks','keeplimits')
    title('Zoom, No Log(10)')

% [PXX, FF]=pwelch(nu,hamming(2048),1024,2048,1/dt,'power');
% N=length(nu);
% sig=var(nu);
% alpha=0.9991;
% alpha2=alpha^2;
% % N/2?2%
% k=1:1025;
% Pk=(1-alpha2)./(1+alpha2-(2.*alpha.*cos(2.*pi*k/N)));
% 
% mwave=nanmean(data1,2);
% figure(2)
%  loglog(FF,PXX*N/(2*sig),'k',FF,Pk,'r')
% %loglog(FF,PXX.*FF,'k',F,mwave,'b')
% grid on
% %data_struct.('v') = ncread(filename,'v');

toc

clear
clc

url='http://dods.ndbc.noaa.gov/thredds/dodsC/data/swden/44025/44025w2017.nc';
spwden=squeeze(ncread(url,'spectral_wave_density'));
freq=double(ncread(url,'frequency'));
time=double(ncread(url,'time'));
time=time/(60*60*24);
time=time+datenum(1970,1,1);

url2='http://dods.ndbc.noaa.gov/thredds/dodsC/data/stdmet/44025/44025h2017.nc';

swh=squeeze(ncread(url2,'wave_height'));
dwp=squeeze(ncread(url2,'dominant_wpd'));
awp=squeeze(ncread(url2,'average_wpd'));
time2=double(ncread(url2,'time'));
time2=time2/(60*60*24);
time2=time2+datenum(1970,1,1);


figure(1)
 set(gcf,'renderer','zbuffer')
subplot(3,1,1)
pcolor(time,freq,log10(spwden));
shading interp

set(gca,'ylim',[0 .5])
datetick('x',23,'keepticks','keeplimits')
xl=get(gca,'xlim');
title('spectra')
ylabel('Frequency(Hz)')
 subplot(3,1,2)
 plot(time2,swh,'r');
 grid on
set(gca,'xlim',xl)
datetick('x',23,'keepticks','keeplimits')

title('Significant Wave Height')
ylabel('Wave Height,(m)')
 subplot(3,1,3)
 plot(time2,dwp,'r',time2,awp,'k');
 grid on
set(gca,'xlim',xl)
datetick('x',23,'keepticks','keeplimits')

title('Wave Period')
ylabel('Seconds')
legend('Dom. Wave Per','Average Wave Per')

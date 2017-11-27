clear
url='http://dods.ndbc.noaa.gov/thredds/dodsC/data/swden/44025/44025w2017.nc';
spwden=squeeze(ncread(url,'spectral_wave_density'));
freq=double(ncread(url,'frequency'));
time=double(ncread(url,'time'));
time=time/(60*60*24);
time=time+datenum(1970,1,1);

time2=time-datenum(2017,1,1);


figure(1)
 set(gcf,'renderer','zbuffer')

pcolor(time2,freq,log10(spwden));
shading interp

set(gca,'ylim',[0 .5])
set(gca,'xlim',[datenum(2012,1,1) datenum(2012,2,1)])
set(gca,'xlim',[0 30])

datetick('x',23,'keepticks','keeplimits')
xl=get(gca,'xlim');
title('spectra')
ylabel('Frequency(Hz)')
 

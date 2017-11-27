function [DATA]=ndbc_nc(buoy)


tic

javaaddpath('/javapath/netcdfAll-4.2.jar')
setpref ( 'SNCTOOLS', 'USE_JAVA', true );


DATA=[];

for ii=1:length(buoy.year)
    
    %% if statement to deal with no data for 2012 on station 44014
%     if buoy.year(ii)==2012
%         continue
%     end

    %file=['http://dods.ndbc.noaa.gov//thredds/dodsC/data/stdmet/44009/44009h' num2str(year(ii)) '.nc'];
    file=['http://dods.ndbc.noaa.gov//thredds/dodsC/data/stdmet/' buoy.name '/' buoy.name 'h' num2str(buoy.year(ii)) '.nc'];
    disp(file);
    ncdisp(file)
    
    data(:,1) = ncread(file,'time');
    data = double(data(:,1));
    data(:,1) = epoch2datenum( data(:,1));
    data(:,2) = ncread(file,'wind_dir');
    data(:,3) = ncread(file,'wind_spd');
    data(:,4) = ncread(file,'gust');
    data(:,5) = ncread(file,'wave_height');
    data(:,6) = ncread(file,'dominant_wpd');
    data(:,7) = ncread(file,'average_wpd');
    data(:,8) = ncread(file,'mean_wave_dir');
    data(:,9) = ncread(file,'air_pressure');
    data(:,10) = ncread(file,'air_temperature');
    data(:,11) = ncread(file,'sea_surface_temperature');
    data(:,12) = ncread(file,'dewpt_temperature');
%     data(:,13) = ncread(file,'visibility');
%     data(:,13) = ncread(file,'visibility_in_air');
%     data(:,14) = ncread(file,'water_level');
    
    DATA=[DATA; data];
    
    clear data
    
end

%% Identify the fill values and replace with NaNs
ind_MWID= DATA(:,2)==999; %% column 
DATA(ind_MWID,2)=NaN;

ind_WSPD= DATA(:,3)==99;
DATA(ind_WSPD,3)=NaN;

ind_WGST= DATA(:,4)==99;
DATA(ind_WGST,4)=NaN;

ind_WVHT= DATA(:,5)==99;
DATA(ind_WVHT,5)=NaN;

ind_DPD= DATA(:,6)==99;
DATA(ind_DPD,6)=NaN;

ind_APD= DATA(:,7)==99;
DATA(ind_APD,7)=NaN;

ind_MWAD= DATA(:,8)==999;
DATA(ind_MWAD,8)=NaN;

ind_PRES= DATA(:,9)==9999;
DATA(ind_PRES,9)=NaN;

ind_ATMP= DATA(:,10)==999;
DATA(ind_ATMP,10)=NaN;

ind_WTMP= DATA(:,11)==999;
DATA(ind_WTMP,11)=NaN;

toc


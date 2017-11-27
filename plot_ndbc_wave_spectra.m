clear 
clc

conf.print_path='C:/Users/Jaden Dicopoulos/COOL/waves/figures/AvgPwrSpecDaily/';

year.num=2017;
year.str=num2str(year.num);

a=datenum(2017,06,01);
%dtime.end=datenum(2017,01,2);
z = datenum(2017,06,2);    %END DATE

for k = a:z 
    dtime.start = k
    dtime.end = k+1;

dtime.start_str=datestr(dtime.start,'yyyymmdd');
dtime.end_str=datestr(dtime.end,'yyyymmdd');

url=['http://dods.ndbc.noaa.gov/thredds/dodsC/data/swden/44025/44025w' year.str '.nc'];
spwden=squeeze(ncread(url,'spectral_wave_density'));
freq=double(ncread(url,'frequency'));
time=double(ncread(url,'time'));
time=time/(60*60*24);
time=time+datenum(1970,1,1);


time_vec=datevec(time);

for ii=9
    %% find the index to match the particular year
    ind=find(time_vec(:,2)==ii);
    
    %% find the inex to match the particular data range
    ind=time>=dtime.start & time<=dtime.end;
    ind=find(time>=dtime.start & time<=dtime.end);
    
    %% colormap
    M=jet(length(ind));
    
    spwden_month=mean(spwden(:,ind),2);
    
    hold on
    
    for jj=1:length(ind)
        plot(freq,spwden(:,ind(jj)),'color',M(jj,:))
    end
    
   % plot(freq,spwden_month)
    xlim([0 0.5])
    ylim([0 25])
    box on
    grid on
    
    xlabel('Frequency (Hz)')
    ylabel('Average Spectral Density (m^2/Hz)')
    timestr=datestr(time(ind(1)),'mmmm');
    timestr2=append_zero(ii);
    title(['Spectral Wave Density for NDBC 44025 ' dtime.start_str ' to ' dtime.end_str])

    timestamp(1,'plot_ndbc_wave_spectra.m');
    fig = gcf;
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [0 0 8 8];
    print(1,'-dpng','-r400',[conf.print_path 'Average_Power_Spectra_NDBC_44025' dtime.start_str '_' dtime.end_str '.png'])
   
    close all
  
    clear ind  spwden_month
end
end
%spwden_month=mean(spwden(:,ind),2);


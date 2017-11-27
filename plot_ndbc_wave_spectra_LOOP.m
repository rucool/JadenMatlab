clear all 

year.num=2016;
year.str=num2str(year.num);

dtime.start=datenum(2016,09,01);
dtime.end=datenum(2016,09,08);

dtime.start_str=datestr(dtime.start,'yyyymmdd');
dtime.end_str=datestr(dtime.end,'yyyymmdd');

url=['http://dods.ndbc.noaa.gov/thredds/dodsC/data/swden/44025/44025w' year.str '.nc'];
spwden=squeeze(ncread(url,'spectral_wave_density'));
freq=double(ncread(url,'frequency'));
time=double(ncread(url,'time'));
time=time/(60*60*24);
time=time+datenum(1970,1,1);

conf.PrintPath='/Users/hroarty/COOL/01_CODAR/Waves/20140701_Spectra/20161017_Spectra_Images_Hermine/';


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
    
        %plot(freq,spwden_month)
        xlim([0 0.5])
        ylim([0 25])
        box on
        grid on

        xlabel('Frequency (Hz)')
        ylabel('Average Spectral Density (m^2/Hz)')
        timestr=datestr(time(ind(1)),'mmmm');
        timestr2=append_zero(ii);
        title(['Spectral Wave Density for NDBC 44025 ' datestr(time(ind(jj)),'yyyymmdd HH:MM')])

        timestamp(1,'plot_ndbc_wave_spectra_LOOP.m');
        print(1,'-dpng','-r100',[conf.PrintPath 'Power_Spectra_NDBC_44025_' datestr(time(ind(jj)),'yyyymmddTHHMM') '.png'])


        close all
    %     clear ind  spwden_month
    
    end
end

%spwden_month=mean(spwden(:,ind),2);


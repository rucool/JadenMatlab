close all
clear 
clc

%% m-file to obtain bouy wind speed and direction data

%% Buoy Info Cell Arrays
buoy.name={'44008','44091','44025','44065','44009','44014','44066',};
indB=2;

%% determine the time that you want to analyze
dtime.span=datenum(2017,1,1):1/24:datenum(2017,2,1);
dtime.start=min(dtime.span);
dtime.end=max(dtime.span);
dtime.startSTR=datestr(dtime.start,'yyyymmdd');
dtime.endSTR=datestr(dtime.end,'yyyymmdd');

digits=2;

conf.data_path.NDBC='C:/Users/Jaden Dicopoulos/data/NDBC/';
conf.print_path='C:/Users/Jaden Dicopoulos/COOL/waves/figures/Wspd_Wdir/';

%% Obtain bouy data
buoy01=load([conf.data_path.NDBC buoy.name{indB} '/ndbc_' buoy.name{indB} '_2017.mat']);

%% Find data that matches with time
ind=find(buoy01.DATA(:,1)>=dtime.start & buoy01.DATA(:,1)<=dtime.end);

%% Plot of wind speed over time
hold on
 
NDBC.time=buoy01.DATA(ind,1);
NDBC.WSPD=buoy01.DATA(ind,3);
NDBC.WDIR=buoy01.DATA(ind,2);

[NDBC4.WSPD,idx2] = removeSpikes(NDBC.WSPD,2);
sum(idx2);
subplot(2,1,1);
plot(NDBC.time,NDBC4.WSPD,'g','LineWidth',1);

legend(buoy.name{indB},'AutoUpdate','off')
ylabel('Wind speed (kt)')
format_axis(gca,dtime.start,dtime.end,7,1,'mm/dd',0,22,2)
%% Plot of wind direction over time
[NDBC4.WDIR,idx3] = removeSpikes(NDBC.WDIR,2);
sum(idx3);
subplot(2,1,2);
plot(NDBC.time,NDBC4.WDIR,'k.','LineWidth',2);

buoy01i=interp1(NDBC.time,NDBC4.WSPD,dtime.span);
buoy01i=buoy01i';

legend(buoy.name{indB},'AutoUpdate','off' )
ylabel('Wind Direction (degrees)')
format_axis(gca,dtime.start,dtime.end,7,1,'mm/dd',0,360,90)

timestamp(1,'/Users/Jaden Dicopoulos/Desktop/matlab/NDBC_Windspd_Winddir.m')

%% Wind rose
% wind_rose(NDBC.WDIR,NDBC.WSPD)


%%
fig = gcf;
fig.PaperUnits = 'inches';
fig.PaperPosition = [0 0 12 6];
print('-dpng','-r150',[conf.print_path 'Windspeed_' buoy.name{indB}...
    '_' dtime.startSTR '_'  dtime.endSTR '.png'])


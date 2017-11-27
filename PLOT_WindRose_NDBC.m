close all
clear all
clc

%% m-file to create a wind rose plot for buoys

%% Buoy Info Cell Arrays
buoy.name={'44008','44091','44025','44065','44009','44014','44066',};
indB=4;

%% determine the time that you want to analyze
dtime.span=datenum(2017,5,1):1/24:datenum(2017,6,1);
dtime.start=min(dtime.span);
dtime.end=max(dtime.span);
dtime.startSTR=datestr(dtime.start,'yyyymmdd');
dtime.endSTR=datestr(dtime.end,'yyyymmdd');

digits=2;

conf.data_path.NDBC='C:/Users/Jaden Dicopoulos/data/NDBC/';
conf.print_path='C:/Users/Jaden Dicopoulos/COOL/waves/figures/buoy_wind_rose/';

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

%% Wind rose
[figure_handle,count,speeds,directions,Table] = WindRose(NDBC.WDIR,NDBC.WSPD);
WindTable = table(Table);
writetable(WindTable,'MayWindTable.xls')
%%
fig = gcf;
set(gcf,'color','w');
fig.PaperUnits = 'inches';
fig.PaperPosition = [0 0 12 12];
print('-dpng','-r250',[conf.print_path 'Windrose_' buoy.name{indB}...
    '_' dtime.startSTR '_'  dtime.endSTR '.png'])

%%
close all

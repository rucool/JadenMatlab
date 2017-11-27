%% CSV Creator for buoy data
clear
clc

%%
buoy.name={'44008','44091','44025','44065','44009','44014','44066',};
indB=4;

%% determine the time that you want to analyze
dtime.span=datenum(2017,1,1):1/24:datenum(2017,6,1);
dtime.start=min(dtime.span);
dtime.end=max(dtime.span);
dtime.startSTR=datestr(dtime.start,'yyyymmdd');
dtime.endSTR=datestr(dtime.end,'yyyymmdd');

digits=2;

conf.data_path.NDBC='C:/Users/Jaden Dicopoulos/data/NDBC/';
conf.print_path='C:/Users/Jaden Dicopoulos/COOL/waves/';

%% Obtain bouy data
buoy01=load([conf.data_path.NDBC buoy.name{indB} '/ndbc_' buoy.name{indB} '_2017.mat']);

%% Find data that matches with time
ind=find(buoy01.DATA(:,1)>=dtime.start & buoy01.DATA(:,1)<=dtime.end);


NDBC.time=buoy01.DATA(ind,1);
NDBC.WSPD=buoy01.DATA(ind,3);
NDBC.WDIR=buoy01.DATA(ind,2);

formatIn = 'mm,dd,HH,MM';
NDBC2.time=datestr(NDBC.time,formatIn);
NDBC3.time=str2num(NDBC2.time);
s=[NDBC3.time NDBC.WDIR];
csvwrite('var_wind_direct.csv',s);












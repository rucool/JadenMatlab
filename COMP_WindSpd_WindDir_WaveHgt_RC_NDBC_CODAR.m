close all
clear
clc

tic

%% m-file to obtain bouy wind speed and direction data

%% Buoy Info Cell Arrays
buoy.name={'44008','44091','44025','44065','44009','44014','44066',};
indB=4;

%% determine the time that you want to analyze
dtime.span=datenum(2017,9,18):1/24:datenum(2017,9,25);
dtime.start=min(dtime.span);
dtime.end=max(dtime.span);
dtime.startSTR=datestr(dtime.start,'yyyymmdd');
dtime.endSTR=datestr(dtime.end,'yyyymmdd');

conf.data_path.NDBC='C:/Users/Jaden Dicopoulos/data/NDBC/';
conf.print_path='C:/Users/Jaden Dicopoulos/COOL/waves/remadefigs/';

%% Obtain bouy data
buoy01=load([conf.data_path.NDBC buoy.name{indB} '/ndbc_' buoy.name{indB} '_2017.mat']);

%% Find data that matches with time
ind=find(buoy01.DATA(:,1)>=dtime.start & buoy01.DATA(:,1)<=dtime.end);

%% Plot of wind speed over time

NDBC.time=buoy01.DATA(ind,1);
NDBC.WSPD=buoy01.DATA(ind,3);
NDBC.WDIR=buoy01.DATA(ind,2);

[NDBC4.WSPD,idx2] = removeSpikes(NDBC.WSPD,2);
sum(idx2);
subplot(4,1,1);
plot(NDBC.time,NDBC4.WSPD,'k','LineWidth',1);

title({'\fontsize{22}2017 SPRK';'\fontsize{13}Wind Speed'})
legend(buoy.name{indB},'AutoUpdate','off')
ylabel('kt')
format_axis(gca,dtime.start,dtime.end,2,1,'mm/dd',0,22,2)
%% Plot of wind direction over time
[NDBC4.WDIR,idx3] = removeSpikes(NDBC.WDIR,2);
sum(idx3);
subplot(4,1,2);
plot(NDBC.time,NDBC4.WDIR,'k.','LineWidth',2);

buoy01i=interp1(NDBC.time,NDBC4.WSPD,dtime.span);
buoy01i=buoy01i';

title('\fontsize{13}Wind Direction')
legend(buoy.name{indB},'AutoUpdate','off' )
ylabel('Degrees')
format_axis(gca,dtime.start,dtime.end,2,1,'mm/dd',0,360,90)

timestamp(1,'/Users/Jaden Dicopoulos/Desktop/matlab/NDBC_Windspd_Winddir.m')

%% Wave height

%% comparisons between NDBC buoys

%% Buoy Info Cell Arrays
buoy.name={'44008','44091','44025','44065','44009','44014','44066',};
indB=2;
%% CODAR Info Cell Arrays
%codar.name={'SEAB','BELM','SPRK','BRNT','BRMR','RATH','WOOD'};
codar.name={'SPRK'};

%% find all combinations of buoys
c = combnk(1:length(buoy.name),2);

% datapath='/Users/hroarty/data/waves/SEAB';
% [BRMR]=Codar_WVM7_readin_func(datapath,'wls');
% ind8=find(BRMR.RCLL==2);
% ind9=find(BRMR.RCLL==3);

%% determine the time that you want to analyze

conf.data_path.CODAR_Waves_R8='C:/Users/Jaden Dicopoulos/data/wavesR8/wavesranged/';

for ii=1:length(codar.name)
   
%% buoy01 is the NDBC data
%% buoy02 is the CODAR data

buoy01=load([conf.data_path.NDBC buoy.name{indB} '/ndbc_' buoy.name{indB} '_2017.mat']);

for rr=[2 5 10]
datapath=[conf.data_path.CODAR_Waves_R8 codar.name{ii}];
[CODAR]=Codar_WVM9_readin_func(datapath,'wls');
ind8=find(CODAR.RCLL==rr);

%% Only take the data from the specified range cell
CODAR2.MWHT=CODAR.MWHT(ind8);
CODAR2.MWPD=CODAR.MWPD(ind8);
CODAR2.WAVB=CODAR.WAVB(ind8);
CODAR2.WNDB=CODAR.WNDB(ind8);
CODAR2.ACNT=CODAR.ACNT(ind8);
CODAR2.DIST=CODAR.DIST(ind8);
CODAR2.RCLL=CODAR.RCLL(ind8);
CODAR2.time=CODAR.time(ind8);


%% find the data that matches the time period you are interesred in
ind=find(buoy01.DATA(:,1)>=dtime.start & buoy01.DATA(:,1)<=dtime.end);
ind2=find(CODAR2.time>=dtime.start & CODAR2.time<=dtime.end);

% sum(isnan(buoy01.DATA(ind,:)),1);
% sum(isnan(buoy02.DATA(ind2,:)),1);

%% FIGURE 1 Time series plot of the two comparisons
% plot(CODAR2.time(ind2),CODAR2.MWHT(ind2),'g','LineWidth',2);
% plot(buoy01.DATA(ind,1),buoy01.DATA(ind,5),'ko','LineWidth',2);

%% declare a new variable for codar data
CODAR3.time=CODAR2.time(ind2);
CODAR3.MWHT=CODAR2.MWHT(ind2);
CODAR3.MWPD=CODAR2.MWPD(ind2);

ind3=CODAR3.MWHT>6;
CODAR3.MWHT(ind3)=NaN;

NDBC.time=buoy01.DATA(ind,1);
NDBC.MWHT=buoy01.DATA(ind,5);

%% identify the spikes in the data records
[CODAR4.MWHT,idx] = removeSpikes(CODAR3.MWHT,2);
% plot(CODAR3.time(idx),CODAR3.MWHT(idx),'or')
 sum(idx);
 
[NDBC4.MWHT,idx7] = removeSpikes(NDBC.MWHT,2);
% plot(NDBC.time(idx2),NDBC.MWHT(idx2),'ob')
 sum(idx7);

%% plot the despiked data
subplot(2,1,2);
hold on
plot(CODAR3.time,CODAR4.MWHT,'LineWidth',1);
end
plot(NDBC.time,NDBC4.MWHT,'k','LineWidth',1);
%% interpolate the data onto a common time axis
buoy01i=interp1(NDBC.time,NDBC4.MWHT,dtime.span);
buoy02i=interp1(CODAR3.time,CODAR4.MWHT,dtime.span)';
buoy01i=buoy01i';

title('\fontsize{13}R8 Comparison of Buoy and CODAR Wave Height');
legend('RC 2','RC 5','RC 10',buoy.name{indB},'AutoUpdate','off')
ylabel('Meters')
format_axis(gca,dtime.start,dtime.end,2,1,'mm/dd',0,7,1)

timestamp(1,'/Users/Jaden Dicopoulos/Desktop/matlab/statistics_NDBC_CODAR.m')

end
%%
fig = gcf;
fig.PaperUnits = 'inches';
fig.PaperPosition = [0 0 12 12];
print('-dpng','-r350',[conf.print_path 'Wspd_Wdir_WVht_' buoy.name{indB}...
    '_' dtime.startSTR '_'  dtime.endSTR '.png'])

close all

toc
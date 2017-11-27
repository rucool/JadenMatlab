close all
clear
clc

tic

%% m script Wave height of CODAR site all Range Cells compared to NDBC wave height.

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
dtime.span=datenum(2017,9,18):1/24:datenum(2017,9,20);
dtime.start=min(dtime.span);
dtime.end=max(dtime.span);
dtime.startSTR=datestr(dtime.start,'yyyymmdd');
dtime.endSTR=datestr(dtime.end,'yyyymmdd');

digits=2;

conf.data_path.NDBC='C:/Users/Jaden Dicopoulos/data/NDBC_Updated/';
conf.data_path.CODAR_Waves_R8='C:/Users/Jaden Dicopoulos/data/wavesR8/wavesranged/';
conf.print_path='C:/Users/Jaden Dicopoulos/COOL/waves/';

for ii=1:length(codar.name)
%% Range Cell Array Start

buoy01=load([conf.data_path.NDBC buoy.name{indB} '/ndbc_' buoy.name{indB} '_2017.mat']);

datapath=[conf.data_path.CODAR_Waves_R8 codar.name{ii}];
[CODAR]=Codar_WVM9_readin_func(datapath,'wls');
for rr=[4 10]
ind9=find(CODAR.RCLL==rr);

% Only take the data from the specified range cell
CODAR7.MWHT=CODAR.MWHT(ind9);
CODAR7.MWPD=CODAR.MWPD(ind9);
CODAR7.WAVB=CODAR.WAVB(ind9);
CODAR7.WNDB=CODAR.WNDB(ind9);
CODAR7.ACNT=CODAR.ACNT(ind9);
CODAR7.DIST=CODAR.DIST(ind9);
CODAR7.RCLL=CODAR.RCLL(ind9);
CODAR7.time=CODAR.time(ind9);


%% find the data that matches the time period you are interesred in
ind=find(buoy01.DATA(:,1)>=dtime.start & buoy01.DATA(:,1)<=dtime.end);
ind2=find(CODAR7.time>=dtime.start & CODAR7.time<=dtime.end);

% sum(isnan(buoy01.DATA(ind,:)),1);
% sum(isnan(buoy02.DATA(ind2,:)),1);

%% FIGURE 1 Time series plot of the two comparisons
hold all
% plot(CODAR2.time(ind2),CODAR2.MWHT(ind2),'g','LineWidth',2);
% plot(buoy01.DATA(ind,1),buoy01.DATA(ind,5),'ko','LineWidth',2);

%% declare a new variable for codar data
CODAR8.time=CODAR7.time(ind2);
CODAR8.MWHT=CODAR7.MWHT(ind2);

% ind3=CODAR8.MWHT>6;
% CODAR8.MWHT(ind3)=NaN;

NDBC.time=buoy01.DATA(ind,1);
NDBC.MWHT=buoy01.DATA(ind,5);

%% identify the spikes in the data records
[CODAR9.MWHT,idx] = removeSpikes(CODAR8.MWHT,2);
% plot(CODAR3.time(idx),CODAR3.MWHT(idx),'or')
 sum(idx);
 
[NDBC4.MWHT,idx2] = removeSpikes(NDBC.MWHT,2);
% plot(NDBC.time(idx2),NDBC.MWHT(idx2),'ob')
 sum(idx2);
 
%% plot the despiked data
plot(CODAR8.time,CODAR9.MWHT,'LineWidth',1);
end

plot(NDBC.time,NDBC4.MWHT,'k','LineWidth',2);
%% interpolate the data onto a common time axis

title('Buoy and CODAR Wave Height (m) Using R8 Range Cells');
legend({'RC 4','RC 10',buoy.name{indB}},'AutoUpdate','off')
ylabel('Wave Height (m)')
format_axis(gca,dtime.start,dtime.end,2,1,'mm/dd',0,7,1)

timestamp(1,'/Users/Jaden Dicopoulos/Desktop/matlab/statistics_NDBC_CODAR.m')

fig = gcf;
fig.PaperUnits = 'inches';
fig.PaperPosition = [0 0 12 6];
print('-dpng','-r250',[conf.print_path 'RangeCell_AIO_R8_' buoy.name{indB} '_' codar.name{ii}...
    '_' dtime.startSTR '_'  dtime.endSTR '.png'])


end

close all

toc
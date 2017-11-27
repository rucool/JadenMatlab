close all
clear
clc

tic

%% m script written on July 17th, 2017 To compare wave periods between R7 and R8 reprocessing.

%% CODAR Info Cell Arrays
%codar.name={'SEAB','BELM','SPRK','BRNT','BRMR','RATH','WOOD'};
codar.name={'SPRK'};

%% determine the time that you want to analyze
dtime.span=datenum(2017,3,1):1/24:datenum(2017,4,1);
dtime.start=min(dtime.span);
dtime.end=max(dtime.span);
dtime.startSTR=datestr(dtime.start,'yyyymmdd');
dtime.endSTR=datestr(dtime.end,'yyyymmdd');

digits=2;

conf.data_path.CODAR_Waves_R7='C:/Users/Jaden Dicopoulos/data/wavesR7/original/';
conf.data_path.CODAR_Waves_R8='C:/Users/Jaden Dicopoulos/data/wavesR8/original/';
conf.print_path='C:/Users/Jaden Dicopoulos/COOL/waves/';

for ii=1:length(codar.name)
   
%% buoy02 is the CODAR data

datapath=[conf.data_path.CODAR_Waves_R8 codar.name{ii}];
[CODAR]=Codar_WVM9_readin_func(datapath,'wls');
ind8=find(CODAR.RCLL==2);

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
ind2=find(CODAR2.time>=dtime.start & CODAR2.time<=dtime.end);

% sum(isnan(buoy01.DATA(ind,:)),1);
% sum(isnan(buoy02.DATA(ind2,:)),1);

%% FIGURE 1 Time series plot of the two comparisons
hold on
% plot(CODAR2.time(ind2),CODAR2.MWHT(ind2),'g','LineWidth',2);
% plot(buoy01.DATA(ind,1),buoy01.DATA(ind,5),'ko','LineWidth',2);

%% declare a new variable for codar data
CODAR3.time=CODAR2.time(ind2);
CODAR3.MWPD=CODAR2.MWPD(ind2);


%%

datapath=[conf.data_path.CODAR_Waves_R7 codar.name{ii}];
[CODAR]=Codar_WVM7_readin_func(datapath,'wls');
ind9=find(CODAR.RCLL==3);

%% Only take the data from the specified range cell
CODAR7.MWHT=CODAR.MWHT(ind9);
CODAR7.MWPD=CODAR.MWPD(ind9);
CODAR7.WAVB=CODAR.WAVB(ind9);
CODAR7.WNDB=CODAR.WNDB(ind9);
CODAR7.ACNT=CODAR.ACNT(ind9);
CODAR7.DIST=CODAR.DIST(ind9);
CODAR7.RCLL=CODAR.RCLL(ind9);
CODAR7.time=CODAR.time(ind9);


%% find the data that matches the time period you are interesred in
ind2=find(CODAR7.time>=dtime.start & CODAR7.time<=dtime.end);

% sum(isnan(buoy01.DATA(ind,:)),1);
% sum(isnan(buoy02.DATA(ind2,:)),1);

%% FIGURE 1 Time series plot of the two comparisons
% plot(CODAR2.time(ind2),CODAR2.MWHT(ind2),'g','LineWidth',2);
% plot(buoy01.DATA(ind,1),buoy01.DATA(ind,5),'ko','LineWidth',2);

%% declare a new variable for codar data
CODAR8.time=CODAR7.time(ind2);
CODAR8.MWPD=CODAR7.MWPD(ind2);

%% identify the spikes in the data records
[CODAR9.MWPD,idx4] = removeSpikes(CODAR8.MWPD,2);
% plot(CODAR3.time(idx),CODAR3.MWHT(idx),'or')
 sum(idx4);
 
 
%% plot the despiked data
plot(CODAR3.time,CODAR9.MWPD,'c','LineWidth',2);
plot(CODAR3.time,CODAR3.MWPD,'k','LineWidth',2);

 %% interpolate the data onto a common time axis
buoy02i=interp1(CODAR3.time,CODAR3.MWPD,dtime.span)';


title('Comparison of SPRK, R7 RC3 & R8 Averaged Range Cells');
legend('R7','R8','AutoUpdate','off')
ylabel('Wave Period (s)')
format_axis(gca,dtime.start,dtime.end,3,1,'mm/dd',2,16,1)

timestamp(1,'/Users/Jaden Dicopoulos/Desktop/matlab/COMP_WavePeriod_R7_R8.m')

fig = gcf;
fig.PaperUnits = 'inches';
fig.PaperPosition = [0 0 12 6];
print('-dpng','-r150',[conf.print_path 'COMP_WavePeriod_R7_R8_BUOY_' codar.name{ii}...
    '_' dtime.startSTR '_'  dtime.endSTR '.png'])


clear Good P RHO X Y
close all


end

toc
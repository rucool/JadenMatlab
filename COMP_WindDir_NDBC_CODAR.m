close all
clear
clc

tic

%% m script written on January 17, 2014 to make scatter plots of the wave height
% Recoded by Jaden Dicopoulos on June 6, 2017 to be up to date on current HF Radar
% and Buoy inputs
%% comparisons between NDBC buoys

%% Buoy Info Cell Arrays
buoy.name={'44008','44091','44025','44065','44009','44014','44066',};
indB=4;

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
dtime.span=datenum(2017,1,1):1/24:datenum(2017,2,1);
dtime.start=min(dtime.span);
dtime.end=max(dtime.span);
dtime.startSTR=datestr(dtime.start,'yyyymmdd');
dtime.endSTR=datestr(dtime.end,'yyyymmdd');

digits=2;

conf.data_path.NDBC='C:/Users/Jaden Dicopoulos/data/NDBC/';
%conf.data_path.CODAR_Waves_R8='C:/Users/Jaden Dicopoulos/data/waves/';
conf.print_path='C:/Users/Jaden Dicopoulos/COOL/waves/remadefigs/';
conf.data_path.CODAR_Waves_R8='C:/Users/Jaden Dicopoulos/data/wavesR8/Original/';

for ii=1:length(codar.name)
   
%% buoy01 is the NDBC data
%% buoy02 is the CODAR data

buoy01=load([conf.data_path.NDBC buoy.name{indB} '/ndbc_' buoy.name{indB} '_2017.mat']);


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
ind=find(buoy01.DATA(:,1)>=dtime.start & buoy01.DATA(:,1)<=dtime.end);
ind2=find(CODAR2.time>=dtime.start & CODAR2.time<=dtime.end);

% sum(isnan(buoy01.DATA(ind,:)),1);
% sum(isnan(buoy02.DATA(ind2,:)),1);

%% FIGURE 1 Time series plot of the two comparisons
hold on
% plot(CODAR2.time(ind2),CODAR2.MWHT(ind2),'g','LineWidth',2);
% plot(buoy01.DATA(ind,1),buoy01.DATA(ind,5),'ko','LineWidth',2);

%% declare a new variable for codar data
CODAR3.time=CODAR2.time(ind2);
CODAR3.WNDB=CODAR2.WNDB(ind2);

NDBC.time=buoy01.DATA(ind,1);
NDBC.MDIR=buoy01.DATA(ind,2);

%% identify the spikes in the data records
[CODAR4.WNDB,idx] = removeSpikes(CODAR3.WNDB,2);
% plot(CODAR3.time(idx),CODAR3.MWHT(idx),'or')
 sum(idx);

[NDBC4.MDIR,idx2] = removeSpikes(NDBC.MDIR,2);
% plot(NDBC.time(idx2),NDBC.MWHT(idx2),'ob')
 sum(idx2);

%% plot the despiked data
plot(CODAR3.time,CODAR4.WNDB,'c.','LineWidth',2);
plot(NDBC.time,NDBC4.MDIR,'k.','LineWidth',2);

 %% interpolate the data onto a common time axis
buoy01i=interp1(NDBC.time,NDBC4.MDIR,dtime.span);
buoy02i=interp1(CODAR3.time,CODAR4.WNDB,dtime.span)';
buoy01i=buoy01i';

title('2017 Comparison of Buoy and CODAR Wind Direction for SPRK R8');
legend(codar.name{ii},buoy.name{indB},'AutoUpdate','off')
ylabel('Degrees')
format_axis(gca,dtime.start,dtime.end,2,1,'mm/dd',0,360,90)

timestamp(1,'/Users/Jaden Dicopoulos/Desktop/matlab/COMP_WindDir_NDBC_CODAR.m')

fig = gcf;
fig.PaperUnits = 'inches';
fig.PaperPosition = [0 0 12 6];
print('-dpng','-r150',[conf.print_path 'COMP_WindDir_' buoy.name{indB} '_' codar.name{ii}...
    '_' dtime.startSTR '_'  dtime.endSTR '.png'])

close all

end

toc
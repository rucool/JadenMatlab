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
dtime.span=datenum(2017,1,1):1/24:datenum(2017,7,1);
dtime.start=min(dtime.span);
dtime.end=max(dtime.span);
dtime.startSTR=datestr(dtime.start,'yyyymmdd');
dtime.endSTR=datestr(dtime.end,'yyyymmdd');

digits=2;

conf.data_path.NDBC='C:/Users/Jaden Dicopoulos/data/NDBC/';
conf.data_path.CODAR_Waves_R8='C:/Users/Jaden Dicopoulos/data/wavesR8/original/';
conf.print_path='C:/Users/Jaden Dicopoulos/COOL/waves/';

for ii=1:length(codar.name)
%% Range Cell Array Start

buoy01=load([conf.data_path.NDBC buoy.name{indB} '/ndbc_' buoy.name{indB} '_2017.mat']);

datapath=[conf.data_path.CODAR_Waves_R8 codar.name{ii}];
[CODAR]=Codar_WVM9_readin_func(datapath,'wls');
for rr=2
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
 
%%
%plots ru28 track using plotTrack and plots wave ht vs time
% url='https://marine.rutgers.edu/~tnmiles/ru28-521_DbdGroup_sci-qartod0.mat';
% filename='ru28.mat';
% outfilename=websave(filename,url);
% load ru28.mat
% addCtdSensors(dgroup);

load ru28-521_DbdGroup_sci-qartod0.mat
addCtdSensors(dgroup);

processGps(dgroup,'interp','linear');


%dom_period=(dgroup.toArray('sensors',{'sci_svs603_dom_period'}));
wave_ht=(dgroup.toArray('sensors',{'sci_svs603_hs'}));
%wave_dir=(dgroup.toArray('sensors',{'sci_svs603_wave_dir'}));
%hmax=(dgroup.toArray('sensors',{'sci_svs603_hmax'}));
%hmax2=(dgroup.toArray('sensors',{'sci_svs603_hmax2'}));


%Plotting glider track
%dgroup.plotTrack;
%load coastline_NortheastUS.mat
%plot(coast.xlon,coast.ylat);
%axis([-75.9 -72.7 35.8 42.5])
%title(strcat(['ru28 as of ',datestr(now,'dd-mm-yyyy HH:MM:SS FFF')]))

for i=1:length(wave_ht)
if(wave_ht(i,3)==0)
    wave_ht(i,3)=NaN;
end
end


%% plot the despiked data
%plot(CODAR8.time,CODAR9.MWHT,'LineWidth',1);
end
%plot(NDBC.time,NDBC4.MWHT,'k','LineWidth',2);
%plot(wave_ht(:,1),wave_ht(:,3),'k.','markersize',20)

%% Difference between Codar and Buoy

DiffB=interp1(NDBC.time,NDBC4.MWHT,dtime.span);
DiffC=interp1(CODAR8.time,CODAR9.MWHT,dtime.span)';
DiffB=DiffB';
DiffCB=DiffC-DiffB;

ind3=DiffCB>2;
DiffCB(ind3)=NaN;

plot(DiffB,DiffCB,'o',...
    'MarkerSize',10,...
    'MarkerEdgeColor','k',...
    'MarkerFaceColor',[0,.25,.5]);

%% interpolate the data onto a common time axis

title('Difference between CODAR site SPRK Buoy 44091 Wave Height');
%legend({'Range Cell 4','Range Cell 8','Range Cell 10','Buoy 44091','Glider RU28'},'AutoUpdate','off')
ylabel('CODAR minus Buoy Wave Height')
xlabel('Wave Height from Buoy (m)')
%format_axis(gca,dtime.start,dtime.end,1,1,'mm/dd',0,6,1)

%timestamp(1,'/Users/Jaden Dicopoulos/Desktop/matlab/statistics_NDBC_CODAR.m')

fig = gcf;
fig.PaperUnits = 'inches';
fig.PaperPosition = [0 0 12 6];
print('-dpng','-r250',[conf.print_path 'Difference_Btwn_Ind_' buoy.name{indB} '_' codar.name{ii}...
    '_' dtime.startSTR '_'  dtime.endSTR '.png'])


end

toc
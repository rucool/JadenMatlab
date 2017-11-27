%% Blanking %data return comparison
close all
clear
clc

tic

%% CODAR Info Cell Arrays
%codar.name={'SEAB','BELM','SPRK','BRNT','BRMR','RATH','WOOD'};
codar.name={'SPRK'};

%% determine the time that you want to analyze
dtime.span=datenum(2017,1,1):1/24:datenum(2017,5,1);
dtime.start=min(dtime.span);
dtime.end=max(dtime.span);
dtime.startSTR=datestr(dtime.start,'yyyymmdd');
dtime.endSTR=datestr(dtime.end,'yyyymmdd');

digits=2;

conf.data_path.CODAR_Waves='C:/Users/Jaden Dicopoulos/data/wavesR7/original/';
conf.print_path='C:/Users/Jaden Dicopoulos/COOL/waves/';

for ii=1:length(codar.name)

datapath=[conf.data_path.CODAR_Waves codar.name{ii}];
[CODAR]=Codar_WVM7_readin_func(datapath,'wls');
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
%% declare a new variable for codar data
CODAR3.time=CODAR2.time(ind2);
CODAR3.MWHT=CODAR2.MWHT(ind2);
%% identify the spikes in the data records
[CODAR4.MWHT,idx] = removeSpikes(CODAR3.MWHT,2);
% plot(CODAR3.time(idx),CODAR3.MWHT(idx),'or')
sum(idx);
%% interpolate the data onto a common time axis
buoy02i=interp1(CODAR3.time,CODAR4.MWHT,dtime.span)';

%% find %return and print
fprintf('Percent Data return for Wave Height at CODAR site %s \n',codar.name{ii})

fprintf('Between %s & %s \n',datestr(dtime.start),datestr(dtime.end))

DataPts.CODAR=sum(~isnan(buoy02i));
fprintf('Number of CODAR Data Points %5.0f \n',DataPts.CODAR);

total = numel(dtime.span);
fprintf('Number of Total Possible Data Recordings %5.0f \n',total);

PDR=DataPts.CODAR/total;
fprintf('Percent Data Return for Site %5.1f%% \n',PDR*100);






end

%% Outlier date retrieval between CODAR and NDBC Buoys
% Written by Jaden Dicopoulos
close all
clear
clc

tic

buoy.name={'44008','44091','44025','44065','44009','44014','44066',};
indB=2;
codar.name={'SPRK'};

dtime.span=datenum(2017,1,1):1/24:datenum(2017,6,1);
dtime.start=min(dtime.span);
dtime.end=max(dtime.span);
dtime.startSTR=datestr(dtime.start,'yyyymmdd');
dtime.endSTR=datestr(dtime.end,'yyyymmdd');

conf.data_path.NDBC='C:/Users/Jaden Dicopoulos/data/NDBC/';
conf.data_path.CODAR_Waves_R8='C:/Users/Jaden Dicopoulos/data/wavesR8/Original/';


for ii=1:length(codar.name)
   
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

%% declare a new variable for codar data
CODAR3.time=CODAR2.time(ind2);
CODAR3.MWHT=CODAR2.MWHT(ind2);

ind3=CODAR3.MWHT>6;
CODAR3.MWHT(ind3)=NaN;

NDBC.time=buoy01.DATA(ind,1);
NDBC.MWHT=buoy01.DATA(ind,5);

%% identify the spikes in the data records
[CODAR4.MWHT,idx] = removeSpikes(CODAR3.MWHT,2);
sum(idx);
 
[NDBC4.MWHT,idx2] = removeSpikes(NDBC.MWHT,2);
sum(idx2);
 
buoy01i=interp1(NDBC.time,NDBC4.MWHT,dtime.span);
buoy02i=interp1(CODAR3.time,CODAR4.MWHT,dtime.span)';
buoy01i=buoy01i';

%% find where the data is good
Good = isnan(buoy01i) + isnan(buoy02i);

DataPts.Common=length(Good)-sum(Good);
DataPts.NDBC=sum(~isnan(buoy01i));
DataPts.CODAR=sum(~isnan(buoy02i));

%%
% OI = abs(buoy01i(Good==0) - buoy02i(Good==0));
% for jj=1:length(OI)
%     if OI(jj) >= 2
%     disp(datestr(dtime.span(jj)))
%     end
% end
% 
% end
% % OI = abs(buoy01i - buoy02i);
% % for jj=1:length(OI)
% %     if OI(jj) >= 2
% %     disp(datestr(dtime.span(jj)))
% %     end
% % end
dtime2.span = dtime.span(Good==0);
OI = abs(buoy01i(Good==0) - buoy02i(Good==0));
for jj=1:length(OI)
    if OI(jj) >= 2
    disp(datestr(dtime2.span(jj)))
    end
end

end

toc
function [Data]=Codar_WVM9_readin_func(datapath,file_extension)
% This program was written to read in CODAR wave data 
% Hugh Roarty
% Remade for release 8 by Jaden Dicopoulos

%clear 

% Add path of data because not n same directory as script
addpath(datapath)

% create a variable filename to create a structured array containing all the
% STAT files
filename=dir([datapath '/*.' file_extension]);

% create a variable num_files the length of the structured array filename
num_files=length(filename);

% define variable start_date so i can write to it in the loop

DATA=[];


WAVE_DATA=[];

% variables     
%               sdl     start date line
%               sd      start date
%               msd     matlab start date
%               
for i=1:num_files
    STAT=load(filename(i).name);
    STAT(:,16)=datenum(STAT(:,15),STAT(:,16),STAT(:,17),STAT(:,18),STAT(:,19),STAT(:,20));
    WAVE_DATA=[WAVE_DATA;STAT];
    clear STAT
end

Data.MWHT=WAVE_DATA(:,2); 
Data.MWPD=WAVE_DATA(:,3);
Data.WAVB=WAVE_DATA(:,4);
Data.WNDB=WAVE_DATA(:,5);
Data.ACNT=WAVE_DATA(:,7);
Data.DIST=WAVE_DATA(:,8);
Data.RCLL=WAVE_DATA(:,9);
Data.time=WAVE_DATA(:,16);

%% Identify the fill values and replace with NaNs
ind_MWHT=find(Data.MWHT==999);
Data.MWHT(ind_MWHT)=NaN;

ind_MWPD=find(Data.MWPD==999);
Data.MWPD(ind_MWPD)=NaN;

ind_WAVB=find(Data.WAVB==1080);
Data.WAVB(ind_WAVB)=NaN;

ind_WNDB=find(Data.WNDB==1080);
Data.WNDB(ind_WNDB)=NaN;



close all
clear 

tic

%% Irene Time Period
% start_date=datenum(2011,8,23);
% end_date=datenum(2011,9,3);
% hurricane='Irene';

%% Time Period to grab data
year=2017;

%% Buoy Info Cell Arrays
buoy.name={'44025','44065','44091'};
buoy.year={9999,9999,9999};

%% loop to go though each buoy

for ii=1:length(buoy.name)
    
    %% decalre the individual buoy
    buoy2.name=buoy.name{ii};
    buoy2.year=buoy.year{ii};

    %% read in the wind data
    [DATA]=ndbc_nc(buoy2);


    %% Save the data
    savefile=['C:/Users/Jaden Dicopoulos/data/NDBC_Updated/ndbc_' buoy2.name '_2017.mat'];
    save(savefile,'DATA')
    
end

toc
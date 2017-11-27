%% Script 5: Weather Data Aggregation
% Read in the separate files for each month and combine them into a single
% table. This section could take a few minutes to run depending on the
% amount of data being aggregated, so it will instead load in the result
% from a mat file if it is available.
%
% Copyright 2014-2015 The MathWorks, Inc.

%% Station info

clear;clc; % clean up

% weather stations to read from
stn = {'KALB', 'KART', 'KBGM', 'KBUF', 'KELM', 'KHPN', 'KISP', 'KJFK', 'KLGA',...
    'KMSS', 'KMSV', 'KPBG', 'KPOU', 'KROC', 'KSWF', 'KSYR', 'KRME'}';
% station id's
stnid = [14735, 94790, 04725, 14733, 14748, 94745, 04781, 94789, 14732, ...
    94761, 54746, 64776, 14757, 14768, 14714, 14771, 64775]';
% create table used in helper function for filtering out unwanted stations
stntbl = table;
stntbl.WBAN = stnid;

%% Combine weather data
% Read in the separate files for each month and combine them into a single
% table. This section can take a few minutes to run, so it will instead
% load in the result from a mat file if it is available.

% if it exists, use a mat file containing the aggregated results
preferMAT = true;
weatherFolder = './Data/Weather/HistWeather';
if exist('weather_original.mat','file') && preferMAT
    load('weather_original.mat');
else
    % find txt files to aggregate
    d = dir(fullfile(weatherFolder,'*hourly.txt'));
    data = cell(length(d),1);
    lengd = length(d);
    % loop through txt files in parallel
    parfor ii = 1:lengd
        warning('off','MATLAB:table:ModifiedVarnames');
        fprintf('Reading %s (%4d of %4d): ', d(ii).name, ii, lengd);
        try
            % use a datastore to allow easy read access to only certain
            % parts of the large file
            ds = datastore(fullfile(weatherFolder, d(ii).name),...
                'SelectedVariableNames',{'WBAN','Date','Time','DryBulbFarenheit','DewPointFarenheit'},...
                'RowsPerRead',5e6,'TreatAsMissing',{'M'},'SelectedFormats',{'%f','%f','%f','%f','%f'});
            % using helper function to filter data
            data{ii} = WeatherAggFcn(ds,stntbl);
            fprintf('Success!\n')
        catch ME
            fprintf('Failure: %s\n', ME.message);
        end
    end
    % concatenate data from files into single table
    weatherData = vertcat(data{:});
    % replace WBAN codes with station names
    weatherData.Name = cell(length(weatherData.WBAN),1);
    stn = cellfun(@(x)['Temperature' x],stn,'UniformOutput',false);
    for ii = 1:length(stnid)
        weatherData.Name(weatherData.WBAN==stnid(ii)) = stn(ii);
    end
    weatherData.WBAN = [];
    % get date number to use as grouping variable
    [year,month,day] = datevec(num2str(weatherData.Date),'yyyymmdd');
    weatherData.Date = datenum(year,month,day,weatherData.Hour,0,0);
    weatherData.Hour = [];
    % reformat table
    weatherData = unstack(weatherData,'Temp','Name');
    % create datetime object
    weatherData.Date = datetime(weatherData.Date,'ConvertFrom','datenum','TimeZone','America/New_York');
    weatherData.Date.Second = round(weatherData.Date.Second);
    % sort table into chronological order
    weatherData = sortrows(weatherData,'Date');
    % save table to mat file
    save('weather_original.mat','weatherData')
end

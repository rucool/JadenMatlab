%% Script 2: Aggregate NYISO data 
% Read in the separate files for each day and combine them into a single
% table. This section could take a few minutes to run depending on the
% amount of data being aggregated, so it will instead load in the result
% from a mat file if it is available.
%
% Copyright 2014-2015 The MathWorks, Inc.

%% Aggregate load data from unzipped files

clear;clc; % clean up
% if it exists, use a mat file containing the aggregated results
preferMAT = true;
dataFolder = './Data/NYISO/HistLoad';
if exist('nyiso_original.mat','file') && preferMAT
    load('nyiso_original.mat');
else
    % find csv files to aggregate
    d = dir(fullfile(dataFolder,'*.csv'));
    lengd = length(d);
    data = cell(size(d)); % preallocate cell to hold data from files
    % loop through csv files in parallel
    parfor i = 1:lengd
        warning('off','MATLAB:table:ModifiedVarnames');
        fprintf('Reading %s (%4d of %4d)\n', d(i).name, i, lengd);
        % read from csv into table
        t = readtable(fullfile(dataFolder, d(i).name),'format','%s%q%C%d%f', 'delimiter', ',');
        % find the hour of the day for each time stamp
        [~,~,~,h,~,~] = datevec(t.TimeStamp,'"mm/dd/yyyy HH:MM:ss"');
        % find the first measurement in each hour
        [~,firstHourId] = unique([h double(t.Name)],'rows');
        % save only the desired measurements
        t = t(firstHourId,:);
        data{i} = t(:,{'TimeStamp','Name','Load'});
    end
    % concatenate data from files into single table
    nyiso = vertcat(data{:});
    clear data t
    % reformat data
    nyiso = unstack(nyiso, 'Load', 'Name');
    nyiso.TimeStamp = datetime(nyiso.TimeStamp,'InputFormat','"MM/dd/uuuu HH:mm:ss"','TimeZone','America/New_York');
    nyiso = sortrows(nyiso, 'TimeStamp');
    nyiso.Properties.VariableNames{1} = 'Date';
    % in older data sets NYC and Long Island were merged into a single
    % zone, remove it if it exists
    if any(strcmp(nyiso.Properties.VariableNames,'N_Y_C__LONGIL'))
        nyiso(:,{'N_Y_C__LONGIL'}) = [];
    end
    % save table to mat file
    save('nyiso_original.mat', 'nyiso');
end
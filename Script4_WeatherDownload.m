%% Script 4: Download Weather Data
% This script will download example weather data from the National
% Climatic Data Center:
% http://cdo.ncdc.noaa.gov/qclcd_ascii/
%
% Copyright 2014-2015 The MathWorks, Inc.

%% Specify range to download
% Starting and ending points for range to download. Specify with format
% 'yyyy-mmm-01'. For example to start with March 2010, set firstmonth to
% '2010-Mar-01'.
%
% * firstmonth should be no earlier than 2007-May-01 as the weather data
% source has an unaccounted for format change before that date
% * Recommend lastmonth be no later than 2014-May-01 due to large volumes
% of missing data in the energy data source after that date
% * Downloaded weather files are zip files approximately 60MB in size
% * Each month when fully uncompressed takes up 250-500MB

clear;clc; % clean up
firstmonth = '2007-May-01';
lastmonth = '2014-May-01';
% Create range of months
dates = (datetime(firstmonth):calmonths(1):datetime(lastmonth))';

%% Replace existing zip files?
% If some zip files have already been downloaded, should they be
% redownloaded?

% create directory for zip files if it does not exist
ziploc = '.\Data\Weather\';
if ~exist(ziploc,'dir')
    mkdir(ziploc)
end

% search zip directory for existing zip files
d = dir(fullfile(ziploc,'*.zip'));

% if some zip files already exist from the list to download, should they be
% redownloaded?
replacezips = 0; % set to 0 to not replace zips, or to 1 to replace zips
if replacezips == 0 % if we don't want to replace zips...
    % get the months for existing zips
    existzips=datetime(arrayfun(@(x)x.name(6:end-4),d,'UniformOutput',false),...
        'InputFormat','yyyyMMdd');
    % find which zips exist in the list to download that do not exist in
    % zip director
    [~,idx] = setdiff(dates,existzips);
    % filter out dates that have already been downloaded
    dates = dates(idx);
end

%% Download weather data

lengd = length(dates);
options = weboptions('Timeout',10);
% loop through dates to download in parallel
parfor ii = 1:length(dates)
    % name of zip file
    filename = ['QCLCD' datestr(dates(ii),'yyyymm') '.zip'];
    % destination on local computer
    file_destination = ['Data\Weather\QCLCD' datestr(dates(ii),'yyyymmdd') '.zip'];
    % location of zip file
    url = ['http://cdo.ncdc.noaa.gov/qclcd_ascii/' filename];
    
    fprintf('Downloading %d of %d. %s ', ii, lengd, filename)
    try
        websave(file_destination,url,options);
        fprintf('Success!\n');
    catch ME
        fprintf('Failure: %s\n', ME.message);
    end
end

%% Unzip files

% location to unzip contents to
fileloc = [ziploc 'HistWeather\'];
% create directory if it does not exist
if ~exist(fileloc,'dir')
    mkdir(fileloc)
end
% uncompress files
parfor kk = 1:length(dates)
    unzip([ziploc,'QCLCD',datestr(dates(kk),'yyyymmdd'),'.zip'],fileloc)
end

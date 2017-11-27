%% Script 1: NYISO Download and Aggregation
% This script will download example load data from the New York ISO:
% http://mis.nyiso.com/public/
%
% Copyright 2014-2015 The MathWorks, Inc.

%% Specify range to download
% Starting and ending points for range to download. Specify with format
% 'yyyy-mmm-01'. For example to start with March 2010, set firstmonth to
% '2010-Mar-01'.
%
% * Recommend firstmonth be no earlier than 2007-May-01 as the
% corresponding weather data source has an unaccounted for format change
% before that date
% * Recommend lastmonth be no later than 2014-May-01 due to large volumes
% of missing energy load data after that date

clear;clc; % clean up
firstmonth = '2007-May-01';
lastmonth = '2014-May-01';
% Create range of months
dates = (datetime(firstmonth):calmonths(1):datetime(lastmonth))';

%% Replace existing zip files?
% If some zip files have already been downloaded, should they be
% redownloaded?

% create directory for zip files if it does not exist
ziploc = '.\Data\NYISO\';
if ~exist(ziploc,'dir')
    mkdir(ziploc)
end
% search zip directory for existing zip files
d = dir(fullfile(ziploc,'*.zip'));
% if zip files already exist from the list to download, should they be
% redownloaded
replacezips = 0; % set to 0 to not replace zips, or to 1 to replace zips
if replacezips == 0 % if we don't want to replace zips...
    % get the months for existing zips
    existzips=datetime(arrayfun(@(x)x.name(9:end-4),d,'UniformOutput',false),...
        'InputFormat','yyyyMMdd');
    % find which zips exist in the list to download that do not exist in
    % zip directory
    [~,idx] = setdiff(dates,existzips);
    % filter out dates that have already been downloaded
    dates = dates(idx);
end

%% Download NYISO loads
% Scrape NYISO website and download load data

lengd = length(dates);
% loop through dates to download in parallel
parfor ii = 1:lengd
    % name of zip file
    filename = [datestr(dates(ii),'yyyymmdd') 'pal_csv.zip'];
    % location of zip file
    url = ['http://mis.nyiso.com/public/csv/pal/' filename];
    % destination on local computer
    file_destination = [ziploc 'HistLoad' datestr(dates(ii),'yyyymmdd') '.zip'];
    fprintf('Downloading %d of %d. %s ', ii, lengd, filename)
    try
        % save from web to local directory
        websave(file_destination,url);
        fprintf('Success!\n');
    catch ME
        fprintf('Failure: %s\n', ME.message);
    end
end

%% Unzip files

% location to unzip contents to
fileloc = [ziploc 'HistLoad\'];
% create directory if it does not exist
if ~exist(fileloc,'dir')
    mkdir(fileloc)
end
% unzip files
for kk = 1:length(dates)
    unzip([ziploc,'HistLoad',datestr(dates(kk),'yyyymmdd'),'.zip'],fileloc)
end
%% Script 7: Merge Datasets
% Merge the NYISO and weather data sets together and check for duplicate
% and missing timestamps.
%
% Copyright 2014-2015 The MathWorks, Inc.

%% Load in Data

clear;clc; % clean up
load nyiso_cleaned
load weather_cleaned

%% Merge Load & Weather sets

% join together the nyiso and weatherData tables keeping only the
% timestamps that exist in both data sets
nyiso = innerjoin(nyiso, weatherData);

%% Are there any duplicates?
% check if there are any duplicate dates after merging sets together

% find the list of unique dates
[u, ia] = unique(nyiso.Date);
% if the length of the unique dates is the same as the length of all the
% dates we have, then there are no duplicates
isUnique = length(u) == length(nyiso.Date);
% if there are duplicates, find where they are
dupIdx = setdiff(1:length(nyiso.Date), ia);
% print out results
if ~isUnique
    disp('There are duplicate dates:')
    disp(nyiso.Date(dupIdx));
else
    disp('There are no duplicate dates.')
end
% if duplicates exist, remove them
nyiso(dupIdx,:) = [];

%% Are any timestamps missing?
% check if any timestamps are missing from our data set

% compare the list of timestamps we should have with the list we actually
% have
[missdates,im] = setdiff(nyiso.Date(1):hours(1):nyiso.Date(end),nyiso.Date);
% print out the results
if ~isempty(missdates)
    disp('There are missing dates:')
    disp(missdates')
else
    disp('There are no missing dates.')
end

%% Save merged data

save nyiso_merged.mat nyiso
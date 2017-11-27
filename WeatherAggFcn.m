function weatherData = WeatherAggFcn(ds,stntbl)
% weatherData = WeatherAggFcn(ds,stntbl)
% WeatherAggFcn is a helper function for reading in a subset of a weather
% data file from http://cdo.ncdc.noaa.gov/qclcd_ascii/
% The raw data files are too large to easily load into memory at once, so a
% datastore is used to chunk through the files.
%
% Inputs:
%   ds              datastore object pointing to hourly data file
%   stntbl          table with single column containing the WBAN codes of
%                   desired weather stations
%
% Outputs:
%   weatherData     table containing data from hourly data file
%
% Copyright 2015 The MathWorks, Inc

% initialize data variable
data = cell(1,1);
ii = 1; % loop counter
% while the datastore has more data to read
while hasdata(ds)
    % read in a chunk
    t = read(ds);
    % join t with table containing desired WBAN numbers, this is one easy
    % way to filter out unwanted stations
    t = innerjoin(t,stntbl);
    % if t is not empty, meaning there are desired stations in this chunk
    % of data
    if ~isempty(t)
        % standardize names of the columns from the data store
        t.Properties.VariableNames = {'WBAN','Date','Time','Temp','DewPnt'};
        % combine temperature and dewpoint into single column
        t.Temp = [t.Temp t.DewPnt];
        % find the hour that each measurement is closest to
        t.Hour = floor(t.Time/100);
        t.Minute = rem(t.Time,100);
        t.Hour(t.Minute >= 30) = t.Hour(t.Minute >= 30) + 1;
        % keep only one entry per station per day per hour
        [~,firstHourId] = unique([t.WBAN t.Date t.Hour],'rows');
        % store subset of data
        data{ii} = t(firstHourId,{'WBAN','Date','Hour','Temp'});
        ii = ii+1;
    end
end
% concatenate data set
weatherData = vertcat(data{:});
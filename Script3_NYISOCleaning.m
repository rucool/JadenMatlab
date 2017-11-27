%% Script 3: Clean up NYISO data
% Our data may contain anomalies or bad data points that we want to remove.
% Here we examine two example techniques for identifying when these occur.
%
% Copyright 2014-2015 The MathWorks, Inc.

%% Load data

clear;clc; % clean up
load nyiso_original
% pick sample to use as an example
var = 'DUNWOD';
idx = 1:1e4;
x = datenum(nyiso.Date(idx));
y = nyiso.(var)(idx);

%% Find anomalies using smoothing splines
% A simple way to locate errors is to fit a smoothing spline to the data.
% Any large, sudden spikes will have a large difference between the
% original data and the smoothed data.

% remove any points that are close to zero
idxbad = y<=10;
y(idxbad) = NaN;
% fit smoothing spline and make prediction over data set
fo = fit(x,y,'smoothingspline','Exclude',isnan(y));
yy = fo(x);
% find points that don't meet error threhold
error_threshold = 100;
idxbad = idxbad | (abs(y(idx)-yy) > error_threshold);
% plot results
figure
subplot(2,1,1),f1=plot(nyiso.Date(idx),[y(idx) yy]);ylabel('Load (MW)');hold on;
plot(nyiso.Date(idxbad),y(idxbad),'go')
legend('Actual','Smoothed','Anomalies')
subplot(2,1,2),f2=plot(nyiso.Date(idx),y(idx)-yy);ylabel('Error (MW)');
linkaxes([f1.Parent,f2.Parent],'x')

%% Find anomalies using slope outliers
% Another way to identify anomalies is to examine how the line slope
% changes. If there is a large change in one direction followed by a large
% change in the other, this could signify an anomaly.

% custom helper function to identify slope outliers
[yyy,idxbad] = removeSpikes(y,1,20); 
% plot results
figure; plot(nyiso.Date(idx),y); hold on % plot original data
plot(nyiso.Date(idxbad),y(idxbad),'og'); hold off % identify anomalies
legend('Original signal','Anomalies'); ylabel('Load (MW)')

%% Remove Errors in Load Data
% once we decide on a technique, we can apply it to our different signals

% remove spikes from the different signals
parfor ii = 2:width(nyiso)
    nyiso{:,ii} = removeSpikes(nyiso{:,ii},3,10);
end
% save the results
save('nyiso_cleaned','nyiso');

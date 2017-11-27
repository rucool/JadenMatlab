%% DataAnalyticsScript
% This demo script is used to illustrate a historical data analysis
% workflow. It combines shortened versions of Script1-Script8, also
% included.
%
% Copyright 2014-2015 The MathWorks, Inc.

%% Download files
% First we download and unzip a sample data set. Full example is in
% Script1_NYISODownload

if ~exist('.\Data\Sample\','dir')
    mkdir('.\Data\Sample\')
end
dates = (datetime('2004-Jan-01'):calmonths(1):datetime('2005-Aug-01'))';
parfor i = 1:length(dates)
    filename = [datestr(dates(i),'yyyymmdd') 'pal_csv.zip'];
    url = ['http://mis.nyiso.com/public/csv/pal/' filename];
    file_destination = ['Data\Sample\HistLoad' datestr(dates(i),'yyyymmdd') '.csv.zip'];
    fprintf('Downloading %d of %d. %s \n', i, length(dates), filename)
    websave(file_destination,url);
end

% Unzip files
mkdir('Data\Sample\HistLoad')
!unzip Data\Sample\HistLoad*.zip -d Data\Sample\HistLoad

%% Aggregate files
% After downloading the data we need to aggregate it into a useable data
% format. Full example in Script2_NYISOAggregate.

d = dir('Data\Sample\HistLoad\*.csv');
nyiso = [];
parfor i = 1:length(d)
    warning('off','MATLAB:table:ModifiedVarnames')
    fprintf('Reading %s (%4d of %4d)\n', d(i).name, i, length(d))
    t = readtable(['Data\Sample\HistLoad\' d(i).name],'format','%s%q%C%d%f', 'delimiter', ',');
    % find the hour of the day for each time stamp
    [~,~,~,h,~,~] = datevec(t.TimeStamp,'"mm/dd/yyyy HH:MM:ss"');
    % find the first measurement in each hour
    [~,firstHourId] = unique([h double(t.Name)],'rows');
    % save only the desired measurements
    nyiso = [nyiso; t(firstHourId,{'TimeStamp','Name','Load'})];
end
nyiso = unstack(nyiso, 'Load', 'Name');
nyiso.TimeStamp = datetime(nyiso.TimeStamp,'InputFormat','"MM/dd/uuuu HH:mm:ss"','TimeZone','America/New_York');
nyiso.Properties.VariableNames{1} = 'Date';
nyiso = sortrows(nyiso, 'Date');

plot(nyiso.Date,nyiso.DUNWOD)
xlabel('Date');ylabel('Load (MW)');
title('DUNWOD Region')

%% Find anomalies using smoothing splines
% The plot of the aggregated results shows that there are some anomalies in
% the data we may want to remove. In this example we use a smoothing spline
% to find the points. Full example in Script3_NYISOCleaning

var = 'DUNWOD';
x = datenum(nyiso.Date);
y = nyiso.(var);

% remove any points that are close to zero
idxbad = y<=10;
y(idxbad) = NaN;
% fit smoothing spline and make prediction over data set
fo = fit(x,y,'smoothingspline','Exclude',isnan(y));
yy = fo(x);
% find points that don't meet error threhold
error_threshold = 100;
idxbad = idxbad | (abs(y-yy) > error_threshold);
% plot results
figure
subplot(2,1,1),f1=plot(nyiso.Date,[y yy]);ylabel('Load (MW)');hold on;
plot(nyiso.Date(idxbad),y(idxbad),'go')
legend('Actual','Smoothed','Anomalies')
subplot(2,1,2),f2=plot(nyiso.Date,y-yy);ylabel('Error (MW)');
linkaxes([f1.Parent,f2.Parent],'x')

%% Merge Load & Weather sets
% We can also do the same download, aggregate and cleaning for our second
% data source. Full examples are in Script4, Script5 and Script6. For
% brevity, this example simply loads the results of Scripts 1-6.
%
% Now the two data sources need to be merged together along a common axis.
% Full example in Script7_MergeDatasets

load nyiso_cleaned
load weather_cleaned

% join together the nyiso and weatherData tables keeping only the
% timestamps that exist in both data sets
nyiso = innerjoin(nyiso, weatherData);

%% Modeling a single zone
% Now we're ready to start modeling our data so we can make forecasts. The
% rest of the script examines a neural network applied to the New York
% City area. Full example in Script8_Modeling

% Pull out relevant data into separate table to make it easier to work with
modeldata = nyiso(:,{'Date','N_Y_C_','TemperatureKLGA'});
% Change the table column names to be more general
modeldata.Properties.VariableNames(2:3) = {'Load','Temperature'};

%% Create predictors
% In order to build an accurate model, we need useful predictors to work
% with. A common technique with temporal predictors is to break them into
% their separate parts so they can be varied independently of each other.

% Create temporal predictors
modeldata.Hour = modeldata.Date.Hour;
modeldata.Month = modeldata.Date.Month;
modeldata.Year = modeldata.Date.Year;
modeldata.DayOfWeek = weekday(modeldata.Date);
modeldata.isWeekend = ismember(modeldata.DayOfWeek,[1,7]);

% Pull the temperature and dew point apart into separate columns as
% expected by the machine learning techniques
modeldata.Temp = modeldata.Temperature(:,1);
modeldata.DewPnt = modeldata.Temperature(:,2);
modeldata.Temperature = [];

% Lagged predictors
% The load data itself can be used as a predictor. We could use a
% traditional time series analysis, but a look at the autocorrelation will
% show an interesting pattern that suggest use of lagged predictors of 1
% and 7 days

% Compute and plot autocorrelation in load data
c = xcorr(modeldata.Load(~isnan(modeldata.Load)),200,'coeff');
% Create predictor for the load at the same time the prior day, 24 hour
% lag. Because we have missing timestamps, we can't simply look back by 24
% rows. This method is robust to missing timestamps.
modeldata.PriorDay = nan(height(modeldata),1);
idxload = ismember(modeldata.Date+hours(24),modeldata.Date);
idxprior = ismember(modeldata.Date-days(1),modeldata.Date);
modeldata.PriorDay(idxprior) = modeldata.Load(idxload);
% Create predictor for the load at the same time the same day the prior
% week, 168 hour lag
modeldata.PriorWeek = nan(height(modeldata),1);
idxload = ismember(modeldata.Date+hours(168),modeldata.Date);
idxprior = ismember(modeldata.Date-days(7),modeldata.Date);
modeldata.PriorWeek(idxprior) = modeldata.Load(idxload);

%% Split to training and testing
%
% Here we split the data into training and testing sets based on the date.
% More sophisticated techniques such as cross validation are also
% available.
idxtrain = modeldata.Date <= datetime('31-May-2012','TimeZone','America/New_York');
idxtest = modeldata.Date > datetime('31-May-2012','TimeZone','America/New_York');
% some of the machine learning functions expect separate matricies for the
% inputs and output
Xtrain = modeldata{idxtrain,3:end};
Ytrain = modeldata{idxtrain,2};
Xtest = modeldata{idxtest,3:end};
Ytest = modeldata{idxtest,2};

%% Neural networks
% Fit a feed-forward Neural Network to solve the regression problem. The
% network can be estimated and evaluated using the interactive Neural
% Fitting Tool (nftool) app. The app automatically generates code, some of
% which has been included below to do the same work programmatically.

trainFcn = 'trainlm';  % Levenberg-Marquardt training algorithm

% Create a Fitting Network
hiddenLayerSize = 20; 
net = fitnet(hiddenLayerSize,trainFcn);

% Train the Network
mdl_net = train(net,Xtrain',Ytrain','UseParallel','yes');

fprintf('Neural Net Training set MAPE: %0.2f%%\n', ...
    mape(Ytrain, mdl_net(Xtrain')')*100);

% make predictions on the test data set and plot results
Y_nn = mdl_net(Xtest')';
figure
ax1=subplot(2,1,1);
plot(modeldata.Date(idxtest),Y_nn,'DisplayName','Y_nn');hold on
plot(modeldata.Date(idxtest),Ytest,'DisplayName','Ytest');hold off
legend('Neural Network','Measured')
ylabel('Load (MW)')
ax2=subplot(2,1,2);
plot(modeldata.Date(idxtest),Ytest-Y_nn);
legend('Neural Network')
ylabel('Error (MW)')
linkaxes([ax1,ax2],'x')

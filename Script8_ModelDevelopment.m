%% Script 8: Model Development
% There are many different approaches and techniques for modeling systems.
% This script demonstrates three common techniques: a simple linear
% regression, a neural network, and bagged decision trees. 
%
% Copyright 2014-2015 The MathWorks, Inc.

%% Load in merged data set
clear;clc; % clean up
load nyiso_merged.mat

%% Start with modeling a single zone
% We'll start by evaluating our models on one of the zones, in this case
% the New York City zone. The weather station at Laguardia airport covers
% most of the zone. Once we understand how to model a single zone, we can
% expand our analysis to other zones.

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

%% Lagged predictors
% The load data itself can be used as a predictor. We could use a
% traditional time series analysis, but a look at the autocorrelation will
% show an interesting pattern that suggest use of lagged predictors of 1
% and 7 days

% Compute and plot autocorrelation in load data
c = xcorr(modeldata.Load(~isnan(modeldata.Load)),200,'coeff');
plot(-200:200,c)
title('Autocorrelation in load data')
xlabel('Lag (Hours)'); ylabel('Correlation')
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
% split the table into training and testing sets
modeltrain = modeldata(idxtrain,2:end);
modeltest = modeldata(idxtest,2:end);
% some of the machine learning functions expect separate matricies for the
% inputs and output
Xtrain = modeltrain{:,2:end};
Ytrain = modeltrain{:,1};
Xtest = modeltest{:,2:end};
Ytest = modeltest{:,1};

%% Regression
% Fit and examine a simple linear model to the dataset. This model has a
% small number of parameters, each of which is significant and purports to
% have a "good" R^2 metric. 

mdl_lm = fitlm(modeltrain,'ResponseVar','Load')

%% Regression Performance
% Evaluate the performance of the regression model using the mean absolute
% percent error metric, which is commonly used in electricity demand
% forecasting applications. 

fprintf('Linear Model Training set MAPE: %0.2f%%\n', ...
    mape(Ytrain, predict(mdl_lm, modeltrain))*100);

%% Parallel Computing Environment
% Many MATLAB algorithms can take advantage of parallel processing to speed
% up calculations. Here we open a pool of workers to harness the full
% computational capabilities of the CPU running this script

if isempty(gcp('nocreate'))
    parpool('local')
end

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

%% Ensemble Regression Tree
% Train a bagged regression tree model on the same data set. Bagging
% involves building an ensemble of trees, each trained on a resampled
% subset of the training set. During prediction, each tree creates a
% forecast and the average of all forecasts is taken. This can produce a
% strong classifier. 

opts = statset('UseParallel', 'always');
mdl_tb = TreeBagger(50, Xtrain, Ytrain, 'method', 'regression', ...
                'OOBVarImp', 'on', 'options', opts, 'NVarToSample','all',...
                'CategoricalPredictors',[1,2,3,4]);

fprintf('Treebagger Training set MAPE: %0.2f%%\n', ...
    mape(Ytrain, predict(mdl_tb, Xtrain))*100);

%% Ensemble Predictor importance
% One of the benefits of using an ensemble is that each tree has some
% portion of the dataset it hasn't seen yet (out of bag observations).
% These can be used to perform validation of the model and also measure
% quantities like variable importance. 

figure
barh(mdl_tb.OOBPermutedVarDeltaError);
set(gca,'YTick',1:size(Xtrain,2),'YTickLabel',modeltrain.Properties.VariableNames(2:end));
title('Relative feature importance'); 

%% Compare Models on Validation Set
% Model performance so far has been reported only on the training set. A
% true measure of the generalization capability of the model is measured by
% its performance on a holdout dataset. For example, even though the bagged
% regression tree has a lower MAPE on the training set than the Neural net
% it has a higher MAPE on the test set indicating that it is likely to have
% overfit to the training set. 

% make predictions on the test data set
Y_lm = predict(mdl_lm,modeltest);
Y_nn = mdl_net(Xtest')';
Y_tb = predict(mdl_tb,Xtest);
% concatenae predictions and mape for training and test sets
predTest = [Y_lm, Y_nn, Y_tb];
predTrain = [predict(mdl_lm, modeltrain) mdl_net(Xtrain')' predict(mdl_tb, Xtrain)];

perfTest = mape(Ytest, predTest);
perfTrain = mape(Ytrain, predTrain);
% plot the training and test mape for all three techniques
figure
bar([perfTrain;perfTest]'*100); set(gca,'XTickLabel', {'LM', 'NN', 'TB'});
legend('Training','Test')
ylabel('MAPE (%)'); title('Comparison of models on training & test set');
% plot the neural network outcome for the test set
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


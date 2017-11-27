function [y,idx] = removeSpikes(y,np,lt,ut)
% [yout,idx] = removeSpikes(yin,np,lt,ut)
%
% removeSpikes uses slope outliers to detect spikes in a signal and replace
% them with NaNs. The slopes between consecutive points are flagged as
% outliers if they are +/- 2.5 standard deviations from the mean slope. If
% an outlier slope in one direction is followed within np points of an
% outlier slope in the opposite direction, all points between those two
% slopes are replaced with NaNs.
%
% Inputs:
%   yin     input signal with spikes to remove
%   np      maximum number of points in an anomaly (default: 1)
%   lt      lower threshold, all points below this will be removed (default: -inf)
%   ut      upper threshold, all points above this will be removed (default: inf)
%
% Outputs:
%   yout    signal with spikes replaced by NaNs
%   idx     logical index of points that were replaced
%
% Example:
%   x = 0:pi/10:6*pi;
%   y = sin(x);
%   y([5,28,29,43]) = 5;
%   [~,idx] = removeSpikes(y,2);
%   plot(x,y,x(idx),y(idx),'og')
%   legend('signal','spikes')
%
% Copyright 2014-2015 The MathWorks, Inc.

% default value for np is 1
if nargin < 2 || isempty(np)
    np = 1;
end

% default value for lt is -inf
if nargin < 3 || isempty(lt)
    lt = -inf;
end

% default value for ut is inf
if nargin < 4 || isempty(ut)
    ut = inf;
end

% Remove anomalies below lower threshold or above upper threshold
idxout = y < lt | y > ut;

% calculate the slope
dx = y(2:end) - y(1:end-1);

% create the threshold, in this case the mean +/- 2.5 standard deviations
st = nanstd(dx); % standard deviation of the slope
mn = nanmean(dx); % mean of the slope

% where do large changes happen
idxup = dx > mn+2.5*st; % large positive change
idxdown = dx < mn-2.5*st;  % large negative change
idxuploc = find(idxup); % locations where large positive change occurred
idxdownloc = find(idxdown); % locations where large negative change occurred
idxup_anom = false(length(idxup),1); % preallocate array for storing location of positive anomalies
idxdown_anom = false(length(idxdown),1); % preallocate array for storing location of negative anomalies

% identify anomalies in the positive direction, e.g. large positive
% slope followed by large negative slope within a certain number of
% measurements
for ii = 1:length(idxuploc) % for each location where large positive slope exists...
    % find places where the location of large negative slope comes after a
    % positive anomaly within a certain threshold of points
    idxmatch = idxdownloc-idxuploc(ii) <= np & idxdownloc-idxuploc(ii) > 0;
    % if there's any large negative slopes that match the criteria
    if any(idxmatch)
        % find where they occur, and from the location where the positive
        % slope is recorded to the location before the negative slope is
        % recorded set the value to true, signaling an anomaly
        m = find(idxmatch);
        % if there are multiple large down slopes in range, pick the last
        % one to capture the full anomaly
        idxup_anom(idxuploc(ii):idxdownloc(m(end))-1)=true;
    end
end
% identify anomalies in the negative direction
for jj = 1:length(idxdownloc)
    idxmatch = idxuploc-idxdownloc(jj) <= np & idxuploc-idxdownloc(jj) > 0;
    if any(idxmatch)
        m = find(idxmatch);
        idxdown_anom(idxdownloc(jj):idxuploc(m(end))-1)=true;
    end
end
% combine the different bad data points
idx = idxup_anom | idxdown_anom;
idx = [false;idx(:)] | idxout(:); % pad idx because we lost a point when subtracting for the slope

y(idx) = NaN;
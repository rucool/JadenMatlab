%% Wavelet option #1: 
% toolbox here: http://www.mathworks.com/matlabcentral/fileexchange/47985-cross-wavelet-and-wavelet-coherence
% as written here, it computes the power spectrum for # of standard
% deviations from the mean, not the original data. Cannot run with any nans
% in the time-series - they need to be replaced with zeroes or some other
% value (and should be careful of over-interpreting wavelet especially near
% where the nans were). Smoother output than option #2. Only runs on one
% component.

stdev = nanstd(x);
sst = (x - nanmean(x))/stdev ;
ind=find(isnan(sst));
sst(ind)=0; %NaNs --> 0
dt=1; % time gap between each measurement
n=length(sst);

pad = 1;      % pad the time series with zeroes (recommended)
dj = 0.25;    % this will do 4 sub-octaves per octave
s0 = 2*dt;    % this says start at a scale of twice the time step
j1 = 7/dj;    % this says do 7 powers-of-two with dj sub-octaves each
lag1 = 0.72;  % lag-1 autocorrelation for red noise background
mother = 'Morlet';

% Wavelet transform:
[wave,period,scale,coi] = wavelet(sst,dt,pad,dj,s0,j1,mother);
power = (abs(wave)).^2 ;        % compute wavelet power spectrum

% Significance levels: (variance=1 for the normalized SST)
[signif,fft_theor] = wave_signif(1.0,dt,scale,0,lag1,-1,-1,mother);
sig95 = (signif')*(ones(1,n));  % expand signif --> (J+1)x(N) array
sig95 = power ./ sig95;         % where ratio > 1, power is significant



%% Wavelet option #2:
% toolbox built into matlab
% can get wavelet for complex data, and works with nans in data, but the
% nans can leave fairly large gaps in the wavelet output. Output is
% grainier than option #1.
% may not be available (compatible?) with newer versions of matlab.

scales  = [1:100]; % change to adjust frequency/period to compute wavelet for
dt=1; % time gap between measurements
out=scal2frq(scales,'morl',dt);
per=1./out; % periods wavelet is computed at

nw=U+V*j; % 2-component current
coefsv = cwt(nw,scales,'morl'); % absolute value of coefsv is power of wavelet
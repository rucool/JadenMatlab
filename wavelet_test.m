dt = 0.001;
t = 0:dt:1-dt;
x = ...
cos(2*pi*150*t).*(t>=0.1 & t<0.3)+sin(2*pi*200*t).*(t>0.7);
y = x+0.05*randn(size(t));
y([200 800]) = y([200 800])+2;
a0 = 2^(1/32);
scales = 2*a0.^(0:6*32);
[cfs,frequencies] = cwt(y,scales,'cmor1-1.5',dt);
contour(t,frequencies,abs(cfs)); grid on;
xlabel('Seconds'); ylabel('Hz');
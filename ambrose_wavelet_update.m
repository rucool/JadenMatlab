%%
close all
clear
clc
tic
%% Finding Timescale and creating Wind values
 load ambrose_filled_dataset
 stime=datenum(2005,1,1);
 etime=datenum(2005,6,1);
 It=find(ntime>=stime & ntime< etime);
 ntime=ntime(It);
 nu=nu(It);
 nv=nv(It);
    nw=detrend(nu);
dt=10/60;

%%

[WT,F,COI]= cwt(nw,'amor',1/dt);
data1=(abs(WT)).^2;

    figure(1)
    clf
    colormap(jet)
    subplot(2,1,1)
    pcolor(ntime,log10(F),data1)
    shading interp
    hold on
    plot(ntime,log10(COI),'w','linewidth',3)
    hold off
    %set(gca,'ylim',[0.01 .15])
    colorbar
    datetick('x',31,'keepticks','keeplimits')
    title('Log(10) of frequency')
    subplot(2,1,2)
    pcolor(ntime,F,data1)
    shading interp
    hold on
    plot(ntime,COI,'w','linewidth',3)
    hold off
    set(gca,'ylim',[0.01 .15])
    colorbar
    datetick('x',31,'keepticks','keeplimits')
    title('Zoom, No Log(10)')



[PXX, FF]=pwelch(nu,hamming(2048),1024,2048,1/dt,'power');

N=length(nu);
sig=var(nu);
alpha=0.9991;
alpha2=alpha^2;
% N/2?2%
k=1:1025;
Pk=(1-alpha2)./(1+alpha2-(2.*alpha.*cos(2.*pi*k/N)));



mwave=nanmean(data1,2);
figure(2)
 loglog(FF,PXX*N/(2*sig),'k',FF,Pk,'r')
%loglog(FF,PXX.*FF,'k',F,mwave,'b')
grid on
    
   

toc 
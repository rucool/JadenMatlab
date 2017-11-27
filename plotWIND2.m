close all
clear 
clc

conf.print_path='C:/Users/Jaden Dicopoulos/COOL/waves/';

% % enter buoy name:
 buoy=46013;
% % entery year of data: 
 year=2014;


load BU13_2013_12_31_2014_12_31.mat
%WIND = METE;
dWIND=datevec(WIND(:,1));

magn=(WIND(:,2).^2 + WIND(:,3).^2).^0.5;
maxmagn=max(magn);

% make time axis tick that at 1st of the month:
t=WIND(:,1);
dvec=datevec(t);
tik=[];
for i=1:12
        ti=datenum([2014 i 01 00 00 00]);
        tik=[tik;ti];
end

x1=min(t);
x2=max(t);

figure(1)
set(gca,'LineWidth',1,'FontSize',8,'FontName','Arial')
% squish plot to be landscape:
set(gcf,'PaperPosition',[0.25 2.5 12 1.5])
quiver(WIND(:,1),0.*WIND(:,1),WIND(:,2),WIND(:,3),'.','Markersize',5)
set(gca,'Xtick',tik);
set(gca, 'XTickLabel', cellstr(datestr(tik,6)),'FontSize',8);
ylabel('Wind Speed m/s','FontSize',8)
% title(sprintf('%d Hourly Wind Data, Buoy %d',year,buoy),'FontSize',8)
title('Hourly Wind Data','FontSize',8)
xlim=[x1 x2];
     ax = gca;
     ax.XAxis.MinorTick = 'on';
     ax.XAxis.MinorTickValues = x1:2:x2;
     grid on;
     ax.XMinorGrid = 'on';
     axis tight

print('-dpng','-r150',[conf.print_path 'Quiver_.png'])

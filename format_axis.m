function format_axis(handle,start_date,end_date,x_interval,x_minor_interval,date_format,ymin,ymax,y_interval)

%% format the axes of a time series plot
%% 
%% Usage:
%%       format_axis(handle,start_date,end_date,x_interval,x_minor_interval,date_format,ymin,ymax,y_interval)
%%
%% Input:
%%          handle
%%          start_date,
%%          end_date,
%%          x_interval,
%%          x_minor_interval,
%%          date_format,
%%          ymin,
%%          ymax,
%%          y_interval

X_hashes=(start_date:x_interval:end_date);

Y_hashes=(floor(ymin):y_interval:ceil(ymax));

axis ([start_date end_date ymin ymax])
set(handle,'XTick',X_hashes,'XTicklabel',datestr(X_hashes,date_format))
set(handle,'YTick',Y_hashes)
%set(handle,'XMinorTick', 'on')
%set(handle,'YMinorTick', 'on')

box on
grid on

hold on


% specify the minor grid vector
xg = [start_date:x_minor_interval:end_date];
% specify the Y-position and the height of minor grids
yg = [ymin ymin+(ymax-ymin)*.03];
xx = reshape([xg;xg;NaN(1,length(xg))],1,length(xg)*3);
yy = repmat([yg NaN],1,length(xg));
h_minorgrid = plot(xx,yy,'k');

end





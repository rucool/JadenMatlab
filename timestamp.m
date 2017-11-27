function timestamp(figs,optionalstring);
% function timestamp:  applies a time and date text field with optional text
%    to set of figure windows in figs.  For no inputs, stamp goes to gcf.
% If optionalstring = 'delete', any existing timestamp will be deleted.

allfigs = get(0,'children');
if isempty(allfigs); disp('No figures to stamp'); return; end;

if nargin == 0; figs = gcf; end;      % for no inputs, timestamp current figure
if nargin == 2 & isempty(figs); figs = gcf; end; % for figs input [], use gcf
if nargin < 2 & isnumeric(figs); optionalstring = ''; end;
if nargin < 2 & ischar(figs);    optionalstring = figs; figs = gcf; end;

% start processing figure windows
for i = intersect(figs(:),allfigs(:))';  % Only attempt for an existing window
figure(i);  % Must actually set figure: 'text' command below has no
% way to specify figure hndl
orig_hdls = get(i,'children');

% Delete any existing timestamp
delete(orig_hdls(find(strcmp(get(orig_hdls,'tag'),'timestamp'))));
orig_hdls = get(i,'children');

if ~strcmp(lower(optionalstring),'delete')   % Don't add new stamp
% if user wants to delete it
h = axes('position',[0.98 0.02 eps eps]);
set(h,'visible','off');
set(h,'tag','timestamp');
%text(0,0,[datestr(now,2) '  ' datestr(now,14) '. ' optionalstring])

footer=sprintf('%s\n%s',datestr(now,2) ,optionalstring);
text(0,0,[footer] ,'verticalalignment','bottom','horizontalalignment','right','interpreter','none')
%if ~isempty(orig_hdls)   % rotate timestamp axis handle
% to bottom so subsequent user commands
% like xlabel and gca apply to old top axis (the expected one)
%set(i,'children',[orig_hdls; h]);  
%axes(orig_hdls(1))
%end
end

end; 
function fh = allometric_plot2(xvals,yvals,pplt,gplt,type,fh)
%function fh = allometric_plot2(xvals,yvals,pplt,gplt,type,fh)
%

%
if ~exist('type','var'), type={'loglog','linear'}; end;
if ~iscell(type), type={type}; end;
nsubs = numel(type); % # sub-plots

%
if ~exist('fh','var'),
    if   nsubs==1, fh = figure('Position',     [360   162   826   516]);
    else           fh = figure('Position', [16         139        1265         545]);
    end;
end;
figure(fh);

%
xvsteps = linspace(min(xvals)*0.75, max(xvals)*1.25, 100);

for si=1:nsubs
    if (nsubs>1), subplot(1,nsubs,si); end;
    set(gca, 'FontSize', 16);

    switch type{si}
        case {'linear', ''}
            plot(xvals, yvals, 'ro', 'MarkerSize', 10, 'LineWidth', 5);
            hold on;
            plot(xvsteps, gplt.y(xvsteps), 'LineWidth', 5);
            if pplt(1)==1 && length(pplt) == 3 && pplt(3) ~= 0  % linear with intercept
                sgn = guru_iff(pplt(3) > 0, '+', '-');
                data_label = sprintf(' %4.3fx %s %6.3e', pplt(2), sgn, abs(pplt(3)));
            elseif pplt(1)==1  % linear, no intercept specified
                data_label = sprintf(' %4.3fx', pplt(2));   % exponent 1 means truly linear... never any intercept
            else
                data_label = sprintf(' %4.3e * x^{%4.3f}', 10.^pplt(2), pplt(1));
            end;
            legend({' Original Data', data_label}, 'Location', 'NorthWest');
            axis square; axis tight;

        case {'log','loglog'}
            loglog(xvals, yvals, 'ro', 'MarkerSize', 10, 'LineWidth', 5);
            hold on;
            loglog(xvsteps, gplt.y(xvsteps), 'LineWidth', 5);

            sgn = guru_iff(pplt(2) > 0, '+', '-');
            data_label = sprintf(' %4.3fx %s %4.3f', pplt(1), sgn, abs(pplt(2)));
            legend({' Original Data', data_label}, 'Location', 'NorthWest');
            axis square;

            xl    = xvsteps([1 end]); yl = gplt.y(xl); %get(gca,'xlim'); yl    = get(gca,'ylim');
            xdiff = diff(log10(xl));        ydiff = diff(log10(yl));    mdiff = max(xdiff,ydiff);
            xl2   = 10.^(log10(xl) + (mdiff-xdiff)/2*[-1 1]); if (xl2(1)<0), xl2=xl2-xl2(1); end;
            yl2   = 10.^(log10(yl) + (mdiff-ydiff)/2*[-1 1]); if (yl2(1)<0), yl2=yl2-yl2(1); end;
            %lims  = [min([xl2(1) yl2(1)]) max([xl2(2) yl2(2)])];
            set(gca, 'xlim', xl2, 'ylim', yl2 );

        otherwise, error('Unknown type: %s', type{si});

    end;
end;

if (nsubs>1), subplot(1,nsubs,1); end;
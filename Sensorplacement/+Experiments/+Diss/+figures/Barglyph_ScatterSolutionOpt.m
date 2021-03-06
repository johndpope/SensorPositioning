%%
clearvars -except all_eval;
% clearvars -except small_flat conference_room large_flat office_floor
%%
eval_names = {'conference_room', 'small_flat', 'large_flat', 'office_floor'};
outdir = '..\..\Dissertation\thesis\figures\';

for ideval = 1:numel(eval_names)
    % close all;
%     ideval = 1;
    eval_name = eval_names{ideval};
    
    [X, Y] = meshgrid(0:10:500, 0:10:500);
    range = 1:5:21;
    [idx, idy] = meshgrid(range, range);
    ind = sub2ind([51 51], idx(:), idy(:));
    
    xlist = X(ind);
    ylist = Y(ind);
    height = 20;
    width = 30;
    xrange = [-30 230];
    yrange = [-30 230];
    
    all_x = unique(xlist);
    all_y = unique(ylist);
    
    all_mean_wpn_qualities_rounded = round(all_eval.(eval_name).all_mean_wpn_qualities*100);
    real_num_sp = zeros(size(all_x));
    real_num_wpn = zeros(size(all_x));
    for idxy = 1:numel(all_x)
        input = Experiments.Diss.(eval_name)(all_x(idxy), all_y(idxy));
        real_num_sp(idxy) = input.discretization.num_sensors;
        real_num_wpn(idxy) = input.discretization.num_positions;
    end
    
   
    figure;
    h0 = barglyph(xlist, ylist, height, width, all_mean_wpn_qualities_rounded(ind, 7:10), xrange, yrange);
    
    strlabelsx = arrayfun(@(x, y) sprintf('%d (%d)', x, y), all_x, real_num_sp, 'uniformoutput', false);
    strlabelsy = arrayfun(@(x, y) sprintf('%d (%d)', x, y), all_y, real_num_wpn, 'uniformoutput', false);
    set(h0,  'xticklabel', strlabelsx, 'yticklabel', strlabelsy, 'Ticklength', [0 0], 'box', 'on');
    xlabel(h0,'\#$WPN$', 'interpreter', 'none');
    ylabel(h0, '\#$SP$', 'interpreter', 'none');
    title(h0, 'Mean of max Qualities [%]');
    h = legend({'MSPQM', 'BSPQM', 'RPD\newline(MSPQM)', 'RPD\newline(BSPQM)'},'Location', 'SouthOutside', 'Orientation','horizontal' );
    pos = get(h, 'position');
    set(h, 'position', [0.25 0 0.5 0.05])
    
    outfile = sprintf('%s%s_optimization_comparison_quality.png', outdir, opts.eval_name);
    saveas(gcf, outfile);
    
    figure;
    h0 = barglyph(xlist, ylist, height, width, all_eval.(eval_name).all_num_sp_selected(ind, 7:10), xrange, yrange);
    
    strlabelsx = arrayfun(@(x, y) sprintf('%d (%d)', x, y), all_x, real_num_sp, 'uniformoutput', false);
    strlabelsy = arrayfun(@(x, y) sprintf('%d (%d)', x, y), all_y, real_num_wpn, 'uniformoutput', false);
    set(h0,  'xticklabel', strlabelsx, 'yticklabel', strlabelsy, 'Ticklength', [0 0], 'box', 'on');
    xlabel(h0,'\#$WPN$', 'interpreter', 'none');
    ylabel(h0, '\#$SP$', 'interpreter', 'none');
    title(h0, 'Mean of max Qualities [%]');
    h = legend({'MSPQM', 'BSPQM', 'RPD\newline(MSPQM)', 'RPD\newline(BSPQM)'},'Location', 'SouthOutside', 'Orientation','horizontal' );
    pos = get(h, 'position');
    set(h, 'position', [0.25 0 0.5 0.05])
    
    outfile = sprintf('%s%s_optimization_comparison_quality.png', outdir, opts.eval_name);
    saveas(gcf, outfile);
    
    
    
end

%%

figure;
h0 = barglyph(xlist, ylist, height, width, all_mean_wpn_qualities_rounded(ind, [4,8:10]), xrange, yrange);

strlabelsx = arrayfun(@(x, y) sprintf('%d (%d)', x, y), all_x, real_num_sp, 'uniformoutput', false);
strlabelsy = arrayfun(@(x, y) sprintf('%d (%d)', x, y), all_y, real_num_wpn, 'uniformoutput', false);
set(h0,  'xticklabel', strlabelsx, 'yticklabel', strlabelsy, 'Ticklength', [0 0], 'box', 'on');
xlabel(h0,'\#$WPN$', 'interpreter', 'none');
ylabel(h0, '\#$SP$', 'interpreter', 'none');
title(h0, 'Mean of max Qualities [%]');
%%
range = 1:5:21;
[idx, idy] = meshgrid(range, range);
ind = sub2ind([51 51], idx(:), idy(:));
xrange = [-30 230];
yrange = [-30 220];

xlist = X(ind);
ylist = Y(ind);


figure;
h0 = barglyph(xlist, ylist, height, width, all_num_sp_selected(ind, [1:3, 5]), xrange, yrange);

strlabelsx = arrayfun(@(x, y) sprintf('%d (%d)', x, y), all_x, real_num_sp, 'uniformoutput', false);
strlabelsy = arrayfun(@(x, y) sprintf('%d (%d)', x, y), all_y, real_num_wpn, 'uniformoutput', false);
set(h0,  'xticklabel', strlabelsx, 'yticklabel', strlabelsy, 'Ticklength', [0 0], 'box', 'on');
xlabel(h0,'\#$WPN$', 'interpreter', 'none');
ylabel(h0, '\#$SP$', 'interpreter', 'none');
%%

figure;
h0 = barglyph(xlist, ylist, height, width, all_num_sp_selected(ind, [4,8:10]), xrange, yrange);

%%
% inputs = arrayfun(@(wpn, sp) Experiments.Diss.small_flat(wpn, sp), all_x, all_y,'uniformoutput', false);
% real_num_sp = cellfun(@(x) x.discretization.num_sensors, inputs);
% real_num_wpn = cellfun(@(x) x.discretization.num_positions, inputs);


strlabelsx = arrayfun(@(x, y) sprintf('%d (%d)', x, y), all_x, real_num_sp, 'uniformoutput', false);
strlabelsy = arrayfun(@(x, y) sprintf('%d (%d)', x, y), all_y, real_num_wpn, 'uniformoutput', false);
set(h0,  'xticklabel', strlabelsx, 'yticklabel', strlabelsy, 'Ticklength', [0 0], 'box', 'on');
xlabel(h0,'\#$WPN$', 'interpreter', 'none');
ylabel(h0, '\#$SP$', 'interpreter', 'none');






%%
% matlab2tikz('export\SmallFlatWpnCoverageNumSp.tikz', 'parseStrings', false,...
%     'tikzFileComment', '% -*- root: TestingFigures.tex -*-', 'extraAxisOptions',{'y post scale=1'});

matlab2tikz('export\SmallFlatWpnCoverageNumSp.tikz', 'parseStrings', false,...
    'tikzFileComment', '% -*- root: SmallFlatWpnCoverageNumSp.tex -*-',...
    'extraAxisOptions',{'y post scale=1',...
    'every x tick label/.append style={tickwidth=0cm,major tick length=0cm}'});
%     'standalone', true);
%     'every outer x axis line/.append style={black}'});


find_and_replace('export\SmallFlatWpnCoverageNumSp.tikz','bar width=0.025453in,', '');
find_and_replace('export\SmallFlatWpnCoverageNumSp.tikz','bar shift=-0.063633in,', '');
find_and_replace('export\SmallFlatWpnCoverageNumSp.tikz','bar shift=-0.031817in,', '');
find_and_replace('export\SmallFlatWpnCoverageNumSp.tikz','bar shift=0.031817in,', '');
find_and_replace('export\SmallFlatWpnCoverageNumSp.tikz','bar shift=0.063633in,', '');
% find_and_replace('export\SmallFlatWpnCoverageNumSp.tikz','area legend,', 'major x tick style = transparent,');

Figures.writeTexFile('SmallFlatWpnCoverageNumSp.tikz', 'export\');


%%

function draw(q_val, q_ids, wpn, sp)
%% DRAWSENSORPOSE(sp) draws one or more sensor poses given in [3 n] array

num_colors = 20;
[colors] = cool(20);
xsampl = linspace(0, 1, num_colors);
ids_wpn = 1:size(wpn, 2);
for id_wpn = ids_wpn
    cnt = 1;
    for id_sp = q_ids{id_wpn}'
        drawEdge([wpn(:, id_wpn)', sp(1:2, id_sp)'], 'color', interp1(xsampl, colors, q_val{id_wpn}(cnt)));
        cnt = cnt+1;
    end
end


%% TESTS
clear variables;
format long;
filename = 'res\floorplans\P1-Seminarraum.dxf';
config_discretization = Configurations.Discretization.iterative;

environment = Environment.load(filename);
Environment.draw(environment, false);
% options = config.workspace;

config_discretization.positions.additional = 0;
config_discretization.sensorspace.poses.additional = 0;

discretization = Discretization.generate(environment, config_discretization);

config_quality = Configurations.Quality.diss;
[q_val, q_ids] = Quality.WS.distance(discretization, config_quality);
wpn = discretization.wpn;
sp = discretization.sp;
Quality.WS.draw(q_val, q_ids, wpn, sp);

%% OLD VERSION
% 
% function draw(poses)
% %%
% 
% holdison = false;
% if ishold
%     holdison = true;
% end
% 
% hold on; 
% % drawPoint(pc.problem.S(1:2, :)');
% % rays = createRay(pc.problem.S(1:2, :)', pc.problem.S(3,:)');
% % rays(:,3:4) = bsxfun(@plus, rays(:,1:2), rays(:,3:4)*500);
% % hold on;
% 
% fun_legend_off =@(h) set(get(get(h,'Annotation'),'LegendInformation'),...
%     'IconDisplayStyle','off'); % Exclude line from legend
% % h = drawEdge(rays);
% h = drawPoint(poses(1:2, :)', 'MarkerSize', 6);
% legend(h(1), 'Sensorspace');
% arrayfun(fun_legend_off, h(2:end));
% 
% legend off;
% legend show;
% 
% if ~holdison
%     hold off;
% end
% 
_
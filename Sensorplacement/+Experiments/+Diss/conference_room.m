% function [processing] = room(num_wpn, num_sp)
%% calculates all evaluations for the given number of additional wpn and sp

% num_wpn = 100;
% num_sp = 100;
% clear variables functions
% cplex = 'C:\Users\Nico\App\Cplex\cplex\bin\x64_win64\cplex.exe';
% fun_solve = @(filename) Optimization.Discrete.Solver.cplex.run(filename, cplex);

% clear variables;
% cla;
% axis equal
% hold on;
% axis off
% % set(gca, 'CameraUpVector', [0 1 0]);
% 
% filename = 'res/floorplans/P1-Seminarraum.dxf';
% % [c_Line,c_Poly,c_Cir,c_Arc,c_Poi] = f_LectDxf(filename);
% 
% % polys = c_Poly(:,1);
% % edges = c_Line(:,1);
% % circles = c_Cir(:,1);
% env = environment.load(filename);
% env.obstacles = {};
% env_comb = environment.combine(env);
% % mb.drawPolygon(env_comb.combined);
% bpoly = env_comb.combined;
% bpoly = cellfun(@(x) circshift(x, -1, 1), bpoly, 'uniformoutput', false);

% [P_c, E_r] = mb.polygonConvexDecomposition(bpoly);
% fun_draw_edge = @(e) drawEdge(e, 'linewidth', 2, 'linestyle', '--', 'color', [0 0 0]);
% cellfun(@(x) fun_draw_edge(x.edge), E_r);
% % drawPolygon(P_c, 'linewidth', 2, 'linestyle', '--', 'color', [0 0 0]);
% mb.drawPolygon(bpoly, 'color', [0 0 0], 'linewidth', 2);
% 
% % axis on
% ylim([250 3900]);
% xlim([1150 8400]);

% for num_wpn = 0:50:200
%     for num_sp = 0:50:200
% clear functions
%%
%  num_wpn = 50;
%         num_sp = 50;
clear variables functions;
cla;
num_wpn = 0;
num_sp = 0;
name = 'ConferenceRoom';
workdir = sprintf('tmp/conference_room/%dwpn_%dsp', num_wpn, num_sp);
if exist(workdir, 'dir')
    rmdir(workdir, 's');
end
filename = 'res\floorplans\P1-Seminarraum.dxf';
Configurations.Common.generic(name, workdir);

output_filename = sprintf('../tmp/p1/p1_%d_%d_%s.mat', num_wpn, num_sp, datestr(now,30));

%%% Calculate input and greedy solutions

% processing = Experiments.Diss.create_models(filename, num_wpn, num_sp, name);
% save(output_filename, 'processing');
%%%
config_discretization = Configurations.Discretization.iterative;

environment = Environment.load(filename);
obst_redone = int64([3844 2700; 3300 2700; 3300 1200; 3844 1200; 3844 2700])';
    
environment.obstacles{2}{1} = obst_redone;
%%% Test obstacle point integration
% boundary_vpoly = mb.boost2visilibity(environment.boundary.ring);
% boundary_edges = [boundary_vpoly, circshift(boundary_vpoly, -1, 1)];
% obstacle_vpolys = cellfun(@(x)mb.boost2visilibity(x{1}), environment.obstacles, 'uniformoutput', false);
% obstacle_edges = cellfun(@(x) [x, circshift(x, -1, 1)], obstacle_vpolys,  'uniformoutput', false);
% %%%
% for id_poly = 1:numel(obstacle_edges)
%     %%
%     edges = obstacle_edges{id_poly};
%     for id_edge =  1:size(edges, 1)
%         %%
%         xings = intersectEdges(edges(id_edge,:), boundary_edges);
%         flt_xing = ~isnan(xings(:,1)) & ~isinf(xings(:,1));
%         if any(flt_xing)
%             id_xings = find(flt_xing);
%             for id_xing = id_xings
%             boundary_edges = [boundary_edges(1:id_xing-1, :); 
%                                [ boundary_edges(id_xing, 1:2), xings(id_xing, :) ];
%                                [ xings(id_xing, :), boundary_edges(id_xing, 3:4) ];
%                               boundary_edges(id_xing+1:end, :)];
%             end
% %             fprintf(1, '%d %d\n', id_poly, id_edge);
%         end
%     end
% end
% %%% Merge dublicated points
% edge_length = edgeLength(boundary_edges);
% flt_edge_length = edge_length>10;
% boundary_edges = boundary_edges(flt_edge_length, :);
% 
% environment.boundary.ring = mb.visilibity2boost(boundary_edges(:, 1:2));
% environment.boundary.isplaceable = ones(1, size(environment.boundary.ring, 2));

% options = config.workspace;
%%%

config_discretization.workspace.wall_distance = 200;
% config_discretization.workspace.cell.length = [0 1000];
config_discretization.workspace.positions.additional = num_wpn;
config_discretization.workspace.positions.additional = 0;
config_discretization.sensorspace.poses.additional = 0;
% config_discretization.sensorspace.poses.additional = num_sp+50;

discretization = Discretization.generate(environment, config_discretization);
Discretization.draw(discretization, environment);

%%%
config_quality = Configurations.Quality.diss;
[quality] = Quality.generate(discretization, config_quality);

config_models = [];

input.discretization = discretization;
input.environment = environment;
input.quality = quality;
% input.config.environment = config_environment;
input.config.discretization = config_discretization;
input.config.quality = config_quality;


%%%
maxval = cellfun(@max, input.quality.wss.val);
cla
Discretization.draw(discretization, environment);
axis equal;
xlim([0 4000]);
ylim([800 8500]);
% mb.drawPoint(discretization.wpn);
% Environment.draw(environment);
scatter(input.discretization.wpn(1,:)', input.discretization.wpn(2,:)', [], repmat(maxval, 1,3), 'fill');
%% Calculate Discrete Models
mspqm = Optimization.Discrete.Models.mspqm(discretization, quality, Configurations.Optimization.Discrete.mspqm);

%%
for mnamecell = modelnames'
    mname = mnamecell{1};
    % config = Configurations.Optimization.Discrete.stcm;
    config_models.(mname).name = name;
    if strcmp(mname(1), 'g')
%         solutions.(mname) = Optimization.Discrete.Greedy.(mname)(discretization, quality, config_models.(mname));
    else
        [filenames.(mname)] = Optimization.Discrete.Models.(mname)(discretization, quality, config_models.(mname));
%         solutions.(mname) = fun_solve(filenames.(mname));        
    end
end

% %% Calculate Poly Decomp solutions
% input.rpd.environment_collection = Environment.decompose(environment, Configurations.Environment.rpd);
% input.hertel.environment_collection = Environment.decompose(environment, Configurations.Environment.hertel);
% input.keil.environment_collection = Environment.decompose(environment, Configurations.Environment.keil);
% 
% %%
% input.rpd.discretization_collection = Discretization.split(input.rpd.environment_collection, discretization);
% input.hertel.discretization_collection = Discretization.split(input.hertel.environment_collection, discretization);
% input.keil.discretization_collection = Discretization.split(input.keil.environment_collection, discretization);
% %%
% input.rpd.quality_collection = Quality.split(input.rpd.discretization_collection, quality);
% input.hertel.quality_collection = Quality.split(input.hertel.discretization_collection, quality);
% input.keil.quality_collection = Quality.split(input.keil.discretization_collection, quality);
% 
% %%
% 
% fun_bspqm = @(d, q) Optimization.Discrete.Models.bspqm(d, q, config_models.bspqm);
% fun_mspqm = @(d, q) Optimization.Discrete.Models.bspqm(d, q, config_models.mspqm);
% 
% filenames.rpd.bspqm = cellfun(fun_bspqm, input.rpd.discretization_collection, input.rpd.quality_collection, 'uni', false);
% filenames.hertel.bspqm = cellfun(fun_bspqm, input.hertel.discretization_collection, input.hertel.quality_collection, 'uni', false);
% filenames.keil.bspqm = cellfun(fun_bspqm, input.keil.discretization_collection, input.keil.quality_collection, 'uni', false);
% 
% filenames.rpd.mspqm = cellfun(fun_mspqm, input.rpd.discretization_collection, input.rpd.quality_collection, 'uni', false);
% filenames.hertel.mspqm = cellfun(fun_mspqm, input.hertel.discretization_collection, input.hertel.quality_collection, 'uni', false);
% filenames.keil.mspqm = cellfun(fun_mspqm, input.keil.discretization_collection, input.keil.quality_collection, 'uni', false);
% 
% 
processing.input = input;
processing.filenames = filenames;
processing.solutions = solutions;
% 
return;

%% TEST
num_wpn = 0;
num_sp = 0;
name = 'P1'
filename = 'res\floorplans\P1-Seminarraum.dxf';

[processing] = Experiments.Diss.create_models(filename, num_wpn, num_sp, name);





%     end
% end

%% Solve models

% modelfiles = fieldnames(processing.filenames);
% % modelfiles = {'tekdas'};
% for mfile = modelfiles'
%     modelfile = mfile{1};
%     if ischar(processing.filenames.(modelfile))
%         processing.solutions.(modelfile) = fun_solve(processing.filenames.(modelfile));
%     elseif isstruct(processing.filenames.(modelfile))
%         for split_mfile = fieldnames(processing.filenames.(modelfile))'
%             processing.solutions.(modelfile).(split_mfile{1}) = cellfun(fun_solve,  processing.filenames.(modelfile).(split_mfile{1}), 'uni', false);
%         end
%     end
%     save(output_filename, 'processing');
% end
% return;
%%
% Experiments.Diss.room 
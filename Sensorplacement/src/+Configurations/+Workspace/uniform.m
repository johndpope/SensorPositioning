function ws = uniform()
%% WORKSPACE_CONFIGURATION generates the envelope to store the workspace data

error('Not Implemented');

ws.positions.additional = 0;
ws.cell.length          = [0 1]; 
ws.wall_distance        = 500;
ws.sampling.techniques  = Configurations.Workspace.get_types();
ws.sampling.technique   = ws.sampling.techniques.iterative;

% workspace.number_of_positions = 100;
% workspace.min_position_distance = 300;
% workspace.max_position_distance = 300;
% workspace.seed = 0;
% workspace.grid_position_distance = 200;
% workspace.sampling_technique = common.sampling_techniques.grid; % random, grid
% workspace.x_axis_grid_distance = 100;
% workspace.y_axis_grid_distance = 100;

% workspace.quality.min = 0.6; % [0 .. 1] min quality
% workspace.quality_technique = common.sampling_techniques.uniform;
% workspace.priority = 1; %uniform priority
% workspace.priority_technique = common.sampling_techniques.uniform;
% workspace.coverage = 2; % uniform coverage
% workspace.coverage_technique = common.sampling_techniques.uniform;

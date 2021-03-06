function filename = sco(discretization, quality, config)
%%

import Optimization.Discrete.Models.*
% model = DataModels.optimizationmodel;

config.filename = create_filename(discretization, config);
filename = config.filename;

config = init(config);
% Objective.sum_sensors(discretization, config);
Optimization.Discrete.Models.Objective.sum_sensorcombinations(discretization,config);
% Constraints.two_coverage(discretization, config);
% Optimization.Discrete.Models.Constraints.sameplace(discretization, config);
% Optimization.Discrete.Models.Constraints.sc_backward(discretization, config);
Optimization.Discrete.Models.Constraints.sc_min_quality(discretization, quality, config);
% Binaries.sensor(discretization, config);
Optimization.Discrete.Models.Binaries.sensorcombinations(discretization, config);
config = finish(config);

save(config);

%  = model.ws.coverage();
%  = model.save();
% start_cplex(.model.lastsave);
% s = read_solution(.model.lastsave);
% draw.solution(, s);
return;
%% TEST


clear variables;
format long;
config_environment.filename = 'res\floorplans\P1-Seminarraum.dxf';
config_discretization = Configurations.Discretization.iterative;

environment = Environment.load(config_environment.filename);
Environment.draw(environment);
% options = config.workspace;

config_discretization.positions.additional = 0;
config_discretization.sensorspace.poses.additional = 0;

discretization = Discretization.generate(environment, config_discretization);

config_quality = Configurations.Quality.diss;
[quality] = Quality.generate(discretization, config_quality); 
%%
config_model = Configurations.Optimization.Discrete.mspqm;
config_model.quality.min = 0.58;
config_model.name = 'P1';
% config_model.common.debug = 1;
% config_model.is_relax = false;
filename = Optimization.Discrete.Models.sco(discretization, quality, config_model);
model.filename = filename;
%%
cplex = 'C:\Users\Nico\App\Cplex\cplex\bin\x64_win64\cplex.exe'
solfile = Optimization.Discrete.Solver.cplex.startext(filename, cplex);
sol = Optimization.Discrete.Solver.cplex.read_solution_it(solfile);
%%
solution = DataModels.solution(environment, discretization, quality, model,...
    config_environment, config_discretization, config_quality, config_model,...
    sol);
Evaluation.plots.wss_solution_parsed(solution);
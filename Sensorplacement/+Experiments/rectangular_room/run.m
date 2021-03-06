close all; clear all; fclose all;
%%% diagonal sweep
sensorspace_uniform_position_distance = [800 500 400 350 300 ];%150];
sensorspace_uniform_angle_distance = deg2rad([45 45/2 45/3 45/4 ]); % 45/8 ]);
workspace_grid_position_distance = [800 600 475 350 300 ];%150 ];
%%% xy sweep
% sensorspace_uniform_position_distance = [400 450 450];%150];
% sensorspace_uniform_angle_distance = deg2rad([45/3 45/3 45/4]); % 45/8 ]);
% workspace_grid_position_distance = [475 500 500];%150 ];
%uvariations = uniquecmb(combn(1:4,3));
% svar = combn(1:3,2);
% variations = combn(1:3,2);
% variations = setdiff(variations, uvariations, 'rows');
idv = 1;
variations = repmat((1:1)', 1, 3);
% variations = [1 1 2; 1 2 1; 1 2 2; 2 1 1; 2 1 2; 1 3 1; ];
% variations = [ 1 1 1; 
%     1 2 1 
%     1 1 2
%     2 1 1
%     3 1 1s
%     2 1 2
%     1 2 2
%     2 2 1
%     1 3 1
%     3 2 1];
% variations = [ 2 1 3 ];
% variations = [ 1 1 3 ];
%%%
% function pc = run(pc)
% calculates the two coverage placement with and withoug distance, directional and combined
% constraints
% the following values will be adapted throughout the evaluation process
% close all; clear all; fclose all;
% pc.environment.file =  'res/floorplans/NicoLivingroom_NoObstacles.dxf';
% pc.environment.file =  'res/floorplans/SimpleRectangle.dxf';
% pc.environment.file =  'res/floorplans/SimpleRectangleWithHole.dxf';
% pc.environment.file =  'res/floorplans/SimpleRectangleWithThreeHoles.dxf';
% pc.environment.file =  'res/floorplans/SimpleRectangleWithObstacles.dxf';
% pc.environment.file = 'res/env/rectangle4x4.environment';
% pc.environment.file = 'res/env/simple_poly10_2.environment';
% pc.environment.file = 'res/env/simple_poly10_8.environment';
% pc.environment.file = 'res/env/simple_poly30_52.environment';
num_var = size(variations, 1)*numel(workspace_grid_position_distance);
res.num_positions = nan(num_var, 1);
res.num_sensors = nan(num_var, 1);
res.num_comb = nan(num_var, 1);
res.num_angles = nan(num_var, 1);
res.num_sensorpositions = nan(num_var, 1);
res.pcs = cell(num_var, 1);
%
cnt =1 ;
%%% for idv = 1:size(svar, 1);
for idv = 1:size(variations, 1);
%     idvw = 1;
%     for idvw = 1:numel(workspace_grid_position_distance);
%%
    % 
    fclose all; clear pc; 
    supd = sensorspace_uniform_position_distance(variations(idv,1));
    suad = sensorspace_uniform_angle_distance(variations(idv,2));
    wgpd = workspace_grid_position_distance(variations(idv,3));
%     supd = ;
%     suad = sensorspace_uniform_angle_distance(variations(idv,2));
%     wgpd = workspace_grid_position_distance(variations(idv,3));
pc = processing_configuration(sprintf('rectangular_room-supd%d-wgpd%d-suad%d', supd, wgpd, round(rad2deg(suad))));
% pc.environment.file = 'res/floorplans/P1-Pool.dxf';
pc.environment.file = 'res/env/rectangular_room.environment';
% pc.sensorspace.uniform_position_distance = 500;
% pc.sensorspace.uniform_angle_distance = deg2rad(45);
% pc.workspace.grid_position_distance = 500;
pc.sensorspace.uniform_position_distance = supd;
pc.sensorspace.uniform_angle_distance = suad;
pc.workspace.grid_position_distance = wgpd;
pc.sensors.distance.min = 0;
pc.sensors.distance.max = 6000;
% pc.sensors.quality.distance.max = 2000/pc.sensors.distance.max;
%%%
pc = sensorspace.visibility(pc);
pc = sensorspace.sensorcomb(pc);
% figure,
% title(sprintf('rectangular_room-supd%d-wgpd%d-suad%d', supd, wgpd, round(rad2deg(suad))));
% draw.environment(pc);
% draw.workspace(pc);
% draw.sensorspace(pc);
% pc.model.distance_const.quality.min = 0.9;
res.num_positions(cnt) = pc.problem.num_positions;
res.num_sensors(cnt) = pc.problem.num_sensors;
res.num_comb(cnt) = pc.problem.num_comb;
res.num_sensorpositions(cnt) = pc.problem.num_sensorpositions;
res.pcs{cnt} = pc;
cnt = cnt+1;

%     end
% end
% figure
% scatter(res.num_sensorpositions, res.num_sensors, 20, res.num_comb, 'filled')
% figure
% scatter(res.num_sensors./res.num_sensorpositions, res.num_sensorpositions, 20, res.num_comb, 'filled')
%%
pc = model.ws.coverage(pc);
pc.model.ws_coverage.enable = false;
% %%%
pc = model.ws.sameplace(pc);
pc.model.ws_sameplace.enable = false;
% 
% % pc = model.wss.sc_forward(pc);
% % pc.model.wss_sc_forward.enable = false;
% % pc.model.wss_sc_forward.obj.enable = false;
% 
% % fastest, so far
pc = model.wss.sc_backward(pc);
pc.model.wss_sc_backward.enable = false;
pc.model.wss_sc_backward.obj.enable = false;
% 
% % pc = model.wss.sc_ind(pc);
% % pc.model.wss_sc_ind.enable = false;
% % pc.model.wss_sc_ind.obj.enable = false;
% 
pc.model.wss_qclip.quality.param = 5;
pc.model.wss_qclip.quality.name = pc.quality.types.wss_dd_dop;
pc.model.wss_qclip.quality.min = 0.3;
pc = model.wss.qclip(pc);
pc.model.wss_qclip.enable = false;
pc.model.wss_qclip.obj.enable = false; % disable adding combs

model_type  = pc.model.types.wss_sc_tekdas;
pc.model.(model_type).quality.param = 5;
pc.model.(model_type).quality.name = pc.quality.types.wss_dd_dop;
pc.model.(model_type).quality.min = 0.3;
pc = model.wss.sc_tekdas(pc);
pc.model.(model_type).enable = false;
pc.model.(model_type).obj.enable = true; % disable adding combs

pc.model.wss_qcont.quality.param = 5;
pc.model.wss_qcont.quality.name = pc.quality.types.wss_dd_dop;
pc.model.wss_qcont.quality.min = 0.3;
pc = model.wss.qcont(pc);
pc.model.wss_qcont.enable = false;
pc.model.wss_qcont.obj.enable = false; % disable adding combs

pc.model.wss_qcontinous_sub.quality.param = 5;
pc.model.wss_qcontinous_sub.quality.name = pc.quality.types.wss_dd_dop;
pc.model.wss_qcontinous_sub.quality.min = 0.3;
pc = model.wss.qcontinous_sub(pc);
pc.model.wss_qcontinous_sub.enable = false;

%%%
pc.allsaves = {};

pc.model.ws_coverage.enable = true;
pc = model.save(pc);
pc.allsaves{end+1} = pc.model.lastsave;
%
pc.model.ws_sameplace.enable = true;
pc = model.save(pc);
pc.allsaves{end+1} = pc.model.lastsave;

%%%%%  EXPORT ALL QCONT MODELS
pc.model.wss_qcont.enable = true;
pc.model.ws_coverage.enable = true;
pc.model.ws_sameplace.enable = true;

% % pc.model.wss_sc_forward.enable = false;
% pc.model.wss_sc_forward.enable = true;
% pc = model.save(pc);
% pc.model.wss_sc_forward.enable = false;
% pc.allsaves{end+1} = pc.model.lastsave;

%
pc.model.wss_sc_backward.enable = true;
pc = model.save(pc);
pc.model.wss_sc_backward.enable = false;
pc.allsaves{end+1} = pc.model.lastsave;
%
% pc.model.wss_sc_ind.enable = true;
% pc = model.save(pc);
% pc.model.wss_sc_ind.enable = false;
% pc.allsaves{end+1} = pc.model.lastsave;
pc.model.ws_coverage.enable = false;
pc.model.ws_sameplace.enable = false;
pc.model.wss_qcont.enable = false;
% 
% %%%%%  EXPORT ALL QCONTINOUS_SUP MODELS
pc.model.wss_qcontinous_sub.enable = true;
pc.model.ws_coverage.enable = true;
pc.model.ws_sameplace.enable = true;
% pc.model.wss_sc_forward.enable = false;
% pc.model.wss_sc_forward.enable = true;
% pc = model.save(pc);
% pc.model.wss_sc_forward.enable = false;
% pc.allsaves{end+1} = pc.model.lastsave;

%
% % pc.model.wss_sc_forward.enable = false;
pc.model.wss_sc_backward.enable = true;
pc = model.save(pc);
pc.model.wss_sc_backward.enable = false;
pc.allsaves{end+1} = pc.model.lastsave;
%
% pc.model.wss_sc_ind.enable = true;
% pc = model.save(pc);
% pc.model.wss_sc_ind.enable = false;
% pc.allsaves{end+1} = pc.model.lastsave;

pc.model.ws_coverage.enable = false;
pc.model.ws_sameplace.enable = false;
pc.model.wss_qcontinous_sub.enable = false;
% pc.model.wss_qcontinous_sub.enable = false;
%%%

%%%%%  EXPORT ALL QCLIP MODELS
pc.model.wss_qclip.enable = true;
pc.model.ws_coverage.enable = true;
pc.model.ws_sameplace.enable = true;
% pc.model.wss_sc_forward.enable = true;
% pc = model.save(pc);
% pc.model.wss_sc_forward.enable = false;
% pc.allsaves{end+1} = pc.model.lastsave;

%
% pc.model.ws_coverage.st.enable = true;
pc.model.wss_sc_backward.enable = true;
pc = model.save(pc);
pc.model.wss_sc_backward.enable = false;
% pc.model.ws_coverage.st.enable = true;
pc.allsaves{end+1} = pc.model.lastsave;
%
% pc.model.wss_sc_ind.enable = true;
% pc = model.save(pc);
% pc.model.wss_sc_ind.enable = false;
% pc.allsaves{end+1} = pc.model.lastsave;
pc.model.ws_coverage.enable = false;
% pc.model.ws_sameplace.enable = false;
pc.model.wss_qclip.enable = false;

%%%%%  EXPORT TEKDAS MODEL
pc.model.wss_sc_tekdas.enable = true;
pc = model.save(pc);
pc.allsaves{end+1} = pc.model.lastsave;
pc.model.wss_sc_tekdas.enable = false;


%%%%%  EXPORT ALL APPROXIMATION MODELS
% pc.model.ws_coverage.enable = false;
% pc.model.ws_sameplace.enable = false;
pc.model.wss_qclip.enable = true;
pc.model.wss_qclip.obj.enable = true;
pc = model.save(pc);
pc.allsaves{end+1} = pc.model.lastsave;

save([pc.common.workdir filesep pc.name '.mat'], 'pc');

%     
%     idx = 1:numel(pc.allsaves);
%     for fmodel = pc.allsaves(idx)
%         fmodel = fmodel{1};
%         [~, fmodelbase] = fileparts(fmodel);
%         fprintf(1, '---- solving %s ----', fmodel)
%         solver.cplex.startext(fmodel);
%     end

end



return;



%%
idx = 1:numel(pc.allsaves);
for fmodel = pc.allsaves(idx)
    fmodel = fmodel{1}
    solver.cplex.startext(fmodel);
end
%%

sol = {};
log = {};
for fmodel = pc.allsaves(idx)
    fmodel = fmodel{1}
    sol{end+1} = solver.cplex.read_solution_it(fmodel);
    log{end+1} = solver.cplex.read_log(fmodel);
    for fn = fieldnames(log{end})'
        fn = fn{1};
        sol{end}.(fn) = log{end}.(fn);
    end
end
%%
close all;
for ids = 1:numel(sol)
    figure, draw.ws_solution(pc, sol{ids})
end

%%
pc.model.wss_qcont.enable = false;

pc.model.wss_qcontinous_sub.enable = false;

pc = model.save(pc);
% cpx = solver.cplex.startext(pc.model.lastsave);

%%

pc = model.save(pc);
% cpx2 = solver.cplex.startext(pc.model.lastsave);

pc.model.wss_sc_forward.obj.enable = false;


pc = model.save(pc);
% cpx3 = solver.cplex.startext(pc.model.lastsave);
%%
pc = model.ws.coverage(pc);
pc = model.ws.sameplace(pc);
pc.model.wss_sc_ind.obj.enable = false;
pc = model.wss.sc_ind(pc);

pc.model.wss_qcontinous.quality.param = 500;
pc.model.wss_qcont.quality.name = pc.quality.types.wss_dd_dop;
pc = model.wss.qcont(pc);
pc = model.save(pc);
% cpx3 = solver.cplex.startext(pc.model.lastsave);

% cpx = solver.cplex.start(pc.model.lastsave);
% if ~isempty(cpx.Solution)
%      draw.ws_solution(pc, cpx.Solution);
% %     draw.ws_solution(pc, cpx.Solution);
% %     draw.wss_wp_solution(pc, cpx.Solution);
% %     draw.ws_wp_solstats(pc, cpx.Solution);
%     
% end

%%


%% verbose
% if nargin < 1
    %%
 for file = files'
    for supd = sensorspace_uniform_position_distance
        for suad = sensorspace_uniform_angle_distance
            for wgpd = workspace_grid_position_distance
                
    [path, name, ext] = fileparts(file{1});
    pc = processing_configuration(name);
    pc.environment.file = file{1};               

pc.sensorspace.uniform_position_distance = 500;
pc.sensorspace.uniform_angle_distance = deg2rad(45/2);
pc.workspace.grid_position_distance = 500;
pc.sensors.distance.min = 0;
pc.sensors.distance.max = 6000;
pc.model.directional_sub.quality.min = 0.9;
pc.model.directional_const.quality.min = 0.9;
pc.model.directional_comb.quality.min = 0.9;
pc.model.directional_2comb.quality.min = 0.9;
% pc.common.debug = true;
pc.model.output.current = false;

pc = model.coverage(pc);
pc = model.save(pc);

pc = model.add.sameplace(pc);
pc = model.save(pc);

pc = model.add.directidonal_sub(pc);
pc = model.save(pc);

pc = model.clear(pc);
pc = model.directional_comb(pc);
pc = model.save(pc);

pc = model.clear(pc);
pc = model.coverage(pc);
pc = model.add.directional_const(pc);
pc = model.save(pc);

pc = model.clear(pc);
pc = model.directional_2comb(pc);
pc = model.save(pc);


            end 
        end
    end
end
%%
pc = model.coverage(pc);
pc = model.add.directional_const(pc);
pc = model.save(pc);
%%
pc = model.coverage(pc);
pc = model.add.directidonal_sub(pc);
pc = model.save(pc);
%%
pc = model.add.sameplace(pc);
pc = model.save(pc);  
%%%
pc = model.add.combinations(pc);
pc = model.save(pc);
%%%
pc = model.add.directidonal_sub(pc);
pc = model.save(pc);
%%
c = Cplex('tst');
c.readModel(pc.model.file.lastsave);
c.solve();
draw.solution(pc, c.Solution);
%%
pc = model.add.sameplace(pc);
pc = model.save(pc);  

%%
pc = model.add.combinations(pc);
pc = model.save(pc);
%%
pc = model.add.directidonal_sub(pc);
pc = model.save(pc);

%%
pc = model.coverage(pc);
model.write(pc);

%
pc = model.add.sameplace(pc);
model.write(pc);
%
pc = model.add.combinations(pc);
model.write(pc);
%%
pc = model.add.directional(pc);
model.write(pc);
%%
pc = model.distance(pc);
model.write(pc);
pc = model.add_sameplace(pc);
model.write(pc);
pc = model.add_directional(pc);
model.write(pc);


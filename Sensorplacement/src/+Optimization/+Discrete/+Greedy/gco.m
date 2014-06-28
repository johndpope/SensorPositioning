function [ solution ] = gco( discretization, quality, config )
%% [ solution ] = gsco( discretization, quality, config )
% uses the greedy combined selection strategy to calculate a min quality
% two coverage



is_wpn_covered = false(1, discretization.num_positions);
% sensors_selected = [];
sc_selected = [];
sc_wpn_minq = uint8(zeros(discretization.num_comb, discretization.num_positions));
% qmin = config.quality.min;


%%% min quality sc_wpn_minq
for idw = 1:discretization.num_positions
    ids = discretization.sc_wpn(:,idw)>0;
    wp_comb_flt = quality.wss.val{idw}>=config.quality.min;
    num_pairs = 1;
    %% no sensor has quality, relax model
    if sum(wp_comb_flt) == 0 %&& config.is_relax
        warning('\n relaxing model for point %d\n', idw);
        for num_pairs = [2, 4, 8]
            wp_comb_flt = (quality.wss.val{idw} >= config.quality.min/num_pairs);
            if sum(wp_comb_flt) > num_pairs
                write_log('\nmodel for point %d was sucessful relaxed to %d\n', idw, num_pairs);
                break;
            end
        end
        if num_pairs == 1
            error('workspace point relaxed to max, min quality not guaranteed');
            %             num_pairs = numel(wp_comb_flt);
            %             wp_comb_flt = >0;
        end
    end
    
    sc_wpn_minq(ids, idw) = uint8(wp_comb_flt*num_pairs);
end


%%%
sensors_selected = [];
wpn_remaining = double(max(sc_wpn_minq, [], 1));
vm_tmp = discretization.vm;
%%
while any(wpn_remaining > 0)
    %%
    sumq = sum(sc_wpn_minq>0, 2);
    [num_wpn_sc id_sc] = max(sumq);
        
    if ~isempty(sensors_selected)
        % R and S are synonyms for the first and second sensor selection arrays
        [R ids_R] = sort(sum(vm_tmp(sensors_selected,:), 2), 1, 'descend');
        ids_R = sensors_selected(ids_R);
        id_R = 1;
        idRmax = ids_R(id_R);
        flt_idRmax = find(any(discretization.sc==uint16(idRmax), 2));
        [num_wpn_s id_s] = max(sum(sc_wpn_minq(flt_idRmax, :)>0, 2));
        id_s = flt_idRmax(id_s);
        %%
        while id_R+1 <= numel(ids_R) && num_wpn_s < R(id_R+1)
            id_R = id_R + 1;
            idRmaxTest = ids_R(id_R);
            flt_idRmaxTest = find(any(discretization.sc==uint16(idRmaxTest), 2));
            [num_wpn_s_test id_s_test] = max(sum(sc_wpn_minq(flt_idRmaxTest, :)>0, 2));
            id_s_test = flt_idRmaxTest(id_s_test);
            %%
            if num_wpn_s_test > num_wpn_s
                id_s = id_s_test;
                num_wpn_s = num_wpn_s_test;
            end
        end
    else
        num_wpn_s = 0;
    end
    
    if num_wpn_sc > num_wpn_s        
        sc_sel_id = id_sc;
    else
        sc_sel_id = id_s;
    end
    sc_selected = discretization.sc(sc_sel_id, :);
    wpn_covered = sc_wpn_minq(sc_sel_id, :)>0;
    wpn_remaining = wpn_remaining - wpn_covered;
    vm_tmp(:, wpn_remaining==0) = 0;
    sensors_selected = unique([sensors_selected(:); sc_selected(:)]);
    sc_selected = comb2unique(sensors_selected);
    %%
    sc_wpn_minq(sc_selected, :) = 0;
    sc_wpn_minq(:, wpn_covered) = sc_wpn_minq(:, wpn_covered)-1;
    %     num_wpn_covered = num_wpn_covered + sum(wpn_ids);
end

%% return result in solution form
sensors_selected = unique(discretization.sc(sc_selected, :));
solution = [];
solution.x = sensors_selected;
% mb.drawPoint

return;
%% TEST
clear variables;
format long;
cplex = 'C:\Users\Nico\App\Cplex\cplex\bin\x64_win64\cplex.exe'
fun_solve = @(filename) Optimization.Discrete.Solver.cplex.startext(filename, cplex);
filename = 'res\floorplans\P1-Seminarraum.dxf';
config_discretization = Configurations.Discretization.iterative;

environment = Environment.load(filename);
Environment.draw(environment, false);
% options = config.workspace;

config_discretization.positions.additional = 0;
config_discretization.sensorspace.poses.additional = 0;

discretization = Discretization.generate(environment, config_discretization);

config_quality = Configurations.Quality.diss;
[quality] = Quality.generate(discretization, config_quality);

filenames = [];

config_models = [];
modelnames = Configurations.Optimization.Discrete.get_types();

%%%
% mname = modelnames.gsco;
config = Configurations.Optimization.Discrete.gco;
% config = Configurations.Optimization.Discrete.stcm;
config.name = 'P1';
%%%
solution = Optimization.Discrete.Greedy.gco(discretization, quality, config);
hold on;
mb.drawPoint(discretization.sp(1:2,solution.x));
mb.drawPolygon(discretization.vfovs(solution.x));


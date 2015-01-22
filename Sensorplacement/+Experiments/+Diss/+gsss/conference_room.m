%%
close all;
clear variables;
% num_sp = 0:20:200
num_wpns = 0;
num_sps =  0:10:100;
% num_wpns = 0:10:500;
% num_sps =  0:10:500;
size = [325 420];
pos = [0 0];
% gco = cell(numel(num_sps), numel(num_wpns));
for id_wpn = 1:numel(num_wpns)
    for id_sp = 1:numel(num_sps)
        num_wpn = num_wpns(id_wpn);
        num_sp = num_sps(id_sp);
        
        %%
%                 num_wpn = 0;
%                 num_sp = 0;
        
        input = Experiments.Diss.conference_room(num_sp, num_wpn);% true);
        %%%
        input.config.optimization = Configurations.Optimization.Discrete.gsss;
        input.config.optimization.name = input.name;
        output_filename = sprintf('tmp/conference_room/gsss/gsss__%d_%d_%d.mat', input.discretization.num_sensors, input.discretization.num_positions, input.discretization.num_comb);
        solution_coverage = Optimization.Discrete.Greedy.gssc(input.discretization);
        %%%
        input.solution_coverage = solution_coverage;
        solution = Optimization.Discrete.Greedy.gsss(input.discretization, input.quality, input.solution_coverage, input.config.optimization);
        input.solution = solution;
        [input.solution.discretization, input.solution.quality] = Evaluation.filter(solution, input.discretization, input.config.discretization);
%         save(output_filename, 'input');
        %%
                figure;
                Discretization.draw(input.discretization, input.environment);
                hold on;
                Discretization.draw_wpn_max_qualities(input.solution.discretization, input.solution.quality);
                Discretization.draw_vfos(input.discretization, input.solution);
                allqvall = cell2mat(input.solution.quality.wss.val);
                title(sprintf('Num SP %d, Sel SP %d, Num WPN %d\n MinQ %.4g, MaxQ %.4g,\n Mean/dQ %.4g %.4g SumQ %.4g ',...
                    input.discretization.num_sensors, input.solution.discretization.num_sensors, input.discretization.num_positions,...
                    min(allqvall), max(allqvall), mean(allqvall), median(allqvall), sum(allqvall)));
                set(gcf, 'Position', [pos size]);
                pos(1) = pos(1)+325;
                if pos(1) > 1590
                    pos = [0 500];
                end
        
    end
end

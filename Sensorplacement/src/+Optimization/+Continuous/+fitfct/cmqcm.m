function [ qval, ply_remaining ] = cmqcm( sp, ply, ply_to_cover, contours )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
bpolyclip_options = Configurations.Bpolyclip.vfov;
bpolyclip_batch_options = Configurations.Bpolyclip.combine(bpolyclip_options, true);
% config = Configurations.Discretization.iterative;

%%%
vis_polys = visilibity(sp(1:2, :), ply, 10, 10, 0);
vis_empty_flt = cellfun(@isempty, vis_polys);
% comb_ids = comb_ids(~vis_empty_flt, :);
%%%
vis_polys = cellfun(@int64, vis_polys(~vis_empty_flt), 'uniformoutput', false);
sp = sp(:, ~vis_empty_flt);

comb_ids = comb2unique(1:size(sp, 2));

%%%
% calculates the sensor fov, the inner ring is defined by the min distance and the outer ring by
% the max distance. Since both rings have the same orientation, the inner is flipped to get a
% polygon
default_annulus = [0 10000 9928 9715 9362 8876 8262 7531 6691 0;
                   0 0 1194 2371 3514 4606 5633 6579 7431 0 ];
% default_annulus = mb.createAnnulusSegment(0,0,config.sensor.distance(1), config.sensor.distance(2), 0, config.sensor.fov, config.sensorspace.ringvertices);
fun_sensorfov = @(x,y,theta) int64(bsxfun(@plus, ([cos(theta) -sin(theta); sin(theta)  cos(theta)]*default_annulus), [x;y]));
sensor_fovs = arrayfun(fun_sensorfov, sp(1,:), sp(2,:), sp(3,:), 'uniformoutput', false);

%%%
combined_polys = [vis_polys, sensor_fovs];
% combine vis_polys and sensor_fovs to use batch processing
poly_combine_jobs = mat2cell([1:numel(sensor_fovs); numel(vis_polys)+(1:numel(sensor_fovs))]', ones(numel(sensor_fovs),1), 2);
%%%
[sensor_visibility_polygons] = bpolyclip_batch(combined_polys, 1, poly_combine_jobs, bpolyclip_batch_options );

svp = cellfun(@(x) x{1}{1}, sensor_visibility_polygons, 'uniformoutput', false);
%%%
% calculate distances, move contours to positions and mirror them on the direct connection 
distances = sqrt(sum((sp(1:2, comb_ids(:,1))-sp(1:2, comb_ids(:,2))).^2, 1));
flt_zero = distances>0;

comb_ids = comb_ids(flt_zero, :);
distances = distances(flt_zero);

contour_ids = round(distances/100);
%%%
% calculate angle between sp and place contours
sc_angles = mb.angle2PointsFast(sp(1:2, comb_ids(:,1)),sp(1:2, comb_ids(:,2)));
% middle_pt = sp(1:2, comb_ids_flt(:,1))+0.5*(-sp(1:2, comb_ids_flt(:,1))+sp(1:2, comb_ids_flt(:,2)));
contour_plys = contours.b_chulls(contour_ids);

fun_transform = @(ply,x,y, theta) int64(bsxfun(@plus, [x;y], [cos(theta) -sin(theta); sin(theta)  cos(theta)]*double(ply)));
contour_plys_chng = arrayfun(@(p,x,y, ang) {fun_transform(p{1}{1}, x, y,ang), fun_transform(p{1}{2}, x, y,ang)},...
    contour_plys(:), sp(1, comb_ids(:,1))', sp(2, comb_ids(:,1))',  sc_angles(:), 'uniformoutput', false);



%%%
sensor_visibility_polygons = [sensor_visibility_polygons{:}];
vfov_qval_polys = [sensor_visibility_polygons{:}, contour_plys_chng{:}];
num_vfovs = numel(sensor_visibility_polygons);
num_comb = size(comb_ids, 1);
comb_contour_ids = [(0:num_comb-1)'*2, (0:num_comb-1)'*2+1]+1;
% %%%
% poly_combine_jobs = mat2cell(comb_ids, ones(num_comb,1), 2);
% 
% vfov_int_ply = bpolyclip_batch(sensor_visibility_polygons, 1, poly_combine_jobs, bpolyclip_batch_options );

%%%
poly_combine_jobs = mat2cell([comb_ids, num_vfovs+comb_contour_ids(:,1); comb_ids, num_vfovs+comb_contour_ids(:,2)], ones(2*num_comb,1), 3);

bvfov_qval_intersections = bpolyclip_batch(vfov_qval_polys, 1, poly_combine_jobs, bpolyclip_batch_options );
%%
flt_nonempty = cellfun(@(x) ~isempty(x), bvfov_qval_intersections);
bvfov_qval_intersections = bvfov_qval_intersections(flt_nonempty);
bvfov_qval_intersections = [bvfov_qval_intersections{:}];
%%
covered_ply = bpolyclip_batch(bvfov_qval_intersections, 3, {1:numel(bvfov_qval_intersections)}, bpolyclip_batch_options );
covered_ply = [covered_ply{:}];
covered_ply_merged = cellfun(@(cp) mb.mergePoints(cp, 10), covered_ply, 'uniformoutput', false);

[ply_remaining, area_remaining] = bpolyclip(ply_to_cover, covered_ply_merged, 0, 1, 10, 1);
%%
qval = area_remaining/mb.polygonArea(ply_to_cover);

return;
%%
cla;
Environment.draw(input.environment, false);
mb.drawPolygon(sensor_visibility_polygons);
for idi = 1:numel(vfov_int_ply)
   h = mb.drawPolygon(vfov_int_ply{idi}, 'color', 'g');
   disp(idi);
   pause;
   delete(h);
end
%%
cla;
Environment.draw(input.environment, false);
mb.drawPolygon(sensor_visibility_polygons);

for idj = 1:numel(poly_combine_jobs)
   h = mb.drawPolygon(vfov_qval_polys(poly_combine_jobs{idj}(1)), 'color', 'g');
   h3 = mb.drawPolygon(vfov_qval_polys(poly_combine_jobs{idj}(2)), 'color', 'y');
   h2 = mb.drawPolygon(vfov_qval_polys(poly_combine_jobs{idj}(3)), 'color', 'r');
   h1 = mb.drawPolygon(bvfov_qval_intersections{idj}, 'color', 'm');
   disp(idj);
   xlim([-1000 5000]);
   ylim([0 10000]);
   pause;
   delete([h(:); h1(:); h2(:); h3(:)]);
end
%%
cla;
Environment.draw(input.environment, false);
mb.drawPolygon(sensor_visibility_polygons);
for idp = 1:numel(bvfov_qval_intersections)
   h = mb.drawPolygon(bvfov_qval_intersections{idp}, 'color', 'g');
   disp(idp);
   pause;
end
%%
cla;
Environment.draw(input.environment, false);
mb.drawPolygon(sensor_visibility_polygons);
for idc = 1:numel(contour_plys_chng)
    h = mb.drawPolygon(contour_plys_chng{idc}, 'color', 'g');
disp(idc);pause;
    delete(h);
end

%%
clear variables;
input = Experiments.Diss.conference_room(50, 50);
% sol = load('tmp/conference_room/gco/gco__0_0.mat');
sol = load('tmp/conference_room/gco/gco__50_50.mat');
input.solution = sol.input.solution;
env = load('tmp/conference_room/environment/environment.mat');
ply = env.environment.combined;
ply_to_cover = bpolyclip(env.environment.combined, env.environment.occupied, 0, 1, 100, 1); 

c = load('tmp/contours/contours.mat');
contours = c.contours;
sp = input.discretization.sp(:, input.solution.sensors_selected);

[qval, ply_remaining] = Optimization.Continuous.cmqcm(sp, ply, ply_to_cover, contours);
mb.drawPolygon(ply_remaining, 'color', 'g');

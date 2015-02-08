function [ qval ] = cmqm( x, phi )
%cmqcm The first call of this function does the initialization, thus it has to 
% contain an initialization struct x containing:
% .ply = the combined polygon 
% .ply_to_cover = the combined polygon without occupied
% .contours = the contours lookup
% .placeable_edges = all edges where sensors can be placed

persistent bpolyclip_options bpolyclip_batch_options is_initialized default_annulus ...
    fun_sensorfov fun_transform area_to_cover ply ply_to_cover contours placeable_edges ...
    placeable_edgelenghts_scale placeable_edgelenghts_lut placeable_edges_dir config

if isempty(is_initialized) || nargin < 2
ply = x.ply;
ply_to_cover = x.ply_to_cover;
contours = x.contours;
placeable_edges = x.placeable_edges;
    
bpolyclip_options = Configurations.Bpolyclip.vfov;
bpolyclip_batch_options = Configurations.Bpolyclip.combine(bpolyclip_options, true);

default_annulus = [0 10000 9928 9715 9362 8876 8262 7531 6691 0;
                   0 0 1194 2371 3514 4606 5633 6579 7431 0 ];
fun_sensorfov = @(x,y,theta) int64(bsxfun(@plus, ([cos(theta) -sin(theta); sin(theta)  cos(theta)]*default_annulus), [x;y]));

fun_transform = @(ply,x,y, theta) int64(bsxfun(@plus, [x;y], [cos(theta) -sin(theta); sin(theta)  cos(theta)]*double(ply)));
config = Configurations.Discretization.iterative;
area_to_cover = mb.polygonArea(ply_to_cover);


%%
placeable_edgelenghts_scale = x.placeable_edgelenghts_scale;
placeable_edgelenghts_lut = x.placeable_edgelenghts_lut;
placeable_edges_dir = x.placeable_edges_dir;

wpn = x.wpn;
phi = x.phi;
x = x.x;
%%
is_initialized = true;
end

ids_before = arrayfun(@(x) sum(placeable_edgelenghts_lut<=x), x);
dist_to_first = (x-placeable_edgelenghts_lut(ids_before))*placeable_edgelenghts_scale;
gsp = placeable_edges(ids_before, 1:2) + bsxfun(@times, placeable_edges_dir(ids_before,:), dist_to_first);
sp = [gsp'; phi(:)'*(2*pi)];
%%
% bpolyclip_options = Configurations.Bpolyclip.vfov;
% bpolyclip_batch_options = Configurations.Bpolyclip.combine(bpolyclip_options, true);
% config = Configurations.Discretization.iterative;

% input = Experiments.Diss.conference_room(0, 0);
% sp = input.discretization.sp;
% wpn = input.discretization.wpn;
% ply = input.environment.combined;
%%%
vis_polys = visilibity(sp(1:2, :), ply, 10, 10, 0);
vis_empty_flt = cellfun(@isempty, vis_polys);
%%%
vis_polys = cellfun(@int64, vis_polys(~vis_empty_flt), 'uniformoutput', false);
sp = sp(:, ~vis_empty_flt);

%%
% calculates the sensor fov, the inner ring is defined by the min distance and the outer ring by
% the max distance. Since both rings have the same orientation, the inner is flipped to get a
% polygon
% default_annulus = [0 10000 9928 9715 9362 8876 8262 7531 6691 0;
%                    0 0 1194 2371 3514 4606 5633 6579 7431 0 ];
% default_annulus = mb.createAnnulusSegment(0,0,config.sensor.distance(1), config.sensor.distance(2), 0, config.sensor.fov, config.sensorspace.ringvertices);
% fun_sensorfov = @(x,y,theta) int64(bsxfun(@plus, ([cos(theta) -sin(theta); sin(theta)  cos(theta)]*default_annulus), [x;y]));
sensor_fovs = arrayfun(fun_sensorfov, sp(1,:), sp(2,:), sp(3,:), 'uniformoutput', false);

%%
combined_polys = [vis_polys, sensor_fovs];
% combine vis_polys and sensor_fovs to use batch processing
poly_combine_jobs = mat2cell([1:numel(sensor_fovs); numel(vis_polys)+(1:numel(sensor_fovs))]', ones(numel(sensor_fovs),1), 2);
%%%
[sensor_visibility_polygons] = bpolyclip_batch(combined_polys, 1, poly_combine_jobs, bpolyclip_batch_options );

svp = cellfun(@(x) x{1}{1}, sensor_visibility_polygons, 'uniformoutput', false);

sp_wpn_cell = cellfun(@(x) binpolygon(wpn, x, 1), svp, 'uniformoutput', false);
sp_wpn = cell2mat(sp_wpn_cell');

dmax = config.sensor.distance(2);
num_wpn = size(wpn, 2);
maxvals = zeros(num_wpn, 1);
%%
for idw = 1:size(wpn, 2)
    %%
    ids = find(sp_wpn(:,idw));
    sc = comb2unique(ids);

    s1_idx = sc(:,1);
    s2_idx = sc(:,2);
    %%
    q_sin = sin(mb.angle3PointsFast(sp(1:2, s1_idx), double(wpn(:,idw)), sp(1:2, s2_idx)))';    
    ds1 = mb.distancePoints(wpn(:,idw), sp(1:2, s1_idx));
    ds2 = mb.distancePoints(wpn(:,idw), sp(1:2, s2_idx));
    
    dn1 = ds1./dmax;
    dn2 = ds2./dmax;
    
    v = 1-((dn1'.*dn2')./(q_sin));
    flt_vis = dn1>1|dn2>1;
    v(flt_vis) = [];
    
    maxvals(idw) = max(v);
end


is_penalty = maxvals < 0.45;
penalty = sum(is_penalty)*num_wpn;
qval = maxvals(~is_penalty)+penalty;


return
%%
load tmp\conference_room\gco.mat
clearvars -except gco;
clear functions;
sol = gco{10, 10};
input = Experiments.Diss.conference_room(sol.num_sp, sol.num_wpn);
lut = Optimization.Continuous.prepare_lut(input, sol);
lut.wpn = input.discretization.wpn;
%%
Optimization.Continuous.fitfct.cmqm(lut)
%%
x = lut.x+0.01;
phi = lut.phi+0.5;
Optimization.Continuous.fitfct.cmqm(x, phi)



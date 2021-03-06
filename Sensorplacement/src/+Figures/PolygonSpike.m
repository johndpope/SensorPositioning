close all;
clear all;
%%
cla;
axis equal
hold on;
% axis off
xlim([-300 8300]);
ylim([-300 5300]);

room = [1000 0; 8000 0; 8000 5000; 1000 5000; 1000, 0];
obstacle = flipud([3600 1000; 4300 1000; 4300 3000; 3600 3000; 3600 1000]);
obstacle2 = flipud([5200 3000; 7000 3000; 7000 3500; 5200 3500; 5200 3000]);

env = bpolyclip(room', obstacle', 0, true);
env = bpolyclip(env, obstacle2', 0, true);
mb.drawPolygon(env, 'color', 'k', 'linewidth', 2);

pixel_fov = 48;
distance = 4000;
pix_offset = 66;
sensor.position = [4000 0];

pixfov = circleArcToPolyline([sensor.position, distance, pix_offset, pixel_fov], 16);
pixfov = [sensor.position;pixfov];
drawPolygon(pixfov, 'color', 'k');
fillPolygon(pixfov, zeros(1,3), 'facealpha', 0.3);
% fov_label = circleArcToPolyline([sensor.position, distance+200, pix_offset, pixel_fov], 128);
% drawPolyline(fov_label, 'color', 'k');

%%%
sensor.position = int64([4000 0]);
env_1 = int64(room');
env_2 = int64(obstacle');
env_3 = int64(obstacle2');
env_int = {env_1, env_2, env_3};
res = visilibity([4000; 0], env_int, 10, 10, 0);
res_vfov = bpolyclip(int64(pixfov'), int64(res{1}), true, 10, 1);
mb.fillPolygon(res_vfov, zeros(1,3), 'facealpha', 0.5);
mb.drawPoint(res_vfov{1}{1}, 'color', 'k', 'markersize', 4, 'markerfacecolor', 'w');

text(3700, -300, '$v_1$');
text(3000, 400, '$e_1$');
text(4300, 400, '$e_n$');
text(1800, 4000, '$v_2$');
text(5300, 2600, '$v_n$');

%%%
Figures.makeFigure('PolygonSpike');
% matlab2tikz('export/PolygonSpike.tikz', 'parseStrings', false);


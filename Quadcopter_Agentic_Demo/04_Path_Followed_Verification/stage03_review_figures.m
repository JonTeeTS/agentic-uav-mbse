function [animation, plots] = stage03_review_figures(out)
%STAGE03_REVIEW_FIGURES Frame the native UAV Animation and show flight data.
folder = fileparts(mfilename('fullpath'));
evidence = fullfile(folder, 'flight_evidence');
if ~isfolder(evidence), mkdir(evidence); end
animation = findall(groot, 'Type', 'figure', ...
    'Tag', 'UAVAnimationVisualization_MVP_AI:11');
if numel(animation) ~= 1
    error('QuadMVP:AnimationMissing', 'Expected the live UAV Animation figure. Run the stage-03 model first.');
end
set(animation, 'Name', 'Stage 03 - UAV Animation', 'Color', 'white', ...
    'Position', [40 190 1320 1000]);
ax = findall(animation, 'Type', 'axes');
ax = ax(1);
view(ax, 42, 25);
axis(ax, 'equal');
xlim(ax, [-0.8 2.8]); ylim(ax, [-0.8 2.8]); zlim(ax, [-0.25 2.8]);
set(ax, 'Projection', 'orthographic', 'FontSize', 12);
grid(ax, 'on'); box(ax, 'on');
xlabel(ax, 'East (m)'); ylabel(ax, 'North (m)'); zlabel(ax, 'Up (m)');
title(ax, {'Autonomous quadcopter flight', ...
    'NED position + body-to-NED quaternion input; ENU display'}, 'FontSize', 15);
delete(findall(ax, 'Tag', 'Stage03WaypointLabel'));
p = quad_mvp_parameters();
for index = 1:3
    text(ax, p.Waypoints(index, 2) + 0.08, p.Waypoints(index, 1) + 0.08, ...
        -p.Waypoints(index, 3) + 0.1, sprintf('WP%d', index), ...
        'Color', [0.05 0.2 0.65], 'FontWeight', 'bold', 'FontSize', 12, ...
        'Tag', 'Stage03WaypointLabel');
end
drawnow;
exportgraphics(animation, fullfile(evidence, 'flight_3d_final.png'), 'Resolution', 150);
savefig(animation, fullfile(evidence, 'flight_3d_final.fig'));

position = stage03_rows(out.visualizationState.PositionNED);
reference = stage03_rows(out.guidanceReference.PositionNED);
time = out.visualizationState.PositionNED.Time;
referenceTime = out.guidanceReference.PositionNED.Time;
modes = stage03_rows(out.telemetryFlightMode.Mode);
oldPlots = findall(groot, 'Type', 'figure', 'Tag', 'Stage03FlightPlots');
delete(oldPlots);
plots = figure('Name', 'Stage 03 - Mission position and trajectory', ...
    'Tag', 'Stage03FlightPlots', 'Color', 'white', 'Position', [1400 190 1100 1000]);
layout = tiledlayout(plots, 2, 2, 'Padding', 'compact', 'TileSpacing', 'compact');
title(layout, sprintf('Actual simulated flight | %.2f s | NED model, ENU 3D view', out.tout(end)), ...
    'FontSize', 16, 'FontWeight', 'bold');

a = nexttile(layout);
plot(a, position(:, 2), position(:, 1), '-', 'Color', [0.15 0.2 0.25], 'LineWidth', 1.8);
hold(a, 'on');
scatter(a, p.Waypoints(:, 2), p.Waypoints(:, 1), 65, [0.1 0.35 0.9], 's', 'filled');
scatter(a, position(1, 2), position(1, 1), 45, [0.1 0.5 0.25], 'filled');
scatter(a, position(end, 2), position(end, 1), 55, [0.9 0.05 0.04], 'filled');
for index = 1:3
    text(a, p.Waypoints(index, 2) + 0.08, p.Waypoints(index, 1) + 0.08, sprintf('WP%d', index));
end
axis(a, 'equal'); xlim(a, [-0.5 2.5]); ylim(a, [-0.5 2.5]); grid(a, 'on');
xlabel(a, 'East (m)'); ylabel(a, 'North (m)'); title(a, 'Actual horizontal trajectory');
legend(a, {'Trajectory', 'Targets', 'Start', 'Landing stop'}, 'Location', 'southoutside');

a = nexttile(layout);
plot(a, time, -position(:, 3), 'Color', [0.9 0.05 0.04], 'LineWidth', 1.8);
hold(a, 'on');
plot(a, referenceTime, -reference(:, 3), '--', 'Color', [0.2 0.35 0.7], 'LineWidth', 1.2);
grid(a, 'on'); xlabel(a, 'Time (s)'); ylabel(a, 'Altitude (m)');
title(a, 'Takeoff, cruise, and landing approach');
legend(a, {'Actual altitude', 'Commanded altitude'}, 'Location', 'southoutside');

a = nexttile(layout);
plot(a, time, position(:, 1), 'LineWidth', 1.5); hold(a, 'on');
plot(a, time, position(:, 2), 'LineWidth', 1.5);
grid(a, 'on'); xlabel(a, 'Time (s)'); ylabel(a, 'Position (m)');
title(a, 'Position returned to the system');
legend(a, {'North', 'East'}, 'Location', 'southoutside');

a = nexttile(layout);
stairs(a, out.telemetryFlightMode.Mode.Time, modes, 'Color', [0.2 0.35 0.7], 'LineWidth', 1.8);
ylim(a, [-0.3 6.4]); yticks(a, 0:6);
yticklabels(a, {'Ground','Takeoff','WP1','WP2','WP3','Landing','Landed'});
grid(a, 'on'); xlabel(a, 'Time (s)'); title(a, 'Telemetered mission modes');
set(findall(plots, 'Type', 'axes'), 'FontSize', 11);
drawnow;
exportgraphics(plots, fullfile(evidence, 'mission_position_trajectory.png'), 'Resolution', 150);
savefig(plots, fullfile(evidence, 'mission_position_trajectory.fig'));
figure(animation);
end

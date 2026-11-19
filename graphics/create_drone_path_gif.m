function gifPath = create_drone_path_gif()
%CREATE_DRONE_PATH_GIF Replay recorded flight without modifying checkpoints.
graphicsFolder = fileparts(mfilename('fullpath'));
rootFolder = fileparts(graphicsFolder);
demo = fullfile(rootFolder,'Quadcopter_Agentic_Demo');
source = load(fullfile(demo,'04_Path_Followed_Verification','PathFollowed_run.mat'),'out');
fig = openfig(fullfile(demo,'03_3D_Flight_Simulation','flight_evidence','flight_3d_final.fig'), ...
    'new','invisible');
fig.Tag = 'DroneGIFReplay';
fig.Name = 'Quadcopter path-following replay';
fig.Color = 'white';
fig.Position = [100 100 1000 760];
fig.MenuBar = 'none';
fig.ToolBar = 'none';
ax = findall(fig,'Type','axes');
ax = ax(1);
view(ax,42,26);
axis(ax,'equal');
xlim(ax,[-0.8 2.8]); ylim(ax,[-0.8 2.8]); zlim(ax,[-0.35 2.8]);
ax.Projection = 'orthographic';
ax.FontSize = 10;
ax.Position = [0.08 0.09 0.82 0.79];
delete(findall(fig,'Type','legend'));
title(ax,'Autonomous quadcopter','FontSize',18,'FontWeight','bold');
xlabel(ax,'East (m)'); ylabel(ax,'North (m)'); zlabel(ax,'Altitude (m)');
body = findall(fig,'Type','hgtransform','Tag','BodyToInertialTransform');
trail = findall(fig,'Type','line','Tag','Trajectory');
assert(isscalar(body) && isscalar(trail));
trail.Color = [0.12 0.35 0.6];
trail.LineWidth = 1.8;
positionSeries = source.out.visualizationState.PositionNED;
position = rows(positionSeries);
orientation = rows(source.out.visualizationState.OrientationQuaternion);
time = positionSeries.Time(:);
modeSeries = source.out.telemetryFlightMode.Mode;
modeTime = modeSeries.Time(:);
modes = rows(modeSeries);
labels = {'Ground','Takeoff','Waypoint 1','Waypoint 2','Waypoint 3','Landing','Landed'};
caption = annotation(fig,'textbox',[0.08 0.015 0.84 0.045], ...
    'String','','EdgeColor','none','HorizontalAlignment','center', ...
    'FontSize',12,'Color',[0.18 0.23 0.3]);
frameTimes = [0:0.2:time(end),time(end)];
indices = unique(interp1(time,(1:numel(time))',frameTimes,'nearest'),'stable');
gifPath = fullfile(graphicsFolder,'quadcopter_path_following.gif');
fig.Visible = 'on';
for frameIndex = 1:numel(indices)
    index = indices(frameIndex);
    q = orientation(index,:);
    w=q(1); x=q(2); y=q(3); z=q(4);
    rotation = [1-2*(y*y+z*z),2*(x*y-z*w),2*(x*z+y*w); ...
        2*(x*y+z*w),1-2*(x*x+z*z),2*(y*z-x*w); ...
        2*(x*z-y*w),2*(y*z+x*w),1-2*(x*x+y*y)];
    transform = eye(4);
    transform(1:3,1:3) = rotation; % Native mesh scale of 1 for GIF visibility.
    transform(1:3,4) = position(index,:)';
    body.Matrix = transform;
    % Parent transforms retain the native UAV Animation NED-to-ENU mapping.
    set(trail,'XData',position(1:index,1),'YData',position(1:index,2),'ZData',position(1:index,3));
    modeIndex = find(modeTime <= time(index)+1e-9,1,'last');
    mode = modes(modeIndex);
    if frameIndex == numel(indices)
        caption.String = sprintf('Landing proximity stop  |  %.2f s  |  Recorded flight replay, 2x speed',time(index));
    else
        caption.String = sprintf('%s  |  %.1f s  |  Recorded flight replay, 2x speed',labels{mode+1},time(index));
    end
    drawnow;
    frame = getframe(fig);
    [indexed,map] = rgb2ind(frame.cdata,256,'nodither');
    delay = 0.1;
    if frameIndex == 1, delay = 0.5; end
    if frameIndex == numel(indices), delay = 1.5; end
    if frameIndex == 1
        imwrite(indexed,map,gifPath,'gif','LoopCount',inf,'DelayTime',delay);
    else
        imwrite(indexed,map,gifPath,'gif','WriteMode','append','DelayTime',delay);
    end
    if abs(time(index)-12) < 0.11
        imwrite(frame.cdata,fullfile(graphicsFolder,'quadcopter_path_following_preview.png'));
    end
end
fprintf('Created %s (%d frames).\n',gifPath,numel(indices));
end

function data = rows(series)
count = numel(series.Time);
if series.IsTimeFirst
    data = reshape(series.Data,count,[]);
else
    data = reshape(series.Data,[],count)';
end
end

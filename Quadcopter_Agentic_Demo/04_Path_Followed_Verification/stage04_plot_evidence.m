function fig = stage04_plot_evidence(metrics, data)
%STAGE04_PLOT_EVIDENCE Plot actual evidence without filtering measured values.
folder = fileparts(mfilename('fullpath'));
evidenceFolder = fullfile(folder,'verification_evidence');
if ~isfolder(evidenceFolder), mkdir(evidenceFolder); end
fig = figure('Name','Path Followed - FR-06 verification evidence', ...
    'Tag','Stage04PathEvidence','Color','white','Position',[110 110 1500 1050]);
layout = tiledlayout(fig,2,2,'TileSpacing','compact','Padding','compact');
title(layout,sprintf('Path Followed | %s | approved tolerance %.2f m',metrics.Verdict,metrics.ToleranceMeters), ...
    'FontSize',17,'FontWeight','bold');
vertices = data.PathVerticesNED;
colors = lines(3);
ax = nexttile(layout);
plot3(ax,vertices(:,2),vertices(:,1),-vertices(:,3),'k--','LineWidth',1.6);
hold(ax,'on');
for leg = 1:3
    mask = data.ActiveLeg == leg;
    plot3(ax,data.PositionNED(mask,2),data.PositionNED(mask,1),-data.PositionNED(mask,3), ...
        'Color',colors(leg,:),'LineWidth',1.8);
end
scatter3(ax,vertices(2:end,2),vertices(2:end,1),-vertices(2:end,3),55,'k','s','filled');
grid(ax,'on'); view(ax,38,30); axis(ax,'equal');
xlabel(ax,'East (m)'); ylabel(ax,'North (m)'); zlabel(ax,'Altitude (m)');
title(ax,'Intended finite segments and actual assessed path');
legend(ax,{'Intended','Leg 1','Leg 2','Leg 3','Waypoints'},'Location','southoutside');
ax = nexttile(layout); hold(ax,'on');
for leg = 1:3
    mask = data.ActiveLeg == leg;
    plot(ax,data.Time(mask),data.TrackingErrorMeters(mask),'Color',colors(leg,:),'LineWidth',1.5);
end
yline(ax,metrics.ToleranceMeters,'r--','Approved 0.20 m limit','LineWidth',1.6);
grid(ax,'on'); ylim(ax,[0 max(0.23,1.1*metrics.OverallMaximumErrorMeters)]);
xlabel(ax,'Time (s)'); ylabel(ax,'3D tracking error (m)'); title(ax,'Every assessed position sample; no smoothing');
ax = nexttile(layout);
bar(ax,[[metrics.LegStatistics.MaximumErrorMeters]' [metrics.LegStatistics.RMSErrorMeters]']);
hold(ax,'on'); yline(ax,metrics.ToleranceMeters,'r--'); grid(ax,'on');
xticks(ax,1:3); xticklabels(ax,{'Leg 1','Leg 2','Leg 3'});
ylabel(ax,'Error (m)'); title(ax,'Measured corridor statistics');
legend(ax,{'Maximum','RMS (descriptive)'},'Location','southoutside');
ax = nexttile(layout);
bar(ax,[metrics.LegStatistics.ClosestWaypointDistanceMeters],0.55,'FaceColor',[0.15 0.45 0.7]);
hold(ax,'on'); yline(ax,metrics.ToleranceMeters,'r--','Approved arrival limit'); grid(ax,'on');
xticks(ax,1:3); xticklabels(ax,{'WP1','WP2','WP3'}); ylabel(ax,'Closest approach during assigned leg (m)');
title(ax,'Ordered waypoint arrivals');
set(findall(fig,'Type','axes'),'FontSize',11);
drawnow;
exportgraphics(fig,fullfile(evidenceFolder,'PathFollowed_tracking_evidence.png'),'Resolution',150);
savefig(fig,fullfile(evidenceFolder,'PathFollowed_tracking_evidence.fig'));
end

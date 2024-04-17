function plot_uSEM(uSEM, casename, dir_figs, round_acc, visibility, cmap, threshold)
% ==============================================================================
% uSEM: universial segmentation error map
%       -- a 3D visualisation of segmentation error
% ------------------------------------------------------------------------------
% Matlab Version: 2023b or later (tested)
%
% Last updated on: 17-Apr-2024
%
% Author:
% Yongcheng YAO (yc.yao@ed.ac.uk)
% School of Informatics
% University of Edinburgh
%
% Copyright 2024 Yongcheng YAO
% ------------------------------------------------------------------------------
% ==============================================================================

msg_visibility = sprintf("visibility must be one of the strings: {'on', 'off'}");
assert(ismember(visibility, {'on', 'off'}), msg_visibility);

%% Prepare
ROInames = fields(uSEM);

dir_case = fullfile(dir_figs, casename);
if ~isfolder(dir_case)
    mkdir(dir_case);
end

errormap_all = [];
for i=1:length(ROInames)
    ROIname = ROInames{i};
    errormap_all = cat(1, errormap_all, uSEM.(ROIname).errormap);
end
cmax_all = round_acc * ceil(max(errormap_all./round_acc));
cmin = round_acc * floor(threshold./round_acc); % applied to all subfigures


%% Figure: uSEM for each ROI
for i=1:length(ROInames)
    ROIname = ROInames{i};
    faces = uSEM.(ROIname).faces;
    vers = uSEM.(ROIname).vertices;
    errormap = uSEM.(ROIname).errormap;
    cmax = round_acc * ceil(max(errormap./round_acc));
    % plot error map
    f = figure('visible', visibility);
    patch('Faces', faces, 'Vertices', vers, 'FaceVertexCData', errormap,...
        'FaceColor','interp','EdgeColor','none');
    colormap(cmap);
    clim([cmin, cmax]);
    colorbar;
    axis equal;
    axis off;
    view(3);
    grid off;
    title('uSEM', 'Interpreter','none');
    hold off;
    % save figure
    plotname = ['uSEM_' , casename , '_',ROIname , '.fig'];
    file_fig_saved = fullfile(dir_case, plotname);
    savefig(f, file_fig_saved, 'compact');
    delete(f);
end


%% Figure: combined uSEM
% plot error map
f = figure('visible', visibility);
ROIname = ROInames{1};
faces = uSEM.(ROIname).faces;
vers = uSEM.(ROIname).vertices;
errormap = uSEM.(ROIname).errormap;
patch('Faces', faces, 'Vertices', vers, 'FaceVertexCData', errormap,...
    'FaceColor','interp','EdgeColor','none');
hold on;

for i=2:length(ROInames)
    ROIname = ROInames{i};
    faces = uSEM.(ROIname).faces;
    vers = uSEM.(ROIname).vertices;
    errormap = uSEM.(ROIname).errormap;
    patch('Faces', faces, 'Vertices', vers, 'FaceVertexCData', errormap,...
        'FaceColor','interp','EdgeColor','none');
end
colormap(cmap);
clim([cmin, cmax_all]);
colorbar;
axis equal;
axis off;
view(3);
grid off;
title('uSEM', 'Interpreter','none');
hold off;
% save figure
plotname = ['uSEM_', casename, '_all.fig'];
file_fig_saved = fullfile(dir_case, plotname);
savefig(f, file_fig_saved, 'compact');
delete(f);
end

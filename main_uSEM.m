% ==============================================================================
% uSEM: universial segmentation error map
%       -- a 3D visualisation of segmentation error
% 
% Function:
% for each vertex on the ground truth (GT) surface, calculate the distance to the nearest
%   points in the model-predicted surface, and map those error values onto the GT surface
%   (surface are constructed from binary masks)
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

clc;
clear;

% --------------------------------------------

% --------------------------------------------
% set input paths
wd = pwd;
dir_labels = fullfile(wd, "Data", "labels");
dir_preds = fullfile(wd, "Data", "predictions");
dir_results = fullfile(wd, "Results");

% TODO:
% directional uSEM: test if a point in model-predicted mask is inside or outside the label mask
% directional = true;

% uSEM configs (optional)
cmap = "sky"; % colormaps: sky (default) (since R2023a), cool, hot, jet, spring, summer, autumn, winter
visibility = "on";
round_acc = 0.5; % round error map
threshold = 0; % ignore minor errors
smooth_mesh_iter = 2; % surface smoothing iteration -- only for visualisation; [values unchanged]

% uSEM smoothing
smooth_uSEM = true; % smoothing of error values -- [values changed]
smooth_uSEM_neigh = 9; % neighborhood for uSEM smoothing
% --------------------------------------------


% add functions
addpath(genpath(fullfile(wd, "Source")));

% make folders
dir_uSEM = fullfile(dir_results, "uSEM_mat");
dir_figure = fullfile(dir_results, "uSEM_fig");
if ~isfolder(dir_uSEM)
    mkdir(dir_uSEM);
end
if ~isfolder(dir_figure)
    mkdir(dir_figure);
end

% check list of cases
labels = [dir(fullfile(dir_labels, "*.nii")); dir(fullfile(dir_labels, "*.nii.gz"))];
preds = [dir(fullfile(dir_preds, "*.nii")); dir(fullfile(dir_preds, "*.nii.gz"))];
assert(length(labels)==length(preds), sprintf("mismatched number of cases in:\n %s\n %s\n", dir_labels, dir_preds))

% get uSEM for each case
for i=1:length(labels)
    % load files
    filename = labels(i).name;
    assert(isfile(fullfile(dir_preds, filename)), sprintf("can not find the specified file:\n %s\n in\n %s\n", filename, dir_preds));
    label_info = niftiinfo(fullfile(dir_labels, labels(i).name));
    label = niftiread(label_info);
    pred_info = niftiinfo(fullfile(dir_preds, preds(i).name));
    pred = niftiread(pred_info);

    % get voxel size
    voxSize = pred_info.PixelDimensions;

    % get list of ROIs
    ROIs = unique(label);
    ROIs(ROIs==0) = [];

    % construct uSEM for all ROIs
    for idx=1:length(ROIs)
        % mask to mesh
        mask_label = uint64(label==ROIs(idx));
        mask_pred = uint64(pred==ROIs(idx));
        FV_label = CM_cal_mask2mesh(mask_label);
        FV_pred = CM_cal_mask2mesh(mask_pred);
        FV_label.vertices = FV_label.vertices .* voxSize;
        FV_pred.vertices = FV_pred.vertices .* voxSize;

        % find nearest neighbour in the predicted surface for each vertex in the label surface
        [distance, dest_idx] = pdist2(FV_pred.vertices, FV_label.vertices, 'euclidean', 'Smallest', 1);
        errormap = reshape(distance, [], 1);

        % TODO:
        % if directional
        %
        % end

        if smooth_mesh_iter>0
            [FV_label.vertices, FV_label.faces] = matGeom_smoothMesh(FV_label.vertices, FV_label.faces, smooth_mesh_iter); % matGeom
        end

        if smooth_uSEM
            errormap = cal_smoothMap(errormap, FV_label.vertices, smooth_uSEM_neigh);
        end

        % construct uSEM
        nameROI = "ROI" + num2str(idx);
        uSEM.(nameROI).errormap = errormap;
        uSEM.(nameROI).vertices = FV_label.vertices;
        uSEM.(nameROI).faces = FV_label.faces;
    end

    % save uSEM
    casename = strip_nii_extension(filename);
    filename_uSEM = "uSEM_" + casename + ".mat";
    file_saved = fullfile(dir_uSEM, filename_uSEM);
    save(file_saved, "uSEM", '-mat')

    % visualise uSEM
    plot_uSEM(uSEM, casename, dir_figure, round_acc, visibility, cmap, threshold);
end

function sMap = cal_smoothMap(Map, vertices, n_neigh)
% ==============================================================================
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


sMap = zeros(size(Map));

% [enable parallel computing if available]
if ~license('test', 'Distrib_Computing_Toolbox')
    % (without parallel computing)
    for i = 1:size(Map,1)
        % find the i-th voxel
        i_coor = vertices(i, :);
        % find neighbors of the i-th voxel and their normal vectors
        [~, idx_neigh] = pdist2(vertices, i_coor, 'euclidean', 'Smallest', n_neigh);
        % spatial smoothing of map
        values_neigh = Map(idx_neigh, 1);
        % calculate the mean values of the neighbors as the new estimated values
        mean_value_neigh = mean(values_neigh, 1);
        sMap(i, :) = mean_value_neigh;
    end
elseif isempty(gcp("nocreate"))
    % (same code with parallel computing)
    parpool;
    parfor i = 1:size(Map,1)
        % find the i-th voxel
        i_coor = vertices(i, :);
        % find neighbors of the i-th voxel and their normal vectors
        [~, idx_neigh] = pdist2(vertices, i_coor, 'euclidean', 'Smallest', n_neigh);
        % spatial smoothing of map
        values_neigh = Map(idx_neigh, 1);
        % calculate the mean values of the neighbors as the new estimated values
        mean_value_neigh = mean(values_neigh, 1);
        sMap(i, :) = mean_value_neigh;
    end
else 
    parfor i = 1:size(Map,1)
        % find the i-th voxel
        i_coor = vertices(i, :);
        % find neighbors of the i-th voxel and their normal vectors
        [~, idx_neigh] = pdist2(vertices, i_coor, 'euclidean', 'Smallest', n_neigh);
        % spatial smoothing of map
        values_neigh = Map(idx_neigh, 1);
        % calculate the mean values of the neighbors as the new estimated values
        mean_value_neigh = mean(values_neigh, 1);
        sMap(i, :) = mean_value_neigh;
    end
end

end
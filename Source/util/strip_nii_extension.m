function filename_stripped = strip_nii_extension(filename)
    % Check if the filename ends with ".nii" or ".nii.gz"
    if endsWith(filename, '.nii.gz')
        % Remove ".nii.gz"
        filename_stripped = strrep(filename, '.nii.gz', '');
    elseif endsWith(filename, '.nii')
        % Remove ".nii"
        filename_stripped = strrep(filename, '.nii', '');
    else
        % If the filename doesn't have ".nii" or ".nii.gz" extension, return the original filename
        filename_stripped = filename;
    end
end
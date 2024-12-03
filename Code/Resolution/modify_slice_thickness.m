function thickened_data = modify_slice_thickness(data, slice_thickness)
    % Modify slice thickness
    % data: Original MRI data (3D matrix)
    % slice_thickness: Desired slice thickness in mm (e.g., 2, 5, 10)

    % Determine how many slices to average
    slices_to_average = slice_thickness; % Assuming isotropic voxel size is 1mm

    % Average slices
    thickened_data = zeros(size(data, 1), size(data, 2), floor(size(data, 3) / slices_to_average));
    for i = 1:size(thickened_data, 3)
        slice_start = (i - 1) * slices_to_average + 1;
        slice_end = slice_start + slices_to_average - 1;
        thickened_data(:, :, i) = mean(data(:, :, slice_start:slice_end), 3);
    end
end

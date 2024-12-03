function resampled_data = resample_in_plane(data, target_resolution)
    % Resample in-plane resolution
    % data: Original MRI data (3D matrix)
    % target_resolution: Target in-plane resolution (e.g., [2 2] for 2mm x 2mm)

    % Get scaling factors
    original_size = size(data);
    scaling_factors = [target_resolution(1), target_resolution(2), 1] ./ [1, 1, 1]; % Assuming original is 1mm x 1mm
    
    % Resample using interpolation
    [X, Y, Z] = ndgrid(1:original_size(1), 1:original_size(2), 1:original_size(3));
    [Xq, Yq, Zq] = ndgrid(1:scaling_factors(1):original_size(1), ...
                          1:scaling_factors(2):original_size(2), ...
                          1:scaling_factors(3):original_size(3));
    resampled_data = interp3(X, Y, Z, double(data), Xq, Yq, Zq, 'cubic');
end

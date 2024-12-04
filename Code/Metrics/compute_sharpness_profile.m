function sharpness = compute_sharpness_profile(slice, csf_coord, wm_coord)
    % Computes the sharpness profile using sigmoidal modeling
    %
    % Inputs:
    %   slice - 2D array representing the MRI slice
    %   csf_coord - Starting coordinate (row, col) for CSF
    %   wm_coord - Ending coordinate (row, col) for WM
    %
    % Outputs:
    %   sharpness - Sharpness profile value for the specified path

    % Extract intensity values along the line between CSF and WM
    intensity_profile = improfile(slice, [csf_coord(2), wm_coord(2)], [csf_coord(1), wm_coord(1)]);
    
    % Remove NaN values that might arise from `improfile`
    intensity_profile = intensity_profile(~isnan(intensity_profile));

    % Debug: Check intensity_profile size
    disp(['Intensity profile size: ', num2str(numel(intensity_profile))]);

    % Normalize the intensity profile
    intensity_profile = intensity_profile / max(intensity_profile);

    % Create the x vector with the same size as intensity_profile
    x = linspace(0, 1, numel(intensity_profile));

    % Debug: Check x size
    disp(['x size: ', num2str(numel(x))]);

    % Fit a sigmoid to the intensity profile
    sigmoid_model = @(p, x) p(1) ./ (1 + exp(-p(2) * (x - p(3))));
    initial_guess = [1, 10, 0.5];
    opts = optimset('Display', 'off');
    
    % Ensure sizes match before fitting
    if numel(intensity_profile) ~= numel(x)
        error('Size mismatch: intensity_profile and x must have the same number of elements.');
    end

    % Perform curve fitting
    params = lsqcurvefit(sigmoid_model, initial_guess, x, intensity_profile, [], [], opts);

    % Extract sharpness (k) from the fitted sigmoid parameters
    sharpness = params(2); % The steepness parameter represents sharpness
end

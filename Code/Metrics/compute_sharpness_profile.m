function sharpness_profile = compute_sharpness_profile(slice, csf_coord, wm_coord)
    % Compute sharpness profile along a line from CSF to WM
    % slice: 2D image
    % csf_coord: [x, y] coordinates for CSF region
    % wm_coord: [x, y] coordinates for WM region
    
    % Generate coordinates for the line
    num_points = 100; % Number of points along the line
    x = linspace(csf_coord(1), wm_coord(1), num_points);
    y = linspace(csf_coord(2), wm_coord(2), num_points);
    
    % Extract intensity profile along the line
    intensity_profile = interp2(double(slice), x, y, 'linear');
    
    % Fit sigmoid to the intensity profile
    sigmoid_model = @(p, x) 1 ./ (1 + exp(-p(1) * (x - p(2))));
    p0 = [1, mean(intensity_profile)]; % Initial guess for parameters
    x_data = 1:num_points;
    p_opt = lsqcurvefit(sigmoid_model, p0, x_data, intensity_profile);
    
    % Sharpness parameter (k)
    sharpness_profile = p_opt(1); % Extract k from the fitted parameters
end

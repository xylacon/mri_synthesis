function sharpnessProfile = computeSharpnessProfile(slice, lineCoords)
    % Inputs:
    % - slice: 2D image slice
    % - lineCoords: [x1, y1; x2, y2], coordinates of the line

    % Extract intensity along the line
    intensityProfile = improfile(slice, lineCoords(:, 1), lineCoords(:, 2));
    dist = linspace(0, 1, numel(intensityProfile)); % Normalize distance

    % Fit sigmoid model
    sigmoidFunc = @(p, x) p(1) ./ (1 + exp(-p(2) * (x - p(3))));
    initParams = [max(intensityProfile), 10, 0.5]; % Initial guesses
    fittedParams = lsqcurvefit(sigmoidFunc, initParams, dist, intensityProfile);

    % Compute sharpness as slope at mid-intensity
    sharpnessProfile = fittedParams(2); % p(2) is the slope
end

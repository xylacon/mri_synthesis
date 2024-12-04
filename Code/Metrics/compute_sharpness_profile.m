function gEn = compute_gradient_entropy(slice, mask)
    % Computes Gradient Entropy for a given slice and mask
    %
    % Inputs:
    %   slice - 2D array representing the MRI slice
    %   mask - Binary mask for the region of interest (e.g., CSF, GM, WM)
    %
    % Outputs:
    %   gEn - Gradient Entropy value for the masked region

    % Apply the mask to the slice
    masked_slice = double(slice) .* double(mask);

    % Compute the gradient of the masked slice
    [Gx, Gy] = gradient(masked_slice);

    % Magnitude of the gradient
    gradient_magnitude = sqrt(Gx.^2 + Gy.^2);

    % Restrict to the region of interest
    gradient_magnitude = gradient_magnitude(mask > 0);

    % Normalize the gradient values
    if ~isempty(gradient_magnitude) % Avoid division by zero
        gradient_magnitude = gradient_magnitude / max(gradient_magnitude(:));
    else
        gEn = 0; % If no valid gradient, entropy is zero
        return;
    end

    % Compute entropy
    histogram_bins = 256; % Define the number of bins
    hist_counts = histcounts(gradient_magnitude, histogram_bins, 'Normalization', 'probability');
    gEn = -sum(hist_counts(hist_counts > 0) .* log2(hist_counts(hist_counts > 0)));
end

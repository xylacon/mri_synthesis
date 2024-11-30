function gEn = gradient_entropy(image)
    % Compute Gradient Entropy (gEn) as a sharpness metric
    
    % Determine the number of dimensions
    dims = ndims(image);
    
    if isvector(image)  % 1D signal
        grad_magnitude = abs(gradient(image));  % Single output for 1D gradient
    elseif dims == 2  % 2D image
        [grad_x, grad_y] = gradient(image);  % Two outputs for 2D gradient
        grad_magnitude = sqrt(grad_x.^2 + grad_y.^2);
    elseif dims == 3  % 3D volume
        [grad_x, grad_y, grad_z] = gradient(image);  % Three outputs for 3D gradient
        grad_magnitude = sqrt(grad_x.^2 + grad_y.^2 + grad_z.^2);
    else
        error('Unsupported data dimensionality. The input must be 1D, 2D, or 3D.');
    end

    % Compute entropy of the gradient magnitude
    grad_magnitude = grad_magnitude(:);  % Flatten for entropy calculation
    grad_magnitude = grad_magnitude + 1e-6;  % Avoid log(0)
    gEn = -sum(grad_magnitude .* log(grad_magnitude));
end

function gEn = compute_gradient_entropy(slice, mask)
    % Compute gradient entropy for a given slice
    % slice: 2D image
    % mask: Binary mask to exclude the background
    
    % Compute gradients
    [Gx, Gy] = gradient(double(slice));
    G = sqrt(Gx.^2 + Gy.^2); % Gradient magnitude
    
    % Apply mask to exclude background
    G_masked = G(mask);
    
    % Compute histogram of gradient magnitudes
    [counts, ~] = histcounts(G_masked, 256, 'Normalization', 'probability');
    
    % Compute entropy
    gEn = -sum(counts .* log2(counts + eps));
end

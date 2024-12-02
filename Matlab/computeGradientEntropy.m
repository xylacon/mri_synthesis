function gEn = computeGradientEntropy(slice, tissueMask)
    % Mask the slice to isolate the tissue
    tissueSlice = slice .* tissueMask;

    % Compute gradient magnitudes
    [Gx, Gy] = gradient(double(tissueSlice));
    gradMag = sqrt(Gx.^2 + Gy.^2);

    % Compute histogram of gradient magnitudes
    gradMag = gradMag(:);
    gradMag(gradMag == 0) = []; % Remove background gradients
    histValues = histcounts(gradMag, 256, 'Normalization', 'pdf');

    % Compute Gradient Entropy
    gEn = -sum(histValues .* log2(histValues + eps)); % eps prevents log(0)
end

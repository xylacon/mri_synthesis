function slice = addNoise(slice, B0, SNR_slice)
    % Extract tissues
    [GM, WM, CSF] = extractTissueMaps(slice);
    GM = (slice == 1) | (slice == 2);
    WM = (slice == 3);
    CSF = (slice == 4);

    sigma = 40 * (1 + log(B0));
    
    % Compute intensities
    SI_GM = SNR_slice(1) * sigma .* double(GM > 0);
    SI_WM = SNR_slice(2) * sigma .* double(WM > 0);
    SI_CSF = SNR_slice(3) * sigma .* double(CSF > 0);
    
    % Combine tissues
    slice = SI_GM + SI_WM + SI_CSF;

    % Add noise
    std = 0.05;
    max_signal = max(double(slice(:)));
    noise = normrnd(0, std * max_signal, size(slice));
    slice = slice + noise;
end
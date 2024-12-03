function [image_quality, contrast, SNR] = compute_resolution_metrics(data, resolution, thickness)
    % Compute image quality
    edges = edge(squeeze(data(:, :, round(size(data, 3) / 2))), 'Canny');
    image_quality = sum(edges(:)) / numel(data);

    % Compute contrast
    max_signal = max(data(:));
    min_signal = min(data(:));
    contrast = (max_signal - min_signal) / (max_signal + min_signal);

    % Compute SNR
    signal_mean = mean(data(:));
    noise_std = std(data(:));
    SNR = signal_mean / noise_std;
end

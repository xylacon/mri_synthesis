function SNR = snr_calculation(B0, BW, TE, T1, T2, alpha, TR)
    % Compute the Signal-to-Noise Ratio (SNR)
    SNR = (B0 * 1e3 / sqrt(BW * TE)) * sin(alpha) * exp(-TE / T2) ...
          * (1 - exp(-TR / T1)) / (1 - cos(alpha) * exp(-TR / T1));
end

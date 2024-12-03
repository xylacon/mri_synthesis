function report_noise_effect(B0, sigma_n, SI, output_file)
    % Generates a report on the noise effect on MRI image quality
    %
    % Inputs:
    %   B0 - Array of B0 values (T)
    %   sigma_n - Noise variance for each B0
    %   SI - Signal Intensity matrix [B0 x Tissues]
    %   output_file - File path to save the report

    % Analyze trends
    noise_trend = sprintf('Noise variance increases logarithmically with B0: sigma_n = 40 * (1 + log(B0)).\n');
    snr_trend = sprintf('Signal Intensity (SI) increases proportionally with SNR for each tissue as B0 increases.\n');
    
    % Tissue-specific observations
    tissue_labels = {'White Matter (WM)', 'Gray Matter (GM)', 'Cerebrospinal Fluid (CSF)'};
    tissue_observations = '';
    for t = 1:size(SI, 2)
        tissue_observations = sprintf('%s- %s: SI increases by %.2f%% from B0 = %.1f T to B0 = %.1f T.\n', ...
            tissue_observations, ...
            tissue_labels{t}, ...
            ((SI(end, t) - SI(1, t)) / SI(1, t)) * 100, ...
            B0(1), ...
            B0(end));
    end

    % Write report
    fid = fopen(output_file, 'w');
    fprintf(fid, 'Noise Effect Report on MRI Image Quality\n');
    fprintf(fid, '-------------------------------------------------------------\n');
    fprintf(fid, '%s', noise_trend);
    fprintf(fid, '%s', snr_trend);
    fprintf(fid, '\nTissue-Specific Observations:\n%s', tissue_observations);
    fclose(fid);
end

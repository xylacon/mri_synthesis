function resolution_results = mri_resolution_analysis(GM, WM, CSF)
    % MRI Resolution Analysis
    % Inputs:
    %   GM, WM, CSF - Tissue maps extracted from patient data
    % Outputs:
    %   resolution_results - Structure with resampled data, metrics, and visualizations

    % Initialize structure to store results
    resolution_results = struct();

    %% Step 2: Resample Data
    % Resample to 2mm x 2mm in-plane resolution
    wm_2mm = resample_in_plane(WM, 2, 2);
    gm_2mm = resample_in_plane(GM, 2, 2);
    csf_2mm = resample_in_plane(CSF, 2, 2);

    % Store resampled data
    resolution_results.ResampledData.WM_2mm = wm_2mm;
    resolution_results.ResampledData.GM_2mm = gm_2mm;
    resolution_results.ResampledData.CSF_2mm = csf_2mm;

    %% Step 3: Change Slice Thickness
    % Adjust slice thickness for 2mm, 5mm, and 10mm
    wm_1mm_2mm = change_slice_thickness(WM, 2);
    wm_1mm_5mm = change_slice_thickness(WM, 5);
    wm_1mm_10mm = change_slice_thickness(WM, 10);

    % Store results for slice thickness adjustments
    resolution_results.SliceThickness.WM_1mm_2mm = wm_1mm_2mm;
    resolution_results.SliceThickness.WM_1mm_5mm = wm_1mm_5mm;
    resolution_results.SliceThickness.WM_1mm_10mm = wm_1mm_10mm;

    %% Step 4: Visualize Results
    slice_idx = round(size(wm_1mm_2mm, 3) / 2);  % Middle slice
    figure;
    subplot(1, 3, 1);
    imshow(squeeze(wm_1mm_2mm(:, :, slice_idx)), []);
    title('1mm x 1mm x 2mm');

    subplot(1, 3, 2);
    imshow(squeeze(wm_1mm_5mm(:, :, slice_idx)), []);
    title('1mm x 1mm x 5mm');

    subplot(1, 3, 3);
    imshow(squeeze(wm_1mm_10mm(:, :, slice_idx)), []);
    title('1mm x 1mm x 10mm');

    %% Step 5: Compute Metrics
    % Calculate SNR and contrast
    snr_1mm_2mm = compute_snr(wm_1mm_2mm);
    contrast_wm_gm = compute_contrast(WM, GM);

    % Store metrics
    resolution_results.Metrics.SNR_1mm_2mm = snr_1mm_2mm;
    resolution_results.Metrics.Contrast_WM_GM = contrast_wm_gm;

    %% Step 6: Report Findings
    % Generate graphs
    snr_values = [snr_1mm_2mm, compute_snr(wm_1mm_5mm), compute_snr(wm_1mm_10mm)];
    res_labels = {'1mm x 1mm x 2mm', '1mm x 1mm x 5mm', '1mm x 1mm x 10mm'};

    figure;
    bar(snr_values);
    set(gca, 'XTickLabel', res_labels);
    ylabel('SNR');
    title('SNR Comparison for Different Slice Thicknesses');

    % Display metrics in the console
    disp(['SNR for WM (1mm x 1mm x 2mm): ', num2str(snr_1mm_2mm)]);
    disp(['Contrast between WM and GM: ', num2str(contrast_wm_gm)]);
end

% Helper Functions
function resampled_data = resample_in_plane(data, new_x_res, new_y_res)
    % Resample the in-plane resolution of the data
    [X, Y, Z] = size(data);
    x_new = linspace(1, X, round(X / new_x_res));
    y_new = linspace(1, Y, round(Y / new_y_res));
    [Xq, Yq, Zq] = ndgrid(x_new, y_new, 1:Z);
    resampled_data = interp3(data, Yq, Xq, Zq, 'linear');
end

function resampled_data = change_slice_thickness(data, new_thickness)
    % Adjust slice thickness (Z-dimension)
    [X, Y, Z] = size(data);
    z_new = linspace(1, Z, round(Z / new_thickness));
    [Xq, Yq, Zq] = ndgrid(1:X, 1:Y, z_new);
    resampled_data = interp3(data, Yq, Xq, Zq, 'linear');
end

function snr_value = compute_snr(data)
    % Calculate Signal-to-Noise Ratio
    signal = mean(data(:));
    noise = std(data(:));
    snr_value = signal / noise;
end

function contrast_value = compute_contrast(tissue1, tissue2)
    % Calculate Contrast Between Tissues
    contrast_value = abs(mean(tissue1(:)) - mean(tissue2(:))) / mean(tissue1(:));
end

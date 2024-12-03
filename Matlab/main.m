% main.m

% % % % % % % % % %
% DATA PREPARATION
% % % % % % % % % %

% Define data directory
data_dir = './Data'; % Adjust to your directory

% Dynamically load all .nii files in the data directory
nii_files = dir(fullfile(data_dir, '*.nii'));
num_patients = length(nii_files);

if num_patients == 0
    error('No .nii files found in the specified directory.');
end

% Initialize cell array to store patient data
patients = cell(num_patients, 1);

% Loop through detected .nii files
for i = 1:num_patients
    file_path = fullfile(data_dir, nii_files(i).name);
    
    % Load MRI volume
    patients{i}.data = niftiread(file_path); % Load 3D MRI data
    
    % Load metadata
    patients{i}.info = niftiinfo(file_path); % Get metadata about the file
end

% Display loaded patient information
fprintf('Loaded %d patients:\n', num_patients);
for i = 1:num_patients
    fprintf('%d: %s\n', i, nii_files(i).name);
end


% % % % % % % % % %
% SNR COMPUTATIONS
% % % % % % % % % %

% Magnetic field strengths
B0 = 0.5:0.5:9; % Range of B0 values

% Initialize storage for SNR maps
SNR_maps = cell(num_patients, 1);

% Loop through each patient
for patient_id = 1:num_patients
    patient_data = patients{patient_id}.data;
    num_slices = size(patient_data, 3);
    num_B0 = length(B0);
    num_tissues = 3; % WM, GM, CSF
    
    % Preallocate SNR maps for this patient
    SNR_maps{patient_id} = zeros(num_slices, num_B0, num_tissues);
    
    % Compute relaxation times
    [T1, T2] = compute_relaxation(B0);

    % Loop through slices
    for slice_idx = 1:num_slices
        slice_data = patient_data(:, :, slice_idx); % Extract 2D slice
        
        % Loop through B0 values
        for b_idx = 1:num_B0
            % Compute TE, TR, BW
            T2_WM = T2(b_idx, 1); % Use T2 of WM for TE/TR/BW calculation
            [TE, TR, BW] = compute_TE_TR_BW(T2_WM, B0(b_idx));
            
            % Compute optimal flip angle
            T1_WM = T1(b_idx, 1);
            T1_GM = T1(b_idx, 2);
            [optimal_alpha, ~, ~] = compute_flip_angle(TR, T1_WM, T1_GM);
            alpha_rad = deg2rad(optimal_alpha); % Convert to radians
            
            % Compute SNR for this B0 value and slice
            SNR_maps{patient_id}(slice_idx, b_idx, :) = compute_SNR(... 
                B0(b_idx), ...
                T1(b_idx, :), ...
                T2(b_idx, :), ...
                TE, TR, BW, alpha_rad ...
            );
        end
    end
end

% Save SNR maps
save('./Output/SNR_maps.mat', 'SNR_maps', 'B0');
disp('SNR maps generated and saved successfully.');

% % % % % % % % % %
% NOISE COMPUTATIONS AND VISUALIZATION
% % % % % % % % % %

slice_to_display = 90; % Slice to visualize
sigma_n = 40 * (1 + log(B0)); % Compute noise variance for each B0

% Loop through each patient
for patient_id = 1:num_patients
    % Add noise to the slice for each B0 value
    noisy_images = add_noise(patients, slice_to_display, sigma_n, patient_id);

    % Visualize noisy images at selected B0 values
    selected_B0 = [1, 5, 10, 15]; % Indices for example B0 values
    visualize_noisy_images(noisy_images, B0, selected_B0);

    % Compute Signal Intensity (SI)
    SI = zeros(length(B0), num_tissues); % Preallocate for Signal Intensity
    for b_idx = 1:length(B0)
        for t = 1:num_tissues
            SI(b_idx, t) = SNR_maps{patient_id}(slice_to_display, b_idx, t) * sigma_n(b_idx);
        end
    end

    % Visualize Signal Intensity vs B0
    visualize_signal_intensity(B0, SI);

    % Generate Noise Effect Report
    output_file = sprintf('./Output/noise_effect_report_patient%d.txt', patient_id);
    report_noise_effect(B0, sigma_n, SI, output_file);
    disp(['Noise effect report saved for Patient ', num2str(patient_id), ': ', output_file]);
end

% % % % % % % % % %
% METRICS COMPUTATIONS
% % % % % % % % % %

% Slice to analyze
slice_to_analyze = 90;

% Gradient Entropy Metrics
gEn_values = zeros(length(B0), 3); % Preallocate for CSF, GM, WM
sharpness_profiles = zeros(length(B0), 1); % Preallocate sharpness profile values

% Masks for tissues (assuming predefined or generated masks)
csf_mask = create_mask(patients{1}.data(:, :, slice_to_analyze), 'CSF');
wm_mask = create_mask(patients{1}.data(:, :, slice_to_analyze), 'WM');
gm_mask = create_mask(patients{1}.data(:, :, slice_to_analyze), 'GM');

% Compute metrics for each B0 value
for b_idx = 1:length(B0)
    % Extract the slice
    slice = patients{1}.data(:, :, slice_to_analyze);

    % Compute Gradient Entropy
    gEn_values(b_idx, 1) = compute_gradient_entropy(slice, csf_mask);
    gEn_values(b_idx, 2) = compute_gradient_entropy(slice, gm_mask);
    gEn_values(b_idx, 3) = compute_gradient_entropy(slice, wm_mask);

    % Compute Sharpness Profile
    csf_coord = [50, 50]; % Example CSF coordinate
    wm_coord = [100, 100]; % Example WM coordinate
    sharpness_profiles(b_idx) = compute_sharpness_profile(slice, csf_coord, wm_coord);
end

% Visualize and Save Metrics
visualize_gradient_entropy(B0, gEn_values);
visualize_sharpness_profiles(B0, sharpness_profiles);

% Save Metrics
save('./Output/gradient_entropy.mat', 'gEn_values', 'B0');
save('./Output/sharpness_profiles.mat', 'sharpness_profiles', 'B0');
disp('Gradient entropy and sharpness profile results saved.');

% % % % % % % % % %
% MRI RESOLUTION SIMULATIONS
% % % % % % % % % %

resolutions = {[1 1], [2 2]}; % In-plane resolutions (mm)
slice_thicknesses = [2, 5, 10]; % Slice thicknesses (mm)

% Preallocate storage for metrics
resolution_metrics = cell(num_patients, 1);

for patient_id = 1:num_patients
    patient_data = patients{patient_id}.data;

    % Initialize storage for metrics
    resolution_metrics{patient_id} = struct();

    for r = 1:length(resolutions)
        for t = 1:length(slice_thicknesses)
            % Resample in-plane resolution
            resampled_data = resample_in_plane(patient_data, resolutions{r});
            
            % Modify slice thickness
            thickened_data = modify_slice_thickness(resampled_data, slice_thicknesses(t));
            
            % Compute metrics: image quality, contrast, SNR
            [image_quality, contrast, snr_value] = compute_resolution_metrics(... 
                thickened_data, resolutions{r}, slice_thicknesses(t));
            
            % Store metrics
            resolution_metrics{patient_id}.(['res_', num2str(r), '_thick_', num2str(t)]) = ...
                struct('quality', image_quality, 'contrast', contrast, 'SNR', snr_value);
            
            % Visualize results
            visualize_resolution_and_thickness(... 
                thickened_data, slice_to_analyze, resolutions{r}, slice_thicknesses(t), contrast, snr_value);
        end
    end
end

% Generate reports for resolution metrics
for patient_id = 1:num_patients
    report_file = sprintf('./Output/resolution_metrics_patient%d.txt', patient_id);
    generate_resolution_report(resolution_metrics{patient_id}, report_file);
    disp(['Resolution metrics report saved for Patient ', num2str(patient_id), ': ', report_file]);
end

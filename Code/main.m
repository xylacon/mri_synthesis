% main.m

% % % % % % % % % %
% DATA PREPARATION
% % % % % % % % % %

% Dynamically determine project root
current_file_path = mfilename('fullpath');
project_root = fileparts(current_file_path); % Assuming main.m is in Code folder
data_dir = fullfile(project_root, 'Data'); % Path to Data folder
output_dir = fullfile(project_root, '..', 'Output'); % Path to Output folder

% Dynamically load all .nii files in the data directory
nii_files = dir(fullfile(data_dir, '*.nii'));
num_patients = length(nii_files);

if num_patients == 0
    error('No .nii files found in the specified directory: %s', data_dir);
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
% ADD SUBFOLDER PATHS
% % % % % % % % % %

% Add paths to subfolders for modular functions
addpath(fullfile(project_root, 'SNR'));
addpath(fullfile(project_root, 'Noise'));
addpath(fullfile(project_root, 'Metrics'));
addpath(fullfile(project_root, 'Resolution'));

num_dims = ndims(patients{patient_id}.data);

data_size = size(patients{patient_id}.data);
disp(['Patient ', num2str(patient_id), ' data size: ', mat2str(data_size)]);

% Check dimensionality
if numel(data_size) == 3 && slice_to_display > data_size(3)
    error('slice_to_display exceeds available slices for Patient %d.', patient_id);
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
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end
save(fullfile(output_dir, 'SNR_maps.mat'), 'SNR_maps', 'B0');
disp('SNR maps generated and saved successfully.');

% % % % % % % % % %
% NOISE COMPUTATIONS AND VISUALIZATION
% % % % % % % % % %

disp('Inspecting patient data before calling add_noise:');
disp(size(patients{patient_id}.data)); % Expected: [160 192 224]
disp(['slice_to_display: ', num2str(slice_to_display)]); % Ensure within range

% Validate slice_to_display
if slice_to_display > size(patients{patient_id}.data, 3)
    error('slice_to_display exceeds available slices for Patient %d.', patient_id);
end

% Initialize variables
slice_to_display = 90; % Slice to visualize
sigma_n = 40 * (1 + log(B0)); % Compute noise variance for each B0

% Loop through each patient
for patient_id = 1:num_patients
    if size(patients{patient_id}.data, 3) < slice_to_display
        error('Slice %d does not exist for patient %d.', slice_to_display, patient_id);
    end

    % Add noise to the slice for each B0 value
    noisy_images = add_noise(patients, slice_to_display, sigma_n, patient_id);

    % Compute Signal Intensity (SI) by averaging over spatial dimensions (x, y)
    SI = squeeze(mean(mean(noisy_images, 2), 3)); % Reduce noisy_images to [B0 x Tissues]

    % Visualize noisy images at selected B0 values
    selected_B0 = [1, 5, 10, 15]; % Indices for example B0 values
    visualize_noisy_images(noisy_images, B0, selected_B0);

    % Generate Noise Effect Report
    noise_report_file = fullfile(output_dir, sprintf('noise_effect_report_patient%d.txt', patient_id));
    report_noise_effect(B0, sigma_n, SI, noise_report_file); % Pass SI to report_noise_effect
    disp(['Noise effect report saved for Patient ', num2str(patient_id), ': ', noise_report_file]);
end


% % % % % % % % % %
% METRICS COMPUTATIONS
% % % % % % % % % %

% Slice to analyze
slice_to_analyze = 90;

% Gradient Entropy Metrics
gEn_values = zeros(length(B0), 3); % Preallocate for CSF, GM, WM

% Example: Predefined masks for tissues
csf_mask = create_mask(patients{1}.data(:, :, slice_to_analyze), 'CSF');
wm_mask = create_mask(patients{1}.data(:, :, slice_to_analyze), 'WM');
gm_mask = create_mask(patients{1}.data(:, :, slice_to_analyze), 'GM');

% Compute metrics for each B0 value
for b_idx = 1:length(B0)
    slice = patients{1}.data(:, :, slice_to_analyze);

    % Compute Gradient Entropy
    gEn_values(b_idx, 1) = compute_gradient_entropy(slice, csf_mask);
    gEn_values(b_idx, 2) = compute_gradient_entropy(slice, gm_mask);
    gEn_values(b_idx, 3) = compute_gradient_entropy(slice, wm_mask);
end

% Save and visualize metrics
save(fullfile(output_dir, 'gradient_entropy.mat'), 'gEn_values', 'B0');
visualize_gradient_entropy(B0, gEn_values);

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
        end
    end
end

% Generate reports for resolution metrics
for patient_id = 1:num_patients
    report_file = fullfile(output_dir, sprintf('resolution_metrics_patient%d.txt', patient_id));
    generate_resolution_report(resolution_metrics{patient_id}, report_file);
    disp(['Resolution metrics report saved for Patient ', num2str(patient_id), ': ', report_file]);
end


% Local function definition
function mask = create_mask(slice_data, tissue_type)
    switch tissue_type
        case 'CSF'
            mask = (slice_data == 4);
        case 'WM'
            mask = (slice_data == 3);
        case 'GM'
            mask = (slice_data == 1) | (slice_data == 2);
        otherwise
            error('Unknown tissue type: %s', tissue_type);
    end
end

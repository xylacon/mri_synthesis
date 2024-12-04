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
            [optimal_alpha, contrast] = compute_flip_angle(TR, T1_WM, T1_GM, theta);
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

% Define the slice to analyze
slice_to_display = 90; 

% Loop through each patient
for patient_id = 1:num_patients
    num_slices = size(SNR_maps{patient_id}, 1);
    
    % Ensure the slice exists
    if slice_to_display > num_slices
        error('Slice %d exceeds available slices for Patient %d.', slice_to_display, patient_id);
    end

    % Extract SNR values for the specific slice
    slice_snr = squeeze(SNR_maps{patient_id}(slice_to_display, :, :)); % [B0 x Tissues]

    % Plot SNR vs B0 for WM, GM, and CSF
    plot_SNR(B0, slice_snr); % Call the plot_SNR function

    % Save the plot
    slice_plot_path = fullfile(output_dir, sprintf('Patient%d_SNR_Slice90.png', patient_id));
    saveas(gcf, slice_plot_path);
    disp(['SNR Slice 90 plot saved for Patient ', num2str(patient_id), ': ', slice_plot_path]);

    % Generate relaxation report with correct slice_snr
    generate_relaxation_report(B0, T1, T2, optimal_alpha_values, slice_snr, patient_id, output_dir);
end

% Generate and save T1 and T2* plots for each patient
for patient_id = 1:num_patients
    % T1 and T2* plots
    t1_plot_path = fullfile(output_dir, sprintf('Patient%d_T1_vs_B0.png', patient_id));
    t2_plot_path = fullfile(output_dir, sprintf('Patient%d_T2_vs_B0.png', patient_id));
    figure;
    plot(B0, T1(:, 1), '-r', 'LineWidth', 2); hold on;
    plot(B0, T1(:, 2), '-g', 'LineWidth', 2);
    plot(B0, T1(:, 3), '-b', 'LineWidth', 2);
    xlabel('B_0 [T]'); ylabel('T1 [ms]');
    title(['T1 vs B_0 for Patient ', num2str(patient_id)]);
    legend('WM', 'GM', 'CSF'); grid on;
    saveas(gcf, t1_plot_path);
    disp(['T1 vs B0 plot saved for Patient ', num2str(patient_id), ': ', t1_plot_path]);

    figure;
    plot(B0, T2(:, 1), '-r', 'LineWidth', 2); hold on;
    plot(B0, T2(:, 2), '-g', 'LineWidth', 2);
    plot(B0, T2(:, 3), '-b', 'LineWidth', 2);
    xlabel('B_0 [T]'); ylabel('T2* [ms]');
    title(['T2* vs B_0 for Patient ', num2str(patient_id)]);
    legend('WM', 'GM', 'CSF'); grid on;
    saveas(gcf, t2_plot_path);
    disp(['T2 vs B0 plot saved for Patient ', num2str(patient_id), ': ', t2_plot_path]);
end

disp('Main program completed successfully.');




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

% Loop through each patient for computations
for patient_id = 1:num_patients
    patient_data = patients{patient_id}.data;
    num_slices = size(patient_data, 3);

    % Validate slice selection
    if slice_to_analyze > num_slices
        error('Slice %d exceeds available slices for Patient %d.', slice_to_analyze, patient_id);
    end

    % Initialize storage for Gradient Entropy and Sharpness Profiles
    gEn_values = zeros(length(B0), 3); % Columns for CSF, GM, WM
    sharpness_profiles = zeros(length(B0), 1);

    % Extract the selected slice
    slice = patient_data(:, :, slice_to_analyze);

    % Create tissue masks and remove background
    background_mask = slice > 0;
    csf_mask = create_mask(slice, 'CSF') & background_mask;
    gm_mask = create_mask(slice, 'GM') & background_mask;
    wm_mask = create_mask(slice, 'WM') & background_mask;

    % Compute Gradient Entropy for each B0
    for b_idx = 1:length(B0)
        gEn_values(b_idx, 1) = compute_gradient_entropy(slice, csf_mask); % CSF
        gEn_values(b_idx, 2) = compute_gradient_entropy(slice, gm_mask); % GM
        gEn_values(b_idx, 3) = compute_gradient_entropy(slice, wm_mask); % WM
    end

    % Save and visualize Gradient Entropy
    save(fullfile(output_dir, sprintf('Patient%d_gradient_entropy.mat', patient_id)), 'gEn_values', 'B0');
    visualize_gradient_entropy(B0, gEn_values, patient_id, output_dir);


end


    % Perform MRI Resolution Simulations
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
            
            % Plot sharpness vs resolution
            %visualize_sharpness_vs_resolution(B0, resolutions{r}, thickened_data, patient_id, output_dir);
        end
    end

    % Generate resolution metrics report
    report_file = fullfile(output_dir, sprintf('resolution_metrics_patient%d.txt', patient_id));
    generate_resolution_report(resolution_metrics{patient_id}, report_file);
    disp(['Resolution metrics report saved for Patient ', num2str(patient_id), ': ', report_file]);

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
            
            % Visualize resolution and thickness effect
            figure;
            imagesc(thickened_data(:, :, round(size(thickened_data, 3) / 2))); % Display middle slice
            colormap gray;
            title(sprintf('Patient %d: Resolution %dx%d, Thickness %dmm', ...
                patient_id, resolutions{r}(1), resolutions{r}(2), slice_thicknesses(t)));
            xlabel('X-axis');
            ylabel('Y-axis');
            
            % Save visualization
            plot_path = fullfile(output_dir, sprintf('Patient%d_Resolution_%dx%d_Thickness_%dmm.png', ...
                patient_id, resolutions{r}(1), resolutions{r}(2), slice_thicknesses(t)));
            saveas(gcf, plot_path);
            disp(['Resolution plot saved for Patient ', num2str(patient_id), ...
                ', Resolution: ', num2str(resolutions{r}(1)), 'x', num2str(resolutions{r}(2)), ...
                ', Thickness: ', num2str(slice_thicknesses(t)), 'mm: ', plot_path]);
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

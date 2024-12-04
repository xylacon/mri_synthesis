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

% Define flip angles (in radians) for consistent computation
theta = deg2rad(0:0.2:180); % Flip angles from 0 to 180 degrees
num_theta = length(theta);

% Loop through each patient
for patient_id = 1:num_patients
    patient_data = patients{patient_id}.data;
    num_slices = size(patient_data, 3);
    num_B0 = length(B0);
    num_tissues = 3; % WM, GM, CSF

    % Preallocate SNR maps, contrast, and optimal alpha values for this patient
    SNR_maps{patient_id} = zeros(num_slices, num_B0, num_tissues);
    all_contrast_values = zeros(num_slices, num_theta);
    optimal_alpha_values = zeros(num_B0, 1); % Store optimal alpha for each B0

    % Process each slice
    for slice_idx = 1:num_slices
        for b_idx = 1:num_B0
            % Compute TE, TR, BW
            T2_WM = T2(b_idx, 1); % Use T2 of WM for TE/TR/BW calculation
            [TE, TR, BW] = compute_TE_TR_BW(T2_WM, B0(b_idx));

            % Compute optimal flip angle and contrast
            T1_WM = T1(b_idx, 1);
            T1_GM = T1(b_idx, 2);
            [optimal_alpha, contrast] = compute_flip_angle(TR, T1_WM, T1_GM, theta);

            % Store optimal alpha
            optimal_alpha_values(b_idx) = optimal_alpha;

            % Compute SNR for this slice and B0 value
            alpha_rad = deg2rad(optimal_alpha); % Convert alpha to radians
            SNR_maps{patient_id}(slice_idx, b_idx, :) = compute_SNR(...
                B0(b_idx), ...
                T1(b_idx, :), ...
                T2(b_idx, :), ...
                TE, TR, BW, alpha_rad ...
            );

            % Store contrast for averaging
            all_contrast_values(slice_idx, :) = contrast;
        end
    end

    % Compute the average contrast across all slices
    avg_contrast = mean(all_contrast_values, 1);

    % Plot average Contrast vs Theta
    theta_deg = rad2deg(theta); % Convert theta to degrees
    figure;
    plot(theta_deg, avg_contrast, '-b', 'LineWidth', 2);
    xlabel('\theta [degrees]');
    ylabel('Average Contrast (C_\theta)');
    title(['Average Contrast vs Flip Angle - Patient ', num2str(patient_id)]);
    grid on;

    % Save the plot
    avg_contrast_plot_path = fullfile(output_dir, sprintf('Patient%d_Average_Contrast_vs_FlipAngle.png', patient_id));
    saveas(gcf, avg_contrast_plot_path);
    disp(['Average Contrast vs Flip Angle plot saved for Patient ', num2str(patient_id), ': ', avg_contrast_plot_path]);

    % Pass the optimal alpha values for reporting
    generate_relaxation_report(B0, T1, T2, optimal_alpha_values, slice_snr, patient_id, output_dir);
end

% Save SNR maps
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end
save(fullfile(output_dir, 'SNR_maps.mat'), 'SNR_maps', 'B0');
disp('SNR maps generated and saved successfully.');

% Plot SNR for Slice 90 for Each Patient
slice_to_display = 90;

for patient_id = 1:num_patients
    % Ensure slice_to_display is within range
    num_slices = size(SNR_maps{patient_id}, 1);
    if slice_to_display > num_slices
        error('Slice %d exceeds available slices for Patient %d.', slice_to_display, patient_id);
    end

    % Extract SNR values for slice 90
    slice_snr = squeeze(SNR_maps{patient_id}(slice_to_display, :, :)); % [B0 x Tissues]

    % Plot SNR vs B0 for WM, GM, and CSF
    plot_SNR(B0, slice_snr); % Call the plot_SNR function here

    % Save the plot
    slice_plot_path = fullfile(output_dir, sprintf('Patient%d_SNR_Slice90.png', patient_id));
    saveas(gcf, slice_plot_path);
    disp(['SNR Slice 90 plot saved for Patient ', num2str(patient_id), ': ', slice_plot_path]);
end

% Generate and save T1 and T2* plots and generate reports for each patient
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

    % Generate relaxation report
    generate_relaxation_report(B0, T1, T2, optimal_alpha_values, slice_snr, patient_id, output_dir);
end




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

    % Noise Effect Report
    noise_report_file = fullfile(output_dir, sprintf('Patient%d_Noise_Effect_Report.txt', patient_id));
    report_noise_effect(B0, sigma_n, SI, noise_report_file);
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
% Call visualize_gradient_entropy with output_dir
visualize_gradient_entropy(B0, gEn_values, patient_id, output_dir);



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

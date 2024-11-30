% Main Simulation Script
% Automatically set the current directory to the script's folder
current_file_path = fileparts(mfilename('fullpath'));
cd(current_file_path);

% Add supporting functions folder to MATLAB path
addpath(fullfile(current_file_path, 'Supporting_Functions'));

% Parameters
B0_values = 0.5:0.5:9;  % Magnetic field strengths (0.5T to 9T)
TE = 0.04;  % Echo time in seconds
TR = 500;  % Repetition time in ms
alpha = pi / 6;  % Flip angle in radians
BW = 15000;  % Bandwidth in Hz
file_path = fullfile(pwd, 'OASIS_Data', 'Converted_NIfTI');

% Check if the directory exists
if ~exist(file_path, 'dir')
    error('Converted_NIfTI directory not found. Ensure the correct folder structure is set up.');
end

% List all .nii files in the directory
nii_files = dir(fullfile(file_path, '*.nii'));

% Check if there are any files to process
if isempty(nii_files)
    error('No NIfTI files found in the Converted_NIfTI folder.');
end

% Create a folder for saving results
results_folder = fullfile(current_file_path, 'Results');
if ~exist(results_folder, 'dir')
    mkdir(results_folder);
end

% Process each NIfTI file
hWaitbar = waitbar(0, 'Processing files...'); % Loading bar
for file_idx = 1:length(nii_files)
    % Load the specific file
    nii_file = fullfile(nii_files(file_idx).folder, nii_files(file_idx).name);
    % fprintf('Processing file: %s\n', nii_files(file_idx).name);

    % Update the waitbar
    waitbar(file_idx / length(nii_files), hWaitbar, ...
        sprintf('Processing file %d of %d...', file_idx, length(nii_files)));
    
    % DELETE
    % fprintf('Loading file: %s\n', nii_file);
    if ~exist(nii_file, 'file')
        error('The specified .nii file does not exist: %s', nii_file);
    end

    [t1_image, wm_mask, gm_mask, csf_mask] = load_oasis_data(nii_file);

    % Initialize arrays to store results
    snr_values = zeros(1, length(B0_values));
    contrast_values = zeros(1, length(B0_values));
    gEn_values = zeros(1, length(B0_values));

    % Simulation loop for each B0 value
    for i = 1:length(B0_values)
        B0 = B0_values(i);

        % Calculate T1 and T2 for each tissue type
        T1_GM = calculate_t1_t2('GM', B0, 'T1');
        T2_GM = calculate_t1_t2('GM', B0, 'T2');

        T1_WM = calculate_t1_t2('WM', B0, 'T1');
        T2_WM = calculate_t1_t2('WM', B0, 'T2');

       

        % Compute signal intensities for GM and WM
        SI_GM = signal_intensity(1, T1_GM, T2_GM, TR, TE);
        SI_WM = signal_intensity(1, T1_WM, T2_WM, TR, TE);

        % Add Gaussian noise
        noise_level = 0.05 * B0;  % Adjust noise level based on B0
        noisy_SI_GM = gaussian_noise(SI_GM, noise_level);

        % Calculate contrast, SNR, and sharpness
        contrast_values(i) = calculate_contrast(TE, T2_GM, T2_WM);
        snr_values(i) = snr_calculation(B0, BW, TE, T1_GM, T2_GM, alpha, TR);
        gEn_values(i) = gradient_entropy(noisy_SI_GM);
    end

    % Plot results for the current file
    figure('Visible','off');
    subplot(1, 3, 1);
    plot(B0_values, contrast_values, '-o');
    xlabel('B0 (T)');
    ylabel('Contrast');
    title('Contrast vs B0');
    grid on;

    subplot(1, 3, 2);
    plot(B0_values, snr_values, '-o');
    xlabel('B0 (T)');
    ylabel('SNR');
    title('SNR vs B0');
    grid on;

    subplot(1, 3, 3);
    plot(B0_values, gEn_values, '-o');
    xlabel('B0 (T)');
    ylabel('Gradient Entropy');
    title('Sharpness vs B0');
    grid on;

    % Save the plot for the current file
    output_filename = fullfile(results_folder, sprintf('Results_%s.png', erase(nii_files(file_idx).name, '.nii')));
    saveas(gcf, output_filename);
    close(gcf); % Close the figure to avoid clutter
end

disp('Processing complete.');

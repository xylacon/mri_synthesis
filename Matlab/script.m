% % % % % % % % % % %
% FOLDER PREPARATION %
% % % % % % % % % % %

% Slices
if ~exist('../Slices', 'dir')
    mkdir('../Slices');
end

% Maps
if ~exist('../Maps', 'dir')
    mkdir('../Maps');
end

% Plots
if ~exist('../Plots', 'dir')
    mkdir('../Plots');
end


% % % % % % % % % %
% DATA PREPARATION %
% % % % % % % % % %

% Load patient data
data_dir = '../Data';
nii_files = dir(fullfile(data_dir, '*.nii'));
patients = cell(length(nii_files), 1);
for i = 1:length(nii_files)
    file_path = fullfile(data_dir, nii_files(i).name);
    patients{i} = niftiread(file_path);
end

% % Extract and display tissue maps
% [GM, WM, CSF] = extractTissueMaps(patient);
% tissue_maps = {GM, WM, CSF};
% dispTissueMaps(tissue_maps, slice_index, patientID);

% Variate B0 by increments of 0.5 from 0.5 to 9
B0 = 0.5:0.5:9;


% % % % % % %
% MAIN LOOP %
% % % % % % %

for patientID = 1 : length(patients)
    patient = patients{patientID};


    % % % % % % % % % % %
    % SIGNAL ACQUISITION %
    % % % % % % % % % % %
    
    % All tissue parameters are calculated in calcSNR()

    % Extract tissue maps
    slice_index = 90;
    slice = extractSlice(patient, slice_index);
    [GM, WM, CSF] = extractTissueMaps(slice);

    % Determine scan type
    % 0  = T1-weighted
    % 1  = T2-weighted
    % -1 = Undetermined
    type = determine_scan_type(slice, GM, WM, CSF);

    
    % % % % % % % % % % %
    % SNR Map Generation %
    % % % % % % % % % % %
    
    SNR_maps = zeros(length(B0), 3, size(patient, 3));
    for slice_idx = 1 : size(patient, 3)
        for B0_idx = 1 : length(B0)
            if type == 0
                % T1-weighted
                if slice_idx == slice_index
                    SNR_maps(B0_idx, :, slice_idx) = calcSNR(patientID, B0(B0_idx), false, true);
                else
                    SNR_maps(B0_idx, :, slice_idx) = calcSNR(patientID, B0(B0_idx), false, false);
                end
            elseif type == 1
                % T2-weighted
                if slice_idx == slice_index
                    SNR_maps(B0_idx, :, slice_idx) = calcSNR(patientID, B0(B0_idx), true, true);
                else
                    SNR_maps(B0_idx, :, slice_idx) = calcSNR(patientID, B0(B0_idx), true, false);
                end
            else
                return;
            end
        end
    end
    
    % Display slice 90
    dispSlice(slice, slice_index, patientID);
    
    % Display SNR vs B0 graph
    dispSNRvB0(B0, SNR_maps, patientID);


    % % % % % % % % %
    % Noise Addition %
    % % % % % % % % %

    for i = 1 : length(B0)
        if B0(i) == 1 || B0(i) == 3 || B0(i) == 7
            slice_noise = addNoise(slice, B0(i), SNR_maps(i, :, slice_index));
            dispSlice(slice_noise, slice_index + i, patientID);
        end
    end


    % % % % % % % % % % %
    % Evaluation Metrics %
    % % % % % % % % % % %
    
    % Compute Gradient Entropy (gEn) for each tissue
    gEn_GM = computeGradientEntropy(slice, GM);
    gEn_WM = computeGradientEntropy(slice, WM);
    gEn_CSF = computeGradientEntropy(slice, CSF);

    % Display Gradient Entropy results
    fprintf('Patient %d, Slice %d:\n', patientID, slice_index);
    fprintf('Gradient Entropy (GM): %.4f\n', gEn_GM);
    fprintf('Gradient Entropy (WM): %.4f\n', gEn_WM);
    fprintf('Gradient Entropy (CSF): %.4f\n', gEn_CSF);

    % Plot Gradient Entropy results
    figure;
    bar([gEn_GM, gEn_WM, gEn_CSF]);
    set(gca, 'XTickLabel', {'GM', 'WM', 'CSF'});
    ylabel('Gradient Entropy');
    title(sprintf('Patient %d: Gradient Entropy (Slice %d)', patientID, slice_index));
    saveas(gcf, fullfile('../Plots', sprintf('Patient_%d_Slice_%d_gEn.png', patientID, slice_index)));
    
    % Sharpness profile calculation
    line_coords = [30, 50; 70, 50]; % Define line through CSF to WM
    sharpnessProfile = computeSharpnessProfile(slice, line_coords);

    % Plot Sharpness profile
    figure;
    plot(sharpnessProfile, 'LineWidth', 2);
    xlabel('Pixel Index');
    ylabel('Sharpness');
    title(sprintf('Patient %d: Sharpness Profile (Slice %d)', patientID, slice_index));
    grid on;
    saveas(gcf, fullfile('../Plots', sprintf('Patient_%d_Slice_%d_SharpnessProfile.png', patientID, slice_index)));


    % % % % % % % % %
    % MRI Resolution %
    % % % % % % % % %
    
    % Perform MRI Resolution Analysis
    resolution_results = mri_resolution_analysis(GM, WM, CSF);
    
    % Access metrics
    disp('SNR for 1mm x 1mm x 2mm:');
    disp(resolution_results.Metrics.SNR_1mm_2mm);
    
    disp('Contrast between WM and GM:');
    disp(resolution_results.Metrics.Contrast_WM_GM);
end
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
    
    
    % % % % % % % % % % %
    % SNR Map Generation %
    % % % % % % % % % % %
    
    SNR_maps = zeros(length(B0), 3, size(patient, 3));
    for slice_idx = 1 : size(patient, 3)
        for B0_idx = 1 : length(B0)
            SNR_maps(B0_idx, :, slice_idx) = calcSNR(patientID, B0(B0_idx), false, false);
        end
    end
    
    % Display slice 90
    slice_index = 90;
    slice = extractSlice(patient, slice_index);
    dispSlice(slice, slice_index, patientID);
    
    % Display SNR vs B0 graph
    dispSNRvB0(B0, SNR_maps, patientID);
end


% % % % % % % % %
% Noise Addition %
% % % % % % % % %




% % % % % % % % %
% MRI Resolution %
% % % % % % % % %




% % % % % % % % % % %
% Evaluation Metrics %
% % % % % % % % % % %


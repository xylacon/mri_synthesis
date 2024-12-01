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
patient = niftiread('../Data/patient1.nii');
patientID = 1;

% Variate B0 by increments of 0.5 from 0.5 to 9
B0 = 0.5:0.5:9;

% % Extract and display tissue maps
% [GM, WM, CSF] = extractTissueMaps(patient);
% tissue_maps = {GM, WM, CSF};
% dispTissueMaps(tissue_maps, slice_index, patientID);


% % % % % % % % % % %
% SIGNAL ACQUISITION %
% % % % % % % % % % %

% All tissue parameters are calculated in calcSNR()


% % % % % % % % % % %
% SNR Map Generation %
% % % % % % % % % % %

SNR_maps = zeros(length(B0), 3, size(patient, 3));
for slice_idx = 1:size(patient, 3)
    for B0_idx = 1:length(B0)
        SNR_maps(B0_idx, :, slice_idx) = calcSNR(patientID, B0(B0_idx), false, false);
    end
end

slice_index = 90;
slice = extractSlice(patient, slice_index);
dispSlice(slice, slice_index, patientID);

slice_90 = squeeze(SNR_maps(:, :, 90));
dispSNRvB0(B0, SNR_maps, patientID);


% % % % % % % % %
% Noise Addition %
% % % % % % % % %




% % % % % % % % %
% MRI Resolution %
% % % % % % % % %




% % % % % % % % % % %
% Evaluation Metrics %
% % % % % % % % % % %


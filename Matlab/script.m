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
patient1 = niftiread('../Data/patient1.nii');

% Extract slice
slice_index = 90;
slice = extractSlice(patient1, slice_index);
displaySlice(slice, slice_index, 1);

% Extract and display tissue maps
[GM, WM, CSF] = extractTissueMaps(patient1);
tissue_maps = {GM, WM, CSF};
displayTissueMaps(tissue_maps, slice_index, 1);


% % % % % % % % % % %
% SIGNAL ACQUISITION %
% % % % % % % % % % %

% Variate B0 by increments of 0.5 from 0.5 to 9
B0 = 0.5:0.5:9;

% All tissue parameters are calculated in calcSNR()


% % % % % % % % % % %
% SNR Map Generation %
% % % % % % % % % % %

SNR = calcSNR(1, B0(1));


% % % % % % % % %
% Noise Addition %
% % % % % % % % %




% % % % % % % % %
% MRI Resolution %
% % % % % % % % %




% % % % % % % % % % %
% Evaluation Metrics %
% % % % % % % % % % %


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

%%% Following should loop through B0_values,
%%% but will implement later since testing
%%% would take forever with all the outputs

% Calculate relaxation times
T1 = {calcT1('GM', B0(1)), calcT1('WM', B0(1)), calcT1('CSF', B0(1))};
T2 = {calcT2('GM', B0(1)), calcT2('WM', B0(1)), calcT2('CSF', B0(1))};

% Calculate TE and TR
% T1-weighted
TE_T1 = calcTE_T1(T2{2});
TR_T1 = calcTR(TE_T1);

% T2-weighted
TE_T2 = calcTE_T2(T2{1}, T2{2});
TR_T2 = calcTR(TE_T2);

% Calculate BW
BW_T1 = calcBW(TE_T1);
BW_T2 = calcBW(TE_T2);
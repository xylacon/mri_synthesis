% Main Script: main_analysis.m

%% Step 1: Load Data
patient = niftiread('../Data/patient1.nii');  % Replace with the correct path
disp('Loaded Patient Data Dimensions:');
disp(size(patient));

[GM, WM, CSF] = extractTissueMaps(patient);
disp('Extracted tissue maps: GM, WM, CSF');

%% Step 2: Perform MRI Resolution Analysis
resolution_results = mri_resolution_analysis(GM, WM, CSF);

% Access metrics
disp('SNR for 1mm x 1mm x 2mm:');
disp(resolution_results.Metrics.SNR_1mm_2mm);

disp('Contrast between WM and GM:');
disp(resolution_results.Metrics.Contrast_WM_GM);

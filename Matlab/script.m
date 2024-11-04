% Load the NIfTI data for patient 1
patient1 = niftiread('../Data/patient1.nii');

% Visualize a mid-slice of the 3D volume
slice_index = 90;
slice = extractSlice(patient1, slice_index);
displaySlice(slice, slice_index, 1);

% Extract and display tissue maps
[GM, WM, CSF] = extractTissueMaps(patient1);
tissue_maps = {GM, WM, CSF};
displayTissueMaps(tissue_maps, slice_index, 1);
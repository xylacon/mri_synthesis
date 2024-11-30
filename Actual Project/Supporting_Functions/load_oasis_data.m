function [t1_image, wm_mask, gm_mask, csf_mask] = load_oasis_data(file_path)
    % Load T1-weighted MRI image and generate segmentation masks for WM, GM, and CSF.
    
    % Check if the file exists
    if ~exist(file_path, 'file')
        error('Specified NIfTI file does not exist: %s', file_path);
    end

    % Load the NIfTI data
    t1_image = niftiread(file_path); 

    % Determine unique intensity values in the segmentation file
    unique_values = unique(t1_image);
    % disp('Unique voxel values in the segmentation file:');
    % disp(unique_values);

    % Assign tissue masks based on voxel values
    % CSF (lowest intensity), GM (middle intensity), WM (highest intensity)
    csf_mask = t1_image == min(unique_values);          % CSF
    gm_mask = t1_image == unique_values(2);            % GM
    wm_mask = t1_image == max(unique_values);          % WM

    % Debug: Visualize segmentation masks (optional)
    slice_idx = round(size(t1_image, 3) / 2); % Middle slice
    figure('Visible','off'); imshow(t1_image(:, :, slice_idx), []); title('T1 Image');
    figure('Visible','off'); imshow(csf_mask(:, :, slice_idx), []); title('CSF Mask');
    figure('Visible','off'); imshow(gm_mask(:, :, slice_idx), []); title('Gray Matter Mask');
    figure('Visible','off'); imshow(wm_mask(:, :, slice_idx), []); title('White Matter Mask');

    % Save masks as separate files for external use
    [path, name, ~] = fileparts(file_path); % Extract file name without extension
    niftiwrite(uint8(csf_mask), fullfile(path, [name '_CSF_mask.nii']));
    niftiwrite(uint8(gm_mask), fullfile(path, [name '_GM_mask.nii']));
    niftiwrite(uint8(wm_mask), fullfile(path, [name '_WM_mask.nii']));

    % disp('Segmentation masks saved as NIfTI files.');
end
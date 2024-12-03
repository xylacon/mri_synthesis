function visualize_resolution_and_thickness(data, slice_num, resolution, slice_thickness, contrast, SNR)
    % Visualizes a slice with the given resolution and slice thickness
    % data: MRI data (3D matrix)
    % slice_num: Slice number to visualize
    % resolution: Resolution in mm (e.g., [1 1] or [2 2])
    % slice_thickness: Slice thickness in mm
    % contrast: Image contrast value
    % SNR: Signal-to-noise ratio value
    
    figure;
    imagesc(squeeze(data(:, :, slice_num))); colormap gray;
    title(sprintf('Res: %dx%d mm, Thick: %d mm, Contrast: %.2f, SNR: %.2f', ...
          resolution(1), resolution(2), slice_thickness, contrast, SNR));
    axis off;
    
    % Save the visualization
    saveas(gcf, sprintf('./Output/Res_%dx%d_Thick_%dmm.png', resolution(1), resolution(2), slice_thickness));
end
